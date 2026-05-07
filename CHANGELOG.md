# Changelog

## Unreleased

- Stopped bundling `assets/credentials.json` as a loose Flutter asset; Google Desktop app credentials are now supplied through a build-time define so release binaries can contain the configuration directly.
- Added a sign-in-capable macOS production build flow and packaged the release app as an ignored local ZIP under `dist/`.
- Made the Windows credential build helper validate the Google Desktop app file, clean first, and pass credentials through direct `--dart-define` for a more reliable sign-in-capable `.exe`.
- Limited Google sign-in to the currently approved Classroom scopes and stopped requesting profile/student email fields or topic names.
- Changed the default interface language to Ukrainian and updated runtime/native app titles to teacher-friendly names.
- Renamed the macOS release product to `Перевірка Classroom.app` so the Dock tooltip no longer shows `classroom_ungraded_checker`.
- Aligned macOS and Windows launch icons with the normal tray icon artwork and regenerated them with transparent borders.
- Added a configurable automatic refresh interval in Settings with persisted 5, 10, 15, 30, and 60 minute choices.
- Added lightweight project memory files for incremental sessions: `PROJECT_CONTEXT.md`, `TODO.md`, and `CHANGELOG.md`.
- Adopted future-session rule: read only the three memory files first, then inspect task-specific files only.
