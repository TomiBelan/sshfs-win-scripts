param (
  [switch]$Waitless = $false,
  [switch]$Verbose = $false
)

$scriptrootslash = $PSScriptRoot.Replace("\", "/")   # shrug, blame cygwin (or maybe winfsp option parser)

$Env:SSH_ASKPASS = $PSScriptRoot + "\askpass1.bat"
$Env:SSH_ASKPASS_REQUIRE = "force"

#$exe = "C:\Program Files\SSHFS-Win\bin\sshfs.exe"
$exe = "$PSScriptRoot\build_output\bin\sshfs.exe"

$argarr = @(
  "-f",
  "-ofstypename=SSHFS",  # sshfs-win.c does it, unclear why
  "-ossh_command=/usr/bin/ssh",
#  "-ouid=-1,gid=-1",  # probably not needed
  "-oidmap=user",  # Needed in order to access e.g. folders with mode 700. (Does winfsp always enable "default_permissions"??)
  "-odelay_connect",
  "-oreconnect",
  "-oUserKnownHostsFile=$scriptrootslash/known_hosts",
  "-oIdentityFile=$scriptrootslash/tomi-REMOVED-id_ed25519",
  "-oPreferredAuthentications=publickey",
  "--VolumePrefix=/mysshfs/REMOVED",
  "tomi@REMOVED:/",
  "S:"  # no trailing comma
)

if ($Verbose) {
  $argarr = @("-d") + $argarr
}

# This should work well enough, as long as no argument contains a " or ends with a \.
# See also:
#   https://github.com/python/cpython/blob/5b63ba3ff5ab56ebf0ed1173cf01dd23169e3dfe/Lib/subprocess.py#L529
#   https://github.com/PowerShell/PowerShell/blob/master/src/System.Management.Automation/engine/NativeCommandProcessor.cs
$argstr = ($argarr | % { '"' + $_ + '"' }) -Join " "

if ($Verbose) {
  "args: $args"
  "original root: $PSScriptRoot"
  "replaced root: $scriptrootslash"
  "exe: $exe"
  "argstr: $argstr"
  "waitless: $Waitless"
}

If ($Waitless) {
  Start-Process -FilePath $exe -ArgumentList $argstr -WindowStyle Hidden
} Else {
  Start-Process -FilePath $exe -ArgumentList $argstr -NoNewWindow -Wait
}
