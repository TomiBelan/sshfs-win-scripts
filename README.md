# sshfs-win-scripts

This project contains my scripts and patches for [SSHFS-Win - SSHFS for Windows](https://github.com/winfsp/sshfs-win).

My goal is to have a permanently mounted network drive which won't need explicit connect or disconnect operations. It should automatically connect to the server only when needed. And it should handle network problems and disconnects gracefully.

## Differences from upstream sshfs-win

  - Various options are enabled, especially `delay_connect` and `reconnect`.
  - The current SSH connection is closed when the laptop goes to sleep.
  - The top level contains virtual directories, e.g. `S:\myhome` can point to `/home/you` and `S:\root` to `/`.
  - Private keys are saved in Microsoft's ssh-agent, which can safely store them across reboots.
  - It runs as your normal Windows user, not as SYSTEM.
  - It doesn't have SSHFS-Win's support for "[Map Network Drive](https://github.com/winfsp/sshfs-win#windows-explorer)" or [\\sshfs\\ UNC syntax](https://github.com/winfsp/sshfs-win#unc-syntax). (Though you could install it side by side the original SSHFS-Win.)

## I don't recommend it

I'm using it and it mostly works, but I'm not 100% happy with how this experiment turned out. Most users should probably use sshfs-win directly, or one of its GUI frontends. Or some completely different protocol.

  - Establishing a new connection is slower than I'd expect. It's noticeably slower than e.g. connecting to a new https website. I'm not sure if that's my problem or something inherent to SSH.
  - Reads and writes feel slower than I'd expect. But maybe that's normal? It feels slower than downloading files over http, but I could be mistaken. I don't know how much to blame Windows, WinFsp, SSHFS, or my network. I should measure it properly.
  - Connecting "only when needed" doesn't work very consistently. The top level directory helps a lot against automatic Windows access of `/`, `/Desktop.ini` and `/AutoRun.inf`. But Windows Explorer is being a little b-word. It remembers recently opened files and folders, and it just loves to `getattr` them all the time. Just opening a Windows Explorer window can often cause a reconnection.
  - Windows Explorer makes thumbnails and previews even though it's a network drive. I don't know how to turn it off. Everyone online is asking how to solve the opposite problem.
  - The WinFsp project recommends to start filesystems with WinFsp.Launcher and run them as SYSTEM. I run it as a normal user for weak subjective reasons: I just didn't like the idea of parsers of the SSH & SFTP protocols running as root. This needed some ugly hacks, for example inside stop\_sshfs. But I have a single-user machine anyway, so it's a bit pointless.
  - Closing the SSH connection on sleep might theoretically help against situations where the connection gets stuck and sshfs doesn't realize it. But in practice the only observable effect is to stop the remote sftp-server process a bit earlier than it would stop otherwise (when the TCP connection times out a few hours later). So it's a bit pointless.

## How to use it

  - Install [WinFsp](https://github.com/winfsp/winfsp).
      - Either directly, or with [Chocolatey](https://community.chocolatey.org/), or with WinGet.
  - Install [AutoHotkey](https://www.autohotkey.com/).
      - This script only needs AutoHotkey v2, but most other scripts usually need v1, so it's safest to get both.
      - I prefer to first install AutoHotkey v2 and second install AutoHotkey v1. But [either way should work](https://www.autohotkey.com/docs/v2/Program.htm#install_v1).
      - Personally, I like to install Windows software with Chocolatey, but at the moment their autohotkey.install package is still v1.
  - Install [Microsoft's OpenSSH Client](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=gui). Settings → Apps → Optional features → Add a feature → OpenSSH Client → Install.
  - Enable [Microsoft's SSH Agent service](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement). In PowerShell running as administrator, run:
      - `Set-Service ssh-agent -StartupType Automatic`
      - `Start-Service ssh-agent`
      - `Get-Service ssh-agent | Format-List *`.
  - If you want a new SSH key, in cmd.exe, run `ssh-keygen -t ed25519 -C "some comment"`. Choose a passphrase. The filename doesn't matter and you can move it later. Add the public key to your `.ssh/authorized_keys` on the server.
  - In cmd.exe, add the key to ssh-agent with `ssh-add path\to\the\key`. Enter its passphrase.
  - In cmd.exe, run `ssh-add -L` to check if the key is there.
  - In cmd.exe, run `ssh youruser@example.com` to check if it works without a password.
  - Download sshfs-win-scripts. Either download the binary release from the Releases page, or build it from source: clone the repo, install Cygwin, read and run `src/compile.sh`, follow its instructions.
  - Edit `start_sshfs2.ps1` and change the configuration on top.
  - In cmd.exe, run `powershell -ExecutionPolicy Bypass .\start_sshfs2.ps1 -Verbose` to see if everything works. Stop it with Ctrl+C.
  - Create shortcuts to `start_sshfs.js` and `kill_ssh_on_sleep.ahk` in your "Startup" folder. The "Startup" folder can be opened by pressing Win+R and typing `shell:startup`.

## License

Copyright 2023 Tomi Belan

The files in `sshfs/src/*.patch` and `sshfs/build_output` are derived works of [SSHFS](https://github.com/libfuse/sshfs) and [SSHFS-Win](https://github.com/winfsp/sshfs-win), and they use the same license as SSHFS and SSHFS-Win, which is GPLv2+. See also [licenses of their dependencies](https://github.com/winfsp/sshfs-win#license).

Everything else is multi-licensed and you may use it under either the GPLv2+ licenses, the MIT license, or the WTFPL license (at your option).
