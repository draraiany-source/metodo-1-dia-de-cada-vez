$ErrorActionPreference = 'Continue'
$out = 'tools\_fixed_status2.txt'
$L = New-Object System.Collections.Generic.List[string]
$log = 'tools\_aab_rebuild_fixed.log'
if (Test-Path $log) {
  $fi = Get-Item $log
  [void]$L.Add(("LOG_BYTES=" + $fi.Length + " MTIME=" + $fi.LastWriteTime))
  Get-Content $log -Tail 30 -Encoding UTF8 | ForEach-Object { [void]$L.Add("T`t$_") }
}
$procs = Get-Process -Name java,cmd,flutter,dart,powershell -EA SilentlyContinue | Select-Object Id,ProcessName,CPU
foreach ($p in $procs) { [void]$L.Add(("P`t" + $p.Id + "`t" + $p.ProcessName + "`t" + $p.CPU)) }
[void]$L.Add(("FREE_GB=" + [math]::Round((Get-PSDrive C).Free/1GB,2)))
# is sandbox cache still there?
[void]$L.Add(("SANDBOX_CACHE=" + (Test-Path 'C:\Users\Lenovo\AppData\Local\Temp\cursor-sandbox-cache')))
$L | Set-Content $out -Encoding UTF8
Write-Output ("WROTE " + $out)
$L | ForEach-Object { Write-Output $_ }
