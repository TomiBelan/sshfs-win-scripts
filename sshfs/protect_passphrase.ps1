Add-Type -AssemblyName System.Security
$passphrase = Read-Host -Prompt "Enter the passphrase"
[Convert]::ToBase64String(
  [System.Security.Cryptography.ProtectedData]::Protect(
    [System.Text.Encoding]::Unicode.GetBytes($passphrase),
    $null,
    [System.Security.Cryptography.DataProtectionScope]::CurrentUser))
Read-Host -Prompt "Press enter"
