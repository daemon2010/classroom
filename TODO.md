# TODO

- Runtime-check current-year scope against real Classroom data; tray count should not show all-years total unless Settings is set to All years.
- Runtime-check Google sign-in after resetting login; consent should list only courses, coursework, and rosters permissions.
- Runtime-check sign-in from the packaged build made with `tool/build_macos_with_credentials.sh`; loose `assets/credentials.json` was already checked absent from the app bundle and ZIP.
- Runtime-check macOS Dock icon appears when opening the report and disappears when hiding/closing it.
- Runtime-check the Dock/taskbar app title and transparent icon after installing/running a fresh build; clear macOS Dock icon cache if it still shows an older cached icon.
- Runtime-check Settings > Send test notification.
- Runtime-check cached second launch avoids immediate full Classroom scan when cache is fresh.
- Runtime-check that changing the automatic check interval reconfigures the background timer.
- Validate CSV export with real rows.
- Add Developer ID signing and notarization before broad macOS distribution.
- Verify Windows tray behavior later.
- Runtime-check updated Windows build helper on Windows; sign-in should be configured after running `powershell -ExecutionPolicy Bypass -File tool\build_windows_with_credentials.ps1`.

Current working tree note: uncommitted feature changes exist for year-scope filtering, Dock visibility, removal of turned-in UI filter, and related docs/tests.
