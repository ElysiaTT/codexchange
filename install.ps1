param(
    [string]$InstallDir = "$env:USERPROFILE\.codex\tools",
    [switch]$NoPath
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Installer = Join-Path $ProjectRoot "windows\install.ps1"

if (-not (Test-Path -LiteralPath $Installer)) {
    throw "Missing Windows installer: $Installer"
}

$argsList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $Installer, "-InstallDir", $InstallDir)
if ($NoPath) {
    $argsList += "-NoPath"
}

& powershell @argsList
