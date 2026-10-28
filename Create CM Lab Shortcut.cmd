@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0desktop\Install-Shortcut.ps1"
if errorlevel 1 pause
