import "package:flutter/material.dart";

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diagnostics")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _DiagnosticTile(
            icon: Icons.desktop_mac_outlined,
            label: "Desktop shell",
            value: "Menu bar/tray enabled",
          ),
          _DiagnosticTile(
            icon: Icons.login_outlined,
            label: "Google sign-in",
            value: "Browser sign-in enabled",
          ),
          _DiagnosticTile(
            icon: Icons.school_outlined,
            label: "Classroom access",
            value: "Profile, classes, topics, and assignments enabled",
          ),
          _DiagnosticTile(
            icon: Icons.filter_alt_outlined,
            label: "Assignment filter",
            value: "Only assignments created by this teacher",
          ),
          _DiagnosticTile(
            icon: Icons.upload_file_outlined,
            label: "CSV export",
            value: "String builder only; file writing disabled",
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
