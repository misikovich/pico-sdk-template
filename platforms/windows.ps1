<#
.SYNOPSIS
Installs the Raspberry Pi Pico SDK toolchain on Windows using winget.

.DESCRIPTION
Run from a PowerShell prompt in the repository root:

    powershell -ExecutionPolicy Bypass -File platforms\windows.ps1

Self-contained on purpose (PowerShell cannot source versions.env) — keep the
default versions below in sync with ..\versions.env.

For a fully guided setup including drivers and OpenOCD, Raspberry Pi's
official installer is a good alternative:
https://github.com/raspberrypi/pico-setup-windows
#>
param(
    [string]$PicoSdkVersion = "2.1.1",
    [string]$PicoRoot = "$env:USERPROFILE\.pico-sdk",
    [switch]$WithOpenOCD
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget is required. Install 'App Installer' from the Microsoft Store and re-run."
}

$packages = @(
    "Git.Git",
    "Kitware.CMake",
    "Ninja-build.Ninja",
    "Python.Python.3.12",
    "Arm.GnuArmEmbeddedToolchain"
)

foreach ($id in $packages) {
    winget list --id $id -e | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "already installed: $id"
    } else {
        Write-Host "installing: $id"
        winget install --id $id -e --accept-source-agreements --accept-package-agreements
    }
}

if ($WithOpenOCD) {
    Write-Warning "OpenOCD is not installed by this script on Windows."
    Write-Warning "Use the official installer instead: https://github.com/raspberrypi/pico-setup-windows"
}

# The Arm toolchain installer does not add itself to PATH in silent mode;
# find its bin directory and add it to the user PATH if missing.
$armBin = Get-ChildItem -Path "$env:ProgramFiles*\Arm GNU Toolchain arm-none-eabi\*\bin" `
    -Directory -ErrorAction SilentlyContinue | Select-Object -Last 1
if ($armBin) {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$($armBin.FullName)*") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$($armBin.FullName)", "User")
        Write-Host "added to user PATH: $($armBin.FullName)"
    }
} else {
    Write-Warning "could not locate the Arm toolchain bin directory; add it to PATH manually"
}

# Clone or update pico-sdk at the pinned tag (idempotent).
$sdkPath = Join-Path $PicoRoot "sdk\$PicoSdkVersion"
if (Test-Path (Join-Path $sdkPath ".git")) {
    Write-Host "updating pico-sdk at $sdkPath"
    git -C $sdkPath fetch --tags origin
} else {
    Write-Host "cloning pico-sdk $PicoSdkVersion into $sdkPath"
    New-Item -ItemType Directory -Force -Path (Split-Path $sdkPath) | Out-Null
    git clone https://github.com/raspberrypi/pico-sdk.git $sdkPath
}
git -C $sdkPath checkout --quiet $PicoSdkVersion
git -C $sdkPath submodule update --init

[Environment]::SetEnvironmentVariable("PICO_SDK_PATH", $sdkPath, "User")
Write-Host ""
Write-Host "PICO_SDK_PATH set to $sdkPath (user environment)."
Write-Host "Open a new terminal for PATH and PICO_SDK_PATH changes to take effect."
