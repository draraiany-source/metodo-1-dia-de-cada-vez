"""Fast Pillow-only near-black/near-white background removal for icon PNGs."""
from pathlib import Path
from PIL import Image
import shutil
import sys

ROOT = Path(r"C:\Users\Lenovo\Downloads\metodo 1 dia perfil premium 2\assets\images\icons_3d_pack2")
BACKUP = ROOT / "_backup_rgb"


def process_bytes(data: bytearray) -> None:
    # RGBA interleaved
    n = len(data) // 4
    for i in range(n):
        o = i * 4
        r = data[o]
        g = data[o + 1]
        b = data[o + 2]
        a = data[o + 3]
        mx = r if r > g else g
        if b > mx:
            mx = b
        mn = r if r < g else g
        if b < mn:
            mn = b
        c = mx - mn

        # High chroma content stays
        if c >= 25:
            continue

        # Near-black solid
        if r <= 35 and g <= 35 and b <= 35:
            data[o + 3] = 0
            continue

        # Near-white solid
        if r >= 245 and g >= 245 and b >= 245:
            data[o + 3] = 0
            continue

        # luminance approx
        lum = (77 * r + 150 * g + 29 * b) >> 8

        # Soft near-black
        if lum < 45:
            # t^2 * 255
            t = lum
            soft = (t * t * 255) // (45 * 45)
            if soft < a:
                data[o + 3] = soft
            continue

        # Soft near-white / light gray
        if lum > 220:
            if mn >= 230:
                # m=230 -> 255, m=245 -> 0
                soft = ((245 - mn) * 255) // 15
                if soft < 0:
                    soft = 0
                if soft > 255:
                    soft = 255
                if soft < a:
                    data[o + 3] = soft
                continue
            # lum 220..255 -> alpha 255..0
            soft = ((255 - lum) * 255) // 35
            if soft < 0:
                soft = 0
            if soft > 255:
                soft = 255
            if soft < a:
                data[o + 3] = soft
            continue

        if mn >= 235 and c < 20:
            soft = ((245 - mn) * 255) // 10
            if soft < 0:
                soft = 0
            if soft > 255:
                soft = 255
            if soft < a:
                data[o + 3] = soft


def classify_corner(r, g, b, a):
    if a < 10:
        return "already_transparent"
    if r <= 40 and g <= 40 and b <= 40:
        return "black"
    if r >= 240 and g >= 240 and b >= 240:
        return "white"
    mx = max(r, g, b)
    mn = min(r, g, b)
    if mn >= 230 and (mx - mn) < 25:
        return "white"
    return "other"


def main():
    files = sorted(ROOT.glob("icon_*.png"))
    print(f"Found {len(files)} icon_*.png files", flush=True)

    need_backup = True
    if BACKUP.exists():
        existing = list(BACKUP.glob("*.png"))
        if existing:
            need_backup = False
            print(f"Backup already has {len(existing)} files — skipping copy", flush=True)
    if need_backup:
        BACKUP.mkdir(parents=True, exist_ok=True)
        for p in files:
            shutil.copy2(p, BACKUP / p.name)
        print(f"Backed up {len(files)} files to {BACKUP}", flush=True)

    n_processed = n_black = n_white = n_already = 0

    for p in files:
        im = Image.open(p)
        rgba = im.convert("RGBA")
        r0, g0, b0, a0 = rgba.getpixel((0, 0))
        kind = classify_corner(r0, g0, b0, a0)
        if kind == "black":
            n_black += 1
        elif kind == "white":
            n_white += 1
        elif kind == "already_transparent":
            n_already += 1

        data = bytearray(rgba.tobytes())
        process_bytes(data)
        out = Image.frombytes("RGBA", rgba.size, bytes(data))
        out.save(p, optimize=True)
        n_processed += 1
        ra, ga, ba, aa = out.getpixel((0, 0))
        print(
            f"  [{n_processed}/{len(files)}] {p.name}: before=({r0},{g0},{b0},{a0}) ({kind}) -> after=({ra},{ga},{ba},{aa})",
            flush=True,
        )

    print("\n=== SUMMARY ===", flush=True)
    print(f"Processed: {n_processed}", flush=True)
    print(f"Had black/near-black bg (corner): {n_black}", flush=True)
    print(f"Had white/near-white bg (corner): {n_white}", flush=True)
    print(f"Already transparent (corner): {n_already}", flush=True)
    print(f"Other/unclassified corner: {n_processed - n_black - n_white - n_already}", flush=True)


if __name__ == "__main__":
    main()
