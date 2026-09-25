$ErrorActionPreference = 'Continue'
$root = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2'
Set-Location $root
$log = Join-Path $root 'tools\_aab_rebuild_20260922.log'
$flutter = 'C:\Users\Lenovo\Desktop\flutter\flutter\bin\flutter.bat'
$args = @(
  'build','appbundle','--release',
  '--split-debug-info=build/app/debug-info',
  '--dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com',
  '--dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html',
  '--dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html'
)
"START $(Get-Date -Format o)" | Set-Content $log -Encoding UTF8
& $flutter @args *>> $log
$code = $LASTEXITCODE
"EXIT_CODE=$code" | Add-Content $log
"END $(Get-Date -Format o)" | Add-Content $log
$aab = 'build\app\outputs\bundle\release\app-release.aab'
if (Test-Path $aab) {
  $f = Get-Item $aab
  ("AAB_BYTES={0}" -f $f.Length) | Add-Content $log
  ("AAB_MB={0:N2}" -f ($f.Length/1MB)) | Add-Content $log
  ("AAB_MTIME={0}" -f $f.LastWriteTime) | Add-Content $log
}
Write-Output ("DONE exit=$code log=$log")
