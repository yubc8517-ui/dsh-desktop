@echo off
chcp 65001 >nul
title DeepSeek Harness Uninstaller
echo.
echo ============================================
echo   DeepSeek Harness - 卸载
echo ============================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"
set EXITCODE=%ERRORLEVEL%

echo.
if "%EXITCODE%"=="0" (
  echo ============================================
  echo   卸载完成。
  echo   dsh 本身 (npm 全局包) 如需卸载:
  echo     npm uninstall -g @deepseek-ai/dsh
  echo ============================================
) else (
  echo   卸载过程中出现问题, 请手动删除快捷方式和安装目录。
)
echo.
pause
