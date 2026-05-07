# classroom_ungraded_checker

A Flutter desktop tray/menu bar app for checking ungraded Google Classroom submissions.

## Current scope

- macOS and Windows desktop project files are generated.
- macOS is configured as a menu bar accessory app with the main window hidden by default.
- Opening the report on macOS makes the app appear in the Dock; hiding the report returns it to menu-bar-only mode.
- The current macOS release app builds as universal `x86_64` and `arm64`.
- Tray/menu actions open the report, run checks, export CSV, sign in, open settings, and quit through shared app state.
- If already signed in, the app restores the last successful report from a local cache on startup.
- If automatic checking is enabled, startup only scans Classroom immediately when the cache is missing or older than the configured check interval; otherwise the next periodic check handles refresh.
- Optional desktop notifications can alert when a background check finds a higher filtered ungraded count.
- macOS notifications use a native notification bridge and Settings includes a test notification action.
- Google browser sign-in is implemented for desktop.
- Signed-in access is restored locally on app startup.
- Google sign-in is limited to the currently approved Classroom permissions: classes, coursework, and rosters.
- Google Classroom profile, active teacher course, roster, teacher-owned assignment, and turned-in student submission reads are implemented.
- Teacher/student email fields and topic names are not requested in the current permission set.
- Report rows are built from turned-in submissions with no assigned or draft grade.
- Report rows sort by submitted date by default, table columns are sortable, and Settings controls whether the app displays current-year work or all years.
- The main status area includes a live `Now` clock and updates last-checked age while the window is open.
- Interface localization supports Ukrainian, English, and Russian. Ukrainian is the default, Settings can override the interface language, and the "System language" option follows the operating system when supported.
- Runtime window/tray titles and notification app name use teacher-friendly localized names, while native app metadata avoids `classroom_ungraded_checker`.
- The macOS Dock icon and Windows taskbar icon use the same transparent artwork as the normal tray icon.
- Google Desktop app credentials are supplied at build time and compiled into release binaries; `assets/credentials.json` is not bundled as a loose Flutter asset.
- Classroom write operations are not implemented and must stay unwired.
- CSV export saves UTF-8 CSV through a desktop save dialog with `classroom-ungraded-report.csv` as the default filename.
- The app stores the automatic check interval, last successful total and filtered counts, last notified filtered count, last checked time, last selected class, year display scope, and table column settings locally.
- The app also stores a local report cache in the app support directory. It contains report data such as student names and links, but no Google credentials.

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

Run local checks:

```bash
flutter pub get
flutter analyze
flutter test
```

Build macOS with the Google connection file compiled into the app:

```bash
zsh tool/build_macos_with_credentials.sh
```

Create a distributable ZIP after building:

```bash
ditto -c -k --keepParent "build/macos/Build/Products/Release/Перевірка Classroom.app" "dist/Перевірка Classroom-macos-universal.zip"
```

`dist/` is ignored because packaged builds contain the compiled-in Google connection configuration. This local build is ad-hoc signed; public distribution should use Developer ID signing and notarization.

On Windows, build with:

```powershell
powershell -ExecutionPolicy Bypass -File tool\build_windows_with_credentials.ps1
```

Then launch the built executable from:

```text
build\windows\x64\runner\Release\classroom_ungraded_checker.exe
```

For a local macOS debug run with sign-in configured:

```bash
zsh tool/run_macos_with_credentials.sh
```

## Handoff discipline

After each feature/request is fully implemented and verification has been attempted, update the Markdown handoff files before closing the task. This is part of the definition of done.

`MEMORY.md` should always reflect what changed, what is still pending, verification commands/results or gaps, and runtime caveats so work can continue after context compaction or token exhaustion. Update `README.md`, `RUNBOOK.md`, `AGENTS.md`, and `SKILLS.md` too when behavior, setup, architecture, dependencies, or workflow changes.
