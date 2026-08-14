@echo off
chcp 65001 >nul
title DeepSeek Harness Installer
echo.
echo ============================================
echo   DeepSeek Harness - 桌面版一键安装
echo ============================================
echo.

REM 找到 PowerShell 并运行安装脚本
where powershell >nul 2>nul
if errorlevel 1 (
  echo [ERROR] PowerShell not found. Windows 10/11 required.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
set EXITCODE=%ERRORLEVEL%

echo.
if "%EXITCODE%"=="0" (
  echo ============================================
  echo   安装完成! 桌面上已出现两个快捷方式:
  echo     "DeepSeek Harness"        - 启动
  echo     "Stop DeepSeek Harness"   - 停止
  echo   双击 "DeepSeek Harness" 即可开始使用。
  echo ============================================
) else (
  echo ============================================
  echo   安装未完成, 请根据上方提示操作后重试。
  echo ============================================
)
echo.
pause
