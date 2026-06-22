# Codexchange

Switch local Codex accounts without running `codex logout` on the active
account. The tool stores named copies of Codex `auth.json` and can log in to a
new account through an isolated `CODEX_HOME`.

## Choose Your Platform

```text
windows/  Windows PowerShell implementation
unix/     Linux, macOS, WSL, and remote-server Python implementation
```

Windows users:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\install.ps1
codex-auth-profile.cmd help
```

Linux/macOS/remote server users:

```sh
sh ./unix/install.sh
export PATH="$HOME/.local/bin:$PATH"
codex-auth-profile --help
```

The root installers remain as compatibility shims:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

```sh
sh ./install.sh
```

## Why This Exists

Codex CLI, the VS Code Codex extension, and other Codex surfaces use local auth
state:

```text
Windows:     %USERPROFILE%\.codex\auth.json
Linux/macOS: ~/.codex/auth.json
Profiles:    <CODEX_HOME>/auth-profiles/<name>.auth.json
```

Repeatedly using `codex logout` to add another account can revoke the active
refresh token. A saved profile may then fail later with:

```text
Your access token could not be refreshed because your refresh token was revoked.
Please log out and sign in again.
```

Use `login-as` instead. It runs `codex login` in a temporary isolated
`CODEX_HOME`, then saves that login as a named profile.

## Common CLI Interface

Both platform versions expose the same actions:

```text
list                 List saved profiles
save <name>          Save the active auth.json as a profile
use <name>           Activate a saved profile
login-as <name>      Log in under isolated CODEX_HOME and save as a profile
backup               Back up the active auth.json
status               Show non-secret auth summary and codex login status
where                Show paths used by the tool
help / --help        Show help
```

Windows command shape:

```powershell
codex-auth-profile.cmd save team-a
codex-auth-profile.cmd login-as team-b
codex-auth-profile.cmd login-as team-b -DeviceAuth
codex-auth-profile.cmd use team-b
```

Linux/macOS command shape:

```sh
codex-auth-profile save team-a
codex-auth-profile login-as team-b
codex-auth-profile login-as team-b --device-auth
codex-auth-profile use team-b
```

On headless SSH servers, prefer device auth:

```sh
codex-auth-profile login-as team-b --device-auth
```

## After Switching

`use <profile>` changes the local Codex auth file immediately. Already-open
Codex surfaces may keep the old account in memory.

Reload the surface you are using:

```text
VS Code: Ctrl+Shift+P -> Developer: Reload Window
VS Code Remote: reload the client window
Codex desktop app: close the app completely, then reopen it
Codex CLI/TUI: start a fresh session
```

If the visible account name does not change before reload, that is expected.
The file has switched; the UI has not re-read it yet.

## Do Not Use This Flow

Avoid this:

```sh
codex-auth-profile save team-a
codex logout
codex login
codex-auth-profile save team-b
```

The `logout` step can invalidate the refresh token inside the profile you just
saved. If you already did this and a profile is revoked, refresh it:

```powershell
codex-auth-profile.cmd login-as team-a -Force
```

```sh
codex-auth-profile login-as team-a --force
```

## Environment Interface

```text
CODEX_HOME  Override the Codex home directory. Defaults to ~/.codex or
            %USERPROFILE%\.codex.
CODEX_EXE   Override the codex executable path when codex is not on PATH.
```

Examples:

```powershell
$env:CODEX_EXE = "C:\path\to\codex.exe"
```

```sh
export CODEX_EXE=/path/to/codex
```

## Security

Saved profiles contain real login credentials. Never commit or share:

```text
auth.json
*.auth.json
auth-profiles/
```

This repository's `.gitignore` excludes those patterns.

Use this only for accounts you own or are authorized to use. It does not bypass
OpenAI account limits, admin policy, verification, or access controls.
