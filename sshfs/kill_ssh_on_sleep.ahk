#Requires AutoHotkey v2.0

; This script notices when the computer is about to sleep and hibernate, and closes the connection by running kill_ssh_now.ps1.
; It is usually started by a shortcut in the user's Startup folder. It can also be started manually.

; More info:
; https://docs.microsoft.com/en-us/windows/win32/power/wm-powerbroadcast
; https://docs.microsoft.com/en-us/windows/win32/power/pbt-apmsuspend

TraySetIcon("shell32.dll", 43)

OnMessage(0x218, myhandler)   ; 0x218 = WM_POWERBROADCAST

Persistent

myhandler(wparam, lparam, msg, hwnd)
{
  ; MsgBox("test w=" wparam " l=" lparam)
  ; FileAppend(FormatTime(, "HH:mm:ss") " " wparam " " lparam "`n", "log.txt")
  if (wparam = 0x4) {   ; 0x4 = PBT_APMSUSPEND
    Run("powershell.exe -ExecutionPolicy Bypass ./kill_ssh_now.ps1", A_ScriptDir, "Hide")
  }
  ; FileAppend(FormatTime(, "HH:mm:ss") " done`n", "log.txt")
}
