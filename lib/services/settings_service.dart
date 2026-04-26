import "package:shared_preferences/shared_preferences.dart";

class AppSettings {
  const AppSettings({
    required this.refreshIntervalMinutes,
    required this.includeArchivedCourses,
  });

  final int refreshIntervalMinutes;
  final bool includeArchivedCourses;
}

class SettingsService {
  static const _refreshIntervalKey = "refreshIntervalMinutes";
  static const _includeArchivedCoursesKey = "includeArchivedCourses";

  AppSettings _settings = const AppSettings(
    refreshIntervalMinutes: 15,
    includeArchivedCourses: false,
  );

  AppSettings get settings => _settings;

  Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    _settings = AppSettings(
      refreshIntervalMinutes:
          preferences.getInt(_refreshIntervalKey) ??
          _settings.refreshIntervalMinutes,
      includeArchivedCourses:
          preferences.getBool(_includeArchivedCoursesKey) ??
          _settings.includeArchivedCourses,
    );
  }
}
