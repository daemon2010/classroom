import "dart:async";

import "package:flutter/material.dart";
import "package:window_manager/window_manager.dart";

import "app.dart";
import "l10n/app_language.dart";
import "l10n/app_localizations.dart";
import "services/classroom_api_service.dart";
import "services/csv_export_service.dart";
import "services/google_auth_service.dart";
import "services/notification_service.dart";
import "services/report_cache_service.dart";
import "services/report_controller.dart";
import "services/report_service.dart";
import "services/settings_service.dart";
import "services/tray_service.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  final settingsService = SettingsService();
  await settingsService.init();

  final googleAuthService = GoogleAuthService();
  final classroomApiService = ClassroomApiService(googleAuthService);
  const reportService = ReportService();
  final csvExportService = CsvExportService();
  final reportCacheService = ReportCacheService();
  final notificationService = NotificationService();
  await notificationService.init();
  final reportController = ReportController(
    googleAuth: googleAuthService,
    classroomApi: classroomApiService,
    report: reportService,
    csvExport: csvExportService,
    cache: reportCacheService,
    settings: settingsService,
    notifications: notificationService,
  );
  await reportController.loadAuthStatus();

  final services = AppServices(
    googleAuth: googleAuthService,
    classroomApi: classroomApiService,
    report: reportService,
    reportController: reportController,
    csvExport: csvExportService,
    settings: settingsService,
  );

  final windowOptions = WindowOptions(
    size: const Size(1000, 700),
    minimumSize: const Size(760, 500),
    center: true,
    title: AppLocalizations.forLanguageCode(
      _resolvedInterfaceLanguage(settingsService),
    ).appTitle,
  );

  await windowManager.setPreventClose(true);

  final navigatorKey = GlobalKey<NavigatorState>();
  final trayService = TrayService();
  final windowController = DesktopWindowController(trayService);
  windowManager.addListener(windowController);

  Future<void> updateTrayState() async {
    await trayService.updateTrayMenu(
      ungradedCount: reportController.visibleUngradedCount,
      lastChecked: reportController.lastChecked,
      signedInName: reportController.signedInName,
      isSignedIn: reportController.isSignedIn,
      hasLoadedRows: reportController.hasLoadedRows,
      lastError: reportController.lastError,
      isRefreshing: reportController.isRefreshing,
      languageCode: _resolvedInterfaceLanguage(settingsService),
    );
  }

  void scheduleTrayUpdate() {
    unawaited(updateTrayState());
  }

  reportController.addListener(scheduleTrayUpdate);

  Timer? backgroundRefreshTimer;
  void configureBackgroundRefresh() {
    backgroundRefreshTimer?.cancel();
    backgroundRefreshTimer = null;

    final settings = settingsService.settings;
    if (!settings.autoCheckEnabled || settings.refreshIntervalMinutes <= 0) {
      return;
    }

    backgroundRefreshTimer = Timer.periodic(
      Duration(minutes: settings.refreshIntervalMinutes),
      (_) {
        if (!reportController.isSignedIn || reportController.isRefreshing) {
          return;
        }
        unawaited(reportController.refreshReport(isBackground: true));
      },
    );
  }

  void handleSettingsChanged() {
    configureBackgroundRefresh();
    unawaited(
      windowManager.setTitle(
        AppLocalizations.forLanguageCode(
          _resolvedInterfaceLanguage(settingsService),
        ).appTitle,
      ),
    );
    scheduleTrayUpdate();
  }

  settingsService.addListener(handleSettingsChanged);
  configureBackgroundRefresh();

  Future<void> signInFromTray() async {
    await reportController.signIn();
    await _showWindow(trayService, navigatorKey, "/");
  }

  runApp(
    ClassroomUngradedCheckerApp(navigatorKey: navigatorKey, services: services),
  );

  await trayService.init(
    onOpenReport: () => _showWindow(trayService, navigatorKey, "/"),
    onCheckNow: reportController.refreshReport,
    onExportCsv: () async {
      final exportedPath = await reportController.exportCsv();
      if (exportedPath == null && reportController.lastError != null) {
        await _showWindow(trayService, navigatorKey, "/");
      }
    },
    onSignInWithGoogle: signInFromTray,
    onOpenSettings: () => _showWindow(trayService, navigatorKey, "/settings"),
    languageCode: _resolvedInterfaceLanguage(settingsService),
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await trayService.hideMainWindow();
  });

  await updateTrayState();

  if (settingsService.settings.autoCheckEnabled &&
      reportController.shouldRefreshOnStartup) {
    unawaited(reportController.refreshReport(isBackground: true));
  }
}

Future<void> _showWindow(
  TrayService trayService,
  GlobalKey<NavigatorState> navigatorKey,
  String routeName,
) async {
  await trayService.showMainWindow();

  final navigator = navigatorKey.currentState;
  if (navigator == null) {
    return;
  }

  if (routeName == "/") {
    navigator.popUntil((route) => route.isFirst);
  } else {
    navigator.pushNamedAndRemoveUntil(routeName, (route) => route.isFirst);
  }
}

class DesktopWindowController with WindowListener {
  const DesktopWindowController(this.trayService);

  final TrayService trayService;

  @override
  void onWindowClose() {
    unawaited(trayService.hideMainWindow());
  }
}

String _resolvedInterfaceLanguage(SettingsService settingsService) {
  final setting = settingsService.settings.interfaceLanguageCode;
  final systemLanguage =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return AppLanguage.resolve(setting, systemLanguage);
}
