# This script disconnects the current connection, but keeps the network drive mounted.
# It is called from kill_ssh_on_sleep.ahk and can be used manually. (Right click -> "Run with PowerShell".)
# sshfs will reconnect on next access.

# https://stackoverflow.com/questions/17563411/how-to-get-command-line-info-for-a-process-in-powershell-or-c-sharp

Get-WmiObject Win32_Process -Filter "name = 'ssh.exe'" | Where { ($_.CommandLine -match '-oClearAllForwardings=yes') -and ($_.CommandLine -match '-oGlobalKnownHostsFile=sshfs_ssh_marker') } | ForEach { Stop-Process -Id $_.ProcessId }
