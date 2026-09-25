$ErrorActionPreference = 'Continue'
$root = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2'
Set-Location $root
$out = 'tools\_folder_sizes_after.txt'
$L = New-Object System.Collections.Generic.List[string]
Get-ChildItem (Join-Path $root 'assets') -Directory -EA SilentlyContinue | ForEach-Object {
  $files = @(Get-ChildItem $_.FullName -Recurse -File -EA SilentlyContinue)
  $sum = ($files | Measure-Object Length -Sum).Sum
  if (-not $sum) { $sum = 0 }
  [void]$L.Add(("{0}`t{1:N2} MB`t{2} files`t{3}" -f $_.Name, ($sum/1MB), $files.Count, $sum))
}
# hot paths remaining
$hot = @(
  'assets\amanda',
  'assets\amanda\promo',
  'assets\amanda\optimized',
  'assets\amanda\thumbs',
  'assets\lily_exercicios',
  'assets\icons',
  'assets\icons\neon',
  'assets\images',
  'assets\lily'
)
foreach ($p in $hot) {
  if (Test-Path $p) {
    $files = @(Get-ChildItem $p -Recurse -File -EA SilentlyContinue)
    $sum = ($files | Measure-Object Length -Sum).Sum
    if (-not $sum) { $sum = 0 }
    [void]$L.Add(("HOT`t{0}`t{1:N2} MB`t{2}" -f $p, ($sum/1MB), $files.Count))
  } else {
    [void]$L.Add(("HOT_MISSING`t{0}" -f $p))
  }
}
foreach ($c in @('lily_fit_cadeira_abdutora.jpeg','lily_fit_cadeira_extensora.jpeg')) {
  [void]$L.Add(("CADEIRA`t{0}`t{1}" -f $c, (Test-Path ("assets\lily_exercicios\" + $c))))
}
$L | Set-Content $out -Encoding UTF8
Write-Output ("WROTE $out lines=$($L.Count)")
