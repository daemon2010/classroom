import "package:flutter/material.dart";

import "../l10n/app_localizations.dart";

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.diagnostics)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DiagnosticTile(
            icon: Icons.desktop_mac_outlined,
            label: l10n.desktopShell,
            value: l10n.menuBarTrayEnabled,
          ),
          _DiagnosticTile(
            icon: Icons.login_outlined,
            label: l10n.googleSignIn,
            value: l10n.browserSignInEnabled,
          ),
          _DiagnosticTile(
            icon: Icons.school_outlined,
            label: l10n.classroomAccess,
            value: l10n.classroomAccessEnabled,
          ),
          _DiagnosticTile(
            icon: Icons.filter_alt_outlined,
            label: l10n.assignmentFilter,
            value: l10n.assignmentFilterValue,
          ),
          _DiagnosticTile(
            icon: Icons.upload_file_outlined,
            label: l10n.csvExport,
            value: l10n.csvExportEnabled,
          ),
        ],
      ),
    );
  }
}

class _DiagnosticTile extends StatelessWidget {
  const _DiagnosticTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
