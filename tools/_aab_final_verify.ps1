$ErrorActionPreference = 'Continue'
$root = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2'
Set-Location $root
$out = 'tools\_aab_final_verify.txt'
$L = New-Object System.Collections.Generic.List[string]
$aab = 'build\app\outputs\bundle\release\app-release.aab'
$f = Get-Item $aab
[void]$L.Add(("AAB_PATH=" + $f.FullName))
[void]$L.Add(("AAB_BYTES=" + $f.Length))
[void]$L.Add(("AAB_MB=" + [math]::Round($f.Length/1MB, 2)))
[void]$L.Add(("AAB_MTIME=" + $f.LastWriteTime))
Add-Type -AssemblyName System.IO.Compression.FileSystem
$z = [System.IO.Compression.ZipFile]::OpenRead($f.FullName)
try {
  $entries = @($z.Entries)
  $fa = @($entries | Where-Object { $_.FullName -like '*flutter_assets*' })
  [void]$L.Add(("FLUTTER_ASSETS_MB=" + [math]::Round((($fa | Measure-Object Length -Sum).Sum)/1MB, 2)))
  [void]$L.Add(("AAB_MP3=" + @($entries | Where-Object { $_.FullName -like '*.mp3' }).Count))
  [void]$L.Add(("AAB_PNG=" + @($entries | Where-Object { $_.FullName -like '*.png' }).Count))
  [void]$L.Add(("AAB_JPG=" + @($entries | Where-Object { $_.FullName -match '\.jpe?g$' }).Count))
  $bad = @($entries | Where-Object { $_.FullName -match '_backup|originals|icons_3d|_incoming|trim_preview' })
  [void]$L.Add(("BAD_PATHS=" + $bad.Count))
  foreach ($b in ($bad | Select-Object -First 10)) { [void]$L.Add(("BAD`t" + $b.FullName)) }
  $cadeiras = @($entries | Where-Object { $_.FullName -match 'lily_fit_cadeira_' })
  [void]$L.Add(("CADEIRA_IN_AAB=" + $cadeiras.Count))
  foreach ($c in $cadeiras) { [void]$L.Add(("CADEIRA`t" + $c.Length + "`t" + $c.FullName)) }
  $dirMap = @{}
  foreach ($e in $fa) {
    if ($e.FullName -match 'flutter_assets/assets/([^/]+)/') {
      $d = $Matches[1]
      if (-not $dirMap.ContainsKey($d)) { $dirMap[$d] = [int64]0 }
      $dirMap[$d] += $e.Length
    }
  }
  $dirMap.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 12 | ForEach-Object {
    [void]$L.Add(("AAB_DIR`t{0}`t{1:N2} MB" -f $_.Key, ($_.Value/1MB)))
  }
} finally { $z.Dispose() }
foreach ($c in @('lily_fit_cadeira_abdutora.jpeg','lily_fit_cadeira_extensora.jpeg')) {
  [void]$L.Add(("DISK_CADEIRA`t$c`t" + (Test-Path ("assets\lily_exercicios\$c"))))
}
$L | Set-Content $out -Encoding UTF8
Write-Output ("WROTE " + $out)
$L | ForEach-Object { Write-Output $_ }
