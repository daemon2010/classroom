import "package:classroom_ungraded_checker/app.dart";
import "package:classroom_ungraded_checker/l10n/app_localizations.dart";
import "package:classroom_ungraded_checker/models/classroom_models.dart";
import "package:classroom_ungraded_checker/services/classroom_api_service.dart";
import "package:classroom_ungraded_checker/services/csv_export_service.dart";
import "package:classroom_ungraded_checker/services/google_auth_service.dart";
import "package:classroom_ungraded_checker/services/notification_service.dart";
import "package:classroom_ungraded_checker/services/report_cache_service.dart";
import "package:classroom_ungraded_checker/services/report_controller.dart";
import "package:classroom_ungraded_checker/services/report_service.dart";
import "package:classroom_ungraded_checker/services/settings_service.dart";
import "package:classroom_ungraded_checker/widgets/course_filter.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  testWidgets("shows the report screen", (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ClassroomUngradedCheckerApp(
        navigatorKey: GlobalKey<NavigatorState>(),
        services: _testServices(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Перевірка неоцінених робіт Classroom"), findsOneWidget);
    expect(find.textContaining("Підключіть Google-акаунт"), findsWidgets);
    expect(
      find.text("Немає неоцінених робіт Classroom для показу."),
      findsOneWidget,
    );
  });

  testWidgets("uses the selected interface language", (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final services = _testServices();
    await services.settings.setInterfaceLanguageCode("en");

    await tester.pumpWidget(
      ClassroomUngradedCheckerApp(
        navigatorKey: GlobalKey<NavigatorState>(),
        services: services,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Classroom Ungraded Checker"), findsOneWidget);
    expect(find.textContaining("Connect your Google account"), findsWidgets);
  });

  testWidgets("course filter stays compact without layout overflow", (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(540, 360);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale("en"),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: CourseFilter(
              courses: const [
                ClassroomCourse(
                  id: "course-1",
                  name: "Very long classroom name for compact layout",
                  section: "Long section name",
                ),
              ],
              selectedCourseId: "course-1",
              searchQuery: "",
              onCourseChanged: (_) {},
              onSearchChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining("Very long classroom name"), findsOneWidget);
    expect(find.text("Search"), findsOneWidget);
  });
}

AppServices _testServices() {
  final googleAuth = GoogleAuthService();
  final classroomApi = ClassroomApiService(googleAuth);
  const report = ReportService();
  final csvExport = CsvExportService();
  final cache = ReportCacheService();
  final settings = SettingsService();
  final notifications = NotificationService();

  return AppServices(
    googleAuth: googleAuth,
    classroomApi: classroomApi,
    report: report,
    reportController: ReportController(
      googleAuth: googleAuth,
      classroomApi: classroomApi,
      report: report,
      csvExport: csvExport,
      cache: cache,
      settings: settings,
      notifications: notifications,
    ),
    csvExport: csvExport,
    settings: settings,
  );
}
