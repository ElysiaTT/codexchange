# Codexchange（Codex 账号切换工具）

[English](README.md)

**无需退出 ChatGPT，即可切换本地 Codex 账号。**

Codexchange 是一个轻量 Windows PowerShell 工具，用于保存、切换和恢复本地 Codex 登录状态（auth profile）。适用于需要同时使用多个 Codex / ChatGPT 账号，但不希望反复 logout / login 的场景。

```powershell
codex-auth-profile.cmd save personal
codex-auth-profile.cmd login-as work
codex-auth-profile.cmd use work
```

## 为什么需要它

Codex CLI 和 VS Code Codex 扩展使用本地登录状态。当你在多个账号之间频繁切换时，反复 logout/login 可能会导致本地状态混乱，并出现如下错误：

```text
Your access token could not be refreshed because you have since logged out or signed in to another account.
Please sign in again.
```

Codexchange 通过 `login-as` 避免这个问题：在隔离的 `CODEX_HOME` 中完成登录，再保存为独立 profile。

它管理的文件结构如下：

```text
%USERPROFILE%\.codex\auth.json
%USERPROFILE%\.codex\auth-profiles\<name>.auth.json
```

## 功能

- 保存当前登录为 profile
- 一键切换账号
- 在隔离环境登录新账号
- 自动备份 auth.json
- 查看账号状态（不包含敏感信息）
- Windows PowerShell / VS Code 友好

## 安装

在项目目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

然后打开新终端：

```powershell
codex-auth-profile.cmd help
```

也可以直接运行：

```powershell
.\bin\codex-auth-profile.cmd help
```

## 推荐用法

保存当前账号：

```powershell
codex-auth-profile.cmd save team-a
```

添加新账号：

```powershell
codex-auth-profile.cmd login-as team-b
```

切换账号：

```powershell
codex-auth-profile.cmd use team-a
codex-auth-profile.cmd use team-b
```

查看已保存账号：

```powershell
codex-auth-profile.cmd list
codex-auth-profile.cmd status
```

## 切换之后

`use <profile>` 会立即修改本地 auth 文件，但已打开的 Codex 界面可能仍缓存旧账号。

请执行：

```text
VS Code: Ctrl+Shift+P -> Developer: Reload Window
Codex desktop: 重启应用
CLI: 重新打开会话
```

## 避免旧流程

不要使用旧方式：

```powershell
codex-auth-profile.cmd save team-a
codex logout
codex login
codex-auth-profile.cmd save team-b
```

旧流程可能导致 token 状态异常。当前推荐使用 `login-as`。

如果已经出现问题：

```powershell
codex-auth-profile.cmd login-as team-a -Force
```

## 命令

```text
list         查看 profile
save         保存当前登录
use          切换 profile
login-as     在隔离环境登录
backup       备份 auth.json
status       查看状态
where        查看路径
help         帮助
```

## 发布说明

通过 GitHub tag 发布版本：

```powershell
git tag v1.0.0
git push origin v1.0.0
```

## 安全说明

请勿提交以下文件：

```text
auth.json
*.auth.json
auth-profiles/
```

## 平台说明

当前仅 Windows 优先。

路径：

```text
%USERPROFILE%\.vscode\extensions\openai.chatgpt-*\bin\windows-x86_64\codex.exe
```

未来可扩展跨平台支持。