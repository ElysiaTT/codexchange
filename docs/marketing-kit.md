# Marketing Kit

This file collects short copy blocks for sharing Codexchange.

## One-liner

Switch Codex accounts without logging out of ChatGPT.

## Short description

Codexchange is a tiny Windows PowerShell helper for saving, switching, and restoring local Codex auth profiles. It is useful when you use multiple Codex-capable accounts and do not want to repeatedly run `codex logout` just to switch local account state.

## GitHub About description

Switch Codex accounts without logging out of ChatGPT. A Windows PowerShell tool for managing Codex auth profiles safely.

## Suggested GitHub topics

```text
codex
openai
chatgpt
powershell
windows
cli
developer-tools
auth
authentication
profile-switcher
vscode
```

## English launch post

```text
I built Codexchange, a tiny Windows PowerShell tool for switching Codex accounts without logging out of ChatGPT.

It lets you save the current Codex auth state, add another account in an isolated CODEX_HOME, and switch between profiles with one command.

Useful if you use multiple Codex-capable accounts and want to avoid repeated codex logout/login workflows.

GitHub: https://github.com/ElysiaTT/codexchange
```

## Chinese launch post

```text
我做了一个小工具 Codexchange：不用退出 ChatGPT，也能切换本地 Codex 账号。

它可以把当前 Codex 登录保存成 profile，再用隔离的 CODEX_HOME 登录另一个账号，之后一条命令切换。

适合有多个 Codex / ChatGPT 账号，但不想反复 logout/login 的 Windows 用户。

GitHub: https://github.com/ElysiaTT/codexchange
```

## V2EX / forum title ideas

```text
我做了个小工具：不用退出 ChatGPT，也能切换 Codex 账号
Codexchange：一个用于切换 Codex 本地 auth profile 的 Windows 小工具
分享一个 Windows PowerShell 工具，用来安全切换多个 Codex 账号
```

## Reddit / Hacker News title ideas

```text
Show HN: Codexchange - Switch Codex accounts without logging out of ChatGPT
I built a tiny Windows tool for switching local Codex auth profiles
Codexchange: Save and switch Codex auth profiles safely on Windows
```

## X / Twitter short post

```text
Built a tiny Windows helper for Codex users:

Codexchange lets you switch Codex accounts without logging out of ChatGPT.

save profile -> login isolated -> use profile

https://github.com/ElysiaTT/codexchange
```

## Short reply when someone asks why not just logout

```text
The goal is to avoid using `codex logout` as the account-switching mechanism. Codexchange keeps each login as a local profile and uses an isolated CODEX_HOME when adding another account, so the current browser or Codex session does not need to be logged out first.
```

## Social preview image text

Use a 1280x640 PNG with this text:

```text
Codexchange
Switch Codex accounts without logging out of ChatGPT
Save profiles - Isolated login - PowerShell
```

Recommended visual style:

```text
Dark terminal-style background, large white title, small command-line snippet, subtle blue/purple accent, no logos that imply official affiliation.
```
