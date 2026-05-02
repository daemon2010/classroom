# Classroom Ungraded Checker Runbook

## Local Setup

Place the Google Desktop app connection file at:

```text
assets/credentials.json
```

That file is ignored by git. Do not print or commit it.

Install and verify:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build macos
```

Run on macOS:

```bash
flutter run -d macos
```

The app hides the main window on startup and appears in the macOS menu bar. Use the menu bar icon to open the report window.

When launching for a local runtime check, remember the first visible surface is the tray/menu bar icon, not the main window.

Check macOS build architectures:

```bash
lipo -info build/macos/Build/Products/Release/classroom_ungraded_checker.app/Contents/MacOS/classroom_ungraded_checker
```

The current macOS release app builds as `Перевірка Classroom.app`. The main executable was previously universal (`x86_64 arm64`), but re-check after native product-name/icon changes before distribution. A bundled `objective_c.framework` currently reports `arm64` only, so clean Intel distribution still needs follow-up or direct Intel Mac validation.

## Current Behavior

- Google browser sign-in is implemented for desktop.
- Saved sign-in access is restored locally on startup.
- The app can load the signed-in teacher profile with `userProfiles.get("me")`.
- The app can load active teacher classes with `courses.list(teacherId: "me", courseStates: ["ACTIVE"])`.
- The app can load class rosters with `courses.students.list(courseId)` to show student names and emails.
- The app can load course topics with `courses.topics.list(courseId)`.
- The app can load assignment coursework with `courses.courseWork.list(courseId)` and keeps only items where `creatorUserId == myProfile.id` and `workType == "ASSIGNMENT"`.
- When Settings is set to current year, the app only requests submissions for teacher-owned assignments whose creation, update, or due date is in the current year.
- The app can load turned-in submissions with `courses.courseWork.studentSubmissions.list(courseId, courseWorkId, states: ["TURNED_IN"])`.
- Submitted date is taken from the latest `TURNED_IN` state history timestamp when available, with submission update time as a fallback.
- Report rows include only turned-in submissions for teacher-owned assignments where no assigned or draft grade is present.
- Report rows are sorted newest submitted first by default.
- The main table columns are sortable.
- The main view filters to the current submitted year by default. Settings can switch display/retrieval scope between current year and all years.
- The main status area shows a live `Now` clock and refreshes the last-checked age every second while the report window is open.
- Interface language supports Ukrainian, English, and Russian through `lib/l10n/`. Ukrainian is the default setting. Settings includes a manual selector, plus "System language" for following the operating system when supported.
- The main window, settings, diagnostics, tray/menu text, and notification text use the selected interface language where practical. Service-level error strings may still be English.
- Runtime window/tray titles and notification app name use teacher-friendly localized names. Native macOS/Windows metadata uses teacher-friendly names instead of `classroom_ungraded_checker`.
- The macOS release product name is `Перевірка Classroom.app`, which is the name the Dock tooltip should use.
- The macOS Dock icon and Windows taskbar icon use the same transparent artwork as the normal tray icon.
- Compact window layouts shorten action labels and expand dropdown text safely to avoid Flutter overflow stripes.
- The earlier `0` result was expected before this read path existed because `listStudentSubmissions()` returned an empty list.
- The class dropdown includes "All classes" plus the active classes returned by Google Classroom.
- The tray/menu label is updated with the signed-in teacher name when available.
- The tray "Check Now" action runs the shared report refresh.
- If already signed in, startup first restores the last successful report from `ReportCacheService`.
- The report cache is stored in the app support directory as `cache.json` and includes profile, classes, report rows, and checked time. It does not store Google credentials.
- If automatic checking is enabled, startup only runs an immediate background refresh when the cache is missing or older than the configured interval.
- The "Check automatically" setting defaults to on, and the check interval defaults to 30 minutes. Settings lets the teacher choose 5, 10, 15, 30, or 60 minutes. Turning automatic checks off stops startup/background refresh, but manual checks still work.
- Background refreshes are guarded by `ReportController`, so multiple refreshes do not run in parallel.
- Failed refreshes keep the previous successful count, store a friendly error, and set the tray tooltip to `Last check failed. Open app for details.`
- Optional desktop notifications are off by default. macOS uses the native `UNUserNotificationCenter` bridge; Windows/Linux use `local_notifier`.
- Settings includes "Send test notification" to request/check OS permission and verify notification delivery.
- When notification setting is on, a background refresh notifies only if the filtered visible count is higher than the previous successful filtered count.
- Notification counts respect the remembered class filter and the year display scope. By default, notifications count only current-year submissions.
- The app does not notify repeatedly for the same filter/count.
- Changing class or year scope clears the filtered notification marker so a previous all-years count cannot suppress current-year notifications.
- The app stores the automatic check interval, last successful total and filtered counts, last notified filtered count, last checked time, last selected class, year display scope, table column settings, and friendly error locally.
- Settings include the year display scope, automatic check toggle, automatic check interval, notification toggle, last-class memory, student email column, and late column.
- On macOS, opening the report switches the app to Dock-visible mode; hiding the report switches it back to menu-bar-only mode.
- The tray tooltip shows sign-in required, last check failed, or `Ungraded works: X. Last checked: HH:mm`.
- The tray attention icon is used only when the ungraded count is greater than zero.
- The tray "Export CSV" action exports current loaded rows, refreshing first if no report has been loaded.
- CSV export saves UTF-8 CSV through a desktop save dialog. The default filename is `classroom-ungraded-report.csv`.

## CSV Columns

- Student Name
- Student Email
- Class Name
- Class Section
- Subject
- Assignment
- Submission State
- Late
- Submitted At
- Created At
- Max Points
- Submission Link
- Assignment Link

## Safety Rules

- Keep the app logically read-only.
- Do not call Classroom create, patch, delete, return, grade, or submission-modifying methods.
- Preserve the core report rule:

```dart
courseWork.creatorUserId == myProfile.id
```

- Keep teacher-facing UI free of technical words such as API, OAuth, token, scope, JSON, and endpoint.

## Handoff Rule

- After every feature/request is fully implemented and verification has been attempted, update the Markdown handoff files before the final response.
- Treat this as part of the definition of done, so the next session can continue after context compaction or token exhaustion.
- Always update `MEMORY.md` with what changed, pending work, verification commands/results or gaps, and runtime caveats.
- Update `README.md`, `RUNBOOK.md`, `AGENTS.md`, and `SKILLS.md` when behavior, setup, architecture, dependencies, user workflow, or future-agent workflow changes.
- Never put credentials, tokens, client secrets, or credential file contents in handoff notes.

## Known Pending Work

- Runtime validation against the user's real Classroom data after pressing "Check Now".
- Runtime validation that a second launch restores cached report rows and avoids an immediate full Classroom scan when the cache is fresh.
- Runtime validation that changing the automatic check interval reconfigures the next background refresh.
- Exercise the tray export path with real submission rows.
- Runtime validation of desktop notification delivery through Settings > Send test notification.
- Resolve or validate the `objective_c.framework` `arm64`-only bundle caveat before claiming a clean universal macOS release.
- Add Windows tray verification from the same codebase.

## Latest Verification

- `dart format lib test` - passed.
- `flutter analyze` - passed.
- `flutter test` - passed, including compact filter overflow and Ukrainian language regression tests.
- `flutter build macos` - passed.
- `git diff --check` - passed.
