# DeepSeek Harness - 桌面版安装脚本 (PowerShell)
# 作用: 检查/安装 Node.js -> 安装 dsh -> 复制文件到用户目录 -> 创建桌面快捷方式
# 全部路径自动生成, 不含任何作者个人信息。
# 编码: UTF-8 with BOM (PowerShell 5.1 读取中文需要)

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  DeepSeek Harness - 桌面版安装" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------
# 0. 确定安装目录: 放到用户目录, 这样删除下载的压缩包也不影响
# ---------------------------------------------------------------
$installDir = Join-Path $env:LOCALAPPDATA "DeepSeekHarness"
$srcDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---------------------------------------------------------------
# 1. 检查 Node.js, 没有则尝试自动安装
# ---------------------------------------------------------------
function Find-NodeExe {
    # 检查 PATH
    $cmd = Get-Command node -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    # 常见安装位置
    $candidates = @(
        "$env:ProgramFiles\nodejs\node.exe",
        "${env:ProgramFiles(x86)}\nodejs\node.exe",
        "$env:LOCALAPPDATA\Programs\nodejs\node.exe",
        "$env:APPDATA\npm\node.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    return $null
}

$nodeExe = Find-NodeExe

if (-not $nodeExe) {
    Write-Host "[1/4] 未检测到 Node.js, 尝试自动安装..." -ForegroundColor Yellow
    # 优先 winget (Win10 1709+ 自带)
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Host "      使用 winget 安装 Node.js LTS (可能需要几分钟, 请耐心等待)..." -ForegroundColor Yellow
        try {
            winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements | Out-Null
            Start-Sleep -Seconds 3
        } catch {
            Write-Host "      winget 安装失败: $_" -ForegroundColor Red
        }
    }
    # 再次检测
    $nodeExe = Find-NodeExe
    if (-not $nodeExe) {
        Write-Host ""
        Write-Host "[ERROR] 未能自动安装 Node.js。" -ForegroundColor Red
        Write-Host "       请手动安装 Node.js 后重新运行本脚本:" -ForegroundColor Red
        Write-Host "       1. 用浏览器打开 https://nodejs.org 下载 LTS 版" -ForegroundColor Yellow
        Write-Host "       2. 安装时一路点 Next 即可" -ForegroundColor Yellow
        Write-Host "       3. 安装完成后重新双击 install.bat" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "      Node.js 安装成功: $nodeExe" -ForegroundColor Green
} else {
    Write-Host "[1/4] 已检测到 Node.js: $nodeExe" -ForegroundColor Green
}

# ---------------------------------------------------------------
# 2. 安装 dsh (DeepSeek Harness CLI)
# ---------------------------------------------------------------
Write-Host "[2/4] 正在安装 DeepSeek Harness (dsh)..." -ForegroundColor Cyan
$nodeDir = Split-Path -Parent $nodeExe
$npmCmd = Join-Path $nodeDir "npm.cmd"
if (-not (Test-Path $npmCmd)) { $npmCmd = "npm" }

& $npmCmd install -g @deepseek-ai/dsh
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] dsh 安装失败, 请检查网络后重试。" -ForegroundColor Red
    exit 1
}
Write-Host "      dsh 安装成功" -ForegroundColor Green

# ---------------------------------------------------------------
# 3. 复制启动器文件到安装目录
# ---------------------------------------------------------------
Write-Host "[3/4] 正在复制启动文件..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
foreach ($file in @("dsh-launcher.cjs", "start-dsh.vbs", "stop-dsh.vbs", "dsh.ico")) {
    $src = Join-Path $srcDir $file
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $installDir $file) -Force
    }
}
Write-Host "      文件已复制到: $installDir" -ForegroundColor Green

# ---------------------------------------------------------------
# 4. 创建桌面快捷方式
# ---------------------------------------------------------------
Write-Host "[4/4] 正在创建桌面快捷方式..." -ForegroundColor Cyan
$desktop = [Environment]::GetFolderPath("Desktop")
$wsh = New-Object -ComObject WScript.Shell

function New-Shortcut($name, $vbsFile, $desc) {
    $lnk = $wsh.CreateShortcut((Join-Path $desktop "$name.lnk"))
    $lnk.TargetPath = "$env:WINDIR\System32\wscript.exe"
    $lnk.Arguments = '"' + (Join-Path $installDir $vbsFile) + '"'
    $lnk.WorkingDirectory = $installDir
    $lnk.IconLocation = (Join-Path $installDir "dsh.ico") + ",0"
    $lnk.Description = $desc
    $lnk.Save()
}

New-Shortcut "DeepSeek Harness" "start-dsh.vbs" "启动 DeepSeek Harness (后台运行, 不依赖终端)"
New-Shortcut "Stop DeepSeek Harness" "stop-dsh.vbs" "停止 DeepSeek Harness 后台服务"
Write-Host "      桌面快捷方式已创建" -ForegroundColor Green

# ---------------------------------------------------------------
# 完成
# ---------------------------------------------------------------
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  安装完成!" -ForegroundColor Green
Write-Host "  现在双击桌面上的 DeepSeek Harness 图标即可使用" -ForegroundColor Green
Write-Host "  首次启动需要几分钟初始化, 请耐心等待" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
exit 0
