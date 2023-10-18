param (
  [switch]$Waitless = $false,
  [switch]$Verbose = $false
)

# ----- my config -----
$MyMountPoint = "S:"
$MyVolumePrefix = "/mysshfs/REMOVED"
$MyUserHostPath = "tomi@REMOVED:/"
$MySubwrapPaths = "myhome=/home/tomi:root=/"
# ---------------------

$windir = $Env:WINDIR.Replace("\", "/")   # shrug, blame cygwin (or maybe winfsp option parser)

$exe = "$PSScriptRoot\build_output\bin\sshfs.exe"

$argarr = @(
  # SSHFS option. Stay in the foreground. This script will take care of running it in background depending on -Waitless.
  "-f",

  # WinFsp option. Copied from sshfs-win.c. I don't know what exactly does it do.
  "-ofstypename=SSHFS",

  # WinFsp option. Set the hidden attribute on dotfiles. It looks nice.
  "-odothidden",

  # WinFsp option. Ignore any st_uid and st_gid received from the FUSE ops.getattr/ops.fgetattr implementation.
  # Pretend that all files are owned by the current user and group. See src/dll/fuse/fuse_intf.c.
  # In case of SSHFS, most server-side users/groups probably don't have an equivalent local user/group.
  # They would be mapped to a nonexistent NT user, or collide with an unrelated one. It's usually fine, but this is more correct.
  # (You can try it without this option by running "icacls X:\path\file" to print the ACL of various files.)
  "-ouid=-1,gid=-1",

  # WinFsp option. Ignore the permission bits of any st_mode received from the FUSE ops.getattr/ops.fgetattr implementation.
  # Pretend that all files have mode 700. See src/dll/fuse/fuse_intf.c.
  # WinFsp should just do the syscall and let SSHFS (or rather, the remote sftp-server) decide whether to allow it.
  # Especially with "-ouid=-1,gid=-1", who knows which of [user, group, other] bits should it even look at.
  # Linux FUSE has default_permissions off and allow_other off by default. WinFsp doesn't implement those options. This emulates them.
  "-oumask=077",

  # WinFsp option. Ignore the PSECURITY_DESCRIPTOR received from Windows.
  # Instead, always call ops.create() with mode 644 and ops.mkdir() with mode 755. See src/dll/fuse/fuse_intf.c.
  # Without this, most ways to create a file or directory (e.g. Explorer, MSYS2, cmd.exe mkdir) resulted in mode 700.
  # ops.mknod() is not completely overridden by this, but it's only called in rare circumstances.
  # ops.chmod() is not overridden by this, but there's nothing I can do about that.
  "-ocreate_file_umask=0133",
  "-ocreate_dir_umask=022",

  # SSHFS option. Map the current user's remote uid/gid to local uid/gid in ops.getattr, and local to remote in ops.chown.
  # The getattr IDs are ignored anyway because of -ouid=-1,gid=-1, but best effort handling of chown might be nice, I guess.
  "-oidmap=user",

  # SSHFS option. The ssh program to use.
  "-ossh_command=$windir/System32/OpenSSH/ssh.exe",

  # SSHFS option. Don't start ssh immediately, wait until it's needed.
  "-odelay_connect",

  # SSHFS option. Reconnect if ssh dies or disconnects. With delay_connect, wait until it's needed.
  "-oreconnect",

  # SSH option. Use only public key authentication.
  "-oPreferredAuthentications=publickey",

  # SSH option. Set an otherwise unneeded option to a nonexistent file. Used by kill_ssh_now.ps1 to identify the process.
  "-oGlobalKnownHostsFile=sshfs_ssh_marker",

  # WinFsp option. It should hopefully mount it as a network drive instead of a fixed drive.
  # For example in rclone, AFAICT the only effect of the --network-mode option is to enable the --VolumePrefix option.
  # https://rclone.org/commands/rclone_mount/#mounting-modes-on-windows
  "--VolumePrefix=$MyVolumePrefix",

  # Custom SSHFS option. Set the list of top-level directories and which paths they map to.
  "-osubwrap_paths=$MySubwrapPaths",

  $MyUserHostPath,
  $MyMountPoint  # no trailing comma
)

if ($Verbose) {
  # SSHFS option. Enable debug logs.
  $argarr = @("-d") + $argarr
}

# This should work well enough, as long as no argument contains a " or ends with a \.
# See also:
#   https://github.com/python/cpython/blob/5b63ba3ff5ab56ebf0ed1173cf01dd23169e3dfe/Lib/subprocess.py#L529
#   https://github.com/PowerShell/PowerShell/blob/master/src/System.Management.Automation/engine/NativeCommandProcessor.cs
$argstr = ($argarr | % { '"' + $_ + '"' }) -Join " "

if ($Verbose) {
  "exe: $exe"
  "argstr: $argstr"
  "waitless: $Waitless"
}

If ($Waitless) {
  Start-Process -FilePath $exe -ArgumentList $argstr -WindowStyle Hidden
} Else {
  Start-Process -FilePath $exe -ArgumentList $argstr -NoNewWindow -Wait
}
