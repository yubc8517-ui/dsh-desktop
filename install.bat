@echo off
chcp 65001 >nul
title DeepSeek Harness Installer
echo.
echo ============================================
echo   DeepSeek Harness - Desktop Installer
echo ============================================
echo.

REM Locate PowerShell
where powershell >nul 2>nul
if errorlevel 1 (
  echo [ERROR] PowerShell not found. Windows 10/11 is required.
  echo.
  pause
  exit /b 1
)

REM Run the installer script (all output is handled there)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
set EXITCODE=%ERRORLEVEL%

echo.
if "%EXITCODE%"=="0" (
  echo ============================================
  echo   INSTALL COMPLETE
  echo   Two shortcuts have been created on your desktop:
  echo     "DeepSeek Harness"       - Start
  echo     "Stop DeepSeek Harness"  - Stop
  echo   Double-click "DeepSeek Harness" to begin.
  echo ============================================
) else (
  echo ============================================
  echo   INSTALL DID NOT COMPLETE
  echo   Check the messages above, then run again.
  echo ============================================
)
echo.
pause
