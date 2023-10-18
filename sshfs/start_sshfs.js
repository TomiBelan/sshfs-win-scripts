// This script runs start_sshfs2.ps1 in the background (no visible window).
// It is usually started by a shortcut in the user's Startup folder. It can also be started manually.

var s = WScript.CreateObject("WScript.Shell");

var scriptdir = WScript.ScriptFullName.replace(/[^/\\]*$/, "");
var command = 'powershell -ExecutionPolicy Bypass "' + scriptdir + 'start_sshfs2.ps1" -Waitless';
// WScript.Echo(command);
s.Run(command, 0);

// More info:
// https://www.autohotkey.com/docs/commands/Run.htm
// http://msdn.microsoft.com/en-us/library/aew9yb99
// https://admhelp.microfocus.com/uft/en/all/VBScript/Content/html/4f0571f3-a65f-400d-bec9-1e285362a738.htm
