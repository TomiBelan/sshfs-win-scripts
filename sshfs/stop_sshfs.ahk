#Requires AutoHotkey v2.0

; This script is not called from anywhere. Run it manually if you wish to cleanly unmount the network drive.

; It finds the sshfs process and sends it a Ctrl+C.

; More info:
; https://github.com/billziss-gh/winfsp/issues/47
; https://blog.codetitans.pl/post/sending-ctrl-c-signal-to-another-application-on-windows/
; https://learn.microsoft.com/en-us/windows/console/freeconsole
; https://learn.microsoft.com/en-us/windows/console/attachconsole
; https://learn.microsoft.com/en-us/windows/console/setconsolectrlhandler
; https://learn.microsoft.com/en-us/windows/console/generateconsolectrlevent

VerboseMsgBox(msg) {
;  MsgBox(msg)
}

sshfsPath := A_ScriptDir "\build_output\bin\sshfs.exe"
sshfsPID := 0

; Is this really the best possible way? :/
for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process") {
  if process.ExecutablePath = sshfsPath {
    sshfsPID := process.processId
    VerboseMsgBox("found " process.processId " = " process.ExecutablePath)
  }
}

if (sshfsPID = 0) {
  MsgBox("sshfs (" sshfsPath ") is not running")
  return
}

;DetectHiddenWindows(true)
;sshfsList := WinGetList("ahk_exe " sshfsPath)
;if (sshfsList.Length == 0) {
;  MsgBox("sshfs (" sshfsPath ") is not running")
;  return
;}
;
;sshfsPID := WinGetPID("ahk_id " sshfsList[1])
;
;VerboseMsgBox("found " (sshfsList.Length) "windows, going to kill PID " sshfsPID)

if (DllCall("FreeConsole") == 0) {
  MsgBox("FreeConsole failed with " A_LastError)
  return
}

if (DllCall("AttachConsole", "UInt", sshfsPID) == 0) {
  MsgBox("AttachConsole failed with " A_LastError)
  return
}

if (DllCall("SetConsoleCtrlHandler", "Ptr", 0, "Int", 1) == 0) {
  MsgBox("SetConsoleCtrlHandler failed with " A_LastError)
  return
}

if (DllCall("GenerateConsoleCtrlEvent", "UInt", 0, "UInt", 0) == 0) {   ; CTRL_C_EVENT == 0
  MsgBox("GenerateConsoleCtrlEvent failed with " A_LastError)
  return
}

VerboseMsgBox("sent ctrl+c to " sshfsPID)
