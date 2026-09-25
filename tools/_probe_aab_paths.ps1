$ErrorActionPreference = 'Continue'
$root = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2'
Set-Location $root
Add-Type -AssemblyName System.IO.Compression.FileSystem
$aab = 'build\app\outputs\bundle\release\app-release.aab'
$z = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path $aab))
$out = 'tools\_probe_aab_paths.txt'
$L = New-Object System.Collections.Generic.List[string]
try {
  $fa = @($z.Entries | Where-Object { $_.FullName -like '*flutter_assets/assets/*' })
  $patterns = @('icons_3d','neon/navegacao','neon/saude','neon/nutricao','neon/conquistas','neon/perfil','neon/treinos','neon/corrida','amanda/originals','amanda/promo','_backup','_incoming','icons_3d_pack2')
  foreach ($p in $patterns) {
    $m = @($fa | Where-Object { $_.FullName -like ("*{0}*" -f $p) })
    $sum = ($m | Measure-Object Length -Sum).Sum
    if (-not $sum) { $sum = 0 }
    [void]$L.Add(("PAT`t{0}`tcount={1}`tMB={2:N2}" -f $p, $m.Count, ($sum/1MB)))
  }
  # sample neon paths
  $fa | Where-Object { $_.FullName -like '*assets/icons/neon*' } | Select-Object -First 15 | ForEach-Object {
    [void]$L.Add(('NEON_SAMPLE`t{0}' -f $_.FullName))
  }
} finally { $z.Dispose() }
$L | Set-Content $out -Encoding UTF8
Write-Output ("WROTE $out lines=$($L.Count)")
