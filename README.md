# classroom_ungraded_checker

A Flutter desktop tray/menu bar app skeleton for checking ungraded Google Classroom submissions.

## Current scope

- macOS and Windows desktop project files are generated.
- macOS is configured as a menu bar accessory app with the main window hidden by default.
- Tray/menu actions open a compact report, settings, and diagnostics window.
- Google browser sign-in is implemented for desktop.
- Signed-in access is restored locally on app startup.
- Classroom write operations are not implemented.
- CSV export currently builds CSV text only; file writing is intentionally disabled.

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
