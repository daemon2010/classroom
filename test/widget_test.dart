import "package:classroom_ungraded_checker/app.dart";
import "package:classroom_ungraded_checker/services/classroom_api_service.dart";
import "package:classroom_ungraded_checker/services/csv_export_service.dart";
import "package:classroom_ungraded_checker/services/google_auth_service.dart";
import "package:classroom_ungraded_checker/services/report_controller.dart";
import "package:classroom_ungraded_checker/services/report_service.dart";
import "package:classroom_ungraded_checker/services/settings_service.dart";
import "package:flutter/material.dart";
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

    expect(find.text("Classroom Ungraded Checker"), findsOneWidget);
    expect(
      find.text(
        "Connect your Google account to check ungraded Classroom work.",
      ),
      findsWidgets,
    );
    expect(find.text("No ungraded Classroom work to show."), findsOneWidget);
  });
}

AppServices _testServices() {
  final googleAuth = GoogleAuthService();
  final classroomApi = ClassroomApiService(googleAuth);
  const report = ReportService();
  final csvExport = CsvExportService();

  return AppServices(
    googleAuth: googleAuth,
    classroomApi: classroomApi,
    report: report,
    reportController: ReportController(
      googleAuth: googleAuth,
      classroomApi: classroomApi,
      report: report,
      csvExport: csvExport,
    ),
    csvExport: csvExport,
    settings: SettingsService(),
  );
}
