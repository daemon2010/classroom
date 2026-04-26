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

## Current Behavior

- Google browser sign-in is implemented for desktop.
- Saved sign-in access is restored locally on startup.
- The app can load the signed-in teacher profile with `userProfiles.get("me")`.
- The app can load active teacher classes with `courses.list(teacherId: "me", courseStates: ["ACTIVE"])`.
- The app can load class rosters with `courses.students.list(courseId)` to show student names and emails.
- The app can load course topics with `courses.topics.list(courseId)`.
- The app can load assignment coursework with `courses.courseWork.list(courseId)` and keeps only items where `creatorUserId == myProfile.id` and `workType == "ASSIGNMENT"`.
- The app can load turned-in submissions with `courses.courseWork.studentSubmissions.list(courseId, courseWorkId, states: ["TURNED_IN"])`.
- Report rows include only turned-in submissions for teacher-owned assignments where no assigned or draft grade is present.
- The earlier `0` result was expected before this read path existed because `listStudentSubmissions()` returned an empty list.
- The class dropdown includes "All classes" plus the active classes returned by Google Classroom.
- The tray/menu label is updated with the signed-in teacher name when available.
- The tray "Check Now" action runs the shared report refresh.
- If already signed in and automatic checking is enabled, startup runs a background refresh and updates the tray count when it finishes.
- The "Check automatically every 30 minutes" setting defaults to on. Turning it off stops startup/background refresh, but manual checks still work.
- Background refreshes are guarded by `ReportController`, so multiple refreshes do not run in parallel.
- Failed refreshes keep the previous successful count, store a friendly error, and set the tray tooltip to `Last check failed. Open app for details.`
- Optional desktop notifications use `local_notifier` and are off by default.
- When notification setting is on, a background refresh notifies only if the new ungraded count is higher than the previous successful count.
- The app does not notify repeatedly for the same count.
- The app stores the last successful count, last notified count, last checked time, last selected class, turned-in filter, table column settings, and friendly error locally.
- Settings include the turned-in-only filter, automatic check toggle, notification toggle, last-class memory, student email column, and late column.
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
- Updated At
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
- Exercise the tray export path with real submission rows.
- Runtime validation of desktop notification permissions and delivery.
- Add Windows tray verification from the same codebase.

## Latest Verification

- `dart format lib test` - passed.
- `flutter analyze` - passed.
- `flutter test` - passed.
- `flutter build macos` - passed.
