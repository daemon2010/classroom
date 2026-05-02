# Project Skills

## Feature Handoff

- After implementing and attempting to verify a feature/request, update the Markdown handoff files before the final response.
- Treat handoff docs as part of the definition of done, so another session can resume after context compaction or token exhaustion.
- Keep `MEMORY.md` accurate enough to resume without rereading the whole conversation: include changed behavior, changed files/services/settings when useful, pending work, verification commands/results or gaps, and runtime caveats.
- Update `README.md`, `RUNBOOK.md`, `AGENTS.md`, and `SKILLS.md` whenever the feature changes user behavior, setup, architecture, dependencies, verification, or future-agent workflow.
- Never include credentials, tokens, client secrets, or credential file contents in handoff docs.

## Desktop Shell

- Initialize `window_manager` before app startup.
- Initialize `tray_manager` with menu actions for report, check, export, sign-in, settings, and quit.
- Hide the main window on startup.
- Hide on close; only tray Quit exits.
- On macOS, make the app Dock-visible while the report window is open and return to menu-bar-only when hidden.
- Route tray actions through `ReportController` so menu and window state stay in sync.
- Use a single periodic timer for automatic background checks.
- Keep desktop notifications isolated behind `NotificationService`.

## Google Sign-In

- Load the Desktop app connection file from `assets/credentials.json`.
- Open Google sign-in in the system browser.
- Save and restore local sign-in access with `shared_preferences`.
- Refresh access when possible.
- Never log or show secrets or saved sign-in data.

## Classroom Reads

- Use `GoogleAuthService.getAuthClient()` to obtain an authenticated client.
- Use `ClassroomApiService.getMyProfile()` for `userProfiles.get("me")`.
- Use `ClassroomApiService.listTeacherCourses()` for paginated active class loading.
- Use `ClassroomApiService.listCourseStudents(courseId)` once per class to resolve student names/emails.
- Use `ClassroomApiService.listCourseTopics(courseId)` for topic names.
- Use `ClassroomApiService.listMyAssignments(courseId: ..., myUserId: ...)` for assignment coursework.
- Use `ClassroomApiService.listStudentSubmissions(courseId: ..., courseWorkId: ..., studentsById: ...)` for paginated turned-in submission reads.
- Use `TURNED_IN` state history timestamps as submitted dates when Google Classroom returns them.
- Never bypass the `creatorUserId == myProfile.id` filter when loading assignments.
- Keep write-capable scope usage logically read-only.

## Report Logic

- Build report rows only from coursework created by the authenticated teacher.
- Report rows should include only turned-in submissions where both assigned grade and draft grade are unset.
- Default report/table ordering should be newest submitted first.
- Main-window filtering should default to the current submitted year. Settings should choose either current year or all years.
- Table columns should stay sortable when columns are visible.
- Compact controls should use ellipsis/expanded dropdowns and shorter button labels instead of overflowing.
- Add widget tests for compact layouts when fixing UI overflow issues.
- Keep live status clocks scoped to mounted widgets and cancel timers in `dispose()`.
- Use `lib/l10n/app_localizations.dart` and `lib/l10n/app_language.dart` for teacher-facing UI strings.
- Default interface language should follow the operating system when the setting is `system`; Settings may override to English, Ukrainian, or Russian.
- When adding teacher-facing text, localize it unless it is fixed report data or a Google/service diagnostic detail.
- Keep notification delivery behind `NotificationService`; macOS uses the native `classroom_notifications` channel in `macos/Runner/AppDelegate.swift`.
- Keep Settings > Send test notification working when changing notification behavior.
- Key coursework matching by both class id and coursework id.
- Keep `ReportCacheService` as the only local report-cache writer.
- Save the cache only after successful refreshes, clear it on Google login reset, and never store Google credentials in it.
- Startup should restore cached rows/classes/profile before deciding whether a full background refresh is needed.
- Use `ReportController.refreshReport()` for Check Now, startup refresh, and refresh-before-export.
- Gate startup and periodic background refresh with `SettingsService.settings.autoCheckEnabled`.
- Rely on `ReportController` in-flight protection to avoid parallel refreshes.
- Notify on background refresh only when the filtered visible count is higher than the previous filtered count and last notified filtered count.
- Notification counts should follow persisted report filters: remembered class and year display scope. Search text is not part of notification filtering.
- Reset the filtered notification marker when class or year scope changes.
- Use `ReportController.exportCsv()` for tray export so it refreshes first when needed.
- Enable main-window CSV export only when visible report rows exist.
- Export UTF-8 CSV through `file_selector` with default filename `classroom-ungraded-report.csv`.
- Use the `csv` package for all CSV field escaping.
- Store last successful total/filtered counts, last notified filtered count, last checked time, last selected class, year display scope, table column settings, and last friendly error in `SettingsService`.
- Keep UI labels teacher-friendly.
- Avoid teacher-facing technical words: API, OAuth, token, scope, JSON, endpoint.
