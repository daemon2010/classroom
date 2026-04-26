# Project Skills

## Desktop Shell

- Initialize `window_manager` before app startup.
- Initialize `tray_manager` with menu actions for report, check, export, sign-in, settings, and quit.
- Hide the main window on startup.
- Hide on close; only tray Quit exits.
- Route tray actions through `ReportController` so menu and window state stay in sync.

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
- Use `ClassroomApiService.listCourseTopics(courseId)` for topic names.
- Use `ClassroomApiService.listMyAssignments(courseId: ..., myUserId: ...)` for assignment coursework.
- Never bypass the `creatorUserId == myProfile.id` filter when loading assignments.
- Keep write-capable scope usage logically read-only.

## Report Logic

- Build report rows only from coursework created by the authenticated teacher.
- Use `ReportController.refreshReport()` for Check Now, startup refresh, and refresh-before-export.
- Use `ReportController.exportCsv()` for tray export so it refreshes first when needed.
- Enable main-window CSV export only when visible report rows exist.
- Export UTF-8 CSV through `file_selector` with default filename `classroom-ungraded-report.csv`.
- Use the `csv` package for all CSV field escaping.
- Keep UI labels teacher-friendly.
- Avoid teacher-facing technical words: API, OAuth, token, scope, JSON, endpoint.
