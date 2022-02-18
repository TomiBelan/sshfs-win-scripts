@echo off
cd /D "%~dp0"

rem echo The arguments are %* 1>&2

rem type passphrase

powershell -ExecutionPolicy Bypass ./askpass2.ps1 %*
