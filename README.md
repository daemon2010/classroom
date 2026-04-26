# classroom_ungraded_checker

A Flutter desktop tray/menu bar app for checking ungraded Google Classroom submissions.

## Current scope

- macOS and Windows desktop project files are generated.
- macOS is configured as a menu bar accessory app with the main window hidden by default.
- Tray/menu actions open the report, run checks, export CSV, sign in, open settings, and quit through shared app state.
- If already signed in, the app runs a background refresh on startup and updates the tray count.
- Google browser sign-in is implemented for desktop.
- Signed-in access is restored locally on app startup.
- Google Classroom profile, active teacher course, topic, and teacher-owned assignment reads are implemented.
- Classroom submission reads are still pending.
- Classroom write operations are not implemented and must stay unwired.
- CSV export saves UTF-8 CSV through a desktop save dialog with `classroom-ungraded-report.csv` as the default filename.

## Core report rule

Reports must include only assignments created by the authenticated teacher:

```dart
courseWork.creatorUserId == myProfile.id
```

Assignments created by other teachers in the same Classroom are excluded.

## Local setup

Place the Google desktop app connection file at:

```text
assets/credentials.json
```

That file is ignored by git.

Run:

```bash
flutter pub get
flutter analyze
flutter test
flutter build macos
```
