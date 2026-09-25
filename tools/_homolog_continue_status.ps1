$ErrorActionPreference = 'Continue'
$root = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2'
Set-Location $root
$out = Join-Path $root 'tools\_homolog_continue_status.txt'
function L($m){ $m | Tee-Object $out -Append }
'' | Set-Content $out -Encoding UTF8
L '=== HEAD ==='
L (git rev-parse HEAD)
L (git rev-parse --short HEAD)
L (git log -5 --oneline)
L '=== STATUS SHORT ==='
L (git status -sb | Select-Object -First 5)
L '=== PERTINENT DIFF STAT ==='
L (git diff --stat HEAD -- lib firebase.json firebase.homolog.json pubspec.yaml docs test public 2>&1 | Out-String)
L '=== UNTRACKED PERTINENT ==='
L (git status --porcelain -- lib firebase.json firebase.homolog.json pubspec.yaml docs test public 2>&1 | Out-String)
L '=== VERSION ==='
L ((Select-String pubspec.yaml '^version:').Line)
L '=== DEVICES ==='
L (flutter devices 2>&1 | Out-String)
L 'DONE'
