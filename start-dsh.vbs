' DeepSeek Harness 桌面启动器 (通用版, 供 GitHub 发布)
' 双击此文件: 后台启动 dsh web 并打开独立应用窗口, 不弹任何窗口。
' 该进程脱离终端运行, 关闭终端不影响服务。
' 所有路径自动检测: 脚本所在目录即安装目录, node 从系统 PATH 获取。
Option Explicit
Dim shell, fso, baseDir, nodeCmd
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
' 脚本所在目录 (自动检测, 不硬编码)
baseDir = fso.GetParentFolderName(WScript.ScriptFullName)
' node 命令: 优先用脚本同目录的 node.exe (便携场景), 否则用系统 PATH 中的 node
If fso.FileExists(baseDir & "\node.exe") Then
  nodeCmd = """" & baseDir & "\node.exe"""
Else
  nodeCmd = "node"
End If
' Run 的第二个参数 0 = 隐藏窗口; 第三个参数 False = 不等待, 立即返回
shell.Run nodeCmd & " """ & baseDir & "\dsh-launcher.cjs"" start", 0, False
