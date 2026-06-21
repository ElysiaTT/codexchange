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

`login-as` runs `codex login` under an isolated `CODEX_HOME`, then copies only
the resulting `auth.json` into the requested profile. It does not log out the
currently active Codex account.

If a profile is already revoked, there is no local repair for that token. Log in
again with:

```powershell
codex-auth-profile.cmd login-as team-a -Force
```

## `codex` command is not found

Install Codex CLI, or install the official VS Code Codex extension. This tool
also searches common VS Code extension paths for `openai.chatgpt-*`.

If Codex is installed somewhere custom:

```powershell
$env:CODEX_EXE = "C:\path\to\codex.exe"
codex-auth-profile.cmd status
```

## The wrong ChatGPT account was saved

During `login-as`, Codex opens the browser login flow. Make sure the browser
finishes login with the account you intended. If the wrong account was saved:

```powershell
codex-auth-profile.cmd login-as team-b -Force
```

Then complete the browser login with the correct account.

## The file switched, but the UI still shows the old account

`use <profile>` replaces the local `auth.json`. Already-open Codex surfaces may
keep the previous auth in memory until they reload.

For VS Code, run:

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

If the hashes match, the file switch succeeded. Reload VS Code, close/reopen
the Codex desktop app, or start a new Codex session.
