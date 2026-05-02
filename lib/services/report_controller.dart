import "dart:ui" as ui;

import "package:flutter/foundation.dart";

import "../l10n/app_language.dart";
import "../models/classroom_models.dart";
import "classroom_api_service.dart";
import "csv_export_service.dart";
import "google_auth_service.dart";
import "notification_service.dart";
import "report_cache_service.dart";
import "report_service.dart";
import "settings_service.dart";

class ReportController extends ChangeNotifier {
  ReportController({
    required GoogleAuthService googleAuth,
    required ClassroomApiService classroomApi,
    required ReportService report,
    required CsvExportService csvExport,
    required ReportCacheService cache,
    required SettingsService settings,
    required NotificationService notifications,
  }) : _googleAuth = googleAuth,
       _classroomApi = classroomApi,
       _report = report,
       _csvExport = csvExport,
       _cache = cache,
       _settings = settings,
       _notifications = notifications {
    _lastSuccessfulCount = settings.settings.lastSuccessfulCount;
    _lastChecked = settings.settings.lastCheckedAt;
    _lastError = settings.settings.lastError;
  }

  final GoogleAuthService _googleAuth;
  final ClassroomApiService _classroomApi;
  final ReportService _report;
  final CsvExportService _csvExport;
  final ReportCacheService _cache;
  final SettingsService _settings;
  final NotificationService _notifications;

  GoogleAuthStatus _authStatus = const GoogleAuthStatus.signedOut();
  ClassroomProfile? _profile;
  ReportSnapshot _snapshot = ReportSnapshot.empty();
  List<ClassroomCourse> _courses = const [];
  bool _isRefreshing = false;
  bool _hasLoadedRows = false;
  int _lastSuccessfulCount = 0;
  DateTime? _lastChecked;
  String? _lastError;
  Future<bool>? _refreshFuture;

  GoogleAuthStatus get authStatus => _authStatus;
  ClassroomProfile? get profile => _profile;
  ReportSnapshot get snapshot => _snapshot;
  List<ClassroomCourse> get courses => _courses;
  bool get isRefreshing => _isRefreshing;
  bool get hasLoadedRows => _hasLoadedRows;
  DateTime? get lastChecked => _lastChecked;
  String? get lastError => _lastError;
  String? get lastNotificationError => _notifications.lastError;
  bool get isSignedIn => _authStatus.state == GoogleAuthState.signedIn;
  bool get shouldRefreshOnStartup {
    if (!isSignedIn || _isRefreshing) {
      return false;
    }
    if (!_hasLoadedRows) {
      return true;
    }

    final checked = _lastChecked;
    if (checked == null) {
      return true;
    }

    final interval = Duration(
      minutes: _settings.settings.refreshIntervalMinutes,
    );
    if (interval <= Duration.zero) {
      return true;
    }

    return DateTime.now().difference(checked) >= interval;
  }

  int get ungradedCount {
    if (!isSignedIn) {
      return 0;
    }
    if (_hasLoadedRows) {
      return _snapshot.rows.length;
    }
    return _lastSuccessfulCount;
  }

  int get visibleUngradedCount {
    if (!isSignedIn) {
      return 0;
    }
    if (_hasLoadedRows) {
      return _filteredNotificationCount(_snapshot);
    }
    return _settings.settings.lastSuccessfulVisibleCount;
  }

  String? get signedInName {
    final profile = _profile;
    final profileName = profile?.fullName.trim();
    if (profileName != null && profileName.isNotEmpty) {
      return profileName;
    }

    final statusName = _authStatus.displayName?.trim();
    if (statusName != null && statusName.isNotEmpty) {
      return statusName;
    }

    final profileEmail = profile?.emailAddress.trim();
    if (profileEmail != null && profileEmail.isNotEmpty) {
      return profileEmail;
    }

    final statusEmail = _authStatus.emailAddress?.trim();
    if (statusEmail != null && statusEmail.isNotEmpty) {
      return statusEmail;
    }

    return null;
  }

  Future<void> loadAuthStatus() async {
    final status = await _googleAuth.currentStatus();
    _authStatus = status;
    _lastSuccessfulCount = _settings.settings.lastSuccessfulCount;
    _lastChecked = _settings.settings.lastCheckedAt;
    if (status.state != GoogleAuthState.signedIn) {
      _profile = null;
      _courses = const [];
      _snapshot = ReportSnapshot.empty();
      _hasLoadedRows = false;
    }
    _lastError = status.state == GoogleAuthState.unavailable
        ? status.message
        : _settings.settings.lastError;
    if (status.state == GoogleAuthState.signedIn) {
      await _loadCachedReport(status);
    }
    notifyListeners();
  }

  Future<bool> signIn() async {
    try {
      await _googleAuth.signIn();
    } on GoogleAuthException catch (error) {
      _lastError = error.message;
      await _settings.recordRefreshError(error.message);
      notifyListeners();
      return false;
    }

    return refreshReport();
  }

  Future<void> resetGoogleLogin() async {
    await _googleAuth.signOut();
    _authStatus = const GoogleAuthStatus.signedOut();
    _profile = null;
    _courses = const [];
    _snapshot = ReportSnapshot.empty();
    _hasLoadedRows = false;
    _isRefreshing = false;
    _lastError = null;
    await _cache.clear();
    await _settings.recordRefreshError("");
    notifyListeners();
  }

  Future<bool> refreshReport({bool isBackground = false}) {
    final inFlight = _refreshFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _refreshReport(isBackground: isBackground);
    _refreshFuture = future;
    future.whenComplete(() {
      if (identical(_refreshFuture, future)) {
        _refreshFuture = null;
      }
    });
    return future;
  }

  Future<String?> exportCsv({
    List<UngradedSubmissionReportRow>? rows,
    bool refreshIfNeeded = true,
  }) async {
    if (refreshIfNeeded && !_hasLoadedRows) {
      final refreshed = await refreshReport();
      if (!refreshed) {
        return null;
      }
    }

    try {
      final exportedPath = await _csvExport.exportCsvFile(
        rows ?? _snapshot.rows,
      );
      if (exportedPath != null) {
        _lastError = null;
        notifyListeners();
      }
      return exportedPath;
    } catch (_) {
      _lastError = "CSV export could not finish.";
      await _settings.recordRefreshError(_lastError!);
      notifyListeners();
      return null;
    }
  }

  Future<bool> sendTestNotification() {
    return _notifications.showTestNotification(
      languageCode: _resolvedLanguageCode(),
    );
  }

  Future<bool> _refreshReport({required bool isBackground}) async {
    _isRefreshing = true;
    _lastError = null;
    notifyListeners();

    final authStatus = await _googleAuth.currentStatus();
    if (authStatus.state != GoogleAuthState.signedIn) {
      if (!isSignedIn) {
        _authStatus = authStatus;
        _profile = null;
        _courses = const [];
        _snapshot = ReportSnapshot.empty();
        _hasLoadedRows = false;
      }
      _isRefreshing = false;
      _lastError = authStatus.state == GoogleAuthState.unavailable
          ? authStatus.message
          : "Sign in with Google first.";
      await _settings.recordRefreshError(_lastError ?? "");
      notifyListeners();
      return false;
    }

    try {
      final previousVisibleCount = _hasLoadedRows
          ? _filteredNotificationCount(_snapshot)
          : _settings.settings.lastSuccessfulVisibleCount;
      final hadPreviousVisibleCount =
          _hasLoadedRows || _settings.settings.hasLastSuccessfulVisibleCount;
      final lastNotifiedVisibleCount =
          _settings.settings.lastNotifiedVisibleCount;
      final myProfile = await _classroomApi.getMyProfile();
      final courses = await _classroomApi.listTeacherCourses();
      final courseWork = <ClassroomCourseWork>[];
      final submissions = <ClassroomSubmission>[];

      for (final course in courses) {
        final students = await _classroomApi.listCourseStudents(course.id);
        final studentsById = {
          for (final student in students) student.id: student,
        };
        final assignments = await _classroomApi.listMyAssignments(
          courseId: course.id,
          myUserId: myProfile.id,
          assignmentYear: _settings.settings.displayAllYears
              ? null
              : DateTime.now().year,
        );
        final workItems = assignments
            .map((assignment) => assignment.toCourseWork())
            .toList(growable: false);
        courseWork.addAll(workItems);

        for (final work in workItems) {
          final workSubmissions = await _classroomApi.listStudentSubmissions(
            courseId: course.id,
            courseWorkId: work.id,
            studentsById: studentsById,
          );
          submissions.addAll(workSubmissions);
        }
      }

      _profile = myProfile;
      _authStatus = _statusFromProfile(myProfile);
      _courses = courses;
      _snapshot = _report.buildSnapshot(
        myProfile: myProfile,
        courses: courses,
        courseWork: courseWork,
        submissions: submissions,
      );
      _lastChecked = DateTime.now();
      _lastSuccessfulCount = _snapshot.rows.length;
      _hasLoadedRows = true;
      _lastError = null;
      _isRefreshing = false;
      final visibleCount = _filteredNotificationCount(_snapshot);
      final shouldNotify =
          isBackground &&
          _settings.settings.notifyOnNewUngradedWorks &&
          hadPreviousVisibleCount &&
          visibleCount > previousVisibleCount &&
          (lastNotifiedVisibleCount == null ||
              visibleCount > lastNotifiedVisibleCount);
      await _settings.recordSuccessfulCheck(
        count: _lastSuccessfulCount,
        visibleCount: visibleCount,
        checkedAt: _lastChecked!,
      );
      await _saveCachedReport();
      if (shouldNotify &&
          await _notifications.showNewUngradedWorks(
            visibleCount,
            languageCode: _resolvedLanguageCode(),
          )) {
        await _settings.recordNotificationShown(visibleCount);
      }
      notifyListeners();
      return true;
    } on ClassroomReadException catch (error) {
      _authStatus = authStatus;
      _lastError = error.message;
    } catch (_) {
      _authStatus = authStatus;
      _lastError = "Classroom check could not finish.";
    }

    _isRefreshing = false;
    await _settings.recordRefreshError(_lastError ?? "");
    notifyListeners();
    return false;
  }

  GoogleAuthStatus _statusFromProfile(ClassroomProfile profile) {
    return GoogleAuthStatus(
      state: GoogleAuthState.signedIn,
      profileId: profile.id,
      emailAddress: profile.emailAddress,
      displayName: profile.fullName,
      message: "Connected to Google Classroom.",
    );
  }

  Future<void> _loadCachedReport(GoogleAuthStatus status) async {
    final cached = await _cache.load(
      profileId: status.profileId,
      emailAddress: status.emailAddress,
    );
    if (cached == null) {
      return;
    }

    _profile = cached.profile;
    _authStatus = _statusFromProfile(cached.profile);
    _courses = cached.courses;
    _snapshot = cached.snapshot;
    _lastChecked = cached.checkedAt;
    _lastSuccessfulCount = cached.snapshot.rows.length;
    _hasLoadedRows = true;
  }

  Future<void> _saveCachedReport() async {
    final profile = _profile;
    final checked = _lastChecked;
    if (profile == null || checked == null) {
      return;
    }

    try {
      await _cache.save(
        profile: profile,
        courses: _courses,
        snapshot: _snapshot,
        checkedAt: checked,
      );
    } catch (_) {
      // The live report is still valid if local cache storage fails.
    }
  }

  int _filteredNotificationCount(ReportSnapshot snapshot) {
    final settings = _settings.settings;
    final selectedCourseId = settings.rememberLastSelectedCourse
        ? settings.lastSelectedCourseId
        : null;
    final currentYear = DateTime.now().year;

    return snapshot.rows.where((row) {
      if (selectedCourseId != null && row.courseId != selectedCourseId) {
        return false;
      }

      if (settings.displayAllYears) {
        return true;
      }

      final submittedYear = (row.submittedAt ?? row.updatedAt)?.toLocal().year;
      return submittedYear == currentYear;
    }).length;
  }

  String _resolvedLanguageCode() {
    return AppLanguage.resolve(
      _settings.settings.interfaceLanguageCode,
      ui.PlatformDispatcher.instance.locale.languageCode,
    );
  }
}
