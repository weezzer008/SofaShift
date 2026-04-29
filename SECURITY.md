# SofaShift Security Notes

SofaShift is a local Windows desktop automation tool. It does not require an account and does not intentionally send telemetry or logs over the network.

## Supported Build

Only the latest `SofaShift-Setup.exe` attached to the GitHub release is supported.

Do not use GitHub's automatically generated `Source code (zip)` or `Source code (tar.gz)` downloads as installers.

## Runtime Model

The setup wizard writes a data-only configuration file. The background watcher is registered as a per-user scheduled task. It watches local controller presence, switches displays/audio, and launches optional local applications selected by the user.

The current setup EXE requests administrator rights so it can create the scheduled task with the run level needed for optional FRL Toggle behavior. SofaShift installs per-user files and an HKCU uninstall entry; it does not install a system service.

FRL Toggle may require administrator rights on some machines because it can affect driver settings. If FRL cannot apply, the watcher logs the failure and continues.

## Third-Party Tools

SofaShift supports optional tools such as NirCmd, Playnite, Hue Sync, MonitorSwitcher, and FRL Toggle. When you click an install action in the wizard, SofaShift may download, extract, or launch the selected tool's installer from the configured upstream project or publisher URL. The wizard also provides official-page links when you prefer to download and select a local executable yourself.

Users should verify third-party downloads from the original publisher before installing or selecting them in SofaShift.

## Logs And Privacy

`controller_watch.log` and `SofaShift_debug.log` may include local file paths, audio device names, display identifiers, controller hardware IDs, and controller container IDs. Redact those fields before sharing logs publicly.

## Reporting Vulnerabilities

Please report suspected vulnerabilities privately to the maintainer before posting exploit details publicly. Include the SofaShift version, Windows version, whether PowerShell was repaired or installed during setup, reproduction steps, and redacted logs.
