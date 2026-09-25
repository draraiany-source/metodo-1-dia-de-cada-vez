$ErrorActionPreference = 'Continue'
$root = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2'
Set-Location $root
$out = Join-Path $root 'tools\_probe_aab_regression_out.txt'
$lines = New-Object System.Collections.Generic.List[string]
function L([string]$s) { $lines.Add($s) | Out-Null }

L "PWD=$pwd"
L "TIME=$(Get-Date -Format o)"

$aab = 'build\app\outputs\bundle\release\app-release.aab'
if (Test-Path $aab) {
  $f = Get-Item $aab
  L ("AAB_BYTES={0}" -f $f.Length)
  L ("AAB_MB={0:N2}" -f ($f.Length/1MB))
  L ("AAB_MTIME={0}" -f $f.LastWriteTime)
} else { L 'AAB_MISSING' }

L '=== ASSETS TOP ==='
Get-ChildItem 'assets' -Directory -EA SilentlyContinue | ForEach-Object {
  $sum = (Get-ChildItem $_.FullName -Recurse -File -EA SilentlyContinue | Measure-Object Length -Sum).Sum
  if (-not $sum) { $sum = 0 }
  L ("{0}`t{1:N2} MB`t{2} files" -f $_.Name, ($sum/1MB), ((Get-ChildItem $_.FullName -Recurse -File -EA SilentlyContinue).Count))
} | Out-Null

# Force sorted write
$assetLines = @()
Get-ChildItem 'assets' -Directory -EA SilentlyContinue | ForEach-Object {
  $files = @(Get-ChildItem $_.FullName -Recurse -File -EA SilentlyContinue)
  $sum = ($files | Measure-Object Length -Sum).Sum
  if (-not $sum) { $sum = 0 }
  $assetLines += [PSCustomObject]@{ Name=$_.Name; MB=[math]::Round($sum/1MB,2); Count=$files.Count; Bytes=[int64]$sum }
}
$assetLines | Sort-Object Bytes -Descending | ForEach-Object {
  L ("ASSET`t{0}`t{1} MB`t{2} files`t{3}" -f $_.Name, $_.MB, $_.Count, $_.Bytes)
}

L '=== HOT PATHS ==='
$hot = @(
  'assets\icons',
  'assets\icons\neon',
  'assets\images',
  'assets\images\recipes\neon',
  'assets\images\icons_3d',
  'assets\images\icons_3d_pack2',
  'assets\lily',
  'assets\lily_treinos',
  'assets\lily_exercicios',
  'assets\lily_exercicios\_backup_before_cadeiras_20260922',
  'assets\amanda',
  'assets\amanda\promo',
  'assets\amanda\optimized',
  'assets\amanda\originals',
  'assets\audio_programs',
  'assets\_lily_backup_before_frame_fix',
  'assets\_lily_trim_preview'
)
foreach ($p in $hot) {
  if (Test-Path $p) {
    $files = @(Get-ChildItem $p -Recurse -File -EA SilentlyContinue)
    $sum = ($files | Measure-Object Length -Sum).Sum
    if (-not $sum) { $sum = 0 }
    $png = @($files | Where-Object { $_.Extension -match '(?i)\.png$' }).Count
    $jpg = @($files | Where-Object { $_.Extension -match '(?i)\.jpe?g$' }).Count
    $webp = @($files | Where-Object { $_.Extension -match '(?i)\.webp$' }).Count
    $mp3 = @($files | Where-Object { $_.Extension -match '(?i)\.mp3$' }).Count
    $zip = @($files | Where-Object { $_.Extension -match '(?i)\.(zip|7z|rar)$' }).Count
    L ("HOT`t{0}`t{1:N2} MB`tfiles={2}`tpng={3}`tjpg={4}`twebp={5}`tmp3={6}`tzip={7}" -f $p, ($sum/1MB), $files.Count, $png, $jpg, $webp, $mp3, $zip)
  } else {
    L ("HOT_MISSING`t{0}" -f $p)
  }
}

L '=== ZIP/BACKUP UNDER ASSETS ==='
Get-ChildItem 'assets' -Recurse -File -EA SilentlyContinue |
  Where-Object { $_.Name -match '(?i)(backup|\.zip$|\.7z$|\.rar$|_incoming|temp|tmp)' -or $_.DirectoryName -match '(?i)(backup|_incoming|_validation|trim_preview)' } |
  Sort-Object Length -Descending |
  Select-Object -First 40 |
  ForEach-Object { L ("BK`t{0:N2} MB`t{1}" -f ($_.Length/1MB), $_.FullName.Substring($root.Length+1)) }

if (Test-Path $aab) {
  L '=== AAB INTERNALS ==='
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $z = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path $aab))
  try {
    $entries = @($z.Entries)
    L ("AAB_ENTRIES={0}" -f $entries.Count)
    $fa = @($entries | Where-Object { $_.FullName -like '*flutter_assets*' })
    $faBytes = ($fa | Measure-Object Length -Sum).Sum
    L ("FLUTTER_ASSETS_BYTES={0}" -f $faBytes)
    L ("FLUTTER_ASSETS_MB={0:N2}" -f ($faBytes/1MB))
    L ("AAB_MP3={0}" -f @($entries | Where-Object { $_.FullName -like '*.mp3' }).Count)
    L ("AAB_PNG={0}" -f @($entries | Where-Object { $_.FullName -like '*.png' }).Count)
    L ("AAB_JPG={0}" -f @($entries | Where-Object { $_.FullName -match '\.jpe?g$' }).Count)
    L ("AAB_BACKUP_PATHS={0}" -f @($entries | Where-Object { $_.FullName -match 'backup|_lily_backup|_incoming' }).Count)
    $entries | Where-Object { $_.FullName -match 'backup|_lily_backup' } | Select-Object -First 20 | ForEach-Object {
      L ("IN_AAB_BK`t{0}`t{1}" -f $_.Length, $_.FullName)
    }
    # top dirs under flutter_assets/assets/
    $dirMap = @{}
    foreach ($e in $fa) {
      if ($e.FullName -match 'flutter_assets/assets/([^/]+)/') {
        $d = $Matches[1]
        if (-not $dirMap.ContainsKey($d)) { $dirMap[$d] = [int64]0 }
        $dirMap[$d] += $e.Length
      }
    }
    $dirMap.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 20 | ForEach-Object {
      L ("AAB_DIR`t{0}`t{1:N2} MB" -f $_.Key, ($_.Value/1MB))
    }
    $entries | Sort-Object Length -Descending | Select-Object -First 25 | ForEach-Object {
      L ("AAB_TOP`t{0:N2} MB`t{1}" -f ($_.Length/1MB), $_.FullName)
    }
  } finally { $z.Dispose() }
}

L 'DONE'
$lines | Set-Content -Path $out -Encoding UTF8
Write-Output "WROTE $out"
Write-Output ("LINES={0}" -f $lines.Count)
