# SofaShift v1.0.1

SofaShift v1.0.1 is a stability, safety, and trust-focused patch release. It updates the setup/runtime model so SofaShift runs without administrator rights by default, improves how display profiles stay bound to the intended physical display, and adds stronger review steps around optional third-party downloads.

## Release Notes

- Setup wizard now runs unelevated by default.
- Background watcher now registers as a per-user, unelevated startup task.
- Display profiles now preserve and re-resolve saved physical display identity more carefully.
- Optional tool downloads now show SHA256/signature details before launch or placement.
- ZIP handling now checks for unsafe archive entries before extraction.
- README and security docs were updated to match the new install/runtime behavior.
- Installer version updated to `1.0.1.0`.
- Windows uninstall metadata updated to `1.0.1`.

## Bug Fix Notes

- Fixed elevated scheduled-task behavior so SofaShift no longer runs user-writable watcher/config paths at high integrity by default.
- Fixed stale display-target assumptions by resolving saved CCD display targets using device path/friendly identity instead of relying only on changing target IDs.
- Fixed unsafe profile application behavior by skipping a saved profile when its physical display target is unavailable instead of applying it to a different HDMI/display target.
- Fixed optional installer flow so downloaded executables are reviewed before being launched.
- Fixed GitHub release download resolution to honor configured asset matching.
- Fixed portable/ZIP install flow to reject unsafe archive paths and overly large entries.
- Fixed saved profile export/import consistency by preserving `TargetDisplay`.
- Fixed UI behavior around unavailable saved displays by marking them clearly instead of silently falling back.
- Fixed uninstall/task messaging for older elevated task registrations.
- Fixed documentation references that still described admin-first install behavior.

## Installer

- Asset: `SofaShift-Setup.exe`
- SHA256: `434e7be5e744cd8f88e93d8e379e52653c3f699c937b65facd56427c1044e70e`
