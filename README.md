# Codexchange

Tiny Windows helper for switching local Codex accounts without logging out of
ChatGPT in your browser, and without running `codex logout` on your current
Codex account.

It manages local Codex `auth.json` profiles:

```text
%USERPROFILE%\.codex\auth.json
%USERPROFILE%\.codex\auth-profiles\<name>.auth.json
```

## Why this exists

Codex CLI and the VS Code Codex extension use local auth state. If you have two
valid Codex-capable accounts, switching them by repeatedly logging out can be
annoying. Worse, `codex logout` may revoke the refresh token in the active
`auth.json`, which can make a saved profile fail later with:

```text
Your access token could not be refreshed because your refresh token was revoked.
Please log out and sign in again.
```

This project avoids that flow. To add a second account, use `login-as`, which
runs Codex login in an isolated `CODEX_HOME` and saves the result as a profile.

## Install

From this project directory:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Open a new PowerShell window, then:

```powershell
codex-auth-profile.cmd help
```

You can also run it without installing:

```powershell
.\bin\codex-auth-profile.cmd help
```

## Recommended usage

Save the currently working Codex login:

```powershell
codex-auth-profile.cmd save team-a
```

Add another account safely:

```powershell
codex-auth-profile.cmd login-as team-b
```

Switch accounts:

```powershell
codex-auth-profile.cmd use team-a
codex-auth-profile.cmd use team-b
```

Check what is saved:

```powershell
codex-auth-profile.cmd list
codex-auth-profile.cmd status
```

## After switching

`use <profile>` changes the local Codex auth file immediately, but already-open
Codex surfaces may keep the old account in memory.

After running:

```powershell
codex-auth-profile.cmd use team-b
```

reload the surface you are using:

```text
VS Code: Ctrl+Shift+P -> Developer: Reload Window
Codex desktop app: close the app completely, then reopen it
Codex CLI/TUI: start a fresh session
```

If the visible account name in the menu does not change before reload, that is
expected. The file has switched; the UI has not re-read it yet.

## Do not use this flow

Avoid this:

```powershell
codex-auth-profile.cmd save team-a
codex logout
codex login
codex-auth-profile.cmd save team-b
```

The `logout` step can invalidate the refresh token inside the profile you just
saved. If you already did this and a profile is revoked, refresh it:

```powershell
codex-auth-profile.cmd login-as team-a -Force
```

## Commands

```text
list                 List saved profiles
save <name>          Save the active auth.json as a profile
use <name>           Activate a saved profile
login-as <name>      Log in under isolated CODEX_HOME and save as a profile
backup               Back up the active auth.json
status               Show non-secret auth summary and codex login status
where                Show paths used by the tool
help                 Show help
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

## Platform

The current scripts are designed for Windows PowerShell because Codex VS Code
users on Windows commonly get Codex from:

```text
%USERPROFILE%\.vscode\extensions\openai.chatgpt-*\bin\windows-x86_64\codex.exe
```

The PowerShell script also works with a normal `codex` command on `PATH`, or a
custom executable path set with:

```powershell
$env:CODEX_EXE = "C:\path\to\codex.exe"
```
