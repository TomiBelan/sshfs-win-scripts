# Find the sshfs process and send it a Ctrl-C.

# More info:
# https://github.com/billziss-gh/winfsp/issues/47
# https://blog.codetitans.pl/post/sending-ctrl-c-signal-to-another-application-on-windows/
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-type?view=powershell-7.2

$sshfspids = Get-Process | Where { $_.Path -match '\\bin\\sshfs\.exe$' } | % { $_.Id }
if ($sshfspids -eq $null) {
    "sshfs is not running"
    return
}
$sshfspid = $sshfspids[0]

$signatures = @'
    using System;
    using System.Runtime.InteropServices;
    public class MyFunctions {
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool AttachConsole(uint dwProcessId);
        [DllImport("kernel32.dll", SetLastError = true, ExactSpelling = true)]
        public static extern bool FreeConsole();
        [DllImport("kernel32.dll")]
        public static extern bool SetConsoleCtrlHandler(ConsoleCtrlDelegate handler, bool add);
        [DllImport("kernel32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool GenerateConsoleCtrlEvent(CtrlTypes dwCtrlEvent, uint dwProcessGroupId);

        // Delegate type to be used as the Handler Routine for SCCH
        public delegate Boolean ConsoleCtrlDelegate(CtrlTypes type);

        // Enumerated type for the control messages sent to the handler routine
        public enum CtrlTypes : uint
        {
            CTRL_C_EVENT = 0,
            CTRL_BREAK_EVENT,
            CTRL_CLOSE_EVENT,
            CTRL_LOGOFF_EVENT = 5,
            CTRL_SHUTDOWN_EVENT
        }
    }
'@

Add-Type -TypeDefinition $signatures

if (![MyFunctions]::FreeConsole()) {
    "FreeConsole failed"
    return
}
if (![MyFunctions]::AttachConsole($sshfspid)) {
    "AttachConsole failed"
    return
}
[MyFunctions]::SetConsoleCtrlHandler($null, $true)
[MyFunctions]::GenerateConsoleCtrlEvent(0, 0)   # CTRL_C_EVENT
