#!/usr/bin/env node
"use strict";

/**
 * DeepSeek Harness 桌面启动器 (通用版, 供 GitHub 发布)
 *
 *  start (默认): 若端口未被占用, 以隐藏的、脱离终端的后台进程启动 dsh web,
 *                然后打开浏览器 UI (优先 Chrome/Edge --app 独立窗口)。
 *                若已在运行, 只打开窗口。
 *  stop:         终止监听在 web 端口上的进程 (dsh web 服务)。
 *  status:       打印运行状态。
 *
 * 本脚本不包含任何个人路径, 所有关键路径自动检测:
 *   - dsh CLI 入口: 依次尝试环境变量 DSH_BIN、npm 全局目录、常见安装位置
 *   - 工作目录:     默认脚本所在目录, 可用 DSH_WORKSPACE 覆盖
 *
 * 环境变量覆盖 (高级用途):
 *   DSH_HOST / DSH_PORT / DSH_BIN / DSH_WORKSPACE / DSH_LOG / DSH_HOME
 *   DSH_BROWSER (指定 Chromium 浏览器路径) / DSH_NO_BROWSER=1
 */

const net = require("net");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawn, execFile, execFileSync } = require("child_process");

const HOST = process.env.DSH_HOST || "127.0.0.1";
const PORT = Number(process.env.DSH_PORT || 3080);
const WORKSPACE = process.env.DSH_WORKSPACE || __dirname;
const LOG_FILE = process.env.DSH_LOG || path.join(WORKSPACE, "dsh-web.log");
const DSH_HOME = process.env.DSH_HOME || path.join(os.homedir(), ".dsh");
const NO_BROWSER = process.env.DSH_NO_BROWSER === "1";
const URL = `http://${HOST}:${PORT}`;

/** 定位 dsh CLI 入口 (lib/bin.js), 找不到返回 null。 */
function findDshBin() {
  if (process.env.DSH_BIN && fs.existsSync(process.env.DSH_BIN)) return process.env.DSH_BIN;
  const candidates = [];
  // 1) npm 全局目录 (Windows 默认 %APPDATA%\npm\node_modules)
  if (process.env.APPDATA) {
    candidates.push(path.join(process.env.APPDATA, "npm", "node_modules", "@deepseek-ai", "dsh", "lib", "bin.js"));
  }
  // 2) 通过 npm root -g 查询 (兼容非默认全局目录)
  try {
    const root = execFileSync("npm", ["root", "-g"], { encoding: "utf8", windowsHide: true }).trim();
    if (root) candidates.push(path.join(root, "@deepseek-ai", "dsh", "lib", "bin.js"));
  } catch (_) {
    /* npm 不可用时忽略 */
  }
  // 3) 脚本同目录的 node_modules (本地安装场景)
  candidates.push(path.join(__dirname, "node_modules", "@deepseek-ai", "dsh", "lib", "bin.js"));
  for (const c of candidates) {
    try {
      if (c && fs.existsSync(c)) return c;
    } catch (_) {
      /* ignore */
    }
  }
  return null;
}

const DSH_BIN = findDshBin();

function log(msg) {
  const line = `[${new Date().toISOString()}] ${msg}`;
  try {
    fs.appendFileSync(LOG_FILE, line + "\n");
  } catch (_) {
    /* 日志写失败不阻塞主流程 */
  }
  console.log(line);
}

/** 检查端口是否已被监听。 */
function portOpen(port, host) {
  return new Promise((resolve) => {
    const sock = net.connect({ port, host });
    sock.setTimeout(1200);
    sock.once("connect", () => {
      sock.destroy();
      resolve(true);
    });
    sock.once("timeout", () => {
      sock.destroy();
      resolve(false);
    });
    sock.once("error", () => {
      sock.destroy();
      resolve(false);
    });
  });
}

/** Chromium 系浏览器候选路径 (用于 --app 独立窗口模式)。 */
function findChromium() {
  const candidates = [
    process.env.DSH_BROWSER,
    "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
    "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
    path.join(process.env.LOCALAPPDATA || "", "Google\\Chrome\\Application\\chrome.exe"),
    "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
    "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe",
    path.join(process.env.LOCALAPPDATA || "", "Microsoft\\Edge\\Application\\msedge.exe"),
  ].filter(Boolean);
  for (const p of candidates) {
    try {
      if (p && fs.existsSync(p)) return p;
    } catch (_) {
      /* ignore */
    }
  }
  return null;
}

/**
 * 打开 UI: 优先用 Chromium 的 --app 模式打开独立应用窗口
 * (无地址栏、无标签页, 类似桌面应用); 找不到则回退默认浏览器。
 */
function openBrowser() {
  if (NO_BROWSER) {
    log(`[launcher] skip browser open (DSH_NO_BROWSER=1)`);
    return;
  }
  const chromium = findChromium();
  if (chromium) {
    spawn(chromium, [`--app=${URL}`], {
      stdio: "ignore",
      detached: true,
      windowsHide: true,
    }).unref();
    log(`[launcher] opening app window (${path.basename(chromium)} --app) at ${URL}`);
    return;
  }
  if (process.platform === "win32") {
    spawn("cmd.exe", ["/c", "start", "", URL], {
      stdio: "ignore",
      detached: true,
      windowsHide: true,
    }).unref();
  } else {
    spawn("xdg-open", [URL], { stdio: "ignore", detached: true }).unref();
  }
  log(`[launcher] opening default browser at ${URL}`);
}

/** 启动 (若未运行) 并打开窗口。 */
async function startServer() {
  if (!DSH_BIN) {
    log("[launcher] ERROR: dsh CLI not found. Run install.bat first, or set DSH_BIN.");
    console.error("dsh CLI not found. 请先运行 install.bat, 或设置 DSH_BIN 环境变量。");
    process.exitCode = 1;
    return;
  }
  if (await portOpen(PORT, HOST)) {
    log(`[launcher] already running at ${URL}; opening window`);
    openBrowser();
    return;
  }
  log(`[launcher] starting dsh web: ${DSH_BIN}`);
  log(`[launcher] workspace=${WORKSPACE}  DSH_HOME=${DSH_HOME}  log=${LOG_FILE}`);
  const logFd = fs.openSync(LOG_FILE, "a");
  const child = spawn(process.execPath, [DSH_BIN, "web"], {
    cwd: WORKSPACE,
    detached: true, // 脱离进程组: 启动器/终端关闭后服务继续运行
    windowsHide: true, // 不弹出控制台窗口
    stdio: ["ignore", logFd, logFd],
    env: { ...process.env, DSH_HOME },
  });
  child.unref();
  // 等待端口就绪 (最长 ~30s), 再打开窗口。
  const deadline = Date.now() + 30_000;
  let up = false;
  while (Date.now() < deadline) {
    await new Promise((r) => setTimeout(r, 600));
    if (await portOpen(PORT, HOST)) {
      up = true;
      break;
    }
  }
  log(up ? `[launcher] server is up at ${URL}` : `[launcher] timeout waiting for ${URL}; see ${LOG_FILE}`);
  openBrowser();
}

/** 查找监听 HOST:PORT 的进程 PID。 */
function findPidListening() {
  return new Promise((resolve) => {
    execFile("netstat", ["-ano", "-p", "tcp"], { windowsHide: true }, (err, stdout) => {
      if (err) return resolve(null);
      const wanted = `${HOST}:${PORT}`.toLowerCase();
      for (const line of stdout.split(/\r?\n/)) {
        const m = line.trim().match(/^TCP\s+(\S+)\s+\S+\s+LISTENING\s+(\d+)$/i);
        if (!m) continue;
        if (m[1].toLowerCase() === wanted) return resolve(Number(m[2]));
      }
      resolve(null);
    });
  });
}

/** 停止服务。 */
async function stopServer() {
  const pid = await findPidListening();
  if (!pid) {
    log(`[launcher] nothing listening on ${URL}`);
    return;
  }
  log(`[launcher] stopping pid ${pid} (${URL})`);
  execFile("taskkill", ["/PID", String(pid), "/F", "/T"], { windowsHide: true }, (err) => {
    if (err) log(`[launcher] taskkill failed: ${err.message}`);
    else log(`[launcher] stopped ${URL}`);
  });
}

/** 打印状态。 */
async function status() {
  const pid = await findPidListening();
  log(pid ? `[launcher] ${URL} is RUNNING (pid ${pid})` : `[launcher] ${URL} is not running`);
}

const action = (process.argv[2] || "start").toLowerCase();
if (action === "stop") {
  stopServer();
} else if (action === "status") {
  status();
} else {
  startServer();
}
