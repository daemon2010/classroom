import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../l10n/app_language.dart";

class AppSettings {
  const AppSettings({
    required this.interfaceLanguageCode,
    required this.refreshIntervalMinutes,
    required this.includeArchivedCourses,
    required this.autoCheckEnabled,
    required this.notifyOnNewUngradedWorks,
    required this.rememberLastSelectedCourse,
    required this.showStudentEmailColumn,
    required this.showLateColumn,
    required this.lastSuccessfulCount,
    required this.lastSuccessfulVisibleCount,
    required this.hasLastSuccessfulCount,
    required this.hasLastSuccessfulVisibleCount,
    required this.displayAllYears,
    this.lastNotifiedCount,
    this.lastNotifiedVisibleCount,
    this.lastCheckedAt,
    this.lastSelectedCourseId,
    this.lastError,
  });

  final String interfaceLanguageCode;
  final int refreshIntervalMinutes;
  final bool includeArchivedCourses;
  final bool autoCheckEnabled;
  final bool notifyOnNewUngradedWorks;
  final bool rememberLastSelectedCourse;
  final bool showStudentEmailColumn;
  final bool showLateColumn;
  final int lastSuccessfulCount;
  final int lastSuccessfulVisibleCount;
  final bool hasLastSuccessfulCount;
  final bool hasLastSuccessfulVisibleCount;
  final DateTime? lastCheckedAt;
  final String? lastSelectedCourseId;
  final bool displayAllYears;
  final int? lastNotifiedCount;
  final int? lastNotifiedVisibleCount;
  final String? lastError;

  AppSettings copyWith({
    String? interfaceLanguageCode,
    int? refreshIntervalMinutes,
    bool? includeArchivedCourses,
    bool? autoCheckEnabled,
    bool? notifyOnNewUngradedWorks,
    bool? rememberLastSelectedCourse,
    bool? showStudentEmailColumn,
    bool? showLateColumn,
    int? lastSuccessfulCount,
    int? lastSuccessfulVisibleCount,
    bool? hasLastSuccessfulCount,
    bool? hasLastSuccessfulVisibleCount,
    DateTime? lastCheckedAt,
    Object? lastSelectedCourseId = _unchanged,
    bool? displayAllYears,
    Object? lastNotifiedCount = _unchanged,
    Object? lastNotifiedVisibleCount = _unchanged,
    Object? lastError = _unchanged,
  }) {
    return AppSettings(
      interfaceLanguageCode:
          interfaceLanguageCode ?? this.interfaceLanguageCode,
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
      lastSuccessfulVisibleCount:
          lastSuccessfulVisibleCount ?? this.lastSuccessfulVisibleCount,
      hasLastSuccessfulCount:
          hasLastSuccessfulCount ?? this.hasLastSuccessfulCount,
      hasLastSuccessfulVisibleCount:
          hasLastSuccessfulVisibleCount ?? this.hasLastSuccessfulVisibleCount,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastSelectedCourseId: identical(lastSelectedCourseId, _unchanged)
          ? this.lastSelectedCourseId
          : lastSelectedCourseId as String?,
      displayAllYears: displayAllYears ?? this.displayAllYears,
      lastNotifiedCount: identical(lastNotifiedCount, _unchanged)
          ? this.lastNotifiedCount
          : lastNotifiedCount as int?,
      lastNotifiedVisibleCount: identical(lastNotifiedVisibleCount, _unchanged)
          ? this.lastNotifiedVisibleCount
          : lastNotifiedVisibleCount as int?,
      lastError: identical(lastError, _unchanged)
          ? this.lastError
          : lastError as String?,
    );
  }
}

class SettingsService extends ChangeNotifier {
  static const _refreshIntervalOptions = [5, 10, 15, 30, 60];
  static const _interfaceLanguageCodeKey = "interfaceLanguageCode";
  static const _refreshIntervalMinutesKey = "refreshIntervalMinutes";
  static const _includeArchivedCoursesKey = "includeArchivedCourses";
  static const _autoCheckEnabledKey = "autoCheckEnabled";
  static const _notifyOnNewUngradedWorksKey = "notifyOnNewUngradedWorks";
  static const _rememberLastSelectedCourseKey = "rememberLastSelectedCourse";
  static const _showStudentEmailColumnKey = "showStudentEmailColumn";
  static const _showLateColumnKey = "showLateColumn";
  static const _lastSuccessfulCountKey = "lastSuccessfulCount";
  static const _lastSuccessfulVisibleCountKey = "lastSuccessfulVisibleCount";
  static const _lastCheckedAtKey = "lastCheckedAt";
  static const _lastSelectedCourseIdKey = "lastSelectedCourseId";
  static const _displayAllYearsKey = "displayAllYears";
  static const _lastNotifiedCountKey = "lastNotifiedCount";
  static const _lastNotifiedVisibleCountKey = "lastNotifiedVisibleCount";
  static const _lastErrorKey = "lastError";

  AppSettings _settings = const AppSettings(
    interfaceLanguageCode: AppLanguage.ukrainian,
    refreshIntervalMinutes: 30,
    includeArchivedCourses: false,
    autoCheckEnabled: true,
    notifyOnNewUngradedWorks: false,
    rememberLastSelectedCourse: true,
    showStudentEmailColumn: true,
    showLateColumn: true,
    lastSuccessfulCount: 0,
    lastSuccessfulVisibleCount: 0,
    hasLastSuccessfulCount: false,
    hasLastSuccessfulVisibleCount: false,
    displayAllYears: false,
  );

  AppSettings get settings => _settings;
  List<int> get refreshIntervalOptions => _refreshIntervalOptions;

  Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    _settings = AppSettings(
      interfaceLanguageCode: AppLanguage.normalizeSetting(
        preferences.getString(_interfaceLanguageCodeKey),
      ),
      refreshIntervalMinutes: _normalizeRefreshInterval(
        preferences.getInt(_refreshIntervalMinutesKey) ??
            _settings.refreshIntervalMinutes,
      ),
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
      lastSuccessfulVisibleCount:
          preferences.getInt(_lastSuccessfulVisibleCountKey) ??
          _settings.lastSuccessfulVisibleCount,
      hasLastSuccessfulCount: preferences.containsKey(_lastSuccessfulCountKey),
      hasLastSuccessfulVisibleCount: preferences.containsKey(
        _lastSuccessfulVisibleCountKey,
      ),
      lastCheckedAt: _parseDateTime(preferences.getString(_lastCheckedAtKey)),
      lastSelectedCourseId: preferences.getString(_lastSelectedCourseIdKey),
      displayAllYears:
          preferences.getBool(_displayAllYearsKey) ?? _settings.displayAllYears,
      lastNotifiedCount: preferences.getInt(_lastNotifiedCountKey),
      lastNotifiedVisibleCount: preferences.getInt(
        _lastNotifiedVisibleCountKey,
      ),
      lastError: preferences.getString(_lastErrorKey),
    );
  }

  Future<void> setInterfaceLanguageCode(String value) async {
    final languageCode = AppLanguage.normalizeSetting(value);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_interfaceLanguageCodeKey, languageCode);
    _settings = _settings.copyWith(interfaceLanguageCode: languageCode);
    notifyListeners();
  }

  Future<void> setAutoCheckEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_autoCheckEnabledKey, value);
    _settings = _settings.copyWith(autoCheckEnabled: value);
    notifyListeners();
  }

  Future<void> setRefreshIntervalMinutes(int value) async {
    final minutes = _normalizeRefreshInterval(value);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_refreshIntervalMinutesKey, minutes);
    _settings = _settings.copyWith(refreshIntervalMinutes: minutes);
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
    await preferences.remove(_lastNotifiedVisibleCountKey);
    _settings = _settings.copyWith(
      rememberLastSelectedCourse: value,
      lastSelectedCourseId: selectedCourseId,
      lastNotifiedVisibleCount: null,
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
    await preferences.remove(_lastNotifiedVisibleCountKey);

    _settings = _settings.copyWith(
      lastSelectedCourseId: trimmed == null || trimmed.isEmpty ? null : trimmed,
      lastNotifiedVisibleCount: null,
    );
    notifyListeners();
  }

  Future<void> setDisplayAllYears(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_displayAllYearsKey, value);
    await preferences.remove(_lastNotifiedVisibleCountKey);
    _settings = _settings.copyWith(
      displayAllYears: value,
      lastNotifiedVisibleCount: null,
    );
    notifyListeners();
  }

  Future<void> recordSuccessfulCheck({
    required int count,
    required int visibleCount,
    required DateTime checkedAt,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_lastSuccessfulCountKey, count);
    await preferences.setInt(_lastSuccessfulVisibleCountKey, visibleCount);
    await preferences.setString(_lastCheckedAtKey, checkedAt.toIso8601String());
    await preferences.remove(_lastErrorKey);

    _settings = _settings.copyWith(
      lastSuccessfulCount: count,
      lastSuccessfulVisibleCount: visibleCount,
      hasLastSuccessfulCount: true,
      hasLastSuccessfulVisibleCount: true,
      lastCheckedAt: checkedAt,
      lastError: null,
    );
    notifyListeners();
  }

  Future<void> recordNotificationShown(int count) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_lastNotifiedVisibleCountKey, count);
    _settings = _settings.copyWith(lastNotifiedVisibleCount: count);
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

  int _normalizeRefreshInterval(int value) {
    return _refreshIntervalOptions.reduce((currentBest, option) {
      final currentDistance = (value - currentBest).abs();
      final optionDistance = (value - option).abs();
      return optionDistance < currentDistance ? option : currentBest;
    });
  }
}

const Object _unchanged = Object();
