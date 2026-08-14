# DeepSeek Harness - 桌面版卸载脚本
$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

trap {
    Write-Host ""
    Write-Host "[ERROR] 卸载过程中出现问题: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  DeepSeek Harness - 卸载" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# 删除桌面快捷方式
$desktop = [Environment]::GetFolderPath("Desktop")
foreach ($name in @("DeepSeek Harness.lnk", "Stop DeepSeek Harness.lnk")) {
    $lnk = Join-Path $desktop $name
    if (Test-Path $lnk) {
        Remove-Item $lnk -Force
        Write-Host "已删除: $lnk" -ForegroundColor Green
    }
}

# 删除安装目录
$installDir = Join-Path $env:LOCALAPPDATA "DeepSeekHarness"
if (Test-Path $installDir) {
    Remove-Item $installDir -Recurse -Force
    Write-Host "已删除: $installDir" -ForegroundColor Green
}

Write-Host "卸载完成" -ForegroundColor Green
exit 0
