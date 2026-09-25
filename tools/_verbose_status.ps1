$ErrorActionPreference = 'Continue'
$log = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\tools\_aab_rebuild_verbose.log'
$out = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\tools\_verbose_status.txt'
$L = New-Object System.Collections.Generic.List[string]
if (Test-Path $log) {
  $fi = Get-Item $log
  [void]$L.Add(("LOG_BYTES=" + $fi.Length))
  [void]$L.Add(("LOG_MTIME=" + $fi.LastWriteTime))
  # Search key lines without loading entire file if huge
  $hits = Select-String -Path $log -Pattern 'FAILURE:|What went wrong|BUILD FAILED|Built build|EXIT_CODE|OutOfMemory|No space|disk|error:' -EA SilentlyContinue | Select-Object -Last 30
  foreach ($h in $hits) { [void]$L.Add(("HIT`t" + $h.LineNumber + "`t" + $h.Line.Trim())) }
  Get-Content $log -Tail 20 -Encoding UTF8 | ForEach-Object { [void]$L.Add("TAIL`t$_") }
} else {
  [void]$L.Add('NO_LOG')
}
$d = Get-PSDrive C
[void]$L.Add(("FREE_GB=" + [math]::Round($d.Free/1GB,2)))
$L | Set-Content $out -Encoding UTF8
Write-Output ("WROTE " + $out)
$L | Select-Object -First 40 | ForEach-Object { Write-Output $_ }
