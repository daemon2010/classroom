# Agent Instructions

## Project Rules

- Work in `/Users/karam/Documents/classroom`.
- Make minimal, reviewable changes.
- Do not commit or push unless the user explicitly asks.
- Do not read, print, or commit `assets/credentials.json` or `credentials.json`.
- Keep `.gitignore` protections for credentials, local state, and `build/`.

## Classroom Safety

- This app must stay logically read-only.
- Allowed Classroom calls currently implemented:
  - `userProfiles.get("me")`
  - `courses.list(teacherId: "me")`
  - `courses.topics.list(courseId)`
  - `courses.courseWork.list(courseId)`
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
- Tray "Check Now" must call `ReportController.refreshReport()`.
- Tray "Export CSV" must call `ReportController.exportCsv()` so it refreshes first when no report has loaded.
- Main-window CSV export should only be enabled when the current filtered rows list is non-empty.
- CSV export defaults to `classroom-ungraded-report.csv` and must use the `csv` package for field escaping.
