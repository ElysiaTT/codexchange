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

To keep the command available in new shells, add that `PATH` line to your shell
profile, such as `~/.profile`, `~/.bashrc`, or `~/.zshrc`.

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
This also applies on remote SSH servers: VS Code Remote or another IDE can keep
showing the old account even after the server's `~/.codex/auth.json` has already
changed.

```text
Codex CLI/TUI: start a fresh session
VS Code Remote / SSH server: Developer: Reload Window, or restart the IDE client
VS Code local: Developer: Reload Window
Codex desktop app: close the app completely, then reopen it
```

Use `codex-auth-profile status` if you want to verify the active auth file
before reloading or restarting the IDE.

## Custom Codex Path

```sh
export CODEX_EXE=/path/to/codex
codex-auth-profile status
```
