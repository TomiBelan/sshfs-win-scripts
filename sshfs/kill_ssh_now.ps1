Get-Process | Where { $_.Path -match 'sshfs.*\\bin\\ssh\.exe$' } | Stop-Process
