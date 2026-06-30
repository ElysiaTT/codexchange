# Troubleshooting / 故障排查

## Token revoked error / refresh token 被撤销

This usually happens when using `codex logout`.
通常发生在使用 `codex logout` 后。

Use `login-as` instead.
请使用 `login-as`。

### Fix / 修复

```powershell
codex-auth-profile.cmd login-as team-a -Force
```

---

## codex not found / 找不到 codex

Set `CODEX_EXE` or install Codex CLI.
设置 CODEX_EXE 或安装 Codex CLI。

---

## UI shows old account / UI 仍显示旧账号

The auth file is switched but UI cache is stale.
文件已切换，但 UI 未刷新。

Reload VS Code / restart app.
重新加载 VS Code 或重启应用。
