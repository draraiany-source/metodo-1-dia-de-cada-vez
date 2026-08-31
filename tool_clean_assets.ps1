# Limpa halo branco / alpha sujo e faz crop com margem de segurança.
# NÃO redesenha a personagem — só remove fundo/resíduo e recorta.
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$bak = Join-Path $root ("backup_assets_pre_alpha_{0:yyyyMMdd_HHmmss}" -f (Get-Date))
New-Item -ItemType Directory -Force -Path $bak, (Join-Path $root 'assets\_incoming_lily') | Out-Null

$upDir = 'C:\Users\Lenovo\.cursor\projects\c-Users-Lenovo-Downloads-metodo-1-dia-perfil-premium-2\assets'
$i = 0
Get-ChildItem -LiteralPath $upDir -Filter '*.png' -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -like '*Imagens_com_fundo*' } |
  ForEach-Object {
    $i++
    $dest = Join-Path $root ("assets\_incoming_lily\lily_upload_{0:D2}.png" -f $i)
    $srcLong = '\\?\' + $_.FullName
    try {
      [System.IO.File]::Copy($srcLong, $dest, $true)
      Write-Host "Copied upload -> $(Split-Path $dest -Leaf)"
    } catch {
      # Fallback: stream copy via .NET with short destination only
      $bytes = [System.IO.File]::ReadAllBytes($srcLong)
      [System.IO.File]::WriteAllBytes($dest, $bytes)
      Write-Host "Copied upload (bytes) -> $(Split-Path $dest -Leaf)"
    }
  }

function Test-NearWhite([System.Drawing.Color]$c, [int]$thresh) {
  return (($c.R -ge $thresh) -and ($c.G -ge $thresh) -and ($c.B -ge $thresh))
}

function Test-LightGrayish([System.Drawing.Color]$c) {
  $max = [Math]::Max($c.R, [Math]::Max($c.G, $c.B))
  $min = [Math]::Min($c.R, [Math]::Min($c.G, $c.B))
  return (($max -ge 180) -and (($max - $min) -le 25))
}

function Invoke-CleanAndCrop {
  param(
    [string]$SrcPath,
    [string]$OutPath,
    [ValidateSet('mascot','icon','checker')]$Mode
  )

  # Carrega via MemoryStream para NÃO travar o arquivo em disco (GDI+ Save falha se o FromFile ainda estiver aberto).
  $fileBytes = [System.IO.File]::ReadAllBytes($SrcPath)
  $ms = New-Object System.IO.MemoryStream(,$fileBytes)
  $src = [System.Drawing.Bitmap]::FromStream($ms)
  $w = $src.Width
  $h = $src.Height
  $bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

  $minX = $w; $minY = $h; $maxX = -1; $maxY = -1
  $removed = 0

  for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
      $p = $src.GetPixel($x, $y)
      $a = [int]$p.A
      $keep = $true

      if ($a -eq 0) {
        $keep = $false
      }
      elseif ($a -lt 28) {
        $keep = $false
        $removed++
      }
      elseif ($Mode -eq 'icon') {
        $nw = Test-NearWhite $p 200
        $lg = Test-LightGrayish $p
        if (($a -lt 245) -and ($nw -or $lg)) {
          $keep = $false
          $removed++
        }
        elseif (($a -lt 200) -and (Test-NearWhite $p 190)) {
          $keep = $false
          $removed++
        }
      }
      elseif ($Mode -eq 'mascot') {
        $nw = Test-NearWhite $p 200
        $lg = Test-LightGrayish $p
        if (($a -lt 250) -and ($nw -or (($lg) -and ($a -lt 230)))) {
          $keep = $false
          $removed++
        }
      }
      elseif ($Mode -eq 'checker') {
        $desatLight = (
          (Test-NearWhite $p 210) -or (
            ($p.R -ge 170) -and ($p.G -ge 170) -and ($p.B -ge 170) -and
            ([Math]::Abs([int]$p.R - [int]$p.G) -le 12) -and
            ([Math]::Abs([int]$p.G - [int]$p.B) -le 12) -and
            ([Math]::Abs([int]$p.R - [int]$p.B) -le 12)
          )
        )
        $isDark = (($p.R -lt 90) -and ($p.G -lt 90) -and ($p.B -lt 90))
        $isSkin = (($p.R -gt 120) -and ($p.G -gt 70) -and ($p.B -gt 50) -and ($p.R -gt $p.B) -and (([int]$p.R - [int]$p.B) -gt 20))
        $isHair = (($p.R -gt 40) -and ($p.R -lt 140) -and ($p.G -lt 100) -and ($p.B -lt 80) -and ($p.R -gt $p.G))
        $isPink = (($p.R -gt 180) -and ($p.G -lt 120) -and ($p.B -gt 100))
        if ($desatLight -and (-not $isDark) -and (-not $isSkin) -and (-not $isHair) -and (-not $isPink)) {
          $keep = $false
          $removed++
        }
        elseif ($a -lt 40) {
          $keep = $false
          $removed++
        }
      }

      if ($keep) {
        $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $p.R, $p.G, $p.B))
        if ($x -lt $minX) { $minX = $x }
        if ($y -lt $minY) { $minY = $y }
        if ($x -gt $maxX) { $maxX = $x }
        if ($y -gt $maxY) { $maxY = $y }
      }
      else {
        $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
      }
    }
  }

  if ($maxX -lt $minX) {
    Write-Host "SKIP empty: $(Split-Path $SrcPath -Leaf)"
    $src.Dispose(); $bmp.Dispose(); $ms.Dispose()
    return
  }

  $pad = [Math]::Max(8, [int]([Math]::Max($maxX - $minX + 1, $maxY - $minY + 1) * 0.03))
  $x0 = [Math]::Max(0, $minX - $pad)
  $y0 = [Math]::Max(0, $minY - $pad)
  $x1 = [Math]::Min($w - 1, $maxX + $pad)
  $y1 = [Math]::Min($h - 1, $maxY + $pad)
  $cw = $x1 - $x0 + 1
  $ch = $y1 - $y0 + 1

  $side = [Math]::Max($cw, $ch)
  $outW = if ($Mode -eq 'icon') { $side } else { $cw }
  $outH = if ($Mode -eq 'icon') { $side } else { $ch }

  $out = New-Object System.Drawing.Bitmap $outW, $outH, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($out)
  $g.Clear([System.Drawing.Color]::Transparent)
  $g.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
  $dx = if ($Mode -eq 'icon') { [int](($side - $cw) / 2) } else { 0 }
  $dy = if ($Mode -eq 'icon') { [int](($side - $ch) / 2) } else { 0 }
  $srcRect = New-Object System.Drawing.Rectangle $x0, $y0, $cw, $ch
  $g.DrawImage($bmp, $dx, $dy, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()

  $rel = $SrcPath.Substring($root.Length).TrimStart('\')
  $bakFile = Join-Path $bak $rel
  New-Item -ItemType Directory -Force -Path (Split-Path $bakFile) | Out-Null
  if (-not (Test-Path $bakFile)) {
    [System.IO.File]::Copy($SrcPath, $bakFile, $true)
  }

  $tmp = $OutPath + '.tmp.png'
  $out.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
  Write-Host ("OK {0} -> {1}x{2} (was {3}x{4}) removed~{5}" -f (Split-Path $SrcPath -Leaf), $outW, $outH, $w, $h, $removed)

  $src.Dispose(); $bmp.Dispose(); $out.Dispose(); $ms.Dispose()
  Move-Item -LiteralPath $tmp -Destination $OutPath -Force
}

Write-Host '=== CLEAN MASCOTS ==='
Get-ChildItem (Join-Path $root 'assets\mascot\png'), (Join-Path $root 'assets\mascot\extras'), (Join-Path $root 'assets\images\mascote') -Filter '*.png' -ErrorAction SilentlyContinue |
  ForEach-Object { Invoke-CleanAndCrop -SrcPath $_.FullName -OutPath $_.FullName -Mode mascot }

Write-Host '=== CLEAN ICONS ==='
Get-ChildItem (Join-Path $root 'assets\icons') -Filter 'icon_*.png' -ErrorAction SilentlyContinue |
  ForEach-Object { Invoke-CleanAndCrop -SrcPath $_.FullName -OutPath $_.FullName -Mode icon }

Write-Host '=== CLEAN UPLOADS ==='
Get-ChildItem (Join-Path $root 'assets\_incoming_lily') -Filter 'lily_upload_*.png' -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -notlike '*_clean.png' } |
  ForEach-Object {
    $out = Join-Path $_.DirectoryName ($_.BaseName + '_clean.png')
    Invoke-CleanAndCrop -SrcPath $_.FullName -OutPath $out -Mode checker
  }

Write-Host "BACKUP=$bak"
Write-Host 'DONE'
