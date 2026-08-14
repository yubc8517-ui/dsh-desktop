@echo off
chcp 65001 >nul
title DeepSeek Harness Uninstaller
echo.
echo ============================================
echo   DeepSeek Harness - Uninstall
echo ============================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"
set EXITCODE=%ERRORLEVEL%

echo.
if "%EXITCODE%"=="0" (
  echo ============================================
  echo   UNINSTALL COMPLETE
  echo   To also remove dsh itself, run:
  echo     npm uninstall -g @deepseek-ai/dsh
  echo ============================================
) else (
  echo   Uninstall had problems. Delete the shortcuts
  echo   and the install folder manually if needed.
)
echo.
pause
