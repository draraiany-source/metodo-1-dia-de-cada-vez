$ErrorActionPreference = 'Continue'
$root = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2'
Set-Location $root
$out = Join-Path $root 'tools\_audit_evidence_20260924.txt'
function Log($m) { $m | Tee-Object -FilePath $out -Append }

'' | Set-Content -Path $out -Encoding UTF8
Log '=== GIT ==='
Log (git rev-parse HEAD)
Log (git rev-parse --short HEAD)
Log (git log -5 --oneline)
Log (git status -sb)
Log '=== VERSION ==='
Log ((Select-String -Path pubspec.yaml -Pattern '^version:').Line)
Log '=== APK ==='
Get-ChildItem -Path 'build\app\outputs\flutter-apk' -Filter '*.apk' -ErrorAction SilentlyContinue |
  ForEach-Object { Log ("APK {0} bytes={1} mtime={2}" -f $_.Name, $_.Length, $_.LastWriteTime) }
Log '=== LOCAL WEB STAMP ==='
$js = 'build\web\main.dart.js'
if (Test-Path $js) {
  $hit = Select-String -Path $js -Pattern '20260924-nav' -SimpleMatch | Select-Object -First 1
  if ($hit) { Log ("LOCAL_JS_STAMP=True line={0}" -f $hit.LineNumber) } else { Log 'LOCAL_JS_STAMP=False' }
  Log ("LOCAL_JS_SIZE={0} mtime={1}" -f (Get-Item $js).Length, (Get-Item $js).LastWriteTime)
} else { Log 'LOCAL_JS_MISSING' }
Log '=== REMOTE HOMOLOG STAMP ==='
try {
  $r = Invoke-WebRequest -Uri 'https://metodo1dia-app--homologacao-cw9j2u83.web.app/main.dart.js' -UseBasicParsing -TimeoutSec 90
  $has = $r.Content.Contains('20260924-nav')
  Log ("REMOTE_STAMP={0} status={1} len={2}" -f $has, $r.StatusCode, $r.Content.Length)
} catch { Log ("REMOTE_ERR={0}" -f $_.Exception.Message) }
Log '=== LEGAL LINKS ==='
foreach ($u in @(
  'https://metodo1dia-app.web.app/privacidade.html',
  'https://metodo1dia-app.web.app/termos.html',
  'https://metodo1dia-app.web.app/privacidade',
  'https://metodo1dia-app.web.app/termos'
)) {
  try {
    $resp = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 30 -MaximumRedirection 5
    Log ("LEGAL {0} -> {1}" -f $u, $resp.StatusCode)
  } catch {
    $code = $null
    if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    Log ("LEGAL {0} -> ERR {1} {2}" -f $u, $code, $_.Exception.Message)
  }
}
Log '=== DEVICES ==='
Log (flutter devices 2>&1 | Out-String)
Log '=== PAYMENTS / HOMOLOG CODE ==='
Log ((Select-String -Path 'lib\core\config\app_config.dart' -Pattern 'paymentsEnabled|homologBuildId|fromEnvironment').Line -join "`n")
Log '=== DONE ==='
Write-Output "WROTE=$out"
Get-Content $out
