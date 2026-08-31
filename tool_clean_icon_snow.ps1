# Remove residual opaque "snow" by flood-filling light background from edges, then crop.
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class IconSnowCleaner {
  static bool IsBg(byte r, byte g, byte b, byte a) {
    if (a < 40) return true;
    int max = Math.Max(r, Math.Max(g, b));
    int min = Math.Min(r, Math.Min(g, b));
    // light desaturated / near white (snow dust)
    if (max >= 160 && (max - min) <= 35) return true;
    if (r >= 200 && g >= 200 && b >= 200) return true;
    return false;
  }

  public static Bitmap Clean(Bitmap src, out int removed) {
    removed = 0;
    int w = src.Width, h = src.Height;
    var rect = new Rectangle(0, 0, w, h);
    Bitmap bmp = src.Clone(rect, PixelFormat.Format32bppArgb);
    BitmapData data = bmp.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
    int stride = data.Stride;
    byte[] px = new byte[Math.Abs(stride) * h];
    Marshal.Copy(data.Scan0, px, 0, px.Length);

    bool[] mark = new bool[w * h];
    var q = new Queue<int>();
    Action<int,int> tryEnq = (x, y) => {
      if (x < 0 || y < 0 || x >= w || y >= h) return;
      int idx = y * w + x;
      if (mark[idx]) return;
      int i = y * stride + x * 4;
      byte b = px[i], g = px[i+1], r = px[i+2], a = px[i+3];
      if (!IsBg(r,g,b,a)) return;
      mark[idx] = true;
      q.Enqueue(idx);
    };

    for (int x = 0; x < w; x++) { tryEnq(x, 0); tryEnq(x, h-1); }
    for (int y = 0; y < h; y++) { tryEnq(0, y); tryEnq(w-1, y); }

    int[] dx = {1,-1,0,0,1,1,-1,-1};
    int[] dy = {0,0,1,-1,1,-1,1,-1};
    while (q.Count > 0) {
      int idx = q.Dequeue();
      int x = idx % w, y = idx / w;
      for (int k = 0; k < 8; k++) tryEnq(x + dx[k], y + dy[k]);
    }

    int minX = w, minY = h, maxX = -1, maxY = -1;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int idx = y * w + x;
        int i = y * stride + x * 4;
        if (mark[idx]) {
          if (px[i+3] != 0) removed++;
          px[i]=0; px[i+1]=0; px[i+2]=0; px[i+3]=0;
        } else if (px[i+3] > 0) {
          // kill leftover tiny near-white speckles not connected? keep colored content
          byte b=px[i], g=px[i+1], r=px[i+2], a=px[i+3];
          if (a < 28 || (r>=230 && g>=230 && b>=230 && a < 255)) {
            px[i]=0; px[i+1]=0; px[i+2]=0; px[i+3]=0; removed++;
          } else {
            px[i+3]=255;
            if (x < minX) minX=x; if (y < minY) minY=y;
            if (x > maxX) maxX=x; if (y > maxY) maxY=y;
          }
        }
      }
    }
    Marshal.Copy(px, 0, data.Scan0, px.Length);
    bmp.UnlockBits(data);

    if (maxX < minX) return bmp;
    int pad = Math.Max(6, (int)(Math.Max(maxX-minX+1, maxY-minY+1) * 0.04));
    int x0 = Math.Max(0, minX-pad), y0 = Math.Max(0, minY-pad);
    int x1 = Math.Min(w-1, maxX+pad), y1 = Math.Min(h-1, maxY+pad);
    var content = new Rectangle(x0,y0,x1-x0+1,y1-y0+1);
    int side = Math.Max(content.Width, content.Height);
    Bitmap outBmp = new Bitmap(side, side, PixelFormat.Format32bppArgb);
    using (Graphics g = Graphics.FromImage(outBmp)) {
      g.Clear(Color.Transparent);
      g.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
      int dx2 = (side - content.Width)/2, dy2 = (side - content.Height)/2;
      g.DrawImage(bmp, dx2, dy2, content, GraphicsUnit.Pixel);
    }
    bmp.Dispose();
    return outBmp;
  }
}
"@

function Save-Icon($path) {
  $bytes = [IO.File]::ReadAllBytes($path)
  $ms = New-Object IO.MemoryStream(,$bytes)
  $src = [Drawing.Bitmap]::FromStream($ms)
  $removed = 0
  $out = [IconSnowCleaner]::Clean($src, [ref]$removed)
  $src.Dispose(); $ms.Dispose()
  $tmp = "$path.tmp.png"
  $out.Save($tmp, [Drawing.Imaging.ImageFormat]::Png)
  Write-Host ("OK {0} -> {1}x{2} removed={3}" -f (Split-Path $path -Leaf), $out.Width, $out.Height, $removed)
  $out.Dispose()
  Move-Item -LiteralPath $tmp -Destination $path -Force
}

# Only re-clean icons that stayed near full canvas (snow spanning frame)
$targets = Get-ChildItem (Join-Path $root 'assets\icons') -Filter 'icon_*.png' | Where-Object {
  $b = [Drawing.Bitmap]::FromStream((New-Object IO.MemoryStream(,[IO.File]::ReadAllBytes($_.FullName))))
  $full = ($b.Width -ge 1000 -or $b.Height -ge 1000)
  $b.Dispose()
  $full
}
Write-Host ("Re-cleaning {0} full-canvas icons..." -f $targets.Count)
$targets | ForEach-Object { Save-Icon $_.FullName }

# Also re-validate home on black
Add-Type -AssemblyName System.Drawing | Out-Null
$home = Join-Path $root 'assets\icons\icon_home.png'
$val = Join-Path $root 'assets\_validation\icon_home_on_black_v2.png'
$bytes=[IO.File]::ReadAllBytes($home); $ms=New-Object IO.MemoryStream(,$bytes); $img=[Drawing.Bitmap]::FromStream($ms)
$c=New-Object Drawing.Bitmap 512,512; $g=[Drawing.Graphics]::FromImage($c); $g.Clear([Drawing.Color]::Black)
$scale=[Math]::Min(0.92*512/$img.Width,0.92*512/$img.Height); $dw=[int]($img.Width*$scale); $dh=[int]($img.Height*$scale)
$g.DrawImage($img,[int]((512-$dw)/2),[int]((512-$dh)/2),$dw,$dh)
$g.Dispose(); $img.Dispose(); $ms.Dispose(); $c.Save($val,[Drawing.Imaging.ImageFormat]::Png); $c.Dispose()
Write-Host "Wrote $val"
Write-Host DONE
