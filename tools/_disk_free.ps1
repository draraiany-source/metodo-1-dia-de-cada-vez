$ErrorActionPreference = 'Continue'
$out = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\tools\_disk_free.txt'
$d = Get-PSDrive C
@(
  ("FREE_GB=" + [math]::Round($d.Free/1GB, 2)),
  ("USED_GB=" + [math]::Round($d.Used/1GB, 2))
) | Set-Content $out -Encoding UTF8
Get-Content $out
