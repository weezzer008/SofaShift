# SofaShift Security Notes

SofaShift is a local Windows desktop automation tool. It does not require an account and does not intentionally send telemetry or logs over the network.

## Supported Build

Only the latest `SofaShift-Setup.exe` attached to the GitHub release is supported.

Do not use GitHub's automatically generated `Source code (zip)` or `Source code (tar.gz)` downloads as installers.

## Runtime Model

The setup wizard writes a data-only configuration file. The background watcher is registered as a per-user scheduled task. It watches local controller presence, switches displays/audio, and launches optional local applications selected by the user.

The setup EXE runs without administrator rights by default. SofaShift installs per-user files, a per-user startup task, and an HKCU uninstall entry; it does not install a system service.

FRL Toggle may require administrator rights on some machines because it can affect driver settings. If FRL cannot apply, the watcher logs the failure and continues.

## Third-Party Tools

SofaShift supports optional tools such as NirCmd, Playnite, Hue Sync, and FRL Toggle. When you click an install action in the wizard, SofaShift resolves the upstream download, stages it locally, shows SHA256/signature information, and asks for confirmation before launching or placing the tool. The wizard also provides official-page links when you prefer to download and select a local executable yourself.

Users should verify third-party downloads from the original publisher before installing or selecting them in SofaShift.

## Logs And Privacy

`controller_watch.log` and `SofaShift_debug.log` may include local file paths, audio device names, display identifiers, controller hardware IDs, and controller container IDs. Redact those fields before sharing logs publicly.

## Reporting Vulnerabilities

Please report suspected vulnerabilities privately to the maintainer before posting exploit details publicly. Include the SofaShift version, Windows version, whether PowerShell was repaired or installed during setup, reproduction steps, and redacted logs.
