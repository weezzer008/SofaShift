<p align="center">
  <img src="assets/sofashift-banner.png" alt="SofaShift - controller-aware couch gaming setup" width="100%">
</p>

<h1 align="center">SofaShift</h1>

<p align="center">
  <img src="assets/sofashift-icon.jpg" alt="SofaShift app icon" width="128" height="128">
</p>

<p align="center">
  Controller-aware couch gaming setup for Windows.
</p>

SofaShift watches for mapped controller connections and can switch display profiles, route audio, apply an optional frame-rate cap, and launch couch-gaming apps.

## Download

Download the latest installer from [GitHub Releases](https://github.com/weezzer008/SofaShift/releases).

Use only the `SofaShift-Setup.exe` release asset. GitHub may also show automatic `Source code (zip)` and `Source code (tar.gz)` downloads; those are not the SofaShift installer.

## Requirements

- Windows 10 or Windows 11.
- PowerShell for the background monitor. Windows PowerShell 5.1 is normally built into Windows 10/11, and PowerShell 7 is also supported.
- Optional tools: NirCmd for audio switching, Playnite, Hue Sync, MonitorSwitcher, and FRL Toggle.

## Install

1. Download `SofaShift-Setup.exe` from the latest release.
2. Put it in the folder where you want SofaShift to live.
3. Run the EXE and follow the setup wizard.

The setup EXE writes the monitor script, config, launcher, logs, and uninstall helper beside itself. Keep those generated files together with the EXE.

## Notes

- Windows SmartScreen may warn because this first release is unsigned. Use only the EXE attached to this repository's GitHub release.
- SofaShift is a local Windows desktop automation tool. It does not require an account and does not intentionally send telemetry or logs over the network.
- Logs may include local paths, display identifiers, audio device names, and controller IDs. Redact logs before sharing them publicly.
- SofaShift does not silently download, extract, or run third-party tools. It opens official pages and lets you select local executables.

## Uninstall

Use Windows Settings or run `uninstall_sofashift.cmd` from the SofaShift install folder.

The uninstaller removes known SofaShift-created files, the `SofaShift Monitor` scheduled task, and the SofaShift per-user uninstall entry. It leaves `SofaShift-Setup.exe` and unrelated files in the folder.

## Tip Jar

SofaShift is free for personal use. If it saves you some couch-to-desk shuffling, tips are welcome:

[paypal.me/weezzer008](https://paypal.me/weezzer008)
