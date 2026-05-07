import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:math";
import "dart:typed_data";

import "package:crypto/crypto.dart";
import "package:googleapis/classroom/v1.dart" as classroom;
import "package:googleapis_auth/auth_io.dart" as auth;
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";
import "package:url_launcher/url_launcher.dart";

class GoogleAuthStatus {
  const GoogleAuthStatus({
    required this.state,
    this.profileId,
    this.emailAddress,
    this.displayName,
    this.message,
  });

  const GoogleAuthStatus.signedOut({
    this.message = "Sign in with Google to check Classroom.",
  }) : state = GoogleAuthState.signedOut,
       profileId = null,
       emailAddress = null,
       displayName = null;

  final GoogleAuthState state;
  final String? profileId;
  final String? emailAddress;
  final String? displayName;
  final String? message;
}

enum GoogleAuthState { signedOut, signedIn, unavailable }

class GoogleAuthException implements Exception {
  const GoogleAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _GoogleClientConfig {
  const _GoogleClientConfig({
    required this.clientId,
    required this.authEndpoints,
  });

  final auth.ClientId clientId;
  final auth.AuthEndpoints authEndpoints;
}

class _GoogleClientAuthEndpoints extends auth.AuthEndpoints {
  const _GoogleClientAuthEndpoints({
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
  });

  @override
  final Uri authorizationEndpoint;

  @override
  final Uri tokenEndpoint;
}

class GoogleAuthService {
  static const classroomScopes = [
    classroom.ClassroomApi.classroomCoursesReadonlyScope,
    classroom.ClassroomApi.classroomCourseworkStudentsScope,
    classroom.ClassroomApi.classroomRostersReadonlyScope,
  ];

  static const _embeddedCredentialsBase64 = String.fromEnvironment(
    "GOOGLE_CREDENTIALS_BASE64",
  );
  static const _savedCredentialsKey = "googleSignInCredentials";
  static const _savedProfileNameKey = "googleSignInProfileName";
  static const _savedProfileEmailKey = "googleSignInProfileEmail";

  auth.AuthClient? _authClient;
  StreamSubscription<auth.AccessCredentials>? _credentialUpdates;

  Future<bool> isSignedIn() async {
    try {
      return await getAuthClient() != null;
    } catch (_) {
      return false;
    }
  }

  Future<auth.AuthClient?> getAuthClient() async {
    if (_authClient != null) {
      return _authClient;
    }

    final savedCredentials = await _loadSavedCredentials();
    if (savedCredentials == null) {
      return null;
    }

    final config = await _loadClientConfig();
    final restoredCredentials = await _refreshIfNeeded(
      config.clientId,
      savedCredentials,
      config.authEndpoints,
    );
    if (restoredCredentials == null) {
      await signOut();
      return null;
    }

    _authClient = _buildAuthClient(config, restoredCredentials);
    return _authClient;
  }

  Future<void> signIn() async {
    final config = await _loadClientConfig();
    final baseClient = http.Client();
    HttpServer? server;

    try {
      server = await HttpServer.bind("localhost", 0);
      final redirectUri = "http://localhost:${server.port}";
      final state = _randomState();
      final codeVerifier = _createCodeVerifier();
      final signInUri = _buildSignInUri(
        config: config,
        redirectUri: redirectUri,
        state: state,
        codeVerifier: codeVerifier,
      );

      final opened = await launchUrl(
        signInUri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        throw const GoogleAuthException(
          "Google sign-in could not be opened in your browser.",
        );
      }

      final request = await server.first.timeout(const Duration(minutes: 5));
      final credentials = await _handleBrowserCallback(
        request: request,
        expectedState: state,
        config: config,
        redirectUri: redirectUri,
        codeVerifier: codeVerifier,
        baseClient: baseClient,
      );

      await _saveCredentials(credentials);
      await _credentialUpdates?.cancel();
      _authClient?.close();
      _authClient = _buildAuthClient(config, credentials);
      await _refreshProfileCache();
    } on TimeoutException {
      throw const GoogleAuthException("Google sign-in timed out.");
    } on GoogleAuthException {
      rethrow;
    } catch (_) {
      throw const GoogleAuthException("Google sign-in could not be completed.");
    } finally {
      await server?.close(force: true);
      baseClient.close();
    }
  }

  Future<void> signOut() async {
    await _credentialUpdates?.cancel();
    _credentialUpdates = null;
    _authClient?.close();
    _authClient = null;

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_savedCredentialsKey);
    await preferences.remove(_savedProfileNameKey);
    await preferences.remove(_savedProfileEmailKey);
  }

  Future<void> resetLogin() async {
    await signOut();
    await signIn();
  }

  Future<GoogleAuthStatus> currentStatus() async {
    final auth.AuthClient? client;
    try {
      client = await getAuthClient();
    } catch (_) {
      return const GoogleAuthStatus(
        state: GoogleAuthState.unavailable,
        message: "Google sign-in is not ready yet.",
      );
    }

    if (client == null) {
      return const GoogleAuthStatus.signedOut();
    }

    try {
      final profile = await classroom.ClassroomApi(
        client,
      ).userProfiles.get("me", $fields: "id,name/fullName");
      await _saveProfile(profile);

      return GoogleAuthStatus(
        state: GoogleAuthState.signedIn,
        profileId: profile.id,
        displayName: profile.name?.fullName,
        message: "Connected to Google Classroom.",
      );
    } catch (_) {
      final preferences = await SharedPreferences.getInstance();
      final cachedName = preferences.getString(_savedProfileNameKey);

      return GoogleAuthStatus(
        state: GoogleAuthState.signedIn,
        displayName: cachedName,
        message: "Connected. Profile details will update after the next check.",
      );
    }
  }

  Future<_GoogleClientConfig> _loadClientConfig() async {
    Map<String, dynamic> decoded;
    try {
      if (_embeddedCredentialsBase64.trim().isEmpty) {
        throw const FormatException("Missing embedded Google sign-in config.");
      }

      decoded =
          jsonDecode(
                utf8.decode(base64Decode(_embeddedCredentialsBase64.trim())),
              )
              as Map<String, dynamic>;
    } catch (_) {
      throw const GoogleAuthException(
        "Google sign-in is not configured for this app.",
      );
    }

    final installed = decoded["installed"];
    if (installed is! Map<String, dynamic>) {
      throw const GoogleAuthException(
        "Google sign-in is not configured for this app.",
      );
    }

    final clientId = installed["client_id"];
    final clientSecret = installed["client_secret"];
    final authUri = installed["auth_uri"];
    final tokenUri = installed["token_uri"];
    if (clientId is! String || clientId.trim().isEmpty) {
      throw const GoogleAuthException(
        "Google sign-in is not configured for this app.",
      );
    }

    final authorizationEndpoint = authUri is String && authUri.trim().isNotEmpty
        ? Uri.tryParse(authUri)
        : const auth.GoogleAuthEndpoints().authorizationEndpoint;
    final tokenEndpoint = tokenUri is String && tokenUri.trim().isNotEmpty
        ? Uri.tryParse(tokenUri)
        : const auth.GoogleAuthEndpoints().tokenEndpoint;

    if (authorizationEndpoint == null || tokenEndpoint == null) {
      throw const GoogleAuthException(
        "Google sign-in is not configured for this app.",
      );
    }

    return _GoogleClientConfig(
      clientId: auth.ClientId(
        clientId,
        clientSecret is String && clientSecret.trim().isNotEmpty
            ? clientSecret
            : null,
      ),
      authEndpoints: _GoogleClientAuthEndpoints(
        authorizationEndpoint: authorizationEndpoint,
        tokenEndpoint: tokenEndpoint,
      ),
    );
  }

  Uri _buildSignInUri({
    required _GoogleClientConfig config,
    required String redirectUri,
    required String state,
    required String codeVerifier,
  }) {
    return config.authEndpoints.authorizationEndpoint.replace(
      queryParameters: {
        "client_id": config.clientId.identifier,
        "response_type": "code",
        "redirect_uri": redirectUri,
        "scope": classroomScopes.join(" "),
        "code_challenge": _codeChallenge(codeVerifier),
        "code_challenge_method": "S256",
        "access_type": "offline",
        "prompt": "consent",
        "state": state,
      },
    );
  }

  Future<auth.AccessCredentials> _handleBrowserCallback({
    required HttpRequest request,
    required String expectedState,
    required _GoogleClientConfig config,
    required String redirectUri,
    required String codeVerifier,
    required http.Client baseClient,
  }) async {
    try {
      final uri = request.uri;
      if (request.method != "GET") {
        throw const GoogleAuthException("Google sign-in did not complete.");
      }

      if (uri.queryParameters["state"] != expectedState) {
        throw const GoogleAuthException("Google sign-in did not complete.");
      }

      if (uri.queryParameters["error"] != null) {
        throw const GoogleAuthException("Google sign-in was cancelled.");
      }

      final code = uri.queryParameters["code"];
      if (code == null || code.isEmpty) {
        throw const GoogleAuthException("Google sign-in did not complete.");
      }

      final credentials = await auth.obtainAccessCredentialsViaCodeExchange(
        baseClient,
        config.clientId,
        code,
        redirectUrl: redirectUri,
        codeVerifier: codeVerifier,
        authEndpoints: config.authEndpoints,
      );

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(_successPage);
      await request.response.close();

      return credentials;
    } on GoogleAuthException {
      await _writeFailurePage(request, "Google sign-in did not complete.");
      rethrow;
    } on auth.ServerRequestFailedException catch (error) {
      final message = _describeServerRequestFailure(error);
      await _writeFailurePage(request, message);
      throw GoogleAuthException(message);
    } on auth.AuthorizationCallbackException catch (_) {
      const message = "Google sign-in did not complete.";
      await _writeFailurePage(request, message);
      throw const GoogleAuthException(message);
    } on auth.UserConsentException catch (_) {
      const message = "Google sign-in was cancelled.";
      await _writeFailurePage(request, message);
      throw const GoogleAuthException(message);
    } catch (error) {
      final message =
          "Google sign-in could not be completed: ${_safeExceptionDetails(error)}.";
      await _writeFailurePage(request, message);
      throw GoogleAuthException(message);
    }
  }

  Future<auth.AccessCredentials?> _loadSavedCredentials() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_savedCredentialsKey);
    if (saved == null || saved.isEmpty) {
      return null;
    }

    try {
      return auth.AccessCredentials.fromJson(
        jsonDecode(saved) as Map<String, dynamic>,
      );
    } catch (_) {
      await preferences.remove(_savedCredentialsKey);
      return null;
    }
  }

  Future<void> _saveCredentials(auth.AccessCredentials credentials) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _savedCredentialsKey,
      jsonEncode(credentials.toJson()),
    );
  }

  Future<auth.AccessCredentials?> _refreshIfNeeded(
    auth.ClientId clientId,
    auth.AccessCredentials credentials,
    auth.AuthEndpoints authEndpoints,
  ) async {
    if (!credentials.accessToken.hasExpired) {
      return credentials;
    }

    if (credentials.refreshToken == null) {
      return null;
    }

    final baseClient = http.Client();
    try {
      final refreshed = await auth.refreshCredentials(
        clientId,
        credentials,
        baseClient,
        authEndpoints: authEndpoints,
      );
      await _saveCredentials(refreshed);
      return refreshed;
    } catch (_) {
      return null;
    } finally {
      baseClient.close();
    }
  }

  auth.AuthClient _buildAuthClient(
    _GoogleClientConfig config,
    auth.AccessCredentials credentials,
  ) {
    if (credentials.refreshToken == null) {
      return auth.authenticatedClient(http.Client(), credentials);
    }

    final client = auth.autoRefreshingClient(
      config.clientId,
      credentials,
      http.Client(),
      authEndpoints: config.authEndpoints,
    );
    unawaited(_credentialUpdates?.cancel());
    _credentialUpdates = client.credentialUpdates.listen((updatedCredentials) {
      unawaited(_saveCredentials(updatedCredentials));
    });
    return client;
  }

  Future<void> _refreshProfileCache() async {
    final client = _authClient;
    if (client == null) {
      return;
    }

    try {
      final profile = await classroom.ClassroomApi(
        client,
      ).userProfiles.get("me", $fields: "name/fullName");
      await _saveProfile(profile);
    } catch (_) {
      return;
    }
  }

  Future<void> _saveProfile(classroom.UserProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    final fullName = profile.name?.fullName;

    if (fullName != null && fullName.isNotEmpty) {
      await preferences.setString(_savedProfileNameKey, fullName);
    }
    await preferences.remove(_savedProfileEmailKey);
  }

  String _createCodeVerifier() {
    final random = Random.secure();
    return List.generate(
      128,
      (_) =>
          _codeVerifierCharacters[random.nextInt(
            _codeVerifierCharacters.length,
          )],
    ).join();
  }

  String _codeChallenge(String codeVerifier) {
    final digest = sha256.convert(ascii.encode(codeVerifier));
    return _base64UrlNoPadding(Uint8List.fromList(digest.bytes));
  }

  String _randomState() {
    final random = Random.secure();
    final bytes = Uint8List(24);
    for (var i = 0; i < bytes.length; i += 1) {
      bytes[i] = random.nextInt(256);
    }
    return _base64UrlNoPadding(bytes);
  }

  String _base64UrlNoPadding(List<int> bytes) {
    return base64UrlEncode(bytes).replaceAll("=", "");
  }

  Future<void> _writeFailurePage(HttpRequest request, String message) async {
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(_failurePage(message));
    await request.response.close().catchError((_) {});
  }

  String _describeServerRequestFailure(
    auth.ServerRequestFailedException error,
  ) {
    final details = _safeServerErrorDetails(error.responseContent);
    if (details == null || details.isEmpty) {
      return "Google sign-in could not be completed.";
    }
    return "Google sign-in could not be completed: $details.";
  }

  String? _safeServerErrorDetails(Object? responseContent) {
    if (responseContent is Map) {
      final code = responseContent["error"];
      final description = responseContent["error_description"];
      final values = [
        if (code is String && code.isNotEmpty) code,
        if (description is String && description.isNotEmpty) description,
      ];
      if (values.isNotEmpty) {
        return values.join(" - ");
      }
    }

    if (responseContent is String && responseContent.length <= 240) {
      return responseContent;
    }

    return null;
  }

  String _safeExceptionDetails(Object error) {
    if (error is auth.ServerRequestFailedException) {
      return _describeServerRequestFailure(error);
    }

    final details = error.toString().trim();
    if (details.isEmpty) {
      return "unexpected response while finishing sign-in";
    }

    return _redactSensitiveText(details);
  }

  String _redactSensitiveText(String value) {
    return value
        .replaceAll(
          RegExp(r"access_token[=:][^,\s&]+"),
          "access_token=<hidden>",
        )
        .replaceAll(
          RegExp(r"refresh_token[=:][^,\s&]+"),
          "refresh_token=<hidden>",
        )
        .replaceAll(
          RegExp(r"client_secret[=:][^,\s&]+"),
          "client_secret=<hidden>",
        )
        .replaceAll(RegExp(r"GOCSPX-[A-Za-z0-9_-]+"), "client_secret=<hidden>");
  }

  String _failurePage(String message) {
    final safeMessage = const HtmlEscape().convert(message);
    return """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Sign-in could not finish</title>
  </head>
  <body style="font-family: -apple-system, BlinkMacSystemFont, sans-serif; text-align: center; padding: 48px 24px;">
    <h2>Sign-in could not finish</h2>
    <p>$safeMessage</p>
    <p>You can close this window and return to Classroom Ungraded Checker.</p>
  </body>
</html>
""";
  }

  static const _codeVerifierCharacters =
      "0123456789-._~abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

  static const _successPage = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Sign-in complete</title>
  </head>
  <body style="font-family: -apple-system, BlinkMacSystemFont, sans-serif; text-align: center; padding-top: 48px;">
    <h2>Sign-in complete</h2>
    <p>You can close this window and return to Classroom Ungraded Checker.</p>
  </body>
</html>
""";
}
