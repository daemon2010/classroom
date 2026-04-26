import "package:flutter/foundation.dart";

import "../models/classroom_models.dart";
import "classroom_api_service.dart";
import "csv_export_service.dart";
import "google_auth_service.dart";
import "report_service.dart";

class ReportController extends ChangeNotifier {
  ReportController({
    required GoogleAuthService googleAuth,
    required ClassroomApiService classroomApi,
    required ReportService report,
    required CsvExportService csvExport,
  }) : _googleAuth = googleAuth,
       _classroomApi = classroomApi,
       _report = report,
       _csvExport = csvExport;

  final GoogleAuthService _googleAuth;
  final ClassroomApiService _classroomApi;
  final ReportService _report;
  final CsvExportService _csvExport;

  GoogleAuthStatus _authStatus = const GoogleAuthStatus.signedOut();
  ClassroomProfile? _profile;
  ReportSnapshot _snapshot = ReportSnapshot.empty();
  List<ClassroomCourse> _courses = const [];
  bool _isRefreshing = false;
  bool _hasLoadedRows = false;
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
  bool get isSignedIn => _authStatus.state == GoogleAuthState.signedIn;
  int get ungradedCount => _snapshot.rows.length;

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

    return isSignedIn ? "Google account" : null;
  }

  Future<void> loadAuthStatus() async {
    final status = await _googleAuth.currentStatus();
    _authStatus = status;
    if (status.state != GoogleAuthState.signedIn) {
      _profile = null;
      _courses = const [];
      _snapshot = ReportSnapshot.empty();
      _hasLoadedRows = false;
    }
    _lastError = status.state == GoogleAuthState.unavailable
        ? status.message
        : null;
    notifyListeners();
  }

  Future<bool> signIn() async {
    try {
      await _googleAuth.signIn();
    } on GoogleAuthException catch (error) {
      _lastError = error.message;
      notifyListeners();
      return false;
    }

    return refreshReport();
  }

  Future<bool> refreshReport() {
    final inFlight = _refreshFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _refreshReport();
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
      notifyListeners();
      return null;
    }
  }

  Future<bool> _refreshReport() async {
    _isRefreshing = true;
    _lastError = null;
    notifyListeners();

    final authStatus = await _googleAuth.currentStatus();
    if (authStatus.state != GoogleAuthState.signedIn) {
      _authStatus = authStatus;
      _profile = null;
      _courses = const [];
      _snapshot = ReportSnapshot.empty();
      _hasLoadedRows = false;
      _isRefreshing = false;
      _lastError = authStatus.state == GoogleAuthState.unavailable
          ? authStatus.message
          : "Sign in with Google first.";
      notifyListeners();
      return false;
    }

    try {
      final myProfile = await _classroomApi.getMyProfile();
      final courses = await _classroomApi.listTeacherCourses();
      final courseWork = <ClassroomCourseWork>[];
      final submissions = <ClassroomSubmission>[];

      for (final course in courses) {
        final assignments = await _classroomApi.listMyAssignments(
          courseId: course.id,
          myUserId: myProfile.id,
        );
        final workItems = assignments
            .map((assignment) => assignment.toCourseWork())
            .toList(growable: false);
        courseWork.addAll(workItems);

        for (final work in workItems) {
          final workSubmissions = await _classroomApi.listStudentSubmissions(
            courseId: course.id,
            courseWorkId: work.id,
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
      _hasLoadedRows = true;
      _lastError = null;
      _isRefreshing = false;
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
}
