import "dart:async";

import "package:flutter/material.dart";
import "package:window_manager/window_manager.dart";

import "app.dart";
import "services/classroom_api_service.dart";
import "services/csv_export_service.dart";
import "services/google_auth_service.dart";
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
  final reportController = ReportController(
    googleAuth: googleAuthService,
    classroomApi: classroomApiService,
    report: reportService,
    csvExport: csvExportService,
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

  const windowOptions = WindowOptions(
    size: Size(1000, 700),
    minimumSize: Size(760, 500),
    center: true,
    title: "Classroom Ungraded Checker",
  );

  await windowManager.setPreventClose(true);

  final navigatorKey = GlobalKey<NavigatorState>();
  final trayService = TrayService();
  final windowController = DesktopWindowController(trayService);
  windowManager.addListener(windowController);

  Future<void> updateTrayState() async {
    await trayService.updateTrayMenu(
      ungradedCount: reportController.ungradedCount,
      lastChecked: reportController.lastChecked,
      signedInName: reportController.signedInName,
      isSignedIn: reportController.isSignedIn,
      hasLoadedRows: reportController.hasLoadedRows,
      lastError: reportController.lastError,
      isRefreshing: reportController.isRefreshing,
    );
  }

  void scheduleTrayUpdate() {
    unawaited(updateTrayState());
  }

  reportController.addListener(scheduleTrayUpdate);

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
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await trayService.hideMainWindow();
  });

  await updateTrayState();

  if (reportController.isSignedIn) {
    unawaited(reportController.refreshReport());
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
