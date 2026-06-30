@echo off
set "SCRIPT=%~dp0..\windows\codex-auth-profile.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
