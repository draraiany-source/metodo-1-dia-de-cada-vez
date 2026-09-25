$ErrorActionPreference = 'Continue'
Start-Sleep -Seconds 15
$log = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\tools\_aab_rebuild_fixed.log'
$out = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\tools\_fixed_status.txt'
$L = New-Object System.Collections.Generic.List[string]
if (Test-Path $log) {
  $fi = Get-Item $log
  [void]$L.Add(("LOG_BYTES=" + $fi.Length))
  Get-Content $log -TotalCount 20 -Encoding UTF8 | ForEach-Object { [void]$L.Add("H`t$_") }
  $hits = Select-String -Path $log -Pattern 'EXIT_CODE|Built build|FAILURE|immutable workspace|GRADLE_USER_HOME|Running Gradle' -EA SilentlyContinue | Select-Object -Last 15
  foreach ($h in $hits) { [void]$L.Add(("HIT`t" + $h.Line.Trim())) }
} else { [void]$L.Add('NO_LOG_YET') }
$d = Get-PSDrive C
[void]$L.Add(("FREE_GB=" + [math]::Round($d.Free/1GB,2)))
$L | Set-Content $out -Encoding UTF8
Write-Output ("WROTE " + $out)
$L | ForEach-Object { Write-Output $_ }
