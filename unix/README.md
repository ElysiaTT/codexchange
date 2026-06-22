# Linux And macOS

Use this version on Linux, macOS, WSL, and remote SSH servers. It is a Python
CLI with a small POSIX shell wrapper.

## Requirements

```text
python3
codex on PATH
```

## Install

From the repository root:

```sh
sh ./unix/install.sh
export PATH="$HOME/.local/bin:$PATH"
```

The root installer still works and delegates here:

```sh
sh ./install.sh
```

## Commands

```sh
codex-auth-profile save team-a
codex-auth-profile login-as team-b
codex-auth-profile login-as team-b --device-auth
codex-auth-profile use team-b
codex-auth-profile list
```

On headless servers, prefer:

```sh
codex-auth-profile login-as team-b --device-auth
```

## After Switching

The file switches immediately, but open sessions cache auth in memory.

```text
Codex CLI/TUI: start a fresh session
VS Code Remote: Developer: Reload Window on the client
Codex desktop app: close the app completely, then reopen it
```

## Custom Codex Path

```sh
export CODEX_EXE=/path/to/codex
codex-auth-profile status
```
