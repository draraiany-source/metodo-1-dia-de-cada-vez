# Fast alpha cleanup using LockBits (icons + uploaded Lily only).
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class PngAlphaCleaner {
  public static Bitmap Clean(Bitmap src, string mode, out int removed, out Rectangle content) {
    removed = 0;
    int w = src.Width, h = src.Height;
    var rect = new Rectangle(0, 0, w, h);
    Bitmap src32 = src.Clone(rect, PixelFormat.Format32bppArgb);
    BitmapData data = src32.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
    int stride = data.Stride;
    int bytes = Math.Abs(stride) * h;
    byte[] px = new byte[bytes];
    Marshal.Copy(data.Scan0, px, 0, bytes);

    int minX = w, minY = h, maxX = -1, maxY = -1;
    for (int y = 0; y < h; y++) {
      int row = y * stride;
      for (int x = 0; x < w; x++) {
        int i = row + x * 4;
        byte b = px[i], g = px[i+1], r = px[i+2], a = px[i+3];
        bool keep = true;
        if (a == 0) keep = false;
        else if (a < 28) { keep = false; removed++; }
        else if (mode == "icon") {
          bool nearWhite = r >= 200 && g >= 200 && b >= 200;
          int maxc = Math.Max(r, Math.Max(g, b));
          int minc = Math.Min(r, Math.Min(g, b));
          bool grayish = maxc >= 180 && (maxc - minc) <= 25;
          if (a < 245 && (nearWhite || grayish)) { keep = false; removed++; }
          else if (a < 200 && r >= 190 && g >= 190 && b >= 190) { keep = false; removed++; }
        }
        else if (mode == "mascot") {
          bool nearWhite = r >= 200 && g >= 200 && b >= 200;
          int maxc = Math.Max(r, Math.Max(g, b));
          int minc = Math.Min(r, Math.Min(g, b));
          bool grayish = maxc >= 180 && (maxc - minc) <= 25;
          if (a < 250 && (nearWhite || (grayish && a < 230))) { keep = false; removed++; }
        }
        else if (mode == "checker") {
          bool desatLight = (r >= 210 && g >= 210 && b >= 210) ||
            (r >= 170 && g >= 170 && b >= 170 &&
             Math.Abs(r-g) <= 12 && Math.Abs(g-b) <= 12 && Math.Abs(r-b) <= 12);
          bool isDark = r < 90 && g < 90 && b < 90;
          bool isSkin = r > 120 && g > 70 && b > 50 && r > b && (r - b) > 20;
          bool isHair = r > 40 && r < 140 && g < 100 && b < 80 && r > g;
          bool isPink = r > 180 && g < 120 && b > 100;
          if (desatLight && !isDark && !isSkin && !isHair && !isPink) { keep = false; removed++; }
          else if (a < 40) { keep = false; removed++; }
        }
        if (keep) {
          px[i+3] = 255;
          if (x < minX) minX = x; if (y < minY) minY = y;
          if (x > maxX) maxX = x; if (y > maxY) maxY = y;
        } else {
          px[i] = 0; px[i+1] = 0; px[i+2] = 0; px[i+3] = 0;
        }
      }
    }
    Marshal.Copy(px, 0, data.Scan0, bytes);
    src32.UnlockBits(data);

    if (maxX < minX) { content = Rectangle.Empty; return src32; }
    int pad = Math.Max(8, (int)(Math.Max(maxX-minX+1, maxY-minY+1) * 0.03));
    int x0 = Math.Max(0, minX - pad);
    int y0 = Math.Max(0, minY - pad);
    int x1 = Math.Min(w - 1, maxX + pad);
    int y1 = Math.Min(h - 1, maxY + pad);
    content = new Rectangle(x0, y0, x1 - x0 + 1, y1 - y0 + 1);

    bool square = mode == "icon";
    int side = Math.Max(content.Width, content.Height);
    int ow = square ? side : content.Width;
    int oh = square ? side : content.Height;
    Bitmap outBmp = new Bitmap(ow, oh, PixelFormat.Format32bppArgb);
    using (Graphics g = Graphics.FromImage(outBmp)) {
      g.Clear(Color.Transparent);
      g.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
      int dx = square ? (side - content.Width) / 2 : 0;
      int dy = square ? (side - content.Height) / 2 : 0;
      g.DrawImage(src32, dx, dy, content, GraphicsUnit.Pixel);
    }
    src32.Dispose();
    return outBmp;
  }
}
"@

$bak = Join-Path $root ("backup_assets_fast_{0:yyyyMMdd_HHmmss}" -f (Get-Date))
New-Item -ItemType Directory -Force -Path $bak | Out-Null

function Save-Clean($srcPath, $outPath, $mode) {
  $bytes = [IO.File]::ReadAllBytes($srcPath)
  $ms = New-Object IO.MemoryStream(,$bytes)
  $src = [Drawing.Bitmap]::FromStream($ms)
  $removed = 0
  $content = New-Object Drawing.Rectangle
  $out = [PngAlphaCleaner]::Clean($src, $mode, [ref]$removed, [ref]$content)
  $src.Dispose(); $ms.Dispose()
  if ($content.IsEmpty) {
    Write-Host "SKIP empty $(Split-Path $srcPath -Leaf)"
    $out.Dispose(); return
  }
  $rel = $srcPath.Substring($root.Length).TrimStart('\')
  $bakFile = Join-Path $bak $rel
  New-Item -ItemType Directory -Force -Path (Split-Path $bakFile) | Out-Null
  if (-not (Test-Path $bakFile)) { [IO.File]::Copy($srcPath, $bakFile, $true) }
  $tmp = "$outPath.tmp.png"
  $out.Save($tmp, [Drawing.Imaging.ImageFormat]::Png)
  Write-Host ("OK {0} -> {1}x{2} removed={3}" -f (Split-Path $srcPath -Leaf), $out.Width, $out.Height, $removed)
  $out.Dispose()
  Move-Item -LiteralPath $tmp -Destination $outPath -Force
}

Write-Host '=== ICONS ==='
Get-ChildItem (Join-Path $root 'assets\icons') -Filter 'icon_*.png' | ForEach-Object {
  Save-Clean $_.FullName $_.FullName 'icon'
}

Write-Host '=== REMAINING AVATARS (if any uncropped 1024) ==='
Get-ChildItem (Join-Path $root 'assets\images\mascote') -Filter 'avatar_*.png' -ErrorAction SilentlyContinue | ForEach-Object {
  $b = [Drawing.Bitmap]::FromStream((New-Object IO.MemoryStream(,[IO.File]::ReadAllBytes($_.FullName))))
  $needs = ($b.Width -eq 1024 -and $b.Height -eq 1024)
  $b.Dispose()
  if ($needs) { Save-Clean $_.FullName $_.FullName 'mascot' }
}

Write-Host '=== UPLOADED LILY (checkerboard) ==='
Get-ChildItem (Join-Path $root 'assets\_incoming_lily') -Filter 'lily_upload_*.png' |
  Where-Object { $_.Name -notlike '*_clean*' } | ForEach-Object {
    $out = Join-Path $_.DirectoryName ($_.BaseName + '_clean.png')
    Save-Clean $_.FullName $out 'checker'
  }

Write-Host "BACKUP=$bak"
Write-Host 'DONE'
