import "dart:async";
import "dart:io";

import "package:flutter/services.dart";
import "package:intl/intl.dart";
import "package:tray_manager/tray_manager.dart";
import "package:window_manager/window_manager.dart";

import "../l10n/app_language.dart";
import "../l10n/app_localizations.dart";

class TrayService with TrayListener {
  static const _dockChannel = MethodChannel("classroom_dock");

  Future<void> init({
    required Future<void> Function() onOpenReport,
    required Future<void> Function() onCheckNow,
    required Future<void> Function() onExportCsv,
    required Future<void> Function() onSignInWithGoogle,
    required Future<void> Function() onOpenSettings,
    required String languageCode,
  }) async {
    _onOpenReport = onOpenReport;
    _onCheckNow = onCheckNow;
    _onExportCsv = onExportCsv;
    _onSignInWithGoogle = onSignInWithGoogle;
    _onOpenSettings = onOpenSettings;

    trayManager.addListener(this);
    await _setTrayIcon(attention: false);
    await trayManager.setToolTip(
      AppLocalizations.forLanguageCode(languageCode).appTitle,
    );
    await updateTrayMenu(
      ungradedCount: 0,
      isSignedIn: false,
      hasLoadedRows: false,
    );
  }

  Future<void> showMainWindow() async {
    await _setDockVisible(true);
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
    await _setDockVisible(false);
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
    String languageCode = AppLanguage.english,
  }) async {
    final l10n = AppLocalizations.forLanguageCode(languageCode);
    final hasError = lastError != null && lastError.trim().isNotEmpty;
    await _setTrayIcon(attention: ungradedCount > 0);
    await trayManager.setToolTip(
      _buildToolTip(
        ungradedCount: ungradedCount,
        lastChecked: lastChecked,
        isSignedIn: isSignedIn,
        lastError: lastError,
        l10n: l10n,
      ),
    );

    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: _openReportKey, label: l10n.openReport),
          MenuItem(
            key: _checkNowKey,
            label: isRefreshing ? l10n.checking : l10n.checkNow,
            disabled: isRefreshing,
            toolTip: hasError ? lastError : null,
          ),
          MenuItem(
            key: _ungradedCountKey,
            label: l10n.ungradedWorksCount(ungradedCount),
            disabled: true,
          ),
          MenuItem(
            key: _lastCheckedKey,
            label: l10n.lastCheckedValue(_formatLastChecked(l10n, lastChecked)),
            disabled: true,
          ),
          MenuItem(
            key: _exportCsvKey,
            label: l10n.exportCsv,
            disabled: !isSignedIn || isRefreshing,
          ),
          MenuItem(
            key: _googleSignInKey,
            label: _buildAuthLabel(
              isSignedIn: isSignedIn,
              signedInName: signedInName,
              l10n: l10n,
            ),
            disabled: isSignedIn,
          ),
          MenuItem(key: _settingsKey, label: l10n.settings),
          MenuItem(key: _quitKey, label: l10n.quit),
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

  String _formatLastChecked(AppLocalizations l10n, DateTime? lastChecked) {
    if (lastChecked == null) {
      return l10n.never;
    }
    return DateFormat(
      "yyyy-MM-dd HH:mm",
      l10n.localeName,
    ).format(lastChecked.toLocal());
  }

  String _buildAuthLabel({
    required bool isSignedIn,
    required String? signedInName,
    required AppLocalizations l10n,
  }) {
    if (!isSignedIn) {
      return l10n.signInWithGoogle;
    }

    final name = signedInName?.trim();
    if (name == null || name.isEmpty) {
      return l10n.signedIn;
    }
    return l10n.signedInAsTray(name);
  }

  String _buildToolTip({
    required int ungradedCount,
    required DateTime? lastChecked,
    required bool isSignedIn,
    required String? lastError,
    required AppLocalizations l10n,
  }) {
    if (!isSignedIn) {
      return l10n.signInRequiredTooltip;
    }

    if (lastError != null && lastError.trim().isNotEmpty) {
      return l10n.lastCheckFailedTooltip;
    }

    return l10n.trayTooltip(
      ungradedCount,
      _formatToolTipChecked(l10n, lastChecked),
    );
  }

  String _formatToolTipChecked(AppLocalizations l10n, DateTime? lastChecked) {
    if (lastChecked == null) {
      return l10n.never;
    }
    return DateFormat("HH:mm", l10n.localeName).format(lastChecked.toLocal());
  }

  void _run(Future<void> Function()? callback) {
    if (callback == null) {
      return;
    }
    unawaited(callback());
  }

  Future<void> _setDockVisible(bool visible) async {
    if (!Platform.isMacOS) {
      return;
    }

    try {
      await _dockChannel.invokeMethod<bool>("setDockVisible", {
        "visible": visible,
      });
    } catch (_) {
      // Dock visibility is a macOS nicety; window behavior should continue.
    }
  }
}
