import "package:flutter/material.dart";

import "../services/settings_service.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.settings, super.key});

  final SettingsService settings;

  @override
  Widget build(BuildContext context) {
    final current = settings.settings;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text("Refresh interval"),
            subtitle: Text("${current.refreshIntervalMinutes} minutes"),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.archive_outlined),
            title: const Text("Archived courses"),
            subtitle: const Text("Disabled while Classroom checks are pending"),
            value: current.includeArchivedCourses,
            onChanged: null,
          ),
          const Divider(height: 32),
          const ListTile(
            leading: Icon(Icons.key_outlined),
            title: Text("Google connection"),
            subtitle: Text("Configured for this app"),
          ),
          const ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text("Classroom write access"),
            subtitle: Text("No write operations are wired"),
          ),
        ],
      ),
    );
  }
}
