"""Remove near-black/near-white backgrounds from icon PNGs using Pillow only."""
from pathlib import Path
from PIL import Image
import shutil

ROOT = Path(r"C:\Users\Lenovo\Downloads\metodo 1 dia perfil premium 2\assets\images\icons_3d_pack2")
BACKUP = ROOT / "_backup_rgb"


def chroma(r, g, b):
    return max(r, g, b) - min(r, g, b)


def luminance(r, g, b):
    return 0.299 * r + 0.587 * g + 0.114 * b


def compute_alpha(r, g, b, existing_a=255):
    """Return new alpha; preserve high-chroma content (pinks/purples)."""
    c = chroma(r, g, b)
    lum = luminance(r, g, b)

    # High chroma = icon content (pink/lilac/purple/etc.) — keep opaque
    if c >= 25:
        return existing_a

    # Near-black solid: all <= 35 and low chroma
    if r <= 35 and g <= 35 and b <= 35 and c < 25:
        return 0

    # Near-white solid: all >= 245 and low chroma
    if r >= 245 and g >= 245 and b >= 245 and c < 25:
        return 0

    # Soft edge: near-black fade (low lum, low chroma)
    if lum < 45 and c < 25:
        # fade: lum 0 -> alpha 0, lum 45 -> alpha ~255
        # also tighten when max channel still dark
        t = lum / 45.0
        # stronger transparency near pure black
        soft = int(max(0, min(255, t * t * 255)))
        return min(existing_a, soft)

    # Soft edge: near-white fade (high lum, low chroma)
    # Treat light gray backgrounds (lum > ~220) with low chroma as bg fade
    if lum > 220 and c < 25:
        # map: lum 255 -> 0, lum 220 -> 255
        # also if all channels fairly high (>= 230-ish) fade harder
        if min(r, g, b) >= 230:
            # interpolate between 230 and 245
            # at 230 -> keep more, at 245+ -> 0 (already handled)
            span = 245 - 230
            # how close to pure white
            m = min(r, g, b)
            # m=230 -> alpha high, m=245 -> 0
            t = (245 - m) / span  # 1 at 230, 0 at 245
            soft = int(max(0, min(255, t * 255)))
            return min(existing_a, soft)
        # softer for 220-230 range
        t = (lum - 220) / (255 - 220)  # 0 at 220, 1 at 255
        soft = int(max(0, min(255, (1.0 - t) * 255)))
        return min(existing_a, soft)

    # Extra soft for mid light-gray near threshold (e.g. 239-244 corners)
    if min(r, g, b) >= 235 and c < 20:
        m = min(r, g, b)
        # 235 -> ~127, 245 -> 0
        soft = int(max(0, min(255, (245 - m) / 10.0 * 255)))
        return min(existing_a, soft)

    return existing_a


def classify_corner(rgba):
    r, g, b, a = rgba
    if a < 10:
        return "already_transparent"
    if r <= 40 and g <= 40 and b <= 40:
        return "black"
    if r >= 240 and g >= 240 and b >= 240:
        return "white"
    # light gray near white
    if min(r, g, b) >= 230 and chroma(r, g, b) < 25:
        return "white"
    return "other"


def main():
    files = sorted(ROOT.glob("icon_*.png"))
    print(f"Found {len(files)} icon_*.png files")

    # Backup only if empty/missing
    need_backup = True
    if BACKUP.exists():
        existing = list(BACKUP.glob("*.png"))
        if existing:
            need_backup = False
            print(f"Backup already has {len(existing)} files — skipping copy")
    if need_backup:
        BACKUP.mkdir(parents=True, exist_ok=True)
        for p in files:
            shutil.copy2(p, BACKUP / p.name)
        print(f"Backed up {len(files)} files to {BACKUP}")

    n_processed = 0
    n_black = 0
    n_white = 0
    n_already = 0

    for p in files:
        im = Image.open(p)
        corner_before = im.convert("RGBA").getpixel((0, 0))
        kind = classify_corner(corner_before)
        if kind == "black":
            n_black += 1
        elif kind == "white":
            n_white += 1
        elif kind == "already_transparent":
            n_already += 1

        rgba = im.convert("RGBA")
        pixels = list(rgba.getdata())
        out = []
        for r, g, b, a in pixels:
            na = compute_alpha(r, g, b, a)
            out.append((r, g, b, na))
        rgba.putdata(out)
        rgba.save(p, optimize=True)
        n_processed += 1
        corner_after = rgba.getpixel((0, 0))
        print(f"  [{n_processed}/{len(files)}] {p.name}: before={corner_before} ({kind}) -> after={corner_after}")

    print("\n=== SUMMARY ===")
    print(f"Processed: {n_processed}")
    print(f"Had black/near-black bg (corner): {n_black}")
    print(f"Had white/near-white bg (corner): {n_white}")
    print(f"Already transparent (corner): {n_already}")
    print(f"Other/unclassified corner: {n_processed - n_black - n_white - n_already}")


if __name__ == "__main__":
    main()
