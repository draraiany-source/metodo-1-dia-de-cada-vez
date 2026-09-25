$ErrorActionPreference = 'Stop'
$root = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2'
Set-Location $root
$destRoot = Join-Path $root 'tools\_excluded_from_bundle'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$dest = Join-Path $destRoot ("aab_regression_" + $stamp)
New-Item -ItemType Directory -Force -Path $dest | Out-Null

# Inventory BEFORE
$beforePath = Join-Path $root 'tools\_folder_sizes_before.txt'
$before = New-Object System.Collections.Generic.List[string]
Get-ChildItem (Join-Path $root 'assets') -Directory -EA SilentlyContinue | ForEach-Object {
  $files = @(Get-ChildItem $_.FullName -Recurse -File -EA SilentlyContinue)
  $sum = ($files | Measure-Object Length -Sum).Sum
  if (-not $sum) { $sum = 0 }
  [void]$before.Add(("{0}`t{1:N2} MB`t{2} files`t{3}" -f $_.Name, ($sum/1MB), $files.Count, $sum))
}
$before | Set-Content $beforePath -Encoding UTF8

$moves = @(
  'assets\lily_exercicios\_backup_before_cadeiras_20260922',
  'assets\lily_exercicios\_incoming',
  'assets\amanda\originals',
  'assets\images\icons_3d',
  'assets\images\icons_3d_pack2',
  'assets\icons\neon\navegacao',
  'assets\icons\neon\saude',
  'assets\icons\neon\nutricao',
  'assets\icons\neon\conquistas',
  'assets\icons\neon\perfil',
  'assets\_lily_backup_before_frame_fix',
  'assets\_lily_backup_before_pack_20260911_002213',
  'assets\_lily_trim_preview'
)

$log = New-Object System.Collections.Generic.List[string]
function L([string]$s) {
  [void]$log.Add($s)
  Write-Output $s
}

L ("DEST=" + $dest)
foreach ($rel in $moves) {
  $from = Join-Path $root $rel
  $safeName = ($rel -replace '[\\\/]', '__')
  $to = Join-Path $dest $safeName
  if (Test-Path -LiteralPath $from) {
    $bytes = (Get-ChildItem -LiteralPath $from -Recurse -File -EA SilentlyContinue | Measure-Object Length -Sum).Sum
    if (-not $bytes) { $bytes = 0 }
    Move-Item -LiteralPath $from -Destination $to -Force
    L ("MOVED`t{0:N2} MB`t{1}" -f ($bytes/1MB), $rel)
  } else {
    L ("SKIP_MISSING`t{0}" -f $rel)
  }
}

# Move extra neon/corrida files except the one declared in pubspec
$corridaDir = Join-Path $root 'assets\icons\neon\corrida'
$keepName = 'icone_neon_de_corrida_e_saude_cardiaca.jpg'
if (Test-Path -LiteralPath $corridaDir) {
  $corridaExcl = Join-Path $dest 'assets__icons__neon__corrida_extras'
  New-Item -ItemType Directory -Force -Path $corridaExcl | Out-Null
  Get-ChildItem -LiteralPath $corridaDir -File -EA SilentlyContinue | Where-Object { $_.Name -ne $keepName } | ForEach-Object {
    Move-Item -LiteralPath $_.FullName -Destination (Join-Path $corridaExcl $_.Name) -Force
    L ("MOVED_CORRIDA_EXTRA`t{0:N2} MB`t{1}" -f ($_.Length/1MB), $_.Name)
  }
}

foreach ($c in @('lily_fit_cadeira_abdutora.jpeg', 'lily_fit_cadeira_extensora.jpeg')) {
  $p = Join-Path $root ('assets\lily_exercicios\' + $c)
  L ("CADEIRA`t{0}`tEXISTS={1}" -f $c, (Test-Path -LiteralPath $p))
}

# List images/icons root files (need pubspec coverage)
$imgRoot = @(Get-ChildItem (Join-Path $root 'assets\images') -File -EA SilentlyContinue)
$iconRoot = @(Get-ChildItem (Join-Path $root 'assets\icons') -File -EA SilentlyContinue)
L ("images_root_files=" + $imgRoot.Count)
$imgRoot | ForEach-Object { L ("IMG_ROOT`t" + $_.Name) }
L ("icons_root_files=" + $iconRoot.Count)

$log | Set-Content (Join-Path $root 'tools\_exclude_aab_bloat_log.txt') -Encoding UTF8
L 'DONE'
