# -*- coding: utf-8 -*-
"""Rasteriza os SVGs oficiais de assets/app_icon/ em PNG 1024x1024.

Não inventa logo: usa os mesmos paths e cores de
app_icon.svg / ios_icon.svg / android_adaptive_foreground.svg.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "app_icon"
SIZE = 1024
SUPERSAMPLE = 4

# Cores oficiais do SVG
C_PURPLE = (0x5A, 0x18, 0x9A)
C_LILAC = (0x9B, 0x5D, 0xE5)
C_PINK = (0xF1, 0x5B, 0xB5)
C_WHITE = (255, 255, 255, 255)
C_MINT = (0x00, 0xC8, 0x96, 255)

# Paths do SVG oficial (viewBox 1024, depois translate/scale)
HEART = [
    ("M", (0, 22)),
    ("C", (-14, 8), (-26, -2), (-26, -14)),
    ("C", (-26, -24), (-18, -30), (-10, -30)),
    ("C", (-4, -30), (0, -26), (0, -22)),
    ("C", (0, -26), (4, -30), (10, -30)),
    ("C", (18, -30), (26, -24), (26, -14)),
    ("C", (26, -2), (14, 8), (0, 22)),
]
LEAF = [
    ("M", (0, 0)),
    ("C", (10, -12), (26, -12), (30, -26)),
    ("C", (14, -24), (2, -16), (0, 0)),
]


def _mix(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    t = max(0.0, min(1.0, t))
    return (
        int(a[0] + (b[0] - a[0]) * t),
        int(a[1] + (b[1] - a[1]) * t),
        int(a[2] + (b[2] - a[2]) * t),
    )


def _gradient_color(t: float) -> tuple[int, int, int]:
    if t <= 0.55:
        return _mix(C_PURPLE, C_LILAC, t / 0.55)
    return _mix(C_LILAC, C_PINK, (t - 0.55) / 0.45)


def _cubic(p0, p1, p2, p3, steps: int = 48) -> list[tuple[float, float]]:
    pts = []
    for i in range(steps + 1):
        t = i / steps
        u = 1.0 - t
        x = u**3 * p0[0] + 3 * u**2 * t * p1[0] + 3 * u * t**2 * p2[0] + t**3 * p3[0]
        y = u**3 * p0[1] + 3 * u**2 * t * p1[1] + 3 * u * t**2 * p2[1] + t**3 * p3[1]
        pts.append((x, y))
    return pts


def _transform(pt: tuple[float, float], tx: float, ty: float, scale: float) -> tuple[float, float]:
    return (pt[0] * scale + tx, pt[1] * scale + ty)


def path_points(commands, tx: float, ty: float, scale: float) -> list[tuple[float, float]]:
    pts: list[tuple[float, float]] = []
    cursor = (0.0, 0.0)
    for cmd in commands:
        kind = cmd[0]
        if kind == "M":
            cursor = cmd[1]
            pts.append(_transform(cursor, tx, ty, scale))
        elif kind == "C":
            p1, p2, p3 = cmd[1], cmd[2], cmd[3]
            curve = _cubic(cursor, p1, p2, p3)
            for p in curve[1:]:
                pts.append(_transform(p, tx, ty, scale))
            cursor = p3
    return pts


def paint_gradient(size: int) -> Image.Image:
    # Faixa 1D do degradê oficial, depois mapeia x+y (diagonal do SVG).
    span = size * 2
    strip = Image.new("RGB", (span, 1))
    sp = strip.load()
    last = span - 1
    for i in range(span):
        sp[i, 0] = _gradient_color(i / last)
    wide = strip.resize((span, size), Image.Resampling.BILINEAR)
    img = Image.new("RGB", (size, size))
    for y in range(size):
        row = wide.crop((y, y, y + size, y + 1))
        img.paste(row, (0, y))
    return img


def draw_marks(img: Image.Image, scale_boost: float, tx: float, ty_heart: float, ty_leaf: float) -> None:
    draw = ImageDraw.Draw(img, "RGBA")
    heart = path_points(HEART, tx, ty_heart, 11 * scale_boost)
    leaf = path_points(LEAF, tx, ty_leaf, 9 * scale_boost)
    draw.polygon(heart, fill=C_WHITE)
    draw.polygon(leaf, fill=C_MINT)


def render_app_icon() -> Path:
    big = SIZE * SUPERSAMPLE
    canvas = paint_gradient(big)
    draw_marks(canvas, SUPERSAMPLE, big / 2, 470 * SUPERSAMPLE, 430 * SUPERSAMPLE)
    out = canvas.resize((SIZE, SIZE), Image.Resampling.LANCZOS).convert("RGB")
    path = OUT_DIR / "app_icon.png"
    out.save(path, "PNG")
    return path


def render_adaptive_foreground() -> Path:
    big = SIZE * SUPERSAMPLE
    canvas = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw_marks(canvas, SUPERSAMPLE, big / 2, 470 * SUPERSAMPLE, 430 * SUPERSAMPLE)
    out = canvas.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    path = OUT_DIR / "android_adaptive_foreground.png"
    out.save(path, "PNG")
    return path


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    icon = render_app_icon()
    fg = render_adaptive_foreground()
    for p in (icon, fg):
        with Image.open(p) as im:
            print(f"{p.relative_to(ROOT)} size={im.size} mode={im.mode} bytes={p.stat().st_size}")


if __name__ == "__main__":
    main()
