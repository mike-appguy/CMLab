param([switch]$CheckOnly)
$ErrorActionPreference = 'Stop'
try {
    $appRoot = Split-Path $PSScriptRoot -Parent
    $appFile = Join-Path $appRoot 'CM_Lab_v0.3.html'
    $manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'app-manifest.json') -Raw | ConvertFrom-Json
    if (-not (Test-Path -LiteralPath $appFile)) { throw 'CM Lab app file is missing. Keep the launcher in the CM Lab folder.' }
    if ((Get-FileHash -LiteralPath $appFile -Algorithm SHA256).Hash.ToLowerInvariant() -ne $manifest.htmlSha256) { throw 'CM Lab app integrity check failed. Rebuild or restore the complete CM Lab release.' }
    $edgeCandidates = @(
        (Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe'),
        (Join-Path $env:ProgramFiles 'Microsoft\Edge\Application\msedge.exe'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\Application\msedge.exe')
    )
    $edgePath = $edgeCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $edgePath) { throw 'Microsoft Edge is required for this standalone web-app launcher. Install Edge, then try again.' }
    $profilePath = Join-Path $env:LOCALAPPDATA 'CM Lab\WebProfile'
    $appUri = ([System.Uri]$appFile).AbsoluteUri
    # Dedicated profile: never attach to or alter the user's normal Chrome/Edge profile.
    $arguments = @(('--app="' + $appUri + '"'), ('--user-data-dir="' + $profilePath + '"'), '--no-first-run', '--no-default-browser-check')
    if ($arguments.Count -ne 4 -or -not $appUri.StartsWith('file:///')) { throw 'Invalid standalone launch arguments.' }
    if ($CheckOnly) { Write-Output "CM Lab V3 launcher valid. Edge runtime found; app hash and app-window arguments verified. No app launched."; exit 0 }
    Start-Process -FilePath $edgePath -ArgumentList $arguments -WindowStyle Normal | Out-Null
} catch {
    if ($CheckOnly) { Write-Error $_; exit 1 }
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'CM Lab could not start', 'OK', 'Error') | Out-Null
    exit 1
}
