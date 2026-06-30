@echo off
set "SCRIPT=%~dp0codex-auth-profile.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
