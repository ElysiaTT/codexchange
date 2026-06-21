@echo off
set "SCRIPT=%~dp0codex-auth-profile.ps1"
if not exist "%SCRIPT%" set "SCRIPT=%~dp0..\scripts\codex-auth-profile.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
