# Codexchange（Codex Account Switcher / Codex 账号切换工具）

[English](README.md)

**Switch Codex accounts without logging out of ChatGPT / 无需退出 ChatGPT 即可切换 Codex 账号**

Codexchange is a cross-platform tool for managing Codex auth profiles.
Codexchange 是一个跨平台 Codex 账号管理工具。

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

## Why / 为什么

Avoid breaking auth state caused by repeated logout/login.
避免频繁 logout/login 导致认证状态异常。

Use `login-as` for isolated login.
使用 `login-as` 进行隔离登录。

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

- 多账号切换
- 隔离登录
- 自动备份
- 跨平台支持

---

## Commands / 命令

- list
- save
- use
- login-as
- status
- backup
- where
