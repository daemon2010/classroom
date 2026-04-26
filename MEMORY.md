# Project Memory

## Status

This repo contains a Flutter desktop app named `classroom_ungraded_checker`.

Implemented:

- macOS menu bar and Windows-ready tray shell using `tray_manager`.
- Window lifecycle using `window_manager`; startup hides the main window and close hides instead of quitting.
- Desktop Google sign-in in the system browser.
- Local sign-in restore with `shared_preferences`.
- macOS network entitlements for Google sign-in.
- Compact main window UI with status, actions, class filter, summaries, and report table.
- Teacher profile read with `classroom.userProfiles.get("me")`.
- Active teacher class read with paginated `classroom.courses.list(teacherId: "me")`.
- Course topic read with paginated `classroom.courses.topics.list(courseId)`.
- Teacher-owned assignment read with paginated `classroom.courses.courseWork.list(courseId)`.
- Assignment filtering by `creatorUserId == myProfile.id` and `workType == "ASSIGNMENT"`.
- Course dropdown population from active classes.
- Shared report controller used by the tray and main window.
- Tray "Check Now" runs real refresh and startup runs a background refresh when already signed in.
- Tray export uses the currently loaded rows and refreshes first if no report has been loaded.
- CSV export writes UTF-8 CSV through the desktop save dialog using the default filename `classroom-ungraded-report.csv`.
- CSV rows include student, class, subject, assignment, state, late flag, timestamps, points, and links.

Still pending:

- Submission read implementation.
- End-to-end report rows from Google Classroom.
- Runtime validation of CSV export once submission rows are available.
- Windows tray build/runtime verification.

## Important Constraints

- `assets/credentials.json`, `credentials.json`, local sign-in state, and build output must stay ignored.
- Never log or display credentials or saved sign-in data.
- The app requests `classroom.coursework.students`, but must not perform write operations.
- The report must only include assignments created by the authenticated teacher.
