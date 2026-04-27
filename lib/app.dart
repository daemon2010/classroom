import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";

import "l10n/app_language.dart";
import "l10n/app_localizations.dart";
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
    return AnimatedBuilder(
      animation: services.settings,
      builder: (context, _) {
        final languageCode = services.settings.settings.interfaceLanguageCode;

        return MaterialApp(
          navigatorKey: navigatorKey,
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          locale: languageCode == AppLanguage.system
              ? null
              : Locale(languageCode),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
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
            "/settings": (_) => SettingsScreen(services: services),
            "/diagnostics": (_) => const DiagnosticsScreen(),
          },
        );
      },
    );
  }
}
