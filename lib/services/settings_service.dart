import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

class AppSettings {
  const AppSettings({
    required this.refreshIntervalMinutes,
    required this.includeArchivedCourses,
    required this.autoCheckEnabled,
    required this.notifyOnNewUngradedWorks,
    required this.rememberLastSelectedCourse,
    required this.showStudentEmailColumn,
    required this.showLateColumn,
    required this.lastSuccessfulCount,
    required this.hasLastSuccessfulCount,
    required this.onlyTurnedIn,
    this.lastNotifiedCount,
    this.lastCheckedAt,
    this.lastSelectedCourseId,
    this.lastError,
  });

  final int refreshIntervalMinutes;
  final bool includeArchivedCourses;
  final bool autoCheckEnabled;
  final bool notifyOnNewUngradedWorks;
  final bool rememberLastSelectedCourse;
  final bool showStudentEmailColumn;
  final bool showLateColumn;
  final int lastSuccessfulCount;
  final bool hasLastSuccessfulCount;
  final DateTime? lastCheckedAt;
  final String? lastSelectedCourseId;
  final bool onlyTurnedIn;
  final int? lastNotifiedCount;
  final String? lastError;

  AppSettings copyWith({
    int? refreshIntervalMinutes,
    bool? includeArchivedCourses,
    bool? autoCheckEnabled,
    bool? notifyOnNewUngradedWorks,
    bool? rememberLastSelectedCourse,
    bool? showStudentEmailColumn,
    bool? showLateColumn,
    int? lastSuccessfulCount,
    bool? hasLastSuccessfulCount,
    DateTime? lastCheckedAt,
    Object? lastSelectedCourseId = _unchanged,
    bool? onlyTurnedIn,
    Object? lastNotifiedCount = _unchanged,
    Object? lastError = _unchanged,
  }) {
    return AppSettings(
      refreshIntervalMinutes:
          refreshIntervalMinutes ?? this.refreshIntervalMinutes,
      includeArchivedCourses:
          includeArchivedCourses ?? this.includeArchivedCourses,
      autoCheckEnabled: autoCheckEnabled ?? this.autoCheckEnabled,
      notifyOnNewUngradedWorks:
          notifyOnNewUngradedWorks ?? this.notifyOnNewUngradedWorks,
      rememberLastSelectedCourse:
          rememberLastSelectedCourse ?? this.rememberLastSelectedCourse,
      showStudentEmailColumn:
          showStudentEmailColumn ?? this.showStudentEmailColumn,
      showLateColumn: showLateColumn ?? this.showLateColumn,
      lastSuccessfulCount: lastSuccessfulCount ?? this.lastSuccessfulCount,
      hasLastSuccessfulCount:
          hasLastSuccessfulCount ?? this.hasLastSuccessfulCount,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastSelectedCourseId: identical(lastSelectedCourseId, _unchanged)
          ? this.lastSelectedCourseId
          : lastSelectedCourseId as String?,
      onlyTurnedIn: onlyTurnedIn ?? this.onlyTurnedIn,
      lastNotifiedCount: identical(lastNotifiedCount, _unchanged)
          ? this.lastNotifiedCount
          : lastNotifiedCount as int?,
      lastError: identical(lastError, _unchanged)
          ? this.lastError
          : lastError as String?,
    );
  }
}

class SettingsService extends ChangeNotifier {
  static const _includeArchivedCoursesKey = "includeArchivedCourses";
  static const _autoCheckEnabledKey = "autoCheckEnabled";
  static const _notifyOnNewUngradedWorksKey = "notifyOnNewUngradedWorks";
  static const _rememberLastSelectedCourseKey = "rememberLastSelectedCourse";
  static const _showStudentEmailColumnKey = "showStudentEmailColumn";
  static const _showLateColumnKey = "showLateColumn";
  static const _lastSuccessfulCountKey = "lastSuccessfulCount";
  static const _lastCheckedAtKey = "lastCheckedAt";
  static const _lastSelectedCourseIdKey = "lastSelectedCourseId";
  static const _onlyTurnedInKey = "onlyTurnedIn";
  static const _lastNotifiedCountKey = "lastNotifiedCount";
  static const _lastErrorKey = "lastError";

  AppSettings _settings = const AppSettings(
    refreshIntervalMinutes: 30,
    includeArchivedCourses: false,
    autoCheckEnabled: true,
    notifyOnNewUngradedWorks: false,
    rememberLastSelectedCourse: true,
    showStudentEmailColumn: true,
    showLateColumn: true,
    lastSuccessfulCount: 0,
    hasLastSuccessfulCount: false,
    onlyTurnedIn: true,
  );

  AppSettings get settings => _settings;

  Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    _settings = AppSettings(
      refreshIntervalMinutes: _settings.refreshIntervalMinutes,
      includeArchivedCourses:
          preferences.getBool(_includeArchivedCoursesKey) ??
          _settings.includeArchivedCourses,
      autoCheckEnabled:
          preferences.getBool(_autoCheckEnabledKey) ??
          _settings.autoCheckEnabled,
      notifyOnNewUngradedWorks:
          preferences.getBool(_notifyOnNewUngradedWorksKey) ??
          _settings.notifyOnNewUngradedWorks,
      rememberLastSelectedCourse:
          preferences.getBool(_rememberLastSelectedCourseKey) ??
          _settings.rememberLastSelectedCourse,
      showStudentEmailColumn:
          preferences.getBool(_showStudentEmailColumnKey) ??
          _settings.showStudentEmailColumn,
      showLateColumn:
          preferences.getBool(_showLateColumnKey) ?? _settings.showLateColumn,
      lastSuccessfulCount:
          preferences.getInt(_lastSuccessfulCountKey) ??
          _settings.lastSuccessfulCount,
      hasLastSuccessfulCount: preferences.containsKey(_lastSuccessfulCountKey),
      lastCheckedAt: _parseDateTime(preferences.getString(_lastCheckedAtKey)),
      lastSelectedCourseId: preferences.getString(_lastSelectedCourseIdKey),
      onlyTurnedIn:
          preferences.getBool(_onlyTurnedInKey) ?? _settings.onlyTurnedIn,
      lastNotifiedCount: preferences.getInt(_lastNotifiedCountKey),
      lastError: preferences.getString(_lastErrorKey),
    );
  }

  Future<void> setAutoCheckEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_autoCheckEnabledKey, value);
    _settings = _settings.copyWith(autoCheckEnabled: value);
    notifyListeners();
  }

  Future<void> setNotifyOnNewUngradedWorks(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_notifyOnNewUngradedWorksKey, value);
    _settings = _settings.copyWith(notifyOnNewUngradedWorks: value);
    notifyListeners();
  }

  Future<void> setRememberLastSelectedCourse(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_rememberLastSelectedCourseKey, value);
    String? selectedCourseId = _settings.lastSelectedCourseId;
    if (!value) {
      await preferences.remove(_lastSelectedCourseIdKey);
      selectedCourseId = null;
    }
    _settings = _settings.copyWith(
      rememberLastSelectedCourse: value,
      lastSelectedCourseId: selectedCourseId,
    );
    notifyListeners();
  }

  Future<void> setShowStudentEmailColumn(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_showStudentEmailColumnKey, value);
    _settings = _settings.copyWith(showStudentEmailColumn: value);
    notifyListeners();
  }

  Future<void> setShowLateColumn(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_showLateColumnKey, value);
    _settings = _settings.copyWith(showLateColumn: value);
    notifyListeners();
  }

  Future<void> setLastSelectedCourseId(String? value) async {
    if (!_settings.rememberLastSelectedCourse) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await preferences.remove(_lastSelectedCourseIdKey);
    } else {
      await preferences.setString(_lastSelectedCourseIdKey, trimmed);
    }

    _settings = _settings.copyWith(
      lastSelectedCourseId: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
    notifyListeners();
  }

  Future<void> setOnlyTurnedIn(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onlyTurnedInKey, value);
    _settings = _settings.copyWith(onlyTurnedIn: value);
    notifyListeners();
  }

  Future<void> recordSuccessfulCheck({
    required int count,
    required DateTime checkedAt,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_lastSuccessfulCountKey, count);
    await preferences.setString(_lastCheckedAtKey, checkedAt.toIso8601String());
    await preferences.remove(_lastErrorKey);

    _settings = _settings.copyWith(
      lastSuccessfulCount: count,
      hasLastSuccessfulCount: true,
      lastCheckedAt: checkedAt,
      lastError: null,
    );
    notifyListeners();
  }

  Future<void> recordNotificationShown(int count) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_lastNotifiedCountKey, count);
    _settings = _settings.copyWith(lastNotifiedCount: count);
    notifyListeners();
  }

  Future<void> recordRefreshError(String message) async {
    final cleanMessage = message.trim();
    final preferences = await SharedPreferences.getInstance();
    if (cleanMessage.isEmpty) {
      await preferences.remove(_lastErrorKey);
    } else {
      await preferences.setString(_lastErrorKey, cleanMessage);
    }

    _settings = _settings.copyWith(
      lastError: cleanMessage.isEmpty ? null : cleanMessage,
    );
    notifyListeners();
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

const Object _unchanged = Object();
