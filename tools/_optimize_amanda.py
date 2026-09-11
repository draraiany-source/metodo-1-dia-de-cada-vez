from pathlib import Path
from PIL import Image

src = Path("assets/amanda/originals")
opt = Path("assets/amanda/optimized")
thumbs = Path("assets/amanda/thumbs")
opt.mkdir(parents=True, exist_ok=True)
thumbs.mkdir(parents=True, exist_ok=True)

files = sorted(src.glob("amanda-*.jpg"))
print(f"found {len(files)} originals")
for f in files:
    im = Image.open(f).convert("RGB")
    w, h = im.size
    # optimized: max width 1600 keeping aspect
    max_w = 1600
    if w > max_w:
        nh = int(h * max_w / w)
        im_opt = im.resize((max_w, nh), Image.Resampling.LANCZOS)
    else:
        im_opt = im
    out = opt / (f.stem + ".webp")
    im_opt.save(out, "WEBP", quality=82, method=6)
    # thumb max 480
    max_t = 480
    if w > max_t:
        th = int(h * max_t / w)
        im_t = im.resize((max_t, th), Image.Resampling.LANCZOS)
    else:
        im_t = im.copy()
    tout = thumbs / (f.stem + ".webp")
    im_t.save(tout, "WEBP", quality=75, method=6)
    print(f"{f.name} {w}x{h} -> {out.name} {im_opt.size} ({out.stat().st_size//1024}KB) thumb {tout.stat().st_size//1024}KB")
print("DONE")
