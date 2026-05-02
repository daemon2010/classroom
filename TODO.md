# TODO

- Runtime-check current-year scope against real Classroom data; tray count should not show all-years total unless Settings is set to All years.
- Runtime-check macOS Dock icon appears when opening the report and disappears when hiding/closing it.
- Runtime-check the Dock/taskbar app title and transparent icon after installing/running a fresh build; clear macOS Dock icon cache if it still shows an older cached icon.
- Runtime-check Settings > Send test notification.
- Runtime-check cached second launch avoids immediate full Classroom scan when cache is fresh.
- Runtime-check that changing the automatic check interval reconfigures the background timer.
- Validate CSV export with real rows.
- Resolve or validate bundled `objective_c.framework` arm64-only caveat before claiming clean universal macOS release.
- Verify Windows tray behavior later.

Current working tree note: uncommitted feature changes exist for year-scope filtering, Dock visibility, removal of turned-in UI filter, and related docs/tests.
