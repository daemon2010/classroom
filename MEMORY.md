# Project Memory

## Status

This repo contains a Flutter desktop app named `classroom_ungraded_checker`.

Implemented:

- macOS menu bar and Windows-ready tray shell using `tray_manager`.
- Current macOS release executable is universal `x86_64 arm64`; bundled `objective_c.framework` reports `arm64` only and needs follow-up before a clean universal release claim.
- Window lifecycle using `window_manager`; startup hides the main window and close hides instead of quitting.
- On macOS, opening the report switches the app into Dock-visible mode; hiding the report returns it to menu-bar-only mode.
- Desktop Google sign-in in the system browser.
- Local sign-in restore with `shared_preferences`.
- macOS network entitlements for Google sign-in.
- Compact main window UI with status, actions, class filter, summaries, and report table.
- Teacher profile read with `classroom.userProfiles.get("me")`.
- Active teacher class read with paginated `classroom.courses.list(teacherId: "me")`.
- Class roster read with paginated `classroom.courses.students.list(courseId)`.
- Course topic read with paginated `classroom.courses.topics.list(courseId)`.
- Teacher-owned assignment read with paginated `classroom.courses.courseWork.list(courseId)`.
- When Settings is set to current year, the refresh path only requests submissions for teacher-owned assignments whose creation, update, or due date falls in the current year.
- Assignment filtering by `creatorUserId == myProfile.id` and `workType == "ASSIGNMENT"`.
- Turned-in student submission read with paginated `classroom.courses.courseWork.studentSubmissions.list(courseId, courseWorkId, states: ["TURNED_IN"])`.
- Submitted date extraction from submission state history, falling back to update time if no state timestamp is returned.
- Report rows now include turned-in submissions for teacher-owned assignments when both assigned grade and draft grade are unset.
- Report rows sort newest submitted first by default, and main-window table columns are sortable.
- Main-window rows default to the current submitted year; Settings can switch display/retrieval scope between current year and all years.
- Main-window status includes a live `Now` clock and recomputes last-checked age every second while mounted.
- Interface localization supports Ukrainian, English, and Russian. Ukrainian is the default language, with a Settings override persisted in `shared_preferences`; "System language" still follows the operating system when supported.
- Localized surfaces include the main window, settings, diagnostics, tray/menu labels/tooltips, and desktop notification text where practical. Some service-level error strings remain English.
- Runtime window/tray titles and notification app name use teacher-friendly localized names. Native macOS/Windows metadata uses teacher-friendly names instead of `classroom_ungraded_checker`.
- The macOS release product name is `Перевірка Classroom.app`, which is the name the Dock tooltip should use.
- The macOS Dock icon and Windows taskbar icon use the same transparent artwork as the normal tray icon.
- Student names/emails are resolved from class rosters.
- The report builder keys coursework by class and work id so matching cannot cross between classes.
- Status/filter/action layout was tightened to avoid the debug overflow stripe seen in compact windows.
- Class dropdowns now use expanded/ellipsized selected text, and compact action buttons use shorter labels below narrow widths.
- Widget coverage includes a compact filter layout regression test with a long class name.
- Course dropdown population from active classes.
- Shared report controller used by the tray and main window.
- `ReportCacheService` stores the last successful profile, classes, rows, and checked time in the app support directory as `cache.json`.
- Startup restores cached rows/classes/profile for the signed-in teacher before the window/tray render, so the tray count and report are available without scanning every class again.
- Startup only runs an immediate background refresh when automatic checking is enabled and the cached check is missing or older than the configured interval.
- Tray "Check Now" runs a real refresh. Periodic background refresh runs only when signed in and automatic checking is enabled.
- Automatic checking defaults to on with a 30-minute interval. Settings can change the interval to 5, 10, 15, 30, or 60 minutes, and the background timer is reconfigured through the existing settings listener.
- Refresh failures keep the previous successful count and store a friendly error for the main window and tray tooltip.
- Desktop notifications are implemented behind `NotificationService`; macOS uses a native `UNUserNotificationCenter` bridge and Windows/Linux still use `local_notifier`.
- Notification logic only runs for background refreshes when the filtered visible count increases and has not already notified for that filter/count.
- Notification counts respect the persisted report filters: selected class when remembered and the year display scope. The default notification year is the current year.
- Changing class or year scope resets the filtered notification marker so counts from another filter cannot suppress a new alert.
- Settings includes "Send test notification" to request/check macOS notification permission and verify delivery without waiting for a new Classroom count.
- Local state persists the automatic check interval, last successful total and filtered counts, last notified filtered count, last checked time, last selected class, year display scope, table column settings, and last friendly error.
- The report cache contains local Classroom report data such as student names/emails and assignment links, but no Google credentials or sign-in secrets.
- Tray export uses the currently loaded rows and refreshes first if no report has been loaded.
- CSV export writes UTF-8 CSV through the desktop save dialog using the default filename `classroom-ungraded-report.csv`.
- CSV rows include student, class, subject, assignment, state, late flag, timestamps, points, and links.

Last verification:

- `dart format lib test` - passed.
- `flutter analyze` - passed.
- `flutter test` - passed, including compact layout and Ukrainian language regression coverage.
- `flutter build macos` - passed.
- Built macOS `Info.plist` was checked: `CFBundleDisplayName` is `Перевірка Classroom`, `CFBundleExecutable` is `Перевірка Classroom`, `CFBundleName` is `Classroom Ungraded Checker`, and `AppIcon.icns` is present.
- `git diff --check` - passed.

Still pending:

- Runtime validation against the user's real Classroom data after pressing "Check Now".
- Runtime validation that second app launch restores the cached report without running an immediate full Classroom scan when the cache is fresh.
- Runtime validation of CSV export once real submission rows are available.
- Runtime validation that changing the automatic check interval reconfigures the next background refresh.
- Runtime validation of notification banner delivery through Settings > Send test notification.
- Runtime validation of Dock/taskbar title and transparent icon from a fresh installed build. If macOS still shows an old icon, clear the Dock icon cache or remove the old Dock item before re-adding the app.
- Resolve or validate the bundled `objective_c.framework` `arm64`-only caveat for Intel Mac distribution.
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
