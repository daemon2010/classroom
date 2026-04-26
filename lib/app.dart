import "package:flutter/material.dart";

import "screens/diagnostics_screen.dart";
import "screens/home_screen.dart";
import "screens/settings_screen.dart";
import "services/classroom_api_service.dart";
import "services/csv_export_service.dart";
import "services/google_auth_service.dart";
import "services/report_controller.dart";
import "services/report_service.dart";
import "services/settings_service.dart";

class AppServices {
  const AppServices({
    required this.googleAuth,
    required this.classroomApi,
    required this.report,
    required this.reportController,
    required this.csvExport,
    required this.settings,
  });

  final GoogleAuthService googleAuth;
  final ClassroomApiService classroomApi;
  final ReportService report;
  final ReportController reportController;
  final CsvExportService csvExport;
  final SettingsService settings;
}

class ClassroomUngradedCheckerApp extends StatelessWidget {
  const ClassroomUngradedCheckerApp({
    required this.navigatorKey,
    required this.services,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: "Classroom Ungraded Checker",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.compact,
      ),
      routes: {
        "/": (_) => HomeScreen(services: services),
        "/settings": (_) => SettingsScreen(settings: services.settings),
        "/diagnostics": (_) => const DiagnosticsScreen(),
      },
    );
  }
}
