# DeepSeek Harness 桌面版

> 把 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 变成像普通软件一样使用的桌面应用 —— **不需要懂任何命令行**。

![logo](logo.png)

## 这是什么?

DeepSeek Harness 是一个 AI 智能体工具(Agent),本来需要在终端里敲命令启动。
本项目把它包装成 **Windows 桌面应用**:

- ✅ 双击桌面图标即可启动,自动打开独立应用窗口(像普通软件一样)
- ✅ 关闭窗口/终端后,服务仍在后台运行
- ✅ 官方图标、一键安装、一键卸载

## 适合谁?

- 不懂 shell 命令的小白爱好者
- 想快速体验 DeepSeek Harness 的 Windows 用户

---

## 快速开始(只需 3 步)

### 第 1 步:下载

点击本页面右上角绿色 **Code** 按钮 → **Download ZIP**,解压到任意文件夹。

### 第 2 步:安装(双击一次)

双击文件夹里的 **`install.bat`**,然后:

| 遇到什么 | 怎么办 |
|---|---|
| 弹出"安装完成" | ✅ 直接看第 3 步 |
| 弹出"正在安装 Node.js" | 正常!第一次使用会自动安装 Node.js(需要几分钟,可能弹出系统授权窗口,点"是"即可) |
| 提示"未能自动安装 Node.js" | 会**自动打开 nodejs.org 下载页**,下载 LTS 版,一路 Next 安装,再回来双击 `install.bat` |
| 出现蓝色 PowerShell 窗口 | 正常,等它自己跑完即可 |
| 提示"已检测到正在运行" | 说明之前启动过,先双击桌面 "Stop DeepSeek Harness" 再重新安装 |

> 安装程序会自动:安装 Node.js(如需要)→ 安装 dsh → 复制文件 → 在桌面创建两个快捷方式。
> 如果之前**已经装过** DeepSeek Harness,安装程序会自动检测并复用,你的配置和记录不会丢失。

### 第 3 步:开始使用

双击桌面上的 **"DeepSeek Harness"** 图标:

1. 第一次启动需要 1~3 分钟初始化(请耐心等待)
2. 初始化完成后,会自动弹出独立应用窗口
3. 如果窗口没有自动弹出,手动打开浏览器访问 `http://127.0.0.1:3080`

---

## 日常使用

| 操作 | 方法 |
|---|---|
| **启动** | 双击桌面 "DeepSeek Harness" |
| **停止** | 双击桌面 "Stop DeepSeek Harness" |
| **查看日志** | 打开 `%LOCALAPPDATA%\DeepSeekHarness\dsh-web.log` |
| **卸载** | 双击安装文件夹里的 `uninstall.bat` |

> 提示:可以在应用窗口右上角把窗口固定到任务栏,以后一键启动更顺手。

---

## 常见问题 (FAQ)

### 1. 双击图标后浏览器没打开?
服务可能还在启动中,等 1~2 分钟,手动访问 `http://127.0.0.1:3080`。

### 2. 双击图标没反应?
- 看看桌面上 "DeepSeek Harness" 图标是否还在
- 重新运行一次 `install.bat`
- 查看日志 `%LOCALAPPDATA%\DeepSeekHarness\dsh-web.log`

### 3. 提示端口被占用?
说明已有实例在运行(比如之前手动开过终端版)。
先双击 "Stop DeepSeek Harness",再重新启动。

### 4. 需要懂命令行吗?
**完全不需要。** 所有安装、启动、停止都是双击完成。

### 5. 关掉窗口后服务会停吗?
不会。关闭窗口只关界面,服务在后台继续运行,下次双击图标会重新打开窗口。

### 6. 我电脑上没有 Node.js 也能装吗?
**能。** 安装程序检测到没有 Node.js 时会自动安装(推荐方式,全程自动);
如果自动安装失败,会自动打开 nodejs.org 让你手动下载,装完再双击一次
`install.bat` 即可。**不需要你自己懂 Node.js 是什么。**

### 7. 我之前已经装过 DeepSeek Harness,会冲突吗?
**不会。** 安装程序会自动检测已安装的版本并复用,你的配置、API Key、
聊天记录都在 `~/.dsh` 里,不会丢失。装完直接双击桌面图标就能用。
唯一注意:如果 Harness 正在运行,先双击 "Stop DeepSeek Harness" 停止,
再运行 install.bat(运行中更新会锁定文件导致失败)。

---

## 隐私说明

- 本项目**不上传任何个人数据**,一切运行在你的电脑本地
- 配置文件保存在 `~/.dsh`(你的用户目录下)
- 使用 DeepSeek API 时,请按 Harness 官方文档自行配置你的 API Key

## 技术原理(给感兴趣的人)

| 组件 | 作用 |
|---|---|
| `dsh-launcher.cjs` | 核心启动器:检测端口、后台启动服务、打开应用窗口 |
| `start-dsh.vbs` / `stop-dsh.vbs` | 隐藏窗口的启停入口(双击/快捷方式调用) |
| `install.ps1` / `install.bat` | 一键安装:自动装 Node.js + dsh + 创建快捷方式 |
| `dsh.ico` | DeepSeek 官方图标 |

底层是官方发布的 `@deepseek-ai/dsh` npm 包,本项目只是把它包装成易用的桌面形式。

## 致谢

- [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 官方项目
- DeepSeek 官方品牌图标

## License

MIT
