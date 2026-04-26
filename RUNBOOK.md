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
- The app can load course topics with `courses.topics.list(courseId)`.
- The app can load assignment coursework with `courses.courseWork.list(courseId)` and keeps only items where `creatorUserId == myProfile.id` and `workType == "ASSIGNMENT"`.
- The class dropdown includes "All classes" plus the active classes returned by Google Classroom.
- The tray/menu label is updated with the signed-in teacher name when available.
- The tray "Check Now" action runs the shared report refresh.
- If already signed in, startup runs a background refresh and updates the tray count when it finishes.
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

## Known Pending Work

- Implement student submission reads and roster/profile lookups.
- Exercise the tray export path after submission rows exist.
- Add Windows tray verification from the same codebase.
