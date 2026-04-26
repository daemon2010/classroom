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
- Never bypass the `creatorUserId == myProfile.id` filter when loading assignments.
- Keep write-capable scope usage logically read-only.

## Report Logic

- Build report rows only from coursework created by the authenticated teacher.
- Report rows should include only turned-in submissions where both assigned grade and draft grade are unset.
- Key coursework matching by both class id and coursework id.
- Use `ReportController.refreshReport()` for Check Now, startup refresh, and refresh-before-export.
- Gate startup and periodic background refresh with `SettingsService.settings.autoCheckEnabled`.
- Rely on `ReportController` in-flight protection to avoid parallel refreshes.
- Notify on background refresh only when the new ungraded count is higher than the previous count and the last notified count.
- Use `ReportController.exportCsv()` for tray export so it refreshes first when needed.
- Enable main-window CSV export only when visible report rows exist.
- Export UTF-8 CSV through `file_selector` with default filename `classroom-ungraded-report.csv`.
- Use the `csv` package for all CSV field escaping.
- Store last successful count, last notified count, last checked time, last selected class, turned-in filter, table column settings, and last friendly error in `SettingsService`.
- Keep UI labels teacher-friendly.
- Avoid teacher-facing technical words: API, OAuth, token, scope, JSON, endpoint.
