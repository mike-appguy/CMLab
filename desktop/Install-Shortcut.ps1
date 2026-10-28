param([string]$ShortcutDirectory = [Environment]::GetFolderPath('Desktop'))
$ErrorActionPreference = 'Stop'
$appRoot = Split-Path $PSScriptRoot -Parent
$launcher = Join-Path $appRoot 'desktop\Start-CMLab.ps1'
if (-not (Test-Path -LiteralPath $launcher)) { throw 'Launcher not found.' }
$shortcutPath = Join-Path $ShortcutDirectory 'CM Lab.lnk'
if (Test-Path -LiteralPath $shortcutPath) {
    $existingShell = New-Object -ComObject WScript.Shell
    $existing = $existingShell.CreateShortcut($shortcutPath)
    if ($existing.Arguments -eq ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $launcher + '"')) { Write-Output 'The CM Lab shortcut already points to this installation.'; exit 0 }
    throw "A different CM Lab shortcut exists at $shortcutPath. It has not been overwritten."
}
$shell = New-Object -ComObject WScript.Shell
$link = $shell.CreateShortcut($shortcutPath)
$link.TargetPath = Join-Path $PSHOME 'powershell.exe'
$link.Arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $launcher + '"'
$link.WorkingDirectory = $appRoot
$link.Description = 'CM Lab V3 - standalone CM 01/02 companion'
$link.WindowStyle = 7
$link.IconLocation = (Join-Path $appRoot 'desktop\CM-Lab.ico') + ',0'
$link.Save()
Write-Output "Created $shortcutPath"
