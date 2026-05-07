# Agent Instructions

## Project Rules

- Work in `/Users/karam/Documents/classroom`.
- At the start of every session, read only `PROJECT_CONTEXT.md`, `TODO.md`, `CHANGELOG.md`, `README.md`, `RUNBOOK.md`, and `MEMORY.md`, then inspect only task-specific files.
- Never reread the whole project unless the memory files are missing, architecture is unclear, a serious bug cannot be localized, or the user explicitly asks for a full review.
- Develop incrementally: keep edits focused, avoid unrelated refactors, and prefer small changes to existing files.
- Make minimal, reviewable changes.
- Do not commit or push unless the user explicitly asks.
- Do not read, print, or commit `assets/credentials.json` or `credentials.json`.
- Do not add `assets/credentials.json` back to Flutter assets. Release builds must inject it with `GOOGLE_CREDENTIALS_BASE64` so it is compiled into the binary.
- Keep `.gitignore` protections for credentials, local state, `build/`, and `dist/`.

## Feature Completion Handoff Rule

- After every feature/request is fully implemented and verification has been attempted, update the short memory files before the final response.
- Update `PROJECT_CONTEXT.md` when systems or architecture changed.
- Update `TODO.md` when task status or pending runtime checks changed.
- Update `CHANGELOG.md` with a short note.
- Treat documentation handoff as part of the definition of done, especially before ending a long turn that could be compacted or run out of tokens.
- Handoff notes must be enough for the next session to continue without rereading the whole conversation, but must never include credentials, tokens, client secrets, or credential file contents.

## Classroom Safety

- This app must stay logically read-only.
- Google sign-in currently requests only the approved scopes for courses, coursework, and rosters. Do not re-add profile email or topics permissions unless the Google consent screen is approved for them.
- Allowed Classroom calls currently implemented:
  - `userProfiles.get("me")`
  - `courses.list(teacherId: "me")`
  - `courses.students.list(courseId)`
  - `courses.topics.list(courseId)` exists but should not be called by the report path without an approved topics permission.
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

For distributable macOS builds with Google sign-in configured, use `zsh tool/build_macos_with_credentials.sh`. Plain `flutter build macos` is still useful for compile verification but intentionally does not embed the local Google connection file.
When packaging a local ZIP under `dist/`, keep it untracked because it contains the compiled-in Google connection configuration.

For macOS runtime checks:

```bash
flutter run -d macos
```

Expected runtime behavior: app starts hidden in the menu bar, close hides the report window, tray Quit exits.
On macOS, opening the report should show a Dock icon and hiding the report should remove it again.

## Current Architecture Notes

- `ReportController` owns shared report state for the tray and main window.
- `ReportController.refreshReport()` loads profile, active teacher classes, class rosters, teacher-owned assignments, and turned-in submissions without requesting email fields or topic names.
- `ReportService` must still key coursework by both class id and coursework id before matching submissions.
- Submitted date should come from `TURNED_IN` state history when available and should drive default row ordering.
- The main table should keep sortable columns and default to the current submitted year. Settings should choose either current year or all years.
- Compact desktop widths must not show Flutter overflow stripes. Prefer ellipsized dropdown text, shorter action labels, and regression widget tests.
- Any live UI timer must be scoped to the widget lifecycle and cancelled in `dispose()`.
- Teacher-facing UI uses in-repo localization for English, Ukrainian, and Russian. Default follows the operating system language; Settings can override it.
- Add new teacher-facing strings through `AppLocalizations` and keep language regression coverage when changing core labels.
- Notification delivery stays behind `NotificationService`; macOS uses the native `classroom_notifications` channel in `macos/Runner/AppDelegate.swift`.
- Use Settings > Send test notification as the runtime notification permission/delivery check.
- `ReportCacheService` owns the local report cache. Save it only after successful refreshes, clear it on Google login reset, and never store Google credentials in it.
- Startup should restore cached rows/classes/profile first, then only run an immediate background refresh when the cache is missing or stale.
- Tray "Check Now" must call `ReportController.refreshReport()`.
- Tray "Export CSV" must call `ReportController.exportCsv()` so it refreshes first when no report has loaded.
- Main-window CSV export should only be enabled when the current filtered rows list is non-empty.
- CSV export defaults to `classroom-ungraded-report.csv` and must use the `csv` package for field escaping.
- `SettingsService` owns the automatic-check toggle and persisted lightweight state.
- Automatic checks run every 30 minutes only when signed in and `autoCheckEnabled` is true.
- Notifications are optional and routed through `NotificationService`.
- Only background refreshes may trigger notifications, and only when the filtered visible count increases beyond both the previous successful filtered count and the last notified filtered count.
- Notification counts should follow persisted report filters: remembered class and year display scope. Search text is not part of notification filtering.
- Reset the filtered notification marker when class or year scope changes.
- Failed refreshes must keep the previous count and surface a friendly stored error.
