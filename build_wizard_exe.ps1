#Requires -Version 5.1
<#
.SYNOPSIS
    SofaShift - Build Script
    Compiles setup_wizard.ps1 into a standalone SofaShift-Setup.exe using ps2exe.
    Run this once after any edits to setup_wizard.ps1.

.NOTES
    Requirements:
      - PowerShell 5.1+ (built into Windows 10/11)
      - ps2exe installed from PSGallery
      - Must be run from the folder containing setup_wizard.ps1

    By default this script will not download build tools. If you want the script
    to install ps2exe from PSGallery for you, run:
      .\build_wizard_exe.ps1 -InstallMissingPs2Exe
    
    Output:
      SofaShift-Setup.exe   -  self-contained, no PowerShell knowledge needed by end users
#>

param(
    [switch]$InstallMissingPs2Exe
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -- Paths ---------------------------------------------------------------------
$scriptDir  = $PSScriptRoot
$inputPs1   = Join-Path $scriptDir "setup_wizard.ps1"
$watchPs1   = Join-Path $scriptDir "controller_watch.ps1"
$iconFile   = Join-Path $scriptDir "SofaShift.ico"
$jpegFile   = Join-Path $scriptDir "SofaShift.jpeg"
$outputExe  = Join-Path $scriptDir "SofaShift-Setup.exe"
$version    = "0.1.0.0"

# -- Convert JPEG to ICO if needed ---------------------------------------------
if ((-not (Test-Path $iconFile)) -and (Test-Path $jpegFile)) {
    Write-Host "  Converting SofaShift.jpeg -> SofaShift.ico..." -ForegroundColor Gray
    Add-Type -AssemblyName System.Drawing
    try {
        $bmp     = [System.Drawing.Bitmap]::new($jpegFile)
        $scaled  = [System.Drawing.Bitmap]::new($bmp, 256, 256)
        $ms      = [System.IO.MemoryStream]::new()
        $scaled.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
        $pngData = $ms.ToArray()
        $ms.Dispose(); $scaled.Dispose(); $bmp.Dispose()

        # Write a minimal ICO: 6-byte header + 16-byte dir entry + PNG payload
        $fs     = [System.IO.FileStream]::new($iconFile, [System.IO.FileMode]::Create)
        $writer = [System.IO.BinaryWriter]::new($fs)
        $writer.Write([uint16]0)                   # reserved
        $writer.Write([uint16]1)                   # type: icon
        $writer.Write([uint16]1)                   # image count
        $writer.Write([byte]0)                     # width  (0 = 256)
        $writer.Write([byte]0)                     # height (0 = 256)
        $writer.Write([byte]0)                     # color count
        $writer.Write([byte]0)                     # reserved
        $writer.Write([uint16]1)                   # planes
        $writer.Write([uint16]32)                  # bit depth
        $writer.Write([uint32]$pngData.Length)     # image size
        $writer.Write([uint32]22)                  # image offset (6+16)
        $writer.Write($pngData)
        $writer.Close(); $fs.Close()
        Write-Host "  Icon     : generated from JPEG ($([math]::Round($pngData.Length / 1KB, 1)) KB)" -ForegroundColor Green
    } catch {
        Write-Host "  WARNING: JPEG->ICO conversion failed: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
}

# -- Pre-flight checks ---------------------------------------------------------
Write-Host ""
Write-Host "  SofaShift Build Script" -ForegroundColor Cyan
Write-Host "  -----------------------------------------" -ForegroundColor DarkGray
Write-Host ""

if (-not (Test-Path $inputPs1)) {
    Write-Host "  ERROR: setup_wizard.ps1 not found at:" -ForegroundColor Red
    Write-Host "         $inputPs1" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Make sure you run this script from the same folder as setup_wizard.ps1."
    exit 1
}

if (-not (Test-Path $watchPs1)) {
    Write-Host "  ERROR: controller_watch.ps1 not found at:" -ForegroundColor Red
    Write-Host "         $watchPs1" -ForegroundColor Red
    Write-Host ""
    Write-Host "  The setup EXE must bundle the current watcher so end users only need one file."
    exit 1
}

Write-Host "  Input  : $inputPs1" -ForegroundColor Gray
Write-Host "  Watcher: $watchPs1" -ForegroundColor Gray
Write-Host "  Output : $outputExe" -ForegroundColor Gray
if (Test-Path $iconFile) {
    Write-Host "  Icon   : $iconFile" -ForegroundColor Gray
} else {
    Write-Host "  Icon   : (none found  -  exe will use default PS icon)" -ForegroundColor DarkYellow
    Write-Host "           Place SofaShift.ico in $scriptDir to embed a custom icon." -ForegroundColor DarkYellow
}
Write-Host ""

# -- Ensure ps2exe is installed ------------------------------------------------
Write-Host "  Checking for ps2exe..." -ForegroundColor Gray

$ps2exeAvailable = Get-Module -ListAvailable -Name ps2exe -ErrorAction SilentlyContinue

if (-not $ps2exeAvailable) {
    Write-Host "  ps2exe not found." -ForegroundColor Yellow

    if (-not $InstallMissingPs2Exe) {
        Write-Host ""
        Write-Host "  Automatic build-tool downloads are disabled by default." -ForegroundColor Yellow
        Write-Host "  Install ps2exe yourself, then rerun this script:" -ForegroundColor Gray
        Write-Host "    Install-Module -Name ps2exe -Scope CurrentUser -Force" -ForegroundColor White
        Write-Host ""
        Write-Host "  Or explicitly opt in to the PSGallery install:" -ForegroundColor Gray
        Write-Host "    .\build_wizard_exe.ps1 -InstallMissingPs2Exe" -ForegroundColor White
        Write-Host ""
        exit 1
    }

    Write-Host "  Installing ps2exe from PSGallery because -InstallMissingPs2Exe was supplied..." -ForegroundColor Yellow

    # Check PSGallery is trusted, configure if needed
    $gallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
    if ($gallery -and $gallery.InstallationPolicy -ne "Trusted") {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }

    try {
        Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        Write-Host "  ps2exe installed successfully." -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Host "  ERROR: Could not install ps2exe: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Try installing manually:" -ForegroundColor Yellow
        Write-Host "    Install-Module -Name ps2exe -Scope CurrentUser -Force" -ForegroundColor White
        Write-Host ""
        exit 1
    }
} else {
    Write-Host "  ps2exe found (v$($ps2exeAvailable.Version))." -ForegroundColor Green
}

# Refresh module path so a freshly installed ps2exe is visible in this session
$env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath", "User") +
    [System.IO.Path]::PathSeparator + $env:PSModulePath

try {
    Import-Module ps2exe -Force -ErrorAction Stop
} catch {
    Write-Host "  ERROR: Could not import ps2exe module: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# -- Inject bundled watcher into a temporary copy of setup_wizard.ps1 ----------
# End users receive only SofaShift-Setup.exe. The wizard source embeds a watcher
# placeholder, and this build step replaces it with the current controller_watch.ps1
# before compiling so released EXEs cannot carry stale monitor code.

Write-Host ""
Write-Host "  Injecting bundled watcher..." -ForegroundColor Cyan

$tempPs1    = $null
$sourceText = Get-Content -LiteralPath $inputPs1 -Raw -Encoding UTF8
$watchText  = Get-Content -LiteralPath $watchPs1 -Raw -Encoding UTF8

if ($watchText -match "(?m)^'@\s*$") {
    Write-Host "  ERROR: controller_watch.ps1 contains a line that would terminate the embedded here-string." -ForegroundColor Red
    exit 1
}

function Normalize-SofaShiftScriptText {
    param([string]$Text)
    return (($Text -replace "`r`n", "`n") -replace "`r", "`n").TrimEnd()
}

$watchPattern = "(?s)\`$script:BundledControllerWatch = @'\r?\n(.*?)\r?\n'@"
$watchMatch = [regex]::Match($sourceText, $watchPattern)
if (-not $watchMatch.Success) {
    Write-Host "  ERROR: setup_wizard.ps1 does not contain the bundled watcher block." -ForegroundColor Red
    exit 1
}

$watchBlock = "`$script:BundledControllerWatch = @'`r`n$watchText`r`n'@"
$sourceText = $sourceText.Substring(0, $watchMatch.Index) + $watchBlock + $sourceText.Substring($watchMatch.Index + $watchMatch.Length)

$verifyMatch = [regex]::Match($sourceText, $watchPattern)
if (-not $verifyMatch.Success -or (Normalize-SofaShiftScriptText $verifyMatch.Groups[1].Value) -ne (Normalize-SofaShiftScriptText $watchText)) {
    Write-Host "  ERROR: embedded watcher validation failed." -ForegroundColor Red
    exit 1
}

Write-Host "  Watcher  : embedded current controller_watch.ps1 ($([math]::Round($watchText.Length / 1KB, 1)) KB)" -ForegroundColor Green

# Write the injected content to a temp file and compile from that
$tempPs1    = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "SofaShift_build_$PID.ps1")
[System.IO.File]::WriteAllText($tempPs1, $sourceText, [System.Text.Encoding]::UTF8)
$inputPs1   = $tempPs1

# -- Compile -------------------------------------------------------------------
Write-Host ""
Write-Host "  Compiling..." -ForegroundColor Cyan

# Build the parameter hashtable  -  conditionally include icon only if file exists
$compileParams = @{
    InputFile   = $inputPs1
    OutputFile  = $outputExe
    # GUI flags
    noConsole   = $true      # no black console window behind the WinForms UI
    STA         = $true      # Single-Threaded Apartment  -  REQUIRED for WinForms/WPF
    # Match the stable V2 installer/runtime behavior: elevate the wizard so it can
    # register the startup task at the same privilege level as the watcher expects.
    requireAdmin = $true
    # Suppress ps2exe's own output/error streams so our messages stay clean
    noOutput    = $true
    noError     = $true
    # File metadata (shows in Windows Explorer > Properties > Details)
    title       = "SofaShift Setup"
    description = "SofaShift controller-based display switcher  -  setup wizard"
    product     = "SofaShift"
    company     = "SofaShift"
    version     = $version
    copyright   = "Copyright (c) $(Get-Date -Format yyyy) SofaShift"
}

# Add icon only if it exists
if (Test-Path $iconFile) {
    $compileParams['iconFile'] = $iconFile
}

# Prefer Invoke-ps2exe (module cmdlet); fall back to the ps2exe alias
$cmdlet = if (Get-Command Invoke-ps2exe -ErrorAction SilentlyContinue) {
    "Invoke-ps2exe"
} else {
    "ps2exe"
}

try {
    & $cmdlet @compileParams
} catch {
    Write-Host ""
    Write-Host "  ERROR during compilation: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Common causes:" -ForegroundColor Yellow
    Write-Host "    - setup_wizard.ps1 contains a syntax error" -ForegroundColor Gray
    Write-Host "    - ps2exe version is outdated (try: Update-Module ps2exe)" -ForegroundColor Gray
    Write-Host "    - Output path is read-only or already open" -ForegroundColor Gray
    exit 1
}

if ($tempPs1 -and (Test-Path $tempPs1)) { Remove-Item $tempPs1 -Force -ErrorAction SilentlyContinue }

# -- Verify output -------------------------------------------------------------
if (Test-Path $outputExe) {
    $exeSize = [math]::Round((Get-Item $outputExe).Length / 1MB, 1)
    Write-Host ""
    Write-Host "  v Build complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  File    : $outputExe" -ForegroundColor White
    Write-Host "  Size    : ${exeSize} MB" -ForegroundColor Gray
    Write-Host "  Version : $version" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  -----------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Distribution:" -ForegroundColor Cyan
    Write-Host "    Share SofaShift-Setup.exe with any Windows 10/11 user." -ForegroundColor Gray
    Write-Host "    They right-click and 'Run as administrator' (or it auto-elevates)." -ForegroundColor Gray
    Write-Host "    The setup EXE is self-contained; the background monitor uses PowerShell." -ForegroundColor Gray
    Write-Host "    If PowerShell is missing, SofaShift prompts the user to install it." -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Note: Windows SmartScreen may warn on first run because the exe" -ForegroundColor DarkYellow
    Write-Host "  is unsigned. Users click 'More info' then 'Run anyway'." -ForegroundColor DarkYellow
    Write-Host "  To suppress: code-sign the exe with a certificate." -ForegroundColor DarkYellow
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "  ERROR: Compilation appeared to succeed but output file not found:" -ForegroundColor Red
    Write-Host "         $outputExe" -ForegroundColor Red
    Write-Host "  Check ps2exe output above for details." -ForegroundColor Red
    exit 1
}
