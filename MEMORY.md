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
- Tray "Check Now" runs real refresh. Startup and periodic background refresh run only when signed in and automatic checking is enabled.
- Automatic checking defaults to every 30 minutes and is controlled from Settings.
- Refresh failures keep the previous successful count and store a friendly error for the main window and tray tooltip.
- Desktop notifications are implemented behind `NotificationService` using `local_notifier`; the setting defaults to off.
- Notification logic only runs for background refreshes when the ungraded count increases and has not already notified for that count.
- Local state persists the last successful count, last notified count, last checked time, last selected class, turned-in filter, table column settings, and last friendly error.
- Tray export uses the currently loaded rows and refreshes first if no report has been loaded.
- CSV export writes UTF-8 CSV through the desktop save dialog using the default filename `classroom-ungraded-report.csv`.
- CSV rows include student, class, subject, assignment, state, late flag, timestamps, points, and links.

Still pending:

- Submission read implementation.
- End-to-end report rows from Google Classroom.
- Runtime validation of CSV export once submission rows are available.
- Runtime validation of the 30-minute background timer.
- Runtime validation of notification permissions and delivery.
- Windows tray build/runtime verification.

## Important Constraints

- `assets/credentials.json`, `credentials.json`, local sign-in state, and build output must stay ignored.
- Never log or display credentials or saved sign-in data.
- The app requests `classroom.coursework.students`, but must not perform write operations.
- The report must only include assignments created by the authenticated teacher.
- After each feature/request is fully implemented and verification has been attempted, update the Markdown handoff files before the final response so work can resume cleanly if context is compacted or tokens run out.
- Handoff updates are part of the definition of done. Keep `MEMORY.md` current with implemented changes, pending work, verification commands/results or gaps, and runtime caveats.
- Update `README.md`, `RUNBOOK.md`, `AGENTS.md`, and `SKILLS.md` too when behavior, setup, architecture, dependencies, user workflow, or future-agent workflow changes.
- Never include credentials, tokens, client secrets, or credential file contents in Markdown handoff notes.
