#Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Security

#[void] [System.Windows.MessageBox]::Show("Askpass is running with arguments: $args")

$protected_passphrase = "***REMOVED***"

$result = [System.Text.Encoding]::Unicode.GetString(
  [System.Security.Cryptography.ProtectedData]::Unprotect(
    [Convert]::FromBase64String($protected_passphrase),
    $null,
    [System.Security.Cryptography.DataProtectionScope]::CurrentUser))

#[void] [System.Windows.MessageBox]::Show("Output: $result")

$result
