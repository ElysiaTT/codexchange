# Codexchange

[![CI](https://github.com/ElysiaTT/codexchange/actions/workflows/ci.yml/badge.svg)](https://github.com/ElysiaTT/codexchange/actions/workflows/ci.yml)

🌐 Language: English | [中文](README.zh-CN.md)

**Switch Codex accounts without logging out of ChatGPT.**

Codexchange is a tiny Windows PowerShell helper for saving, switching, and
restoring local Codex auth profiles. It is useful when you use multiple
Codex-capable accounts and do not want to repeatedly sign out of ChatGPT or run
`codex logout` just to switch local Codex state.

```powershell
codex-auth-profile.cmd save personal
codex-auth-profile.cmd login-as work
codex-auth-profile.cmd use work
```

## Why this exists

Codex CLI and the VS Code Codex extension use local authentication state. When
multiple accounts are involved, repeatedly logging out and logging back in can
leave stale local state and may lead to errors such as:

```text
Your access token could not be refreshed because you have since logged out or signed in to another account.
Please sign in again.
```

Codexchange avoids that old workflow. To add another account, use `login-as`.
It runs `codex login` inside an isolated `CODEX_HOME`, then saves the result as
a named profile.

It manages local Codex profile files here:

```text
%USERPROFILE%\.codex\auth.json
%USERPROFILE%\.codex\auth-profiles\<name>.auth.json
```

## Features

- Save the current Codex login as a named profile
- Switch between saved profiles with one command
- Add another account through an isolated `CODEX_HOME`
- Back up the active `auth.json` before switching
- Show non-secret profile status information
- Designed for Windows PowerShell and VS Code Codex users

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

PowerShell Gallery support is prepared through `codexchange.ps1`, but the
Gallery package is not required for local use.

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

## Do not use this old workflow

Avoid this:

```powershell
codex-auth-profile.cmd save team-a
codex logout
codex login
codex-auth-profile.cmd save team-b
```

Older setups could leave stale account information in `auth.json`, causing the
refresh error shown above. The current `login-as` workflow is designed to avoid
that by keeping the new login isolated.

If you already used the old workflow and a profile stops working, refresh it:

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

## Releases

Maintainers can publish a release by pushing a version tag:

```powershell
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will build a zip package and publish a release automatically.

## Security

Do not commit sensitive authentication files:

```text
auth.json
*.auth.json
auth-profiles/
```

This repository's `.gitignore` excludes those patterns.

Use this only for accounts you own or are authorized to use. It does not bypass
OpenAI account limits, admin policy, verification, or access controls.

## Platform

Codexchange is currently Windows-first. The current scripts are designed for
Windows PowerShell because many Windows Codex users get Codex from the VS Code
extension path:

```text
%USERPROFILE%\.vscode\extensions\openai.chatgpt-*\bin\windows-x86_64\codex.exe
```

The PowerShell script also works with a normal `codex` command on `PATH`, or a
custom executable path set with:

```powershell
$env:CODEX_EXE = "C:\path\to\codex.exe"
```

Cross-platform support can be added later through a PowerShell 7 or Node.js CLI
wrapper.