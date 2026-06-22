# Troubleshooting

## "Your access token could not be refreshed because your refresh token was revoked"

This usually means the saved profile contains a refresh token that has already
been invalidated by the identity provider.

The common cause is this flow:

```powershell
codex-auth-profile.cmd save team-a
codex logout
codex login
codex-auth-profile.cmd save team-b
```

`codex logout` can revoke the refresh token stored in the active `auth.json`.
If that active file was also saved as `team-a`, then switching back to `team-a`
may fail later because Codex cannot refresh the revoked token.

Use this flow instead:

```powershell
codex-auth-profile.cmd save team-a
codex-auth-profile.cmd login-as team-b
codex-auth-profile.cmd use team-b
```

On Linux/macOS:

```sh
codex-auth-profile save team-a
codex-auth-profile login-as team-b --device-auth
codex-auth-profile use team-b
```

`login-as` runs `codex login` under an isolated `CODEX_HOME`, then copies only
the resulting `auth.json` into the requested profile. It does not log out the
currently active Codex account.

If a profile is already revoked, there is no local repair for that token. Log in
again with:

```powershell
codex-auth-profile.cmd login-as team-a -Force
```

On Linux/macOS:

```sh
codex-auth-profile login-as team-a --force
```

## `codex` command is not found

Install Codex CLI, or install the official VS Code Codex extension. This tool
also searches common VS Code extension paths for `openai.chatgpt-*`.

If Codex is installed somewhere custom:

```powershell
$env:CODEX_EXE = "C:\path\to\codex.exe"
codex-auth-profile.cmd status
```

On Linux/macOS:

```sh
export CODEX_EXE=/path/to/codex
codex-auth-profile status
```

## The wrong ChatGPT account was saved

During `login-as`, Codex opens the browser login flow. Make sure the browser
finishes login with the account you intended. If the wrong account was saved:

```powershell
codex-auth-profile.cmd login-as team-b -Force
```

On Linux/macOS:

```sh
codex-auth-profile login-as team-b --force
```

Then complete the browser login with the correct account.

## The file switched, but the UI still shows the old account

`use <profile>` replaces the local `auth.json`. Already-open Codex surfaces may
keep the previous auth in memory until they reload.

This is expected on remote SSH servers too. The server's
`~/.codex/auth.json` can already match the selected profile while VS Code Remote
or another IDE still displays the previous account.

For VS Code local or VS Code Remote, run this in the client window, or restart
the IDE:

```text
Ctrl+Shift+P -> Developer: Reload Window
```

For the Codex desktop app, close the app completely and reopen it. For the
terminal UI, start a fresh Codex session.

Check the file switch:

```powershell
Get-FileHash "$env:USERPROFILE\.codex\auth.json"
Get-FileHash "$env:USERPROFILE\.codex\auth-profiles\team-b.auth.json"
```

On Linux/macOS:

```sh
sha256sum ~/.codex/auth.json ~/.codex/auth-profiles/team-b.auth.json
```

If the hashes match, the file switch succeeded. Reload or restart VS Code,
close/reopen the Codex desktop app, or start a new Codex session. On a remote
server, reload or restart the IDE client window; restarting only the server shell
is not enough to refresh an already-open IDE account menu.
