' DeepSeek Harness 停止脚本 (通用版, 供 GitHub 发布)
' 双击此文件: 终止监听在 127.0.0.1:3080 上的 dsh web 服务。
Option Explicit
Dim shell, fso, baseDir, nodeCmd
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
baseDir = fso.GetParentFolderName(WScript.ScriptFullName)
If fso.FileExists(baseDir & "\node.exe") Then
  nodeCmd = """" & baseDir & "\node.exe"""
Else
  nodeCmd = "node"
End If
shell.Run nodeCmd & " """ & baseDir & "\dsh-launcher.cjs"" stop", 0, False
