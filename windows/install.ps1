param(
    [string]$InstallDir = "$env:USERPROFILE\.codex\tools",
    [switch]$NoPath
)

$ErrorActionPreference = "Stop"

$PlatformRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptSource = Join-Path $PlatformRoot "codex-auth-profile.ps1"
$CmdSource = Join-Path $PlatformRoot "codex-auth-profile.cmd"

if (-not (Test-Path -LiteralPath $ScriptSource)) {
    throw "Missing script: $ScriptSource"
}
if (-not (Test-Path -LiteralPath $CmdSource)) {
    throw "Missing wrapper: $CmdSource"
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item -LiteralPath $ScriptSource -Destination (Join-Path $InstallDir "codex-auth-profile.ps1") -Force
Copy-Item -LiteralPath $CmdSource -Destination (Join-Path $InstallDir "codex-auth-profile.cmd") -Force

if (-not $NoPath) {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $parts = @()
    if ($userPath) {
        $parts = $userPath -split ";" | Where-Object { $_ }
    }

    if ($parts -notcontains $InstallDir) {
        $newPath = (@($InstallDir) + $parts) -join ";"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Output "Added to user PATH: $InstallDir"
    }
    else {
        Write-Output "Already in user PATH: $InstallDir"
    }
}

Write-Output "Installed Windows codex-auth-profile to: $InstallDir"
Write-Output "Open a new terminal, then run: codex-auth-profile.cmd help"
