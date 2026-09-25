$log = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\tools\_aab_rebuild_20260922.log'
$out = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\tools\_aab_rebuild_tail.txt'
# Try Unicode then UTF8
$raw = $null
try { $raw = Get-Content -Path $log -Encoding Unicode -ErrorAction Stop } catch {}
if (-not $raw -or $raw.Count -lt 2) {
  $raw = Get-Content -Path $log -Encoding UTF8
}
$tail = $raw | Select-Object -Last 80
$tail | Set-Content -Path $out -Encoding UTF8
Write-Output ("LINES=" + $raw.Count)
Write-Output ("WROTE " + $out)
$tail | ForEach-Object { Write-Output $_ }
