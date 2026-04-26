import "dart:async";
import "dart:io";

import "package:intl/intl.dart";
import "package:tray_manager/tray_manager.dart";
import "package:window_manager/window_manager.dart";

class TrayService with TrayListener {
  Future<void> init({
    required Future<void> Function() onOpenReport,
    required Future<void> Function() onCheckNow,
    required Future<void> Function() onExportCsv,
    required Future<void> Function() onSignInWithGoogle,
    required Future<void> Function() onOpenSettings,
  }) async {
    _onOpenReport = onOpenReport;
    _onCheckNow = onCheckNow;
    _onExportCsv = onExportCsv;
    _onSignInWithGoogle = onSignInWithGoogle;
    _onOpenSettings = onOpenSettings;

    trayManager.addListener(this);
    await _setTrayIcon(attention: false);
    await trayManager.setToolTip("Classroom Ungraded Checker");
    await updateTrayMenu(
      ungradedCount: 0,
      isSignedIn: false,
      hasLoadedRows: false,
    );
  }

  Future<void> showMainWindow() async {
    if (await windowManager.isMinimized()) {
      await windowManager.restore();
    }
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> hideMainWindow() async {
    if (_isQuitting) {
      return;
    }
    await windowManager.hide();
  }

  Future<void> quitApp() async {
    if (_isQuitting) {
      return;
    }

    _isQuitting = true;
    trayManager.removeListener(this);
    await trayManager.destroy();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
    exit(0);
  }

  Future<void> updateTrayMenu({
    required int ungradedCount,
    DateTime? lastChecked,
    String? signedInName,
    required bool isSignedIn,
    required bool hasLoadedRows,
    String? lastError,
    bool isRefreshing = false,
  }) async {
    final hasError = lastError != null && lastError.trim().isNotEmpty;
    await _setTrayIcon(attention: ungradedCount > 0);
    await trayManager.setToolTip(
      _buildToolTip(
        ungradedCount: ungradedCount,
        lastChecked: lastChecked,
        isSignedIn: isSignedIn,
        lastError: lastError,
      ),
    );

    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: _openReportKey, label: "Open Report"),
          MenuItem(
            key: _checkNowKey,
            label: isRefreshing ? "Checking..." : "Check Now",
            disabled: isRefreshing,
            toolTip: hasError ? lastError : null,
          ),
          MenuItem(
            key: _ungradedCountKey,
            label: "Ungraded works: $ungradedCount",
            disabled: true,
          ),
          MenuItem(
            key: _lastCheckedKey,
            label: "Last checked: ${_formatLastChecked(lastChecked)}",
            disabled: true,
          ),
          MenuItem(
            key: _exportCsvKey,
            label: "Export CSV",
            disabled: !isSignedIn || isRefreshing,
          ),
          MenuItem(
            key: _googleSignInKey,
            label: _buildAuthLabel(
              isSignedIn: isSignedIn,
              signedInName: signedInName,
            ),
            disabled: isSignedIn,
          ),
          MenuItem(key: _settingsKey, label: "Settings"),
          MenuItem(key: _quitKey, label: "Quit"),
        ],
      ),
    );
  }

  Future<void> dispose() async {
    trayManager.removeListener(this);
    await trayManager.destroy();
  }

  Future<void> Function()? _onOpenReport;
  Future<void> Function()? _onCheckNow;
  Future<void> Function()? _onExportCsv;
  Future<void> Function()? _onSignInWithGoogle;
  Future<void> Function()? _onOpenSettings;

  DateTime? _lastPrimaryClickAt;
  bool _isQuitting = false;
  bool? _isShowingAttentionIcon;

  static const _openReportKey = "open_report";
  static const _checkNowKey = "check_now";
  static const _ungradedCountKey = "ungraded_count";
  static const _lastCheckedKey = "last_checked";
  static const _exportCsvKey = "export_csv";
  static const _googleSignInKey = "google_sign_in";
  static const _settingsKey = "settings";
  static const _quitKey = "quit";

  String get _defaultIconPath {
    if (Platform.isWindows) {
      return "assets/tray/tray_icon.ico";
    }
    return "assets/tray/tray_icon.png";
  }

  String get _attentionIconPath {
    if (Platform.isWindows) {
      return "assets/tray/tray_icon.ico";
    }
    return "assets/tray/tray_icon_attention.png";
  }

  @override
  void onTrayIconMouseDown() {
    if (_isDoubleClick()) {
      unawaited(showMainWindow());
      return;
    }

    if (Platform.isMacOS) {
      unawaited(trayManager.popUpContextMenu());
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    unawaited(trayManager.popUpContextMenu());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case _openReportKey:
        _run(_onOpenReport);
        break;
      case _checkNowKey:
        _run(_onCheckNow);
        break;
      case _exportCsvKey:
        _run(_onExportCsv);
        break;
      case _googleSignInKey:
        _run(_onSignInWithGoogle);
        break;
      case _settingsKey:
        _run(_onOpenSettings);
        break;
      case _quitKey:
        unawaited(quitApp());
        break;
    }
  }

  Future<void> _setTrayIcon({required bool attention}) async {
    if (_isShowingAttentionIcon == attention) {
      return;
    }

    _isShowingAttentionIcon = attention;
    await trayManager.setIcon(
      attention ? _attentionIconPath : _defaultIconPath,
      iconSize: 18,
    );
  }

  bool _isDoubleClick() {
    final now = DateTime.now();
    final lastClick = _lastPrimaryClickAt;
    _lastPrimaryClickAt = now;

    if (lastClick == null) {
      return false;
    }

    return now.difference(lastClick) <= const Duration(milliseconds: 400);
  }

  String _formatLastChecked(DateTime? lastChecked) {
    if (lastChecked == null) {
      return "never";
    }
    return DateFormat("MMM d, HH:mm").format(lastChecked.toLocal());
  }

  String _buildAuthLabel({
    required bool isSignedIn,
    required String? signedInName,
  }) {
    if (!isSignedIn) {
      return "Sign in with Google";
    }

    final name = signedInName?.trim();
    if (name == null || name.isEmpty) {
      return "Signed in";
    }
    return "Signed in as $name";
  }

  String _buildToolTip({
    required int ungradedCount,
    required DateTime? lastChecked,
    required bool isSignedIn,
    required String? lastError,
  }) {
    if (!isSignedIn) {
      return "Classroom Ungraded Checker - Sign in required";
    }

    if (lastError != null && lastError.trim().isNotEmpty) {
      return "Last check failed. Open app for details.";
    }

    return "Ungraded works: $ungradedCount. Last checked: ${_formatToolTipChecked(lastChecked)}";
  }

  String _formatToolTipChecked(DateTime? lastChecked) {
    if (lastChecked == null) {
      return "never";
    }
    return DateFormat("HH:mm").format(lastChecked.toLocal());
  }

  void _run(Future<void> Function()? callback) {
    if (callback == null) {
      return;
    }
    unawaited(callback());
  }
}
