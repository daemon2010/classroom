import "dart:io";

import "package:flutter/services.dart";
import "package:local_notifier/local_notifier.dart";

import "../l10n/app_language.dart";
import "../l10n/app_localizations.dart";

class NotificationService {
  static const _macosChannel = MethodChannel("classroom_notifications");

  bool _isReady = false;
  String? _lastError;

  String? get lastError => _lastError;

  Future<void> init() async {
    _lastError = null;
    if (Platform.isMacOS) {
      _isReady = true;
      return;
    }

    try {
      await localNotifier.setup(appName: "Classroom Ungraded Checker");
      _isReady = true;
    } catch (_) {
      _isReady = false;
      _lastError = AppLocalizations.forLanguageCode(
        AppLanguage.english,
      ).notificationsNotReady;
    }
  }

  Future<bool> showNewUngradedWorks(
    int count, {
    String languageCode = AppLanguage.english,
  }) async {
    if (count <= 0) {
      return false;
    }

    final l10n = AppLocalizations.forLanguageCode(languageCode);
    return _showNotification(
      title: l10n.newUngradedNotificationTitle,
      body: l10n.notificationBody(count),
      l10n: l10n,
    );
  }

  Future<bool> showTestNotification({
    String languageCode = AppLanguage.english,
  }) async {
    final l10n = AppLocalizations.forLanguageCode(languageCode);
    return _showNotification(
      title: l10n.testNotificationTitle,
      body: l10n.testNotificationBody,
      l10n: l10n,
    );
  }

  Future<bool> _showNotification({
    required String title,
    required String body,
    required AppLocalizations l10n,
  }) async {
    if (!_isReady) {
      _lastError = l10n.notificationsNotReady;
      return false;
    }

    try {
      if (Platform.isMacOS) {
        final shown =
            await _macosChannel.invokeMethod<bool>("showNotification", {
              "identifier":
                  "classroom-${DateTime.now().microsecondsSinceEpoch}",
              "title": title,
              "body": body,
            }) ??
            false;
        if (!shown) {
          _lastError = l10n.notificationCouldNotBeShown;
          return false;
        }
      } else {
        await LocalNotification(title: title, body: body).show();
      }
      _lastError = null;
      return true;
    } on PlatformException catch (error) {
      _lastError = _friendlyPlatformError(error, l10n);
      return false;
    } catch (_) {
      _lastError = l10n.notificationCouldNotBeShown;
      return false;
    }
  }

  String _friendlyPlatformError(
    PlatformException error,
    AppLocalizations l10n,
  ) {
    if (error.code == "notifications_denied") {
      return l10n.notificationsDenied;
    }
    return l10n.notificationCouldNotBeShown;
  }
}
