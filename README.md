# classroom_ungraded_checker

A Flutter desktop tray/menu bar app for checking ungraded Google Classroom submissions.

## Current scope

- macOS and Windows desktop project files are generated.
- macOS is configured as a menu bar accessory app with the main window hidden by default.
- The current macOS release executable builds as universal `x86_64` and `arm64`; one bundled `objective_c.framework` is currently `arm64` only and should be resolved or Intel-tested before distribution.
- Tray/menu actions open the report, run checks, export CSV, sign in, open settings, and quit through shared app state.
- If already signed in and automatic checking is enabled, the app runs a background refresh on startup and every 30 minutes.
- Optional desktop notifications can alert when a background check finds a higher ungraded count.
- Google browser sign-in is implemented for desktop.
- Signed-in access is restored locally on app startup.
- Google Classroom profile, active teacher course, roster, topic, teacher-owned assignment, and turned-in student submission reads are implemented.
- Report rows are built from turned-in submissions with no assigned or draft grade.
- Report rows sort by submitted date by default, table columns are sortable, and the main view defaults to the current submitted year with multi-year selection available.
- Classroom write operations are not implemented and must stay unwired.
- CSV export saves UTF-8 CSV through a desktop save dialog with `classroom-ungraded-report.csv` as the default filename.
- The app stores the last successful count, last notified count, last checked time, last selected class, table column settings, and turned-in filter setting locally.

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

## Handoff discipline

After each feature/request is fully implemented and verification has been attempted, update the Markdown handoff files before closing the task. This is part of the definition of done.

`MEMORY.md` should always reflect what changed, what is still pending, verification commands/results or gaps, and runtime caveats so work can continue after context compaction or token exhaustion. Update `README.md`, `RUNBOOK.md`, `AGENTS.md`, and `SKILLS.md` too when behavior, setup, architecture, dependencies, or workflow changes.
