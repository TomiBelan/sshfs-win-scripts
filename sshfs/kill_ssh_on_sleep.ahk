; https://docs.microsoft.com/en-us/windows/win32/power/wm-powerbroadcast
; https://docs.microsoft.com/en-us/windows/win32/power/pbt-apmsuspend

OnMessage(0x218, "myhandler")   ; 0x218 = WM_POWERBROADCAST

myhandler(wparam, lparam)
{
  ; msgbox test w=%wparam% l=%lparam%
  FormatTime now
  ; FileAppend %now% %wparam% %lparam%`n, log.txt
  if (wparam = 0x4) {   ; 0x4 = PBT_APMSUSPEND
    Run, powershell.exe -ExecutionPolicy Bypass ./kill_ssh_now.ps1, %A_ScriptDir%, Hide
  }
}
