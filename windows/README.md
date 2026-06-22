# Windows

Use this version on Windows PowerShell, especially when Codex comes from the
VS Code Codex extension.

## Install

From the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\install.ps1
```

The root installer still works and delegates here:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

## Commands

```powershell
codex-auth-profile.cmd save team-a
codex-auth-profile.cmd login-as team-b
codex-auth-profile.cmd login-as team-b -DeviceAuth
codex-auth-profile.cmd use team-b
codex-auth-profile.cmd list
```

## After Switching

The file switches immediately, but open UI surfaces cache auth in memory.

```text
VS Code: Ctrl+Shift+P -> Developer: Reload Window
Codex desktop app: close the app completely, then reopen it
Codex CLI/TUI: start a fresh session
```

## Custom Codex Path

```powershell
$env:CODEX_EXE = "C:\path\to\codex.exe"
codex-auth-profile.cmd status
```
