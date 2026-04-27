import "package:flutter/material.dart";

import "../app.dart";
import "../l10n/app_language.dart";
import "../l10n/app_localizations.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.services, super.key});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = services.settings;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: AnimatedBuilder(
        animation: settings,
        builder: (context, _) {
          final current = settings.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.language),
                subtitle: Text(l10n.languageSubtitle),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 56,
                  end: 16,
                  bottom: 8,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: current.interfaceLanguageCode,
                  isExpanded: true,
                  items: [
                    for (final languageCode in AppLanguage.settingsValues)
                      DropdownMenuItem(
                        value: languageCode,
                        child: Text(
                          l10n.languageName(languageCode),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      settings.setInterfaceLanguageCode(value);
                    }
                  },
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.check_circle_outline),
                title: Text(l10n.onlyTurnedInTitle),
                subtitle: Text(l10n.onlyTurnedInSubtitle),
                value: current.onlyTurnedIn,
                onChanged: (value) {
                  settings.setOnlyTurnedIn(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.sync_outlined),
                title: Text(l10n.autoCheckTitle),
                subtitle: Text(l10n.autoCheckSubtitle),
                value: current.autoCheckEnabled,
                onChanged: (value) {
                  settings.setAutoCheckEnabled(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(l10n.notifyTitle),
                subtitle: Text(l10n.notifySubtitle),
                value: current.notifyOnNewUngradedWorks,
                onChanged: (value) {
                  settings.setNotifyOnNewUngradedWorks(value);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(l10n.sendTestNotification),
                subtitle: Text(l10n.sendTestNotificationSubtitle),
                onTap: () => _sendTestNotification(context),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.school_outlined),
                title: Text(l10n.rememberClassTitle),
                subtitle: Text(l10n.rememberClassSubtitle),
                value: current.rememberLastSelectedCourse,
                onChanged: (value) {
                  settings.setRememberLastSelectedCourse(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.alternate_email_outlined),
                title: Text(l10n.showEmailColumn),
                value: current.showStudentEmailColumn,
                onChanged: (value) {
                  settings.setShowStudentEmailColumn(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.schedule_outlined),
                title: Text(l10n.showLateColumn),
                value: current.showLateColumn,
                onChanged: (value) {
                  settings.setShowLateColumn(value);
                },
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.build_outlined),
                title: Text(l10n.adminDevelopment),
              ),
              ListTile(
                leading: const Icon(Icons.wifi_tethering_outlined),
                title: Text(l10n.runConnectionCheck),
                subtitle: Text(l10n.connectionCheckSubtitle),
                onTap: () => _runConnectionCheck(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: Text(l10n.resetGoogleLogin),
                subtitle: Text(l10n.resetGoogleLoginSubtitle),
                onTap: () => _resetGoogleLogin(context),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.archive_outlined),
                title: Text(l10n.archivedCourses),
                subtitle: Text(l10n.archivedCoursesSubtitle),
                value: current.includeArchivedCourses,
                onChanged: null,
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.key_outlined),
                title: Text(l10n.googleConnection),
                subtitle: Text(l10n.configuredForThisApp),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(l10n.classroomWriteAccess),
                subtitle: Text(l10n.noWriteOperationsWired),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _runConnectionCheck(BuildContext context) async {
    final l10n = context.l10n;
    final ok = await services.reportController.refreshReport();
    if (!context.mounted) {
      return;
    }

    final message = ok
        ? l10n.connectionCheckCompleted
        : services.reportController.lastError ?? l10n.connectionCheckFailed;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resetGoogleLogin(BuildContext context) async {
    final l10n = context.l10n;
    await services.reportController.resetGoogleLogin();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.googleLoginReset)));
  }

  Future<void> _sendTestNotification(BuildContext context) async {
    final l10n = context.l10n;
    final sent = await services.reportController.sendTestNotification();
    if (!context.mounted) {
      return;
    }

    final message = sent
        ? l10n.testNotificationSent
        : services.reportController.lastNotificationError ??
              l10n.testNotificationFailed;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
