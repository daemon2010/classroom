# Agent Instructions

## Project Rules

- Work in `/Users/karam/Documents/classroom`.
- Make minimal, reviewable changes.
- Do not commit or push unless the user explicitly asks.
- Do not read, print, or commit `assets/credentials.json` or `credentials.json`.
- Keep `.gitignore` protections for credentials, local state, and `build/`.

## Feature Completion Handoff Rule

- After every feature/request is fully implemented and verification has been attempted, update the project Markdown handoff files before the final response.
- Treat documentation handoff as part of the definition of done, especially before ending a long turn that could be compacted or run out of tokens.
- At minimum, update `MEMORY.md` with what changed, what remains pending, verification commands/results or gaps, and any runtime caveats.
- When behavior, setup, architecture, dependencies, user workflow, or future-agent workflow changes, also update the relevant parts of `README.md`, `RUNBOOK.md`, `AGENTS.md`, and `SKILLS.md`.
- Handoff notes must be enough for the next session to continue without rereading the whole conversation, but must never include credentials, tokens, client secrets, or credential file contents.

## Classroom Safety

- This app must stay logically read-only.
- Allowed Classroom calls currently implemented:
  - `userProfiles.get("me")`
  - `courses.list(teacherId: "me")`
  - `courses.students.list(courseId)`
  - `courses.topics.list(courseId)`
  - `courses.courseWork.list(courseId)`
  - `courses.courseWork.studentSubmissions.list(courseId, courseWorkId)`
- Do not wire create, patch, delete, return, grade, or submission-modifying calls.
- Preserve the report ownership rule:

```dart
courseWork.creatorUserId == myProfile.id
```

## Verification

Before handing off code changes, run:

```bash
dart format lib test
flutter analyze
flutter test
flutter build macos
```

For macOS runtime checks:

```bash
flutter run -d macos
```

Expected runtime behavior: app starts hidden in the menu bar, close hides the report window, tray Quit exits.

## Current Architecture Notes

- `ReportController` owns shared report state for the tray and main window.
- `ReportController.refreshReport()` loads profile, active teacher classes, class rosters, teacher-owned assignments, and turned-in submissions.
- `ReportService` must still key coursework by both class id and coursework id before matching submissions.
- Submitted date should come from `TURNED_IN` state history when available and should drive default row ordering.
- The main table should keep sortable columns and default to the current submitted year, with multi-year selection available.
- Compact desktop widths must not show Flutter overflow stripes. Prefer ellipsized dropdown text, shorter action labels, and regression widget tests.
- Tray "Check Now" must call `ReportController.refreshReport()`.
- Tray "Export CSV" must call `ReportController.exportCsv()` so it refreshes first when no report has loaded.
- Main-window CSV export should only be enabled when the current filtered rows list is non-empty.
- CSV export defaults to `classroom-ungraded-report.csv` and must use the `csv` package for field escaping.
- `SettingsService` owns the automatic-check toggle and persisted lightweight state.
- Automatic checks run every 30 minutes only when signed in and `autoCheckEnabled` is true.
- Notifications are optional and routed through `NotificationService`.
- Only background refreshes may trigger notifications, and only when the count increases beyond both the previous successful count and the last notified count.
- Failed refreshes must keep the previous count and surface a friendly stored error.
