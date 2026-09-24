# Copia HTML legal para build/web (canal homolog) apos flutter build web.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$web = Join-Path $root 'build\web'
$pub = Join-Path $root 'public'
if (-not (Test-Path $web)) { throw "build/web ausente — rode flutter build web antes" }
Copy-Item (Join-Path $pub 'privacidade.html') (Join-Path $web 'privacidade.html') -Force
Copy-Item (Join-Path $pub 'termos.html') (Join-Path $web 'termos.html') -Force
Write-Output "COPIED legal HTML into build/web"
Get-Item (Join-Path $web 'privacidade.html'), (Join-Path $web 'termos.html') | Format-Table Name, Length
