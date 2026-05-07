# Project Context

- Flutter desktop tray/menu app for Google Classroom ungraded submissions.
- macOS is primary. Windows tray support should remain possible from same codebase.
- App starts hidden in menu bar/tray. Report window is compact desktop UI.
- `ReportController` owns shared report state for tray and main window.
- `ClassroomApiService` is read-only. Do not add create, patch, delete, return, grade, or submission-modifying calls.
- Google sign-in currently requests only the approved Classroom scopes: courses readonly, coursework students, and rosters readonly.
- Google Desktop app credentials are no longer loaded as a Flutter asset. Release builds should pass `GOOGLE_CREDENTIALS_BASE64` at compile time, usually through `tool/build_macos_with_credentials.sh` or `tool/build_windows_with_credentials.ps1`, so the credentials are compiled into the app binary and not copied as a loose asset.
- Local distributable archives are written to ignored `dist/` because packaged builds contain the compiled-in Google connection configuration.
- The app no longer requests profile email or topics permissions. Teacher and student email fields are not requested; assignment subject/topic names are left blank unless a future approved scope restores them.
- Core Classroom rule: include only coursework where `courseWork.creatorUserId == myProfile.id`.
- Report rows currently come from turned-in submissions with no assigned or draft grade.
- `ReportCacheService` stores last successful profile/classes/rows in local app support `cache.json`; never store Google credentials there.
- Settings own local lightweight state: auto check, configurable check interval, notifications, remembered class, year display scope, visible columns, counts, and errors.
- Year display scope is `Current year` by default or `All years`; tray count, report rows, notifications, and refresh scope should follow it.
- macOS Dock visibility is toggled through the native `classroom_dock` channel when the report window opens/hides.
- Notifications are behind `NotificationService`; macOS uses the native `classroom_notifications` channel.
- Localization is in `lib/l10n/` for Ukrainian, English, and Russian; Ukrainian is the default language.
- Runtime window/tray titles use the selected language. Native macOS/Windows metadata uses teacher-friendly names instead of `classroom_ungraded_checker`; macOS release product name is `Перевірка Classroom.app`.

Session rule: at the start of every future session, read only this file, `TODO.md`, `CHANGELOG.md`, `README.md`, `RUNBOOK.md`, and `MEMORY.md`, then inspect only files needed for the task.
