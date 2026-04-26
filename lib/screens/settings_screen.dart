import "package:flutter/material.dart";

import "../app.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.services, super.key});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final settings = services.settings;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: AnimatedBuilder(
        animation: settings,
        builder: (context, _) {
          final current = settings.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.check_circle_outline),
                title: const Text("Only show works turned in by students"),
                subtitle: const Text(
                  "Hide assigned work that has not been submitted",
                ),
                value: current.onlyTurnedIn,
                onChanged: (value) {
                  settings.setOnlyTurnedIn(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.sync_outlined),
                title: const Text("Check automatically every 30 minutes"),
                subtitle: const Text("Updates the menu bar count"),
                value: current.autoCheckEnabled,
                onChanged: (value) {
                  settings.setAutoCheckEnabled(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text("Notify when new ungraded works appear"),
                subtitle: const Text("Only when the count increases"),
                value: current.notifyOnNewUngradedWorks,
                onChanged: (value) {
                  settings.setNotifyOnNewUngradedWorks(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.school_outlined),
                title: const Text("Remember last selected class"),
                subtitle: const Text("Restore the class filter next time"),
                value: current.rememberLastSelectedCourse,
                onChanged: (value) {
                  settings.setRememberLastSelectedCourse(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.alternate_email_outlined),
                title: const Text("Show student email column"),
                value: current.showStudentEmailColumn,
                onChanged: (value) {
                  settings.setShowStudentEmailColumn(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.schedule_outlined),
                title: const Text("Show late column"),
                value: current.showLateColumn,
                onChanged: (value) {
                  settings.setShowLateColumn(value);
                },
              ),
              const Divider(height: 32),
              const ListTile(
                leading: Icon(Icons.build_outlined),
                title: Text("Admin and development"),
              ),
              ListTile(
                leading: const Icon(Icons.wifi_tethering_outlined),
                title: const Text("Run connection check"),
                subtitle: const Text("Checks Google Classroom access"),
                onTap: () => _runConnectionCheck(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text("Reset Google login"),
                subtitle: const Text("Sign in again with Google"),
                onTap: () => _resetGoogleLogin(context),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.archive_outlined),
                title: const Text("Archived courses"),
                subtitle: const Text(
                  "Disabled while Classroom checks are pending",
                ),
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
          );
        },
      ),
    );
  }

  Future<void> _runConnectionCheck(BuildContext context) async {
    final ok = await services.reportController.refreshReport();
    if (!context.mounted) {
      return;
    }

    final message = ok
        ? "Connection check completed."
        : services.reportController.lastError ??
              "Connection check could not finish.";
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resetGoogleLogin(BuildContext context) async {
    await services.reportController.resetGoogleLogin();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Google login has been reset.")),
    );
  }
}
