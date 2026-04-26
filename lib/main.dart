import "dart:async";

import "package:flutter/material.dart";
import "package:window_manager/window_manager.dart";

import "app.dart";
import "services/classroom_api_service.dart";
import "services/csv_export_service.dart";
import "services/google_auth_service.dart";
import "services/report_service.dart";
import "services/settings_service.dart";
import "services/tray_service.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  final settingsService = SettingsService();
  await settingsService.init();

  final googleAuthService = GoogleAuthService();
  final services = AppServices(
    googleAuth: googleAuthService,
    classroomApi: ClassroomApiService(),
    report: ReportService(),
    csvExport: CsvExportService(),
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

  runApp(
    ClassroomUngradedCheckerApp(navigatorKey: navigatorKey, services: services),
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await trayService.hideMainWindow();
  });

  DateTime? lastChecked;
  Future<void> updateInitialTrayState({DateTime? checkedAt}) async {
    lastChecked = checkedAt ?? lastChecked;
    final authStatus = await googleAuthService.currentStatus();
    final signedInName =
        authStatus.displayName ?? authStatus.emailAddress ?? "Google account";

    await trayService.updateTrayMenu(
      ungradedCount: 0,
      lastChecked: lastChecked,
      signedInName: signedInName,
      isSignedIn: authStatus.state == GoogleAuthState.signedIn,
      hasLoadedRows: false,
      lastError: authStatus.state == GoogleAuthState.unavailable
          ? authStatus.message
          : null,
    );
  }

  Future<void> signInFromTray() async {
    try {
      await googleAuthService.signIn();
    } on GoogleAuthException catch (_) {
      await updateInitialTrayState();
      await _showWindow(trayService, navigatorKey, "/");
      return;
    }
    await updateInitialTrayState();
    await _showWindow(trayService, navigatorKey, "/");
  }

  await trayService.init(
    onOpenReport: () => _showWindow(trayService, navigatorKey, "/"),
    onCheckNow: () => updateInitialTrayState(checkedAt: DateTime.now()),
    onExportCsv: () => _showWindow(trayService, navigatorKey, "/"),
    onSignInWithGoogle: signInFromTray,
    onOpenSettings: () => _showWindow(trayService, navigatorKey, "/settings"),
  );

  await updateInitialTrayState();
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
