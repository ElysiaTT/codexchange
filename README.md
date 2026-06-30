# Codexchange

🌐 Language: English | 中文

**Switch Codex accounts without logging out of ChatGPT / 无需退出 ChatGPT 即可切换 Codex 账号**

Codexchange is a cross-platform tool (Windows + Unix) for saving, switching, and restoring local Codex auth profiles.

Codexchange 是一个跨平台工具（Windows + Unix），用于保存、切换和恢复本地 Codex 登录状态。

---

## Quick Start / 快速开始

```powershell
# Windows
codex-auth-profile.cmd save team-a
codex-auth-profile.cmd login-as team-b
codex-auth-profile.cmd use team-b
```

```sh
# Linux / macOS / SSH
codex-auth-profile save team-a
codex-auth-profile login-as team-b
codex-auth-profile use team-b
```

---

## Why / 为什么需要

Repeated logout/login can corrupt local Codex auth state.
频繁 logout/login 可能导致本地 Codex 认证状态异常。

Use isolated login instead of `codex logout`.
使用隔离登录 `login-as` 替代 `codex logout`。

---

## Install / 安装

### Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Unix

```sh
sh ./unix/install.sh
```

---

## Features / 功能

- Save profiles / 保存账号
- Switch profiles / 切换账号
- Isolated login / 隔离登录
- Backup auth.json / 自动备份
- Cross-platform / 跨平台支持

---

## Files / 文件结构

```text
~/.codex/auth.json
~/.codex/auth-profiles/*.auth.json
```

---

## Platform Notes / 平台说明

Windows uses PowerShell implementation.
Windows 使用 PowerShell 实现。

Unix uses Python CLI implementation.
Unix 使用 Python CLI 实现。

---

## Commands / 命令

- list / 列出
- save / 保存
- use / 切换
- login-as / 隔离登录
- status / 状态
- backup / 备份
- where / 路径
