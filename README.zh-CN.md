# Codexchange

[English](README.md)

一个轻量的 Windows 辅助工具，用来切换本地 Codex 账号。它不会让你退出浏览器里的 ChatGPT，也不需要对当前 Codex 账号反复执行 `codex logout`。

它管理的是本地 Codex `auth.json` 配置档案：

```text
%USERPROFILE%\.codex\auth.json
%USERPROFILE%\.codex\auth-profiles\<name>.auth.json
```

## 为什么需要这个工具

Codex CLI 和 VS Code Codex 扩展都会使用本地认证状态。如果你有两个可用的 Codex 账号，通过反复登出再登录来切换会很麻烦。更糟的是，`codex logout` 可能会撤销当前 `auth.json` 里的 refresh token，导致之前保存的配置档案之后报错：

```text
Your access token could not be refreshed because your refresh token was revoked.
Please log out and sign in again.
```

这个项目会避开这种流程。要添加第二个账号，请使用 `login-as`，它会在隔离的 `CODEX_HOME` 中运行 Codex 登录，然后把登录结果保存成一个配置档案。

## 安装

在本项目目录下运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

打开一个新的 PowerShell 窗口，然后运行：

```powershell
codex-auth-profile.cmd help
```

你也可以不安装，直接运行：

```powershell
.\bin\codex-auth-profile.cmd help
```

## 推荐用法

保存当前可用的 Codex 登录状态：

```powershell
codex-auth-profile.cmd save team-a
```

安全地添加另一个账号：

```powershell
codex-auth-profile.cmd login-as team-b
```

切换账号：

```powershell
codex-auth-profile.cmd use team-a
codex-auth-profile.cmd use team-b
```

查看已经保存的配置档案：

```powershell
codex-auth-profile.cmd list
codex-auth-profile.cmd status
```

## 切换之后

`use <profile>` 会立即替换本地 Codex 认证文件，但已经打开的 Codex 界面可能仍然把旧账号缓存到了内存里。

运行下面的命令后：

```powershell
codex-auth-profile.cmd use team-b
```

请重新加载你正在使用的 Codex 界面：

```text
VS Code: Ctrl+Shift+P -> Developer: Reload Window
Codex desktop app: 完全关闭应用，然后重新打开
Codex CLI/TUI: 开启一个新的会话
```

如果菜单里显示的账号名在重新加载前没有变化，这是正常的。文件已经切换了，只是界面还没有重新读取。

## 不要使用这种流程

请避免下面这种做法：

```powershell
codex-auth-profile.cmd save team-a
codex logout
codex login
codex-auth-profile.cmd save team-b
```

其中的 `logout` 步骤可能会让你刚刚保存的配置档案里的 refresh token 失效。如果你已经这样做过，并且某个配置档案已经失效，请重新刷新它：

```powershell
codex-auth-profile.cmd login-as team-a -Force
```

## 命令

```text
list                 列出已保存的配置档案
save <name>          将当前激活的 auth.json 保存为一个配置档案
use <name>           启用一个已保存的配置档案
login-as <name>      在隔离的 CODEX_HOME 下登录，并保存为配置档案
backup               备份当前激活的 auth.json
status               显示不包含敏感信息的认证摘要和 codex 登录状态
where                显示本工具使用的路径
help                 显示帮助信息
```

## 安全

保存的配置档案包含真实登录凭据。请永远不要提交或分享下面这些内容：

```text
auth.json
*.auth.json
auth-profiles/
```

本仓库的 `.gitignore` 已经排除了这些模式。

请只把这个工具用于你自己拥有或被授权使用的账号。它不会绕过 OpenAI 账号限制、管理员策略、验证流程或访问控制。

## 平台

当前脚本面向 Windows PowerShell，因为很多 Windows 上的 Codex VS Code 用户会从下面的位置获得 Codex：

```text
%USERPROFILE%\.vscode\extensions\openai.chatgpt-*\bin\windows-x86_64\codex.exe
```

PowerShell 脚本也支持使用 `PATH` 中普通的 `codex` 命令，或者通过下面的环境变量指定自定义可执行文件路径：

```powershell
$env:CODEX_EXE = "C:\path\to\codex.exe"
```
