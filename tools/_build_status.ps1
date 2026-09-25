$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\tools\_aab_rebuild3.log'
$aab = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\build\app\outputs\bundle\release\app-release.aab'
$out = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\tools\_build_status.txt'
$L = New-Object System.Collections.Generic.List[string]
if (Test-Path $log) {
  $fi = Get-Item $log
  [void]$L.Add(("LOG_BYTES=" + $fi.Length))
  [void]$L.Add(("LOG_MTIME=" + $fi.LastWriteTime))
  $tail = Get-Content $log -Tail 15 -Encoding UTF8
  foreach ($t in $tail) { [void]$L.Add("TAIL`t$t") }
}
if (Test-Path $aab) {
  $f = Get-Item $aab
  [void]$L.Add(("AAB_BYTES=" + $f.Length))
  [void]$L.Add(("AAB_MTIME=" + $f.LastWriteTime))
}
$javas = @(Get-Process java -EA SilentlyContinue)
[void]$L.Add(("JAVA_COUNT=" + $javas.Count))
foreach ($j in $javas) { [void]$L.Add(("JAVA`tPID=" + $j.Id + "`tCPU=" + $j.CPU)) }
$L | Set-Content $out -Encoding UTF8
Write-Output ("WROTE " + $out)
$L | ForEach-Object { Write-Output $_ }
