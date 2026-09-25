$ErrorActionPreference = 'Continue'
$log = 'tools\_aab_rebuild_lowmem.log'
$out = 'tools\_lowmem_status.txt'
$L = New-Object System.Collections.Generic.List[string]
if (Test-Path $log) {
  $fi = Get-Item $log
  [void]$L.Add(("LOG_BYTES=" + $fi.Length + " MTIME=" + $fi.LastWriteTime))
  $hits = Select-String -Path $log -Pattern 'EXIT_CODE|Built build|FAILURE|Out of Memory|Running Gradle|AAB_BYTES|Got dependencies' -EA SilentlyContinue | Select-Object -Last 20
  foreach ($h in $hits) { [void]$L.Add(("HIT`t" + $h.Line.Trim())) }
  Get-Content $log -Tail 8 -Encoding UTF8 | ForEach-Object { [void]$L.Add("T`t$_") }
} else { [void]$L.Add('NO_LOG') }
if (Test-Path 'build\app\outputs\bundle\release\app-release.aab') {
  $f = Get-Item 'build\app\outputs\bundle\release\app-release.aab'
  [void]$L.Add(("AAB_BYTES=" + $f.Length))
  [void]$L.Add(("AAB_MTIME=" + $f.LastWriteTime))
  [void]$L.Add(("AAB_MB=" + [math]::Round($f.Length/1MB,2)))
}
[void]$L.Add(("FREE_GB=" + [math]::Round((Get-PSDrive C).Free/1GB,2)))
$L | Set-Content $out -Encoding UTF8
Write-Output ("WROTE " + $out)
$L | ForEach-Object { Write-Output $_ }
