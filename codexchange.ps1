<#PSScriptInfo
.VERSION 0.1.0
.GUID 6d64a2fe-4a93-4ad5-a89e-e34a6fcbf0c1
.AUTHOR ElysiaTT
.COMPANYNAME ElysiaTT
.COPYRIGHT MIT License
.TAGS Codex OpenAI PowerShell CLI Auth Profile Windows
.LICENSEURI https://github.com/ElysiaTT/codexchange/blob/main/LICENSE
.PROJECTURI https://github.com/ElysiaTT/codexchange
.RELEASENOTES
Initial PowerShell Gallery-ready script entrypoint.
#>

<#
.SYNOPSIS
Switch local Codex auth profiles without logging out of ChatGPT.

.DESCRIPTION
Codexchange manages local Codex auth.json profiles. It can save the active
Codex login, switch to a saved login, back up the active login, and run Codex
login inside an isolated CODEX_HOME so adding another account does not require
running codex logout on the current account.

.PARAMETER Action
Command to run: list, save, use, backup, status, login-as, where, or help.

.PARAMETER Name
Profile name for save, use, or login-as.

.PARAMETER CodexHome
Optional Codex home directory. Defaults to CODEX_HOME, then the user's .codex
folder.

.PARAMETER CodexExe
Optional path to codex or codex.exe. Defaults to CODEX_EXE or codex on PATH.

.PARAMETER Force
Overwrite an existing saved profile when supported.

.EXAMPLE
codexchange.ps1 save team-a

.EXAMPLE
codexchange.ps1 login-as team-b

.EXAMPLE
codexchange.ps1 use team-b
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet("list", "save", "use", "backup", "status", "login-as", "where", "help")]
    [string]$Action = "list",

    [Parameter(Position = 1)]
    [string]$Name,

    [string]$CodexHome,

    [string]$CodexExe,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Get-DefaultCodexHome {
    if ($env:CODEX_HOME) {
        return $env:CODEX_HOME
    }

    $userHome = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($HOME) { $HOME } else { [Environment]::GetFolderPath("UserProfile") }
    return (Join-Path $userHome ".codex")
}

if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    $CodexHome = Get-DefaultCodexHome
}

$AuthFile = Join-Path $CodexHome "auth.json"
$ProfilesDir = Join-Path $CodexHome "auth-profiles"
$BackupsDir = Join-Path $ProfilesDir "_backups"
$LoginHomesDir = Join-Path $ProfilesDir "_login-homes"

function Show-Help {
    @"
Codexchange

Usage:
  codexchange.ps1 list
  codexchange.ps1 save <name> [-Force]
  codexchange.ps1 use <name>
  codexchange.ps1 login-as <name> [-Force]
  codexchange.ps1 status
  codexchange.ps1 backup
  codexchange.ps1 where

Recommended flow:
  codexchange.ps1 save team-a
  codexchange.ps1 login-as team-b
  codexchange.ps1 use team-a
  codexchange.ps1 use team-b

Important:
  Do not run "codex logout" just to add another account. Use "login-as" to run
  Codex login inside an isolated CODEX_HOME and save the result as a profile.

Codex home:
  $CodexHome
"@
}

function Ensure-Dirs {
    New-Item -ItemType Directory -Force -Path $ProfilesDir | Out-Null
    New-Item -ItemType Directory -Force -Path $BackupsDir | Out-Null
    New-Item -ItemType Directory -Force -Path $LoginHomesDir | Out-Null
}

function Assert-ProfileName([string]$ProfileName) {
    if ([string]::IsNullOrWhiteSpace($ProfileName)) {
        throw "Profile name is required."
    }
    if ($ProfileName -notmatch "^[A-Za-z0-9._-]+$") {
        throw "Profile name can only contain letters, numbers, dot, underscore, and hyphen."
    }
}

function Get-ProfilePath([string]$ProfileName) {
    Assert-ProfileName $ProfileName
    Join-Path $ProfilesDir "$ProfileName.auth.json"
}

function Assert-JsonFile([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "File not found: $Path"
    }
    try {
        Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json | Out-Null
    }
    catch {
        throw "File is not valid JSON: $Path"
    }
}

function Get-AuthSummary([string]$Path) {
    Assert-JsonFile $Path
    $json = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
    $keys = @($json.PSObject.Properties.Name)
    [pscustomobject]@{
        Path = $Path
        LastWriteTime = (Get-Item -LiteralPath $Path).LastWriteTime
        AuthMode = if ($json.auth_mode) { $json.auth_mode } else { "unknown" }
        HasApiKey = [bool]$json.OPENAI_API_KEY
        HasTokenFields = ($keys -contains "tokens")
        LastRefresh = if ($json.last_refresh) { $json.last_refresh } else { "" }
    }
}

function Find-CodexExe {
    if ($CodexExe -and (Test-Path -LiteralPath $CodexExe)) {
        return $CodexExe
    }
    if ($env:CODEX_EXE -and (Test-Path -LiteralPath $env:CODEX_EXE)) {
        return $env:CODEX_EXE
    }

    $cmd = Get-Command codex -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd -and $cmd.Source) {
        return $cmd.Source
    }

    $isWindowsHost = ($PSVersionTable.PSVersion.Major -lt 6) -or $IsWindows -or ($env:OS -eq "Windows_NT")
    if ($isWindowsHost) {
        $userHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { [Environment]::GetFolderPath("UserProfile") }
        $extensionRoots = @(
            Join-Path $userHome ".vscode\extensions",
            Join-Path $userHome ".vscode-insiders\extensions"
        )

        foreach ($root in $extensionRoots) {
            if (-not (Test-Path -LiteralPath $root)) {
                continue
            }

            $ext = Get-ChildItem -LiteralPath $root -Directory -Filter "openai.chatgpt-*" -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending |
                Select-Object -First 1

            if ($ext) {
                $exe = Join-Path $ext.FullName "bin\windows-x86_64\codex.exe"
                if (Test-Path -LiteralPath $exe) {
                    return $exe
                }
            }
        }
    }

    throw "Could not find codex. Install Codex CLI, install the VS Code Codex extension, or set CODEX_EXE."
}

function Invoke-Codex([string[]]$ArgsList, [string]$TemporaryCodexHome) {
    $exe = Find-CodexExe
    $oldHome = $env:CODEX_HOME

    try {
        if ($TemporaryCodexHome) {
            $env:CODEX_HOME = $TemporaryCodexHome
        }
        & $exe @ArgsList
        if ($LASTEXITCODE -ne 0) {
            throw "codex exited with code $LASTEXITCODE"
        }
    }
    finally {
        if ($null -eq $oldHome) {
            Remove-Item Env:\CODEX_HOME -ErrorAction SilentlyContinue
        }
        else {
            $env:CODEX_HOME = $oldHome
        }
    }
}

function Backup-Current([string]$Reason) {
    Ensure-Dirs
    if (-not (Test-Path -LiteralPath $AuthFile)) {
        Write-Output "No auth.json found to back up."
        return
    }

    Assert-JsonFile $AuthFile
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $safeReason = $Reason -replace "[^A-Za-z0-9._-]", "-"
    $target = Join-Path $BackupsDir "auth.$stamp.$safeReason.json"
    Copy-Item -LiteralPath $AuthFile -Destination $target -Force
    Write-Output "Backed up current auth.json to: $target"
}

function Assert-SameFileHash([string]$Left, [string]$Right) {
    $leftHash = (Get-FileHash -LiteralPath $Left -Algorithm SHA256).Hash
    $rightHash = (Get-FileHash -LiteralPath $Right -Algorithm SHA256).Hash

    if ($leftHash -ne $rightHash) {
        throw "Switch verification failed: auth.json does not match the selected profile after copy."
    }

    return $leftHash.Substring(0, 12)
}

switch ($Action) {
    "help" {
        Show-Help
    }

    "where" {
        [pscustomobject]@{
            CodexHome = $CodexHome
            AuthFile = $AuthFile
            ProfilesDir = $ProfilesDir
            BackupsDir = $BackupsDir
            LoginHomesDir = $LoginHomesDir
            CodexExe = Find-CodexExe
        } | Format-List
    }

    "list" {
        Ensure-Dirs
        $profiles = Get-ChildItem -LiteralPath $ProfilesDir -Filter "*.auth.json" -File -ErrorAction SilentlyContinue |
            Sort-Object Name |
            ForEach-Object {
                [pscustomobject]@{
                    Profile = $_.BaseName -replace "\.auth$", ""
                    LastWriteTime = $_.LastWriteTime
                    Length = $_.Length
                }
            }

        if (-not $profiles) {
            Write-Output "No saved Codex auth profiles yet."
            Write-Output "Start with: codexchange.ps1 save team-a"
            return
        }

        $profiles | Format-Table -AutoSize
    }

    "save" {
        Ensure-Dirs
        $target = Get-ProfilePath $Name
        Assert-JsonFile $AuthFile

        if ((Test-Path -LiteralPath $target) -and -not $Force) {
            throw "Profile already exists: $Name. Re-run with -Force to overwrite it."
        }

        Copy-Item -LiteralPath $AuthFile -Destination $target -Force
        Write-Output "Saved current Codex auth as profile '$Name': $target"
    }

    "use" {
        Ensure-Dirs
        $source = Get-ProfilePath $Name
        Assert-JsonFile $source
        Backup-Current "before-use-$Name"
        Copy-Item -LiteralPath $source -Destination $AuthFile -Force
        $shortHash = Assert-SameFileHash $AuthFile $source
        Write-Output "Switched Codex auth to profile '$Name'."
        Write-Output "Verified active auth.json matches '$Name' (sha256:$shortHash...)."
        Write-Output "Restart open Codex sessions, VS Code Codex panels, or the Codex desktop app for the switch to appear in the UI."
    }

    "backup" {
        Backup-Current "manual"
    }

    "status" {
        if (Test-Path -LiteralPath $AuthFile) {
            Get-AuthSummary $AuthFile | Format-List
        }
        else {
            Write-Output "No auth.json found at: $AuthFile"
        }

        Write-Output ""
        Invoke-Codex @("login", "status") $null
    }

    "login-as" {
        Ensure-Dirs
        Assert-ProfileName $Name
        $target = Get-ProfilePath $Name

        if ((Test-Path -LiteralPath $target) -and -not $Force) {
            throw "Profile already exists: $Name. Re-run with -Force to overwrite it."
        }

        $loginHome = Join-Path $LoginHomesDir $Name
        New-Item -ItemType Directory -Force -Path $loginHome | Out-Null

        $loginAuth = Join-Path $loginHome "auth.json"
        if ((Test-Path -LiteralPath $loginAuth) -and -not $Force) {
            throw "Temporary login home already has auth.json. Re-run with -Force or choose another profile name."
        }
        if ((Test-Path -LiteralPath $loginAuth) -and $Force) {
            $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
            Copy-Item -LiteralPath $loginAuth -Destination (Join-Path $BackupsDir "login-home.$Name.$stamp.auth.json") -Force
            Remove-Item -LiteralPath $loginAuth -Force
        }

        Write-Output "Starting isolated Codex login for profile '$Name'."
        Write-Output "This uses CODEX_HOME=$loginHome and does not run 'codex logout' on your main account."
        Invoke-Codex @("login") $loginHome

        Assert-JsonFile $loginAuth
        Copy-Item -LiteralPath $loginAuth -Destination $target -Force
        Write-Output "Saved isolated login as profile '$Name': $target"
        Write-Output "To activate it: codexchange.ps1 use $Name"
    }
}