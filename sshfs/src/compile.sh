#!/bin/bash

set -e

reuse=
keep=

while (( $# )); do
  case "$1" in
    --reuse) reuse=t;;
    --keep) keep=t;;
    *) echo >&2 "Usage: $0 [--reuse] [--keep]"; exit 1;;
  esac
  shift
done

if [[ "$(uname -s)" != CYGWIN* ]]; then
  echo >&2 "please run this script in cygwin"
  exit 1
fi

if ! [[ -f /usr/bin/gcc.exe && -f /usr/bin/git.exe && -f /usr/include/glib-2.0/glib.h && -f /usr/bin/make.exe && -f /usr/bin/meson && -f /usr/bin/patch.exe ]]; then
  echo >&2 "please install these cygwin packages:"
  echo >&2 "(they are the build dependencies from the sshfs-win README)"
  echo >&2 "  gcc-core git libglib2.0-devel make meson patch"
  exit 1
fi

if ! [[ -f /proc/registry32/HKEY_LOCAL_MACHINE/SOFTWARE/WinFsp/InstallDir ]]; then
  echo >&2 "please install WinFsp (either directly or for example using Chocolatey)"
  exit 1
fi

if ! [[ -f /usr/include/fuse3/fuse.h ]]; then
  echo >&2 "please run: sh '$(cygpath -u "$(cat /proc/registry32/HKEY_LOCAL_MACHINE/SOFTWARE/WinFsp/InstallDir | tr -d '\0')")/opt/cygfuse/install.sh'"
  exit 1
fi

cd "$(dirname "$0")"

run () {
  echo $'\e[33;1m'"${*@Q}"$'\e[0m' >&2
  "$@"
}

if ! [[ -n $reuse && -d build ]]; then
  run rm -rf build
  run mkdir build
fi

if ! [[ -e build/sshfs-win ]]; then
  run git -C build clone https://github.com/winfsp/sshfs-win.git
  run git -C build/sshfs-win -c advice.detachedHead=false switch --detach 58bde0f151de0e4d30d484cb964091d9ed8b4a0a
  run git -C build/sshfs-win submodule update --init
  run git -C build/sshfs-win/sshfs -c advice.detachedHead=false switch --detach c91eb9a9a992f1a36c49a8e6f1146e45b5e1c8e7
fi

run git -C build/sshfs-win restore Makefile
run git -C build/sshfs-win apply ../../makefile.patch
run cp [0-9]*.patch build/sshfs-win/patches/

run rm -rf build/sshfs-win/.build

run env -C build/sshfs-win make

run rm -rf ../build_output
run cp -rp build/sshfs-win/.build/root ../build_output

if ! [[ -n $keep ]]; then
  run rm -rf build
fi
