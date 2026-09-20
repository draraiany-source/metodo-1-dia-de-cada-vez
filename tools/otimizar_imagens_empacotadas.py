# -*- coding: utf-8 -*-
"""Otimiza imagens JAH empacotadas: redimensiona e recomprime no mesmo caminho.

Mantem o nome e a extensao (.png / .jpg) para nao quebrar referencias Dart.
Originais recuperaveis via git (tag backup-pre-otimizacao-tamanho-20260920).
Nao apaga arquivos. Nao mexe em SVG, JSON, audio, nem pastas _backup/_incoming.
"""
from __future__ import annotations

import io
import json
import sys
from pathlib import Path

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "docs" / "_otimizacao_imagens_log.json"

# Pastas que entram no APK (pubspec). Subpastas _incoming / originals nao.
TARGETS = [
    ROOT / "assets" / "icons",
    ROOT / "assets" / "images",
    ROOT / "assets" / "lily",
    ROOT / "assets" / "lily_treinos",
    ROOT / "assets" / "lily_exercicios",
    ROOT / "assets" / "amanda",
    ROOT / "assets" / "mascot",
    ROOT / "assets" / "app_icon",
]

SKIP_PARTS = {
    "_incoming",
    "_backup",
    "originals",
    "_orig",
    "_lily_backup",
    "_lily_trim",
    "_validation",
    "treinos lily fit",
}

# Icones de UI: 768 px basta em celular xxhdpi. Fotos Lily: 1080.
ICON_HINTS = (
    "icons",
    "recipes",
    "neon",
    "icons_3d",
    "personal-ai",
    "app_icon",
)
IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".webp"}


def should_skip(path: Path) -> bool:
    rel = str(path.relative_to(ROOT)).replace("\\", "/")
    return any(part in rel for part in SKIP_PARTS)


def max_side_for(path: Path) -> int:
    rel = str(path).replace("\\", "/").lower()
    if any(h in rel for h in ICON_HINTS):
        return 768
    return 1080


def has_real_alpha(im: Image.Image) -> bool:
    if im.mode not in ("RGBA", "LA", "PA"):
        return False
    if im.mode == "PA":
        im = im.convert("RGBA")
    alpha = im.getchannel("A")
    extrema = alpha.getextrema()
    return extrema[0] < 255


def optimize_one(path: Path) -> dict | None:
    before = path.stat().st_size
    if before < 12_000:
        return None
    try:
        with Image.open(path) as src:
            im = ImageOps.exif_transpose(src)
            im.load()
            orig_mode = im.mode
            w, h = im.size
            limit = max_side_for(path)
            resized = False
            if max(w, h) > limit:
                ratio = limit / max(w, h)
                nw, nh = max(1, int(w * ratio)), max(1, int(h * ratio))
                im = im.resize((nw, nh), Image.Resampling.LANCZOS)
                resized = True
            ext = path.suffix.lower()
            buf = io.BytesIO()
            if ext in {".jpg", ".jpeg"}:
                if im.mode not in ("RGB", "L"):
                    im = im.convert("RGB")
                im.save(buf, format="JPEG", quality=82, optimize=True, progressive=True)
            elif ext == ".webp":
                im.save(buf, format="WEBP", quality=80, method=6)
            else:
                # PNG: WebP lossless/lossy gravado de volta como PNG quebraria o decoder.
                # Usa PNG otimizado; se opaco, JPEG nao cabe na extensao.
                # Para PNG fotografico, quantiza so se ainda enorme apos resize.
                alpha = has_real_alpha(im)
                if im.mode == "P":
                    im = im.convert("RGBA" if alpha else "RGB")
                elif im.mode == "LA":
                    im = im.convert("RGBA")
                elif im.mode == "CMYK":
                    im = im.convert("RGB")
                if alpha and im.mode != "RGBA":
                    im = im.convert("RGBA")
                elif not alpha and im.mode not in ("RGB", "L"):
                    im = im.convert("RGB")
                im.save(buf, format="PNG", optimize=True, compress_level=9)
                # Paleta 256 so em icones de UI ainda enormes. Lily/Amanda/fotos
                # ficam so no resize + PNG optimize para nao posterizar.
                is_icon = max_side_for(path) == 768
                if is_icon and buf.tell() > 220_000:
                    buf2 = io.BytesIO()
                    q = im.quantize(
                        colors=256,
                        method=Image.Quantize.MEDIANCUT,
                        dither=Image.Dither.FLOYDSTEINBERG,
                    )
                    q.save(buf2, format="PNG", optimize=True, compress_level=9)
                    if 0 < buf2.tell() < buf.tell() * 0.8:
                        buf = buf2
            data = buf.getvalue()
            after = len(data)
            if after < 32 or after >= before * 0.97:
                return {
                    "path": str(path.relative_to(ROOT)).replace("\\", "/"),
                    "before": before,
                    "after": before,
                    "saved": 0,
                    "resized": resized,
                    "skipped": "sem ganho",
                    "wh": f"{w}x{h}",
                    "mode": orig_mode,
                }
            path.write_bytes(data)
            return {
                "path": str(path.relative_to(ROOT)).replace("\\", "/"),
                "before": before,
                "after": after,
                "saved": before - after,
                "resized": resized,
                "skipped": None,
                "wh": f"{w}x{h}",
                "mode": orig_mode,
            }
    except Exception as e:  # noqa: BLE001 — logar e seguir
        return {
            "path": str(path.relative_to(ROOT)).replace("\\", "/"),
            "before": before,
            "after": before,
            "saved": 0,
            "resized": False,
            "skipped": f"erro: {e}",
            "wh": "",
            "mode": "",
        }


def main() -> None:
    files: list[Path] = []
    for folder in TARGETS:
        if not folder.exists():
            continue
        for f in folder.rglob("*"):
            if not f.is_file():
                continue
            if f.suffix.lower() not in IMAGE_EXTS:
                continue
            if should_skip(f):
                continue
            files.append(f)
    files.sort()
    rows = []
    saved_total = 0
    changed = 0
    for i, f in enumerate(files, 1):
        row = optimize_one(f)
        if row is None:
            continue
        rows.append(row)
        saved_total += row["saved"]
        if row["saved"] > 0:
            changed += 1
        if i % 40 == 0:
            print(f"... {i}/{len(files)}  saved_mb={saved_total/1024/1024:.1f}", flush=True)
    summary = {
        "files_seen": len(files),
        "files_logged": len(rows),
        "files_rewritten": changed,
        "saved_bytes": saved_total,
        "saved_mb": round(saved_total / 1024 / 1024, 2),
        "rows": sorted(rows, key=lambda r: -r["saved"]),
    }
    REPORT.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps({k: summary[k] for k in summary if k != "rows"}, indent=2))
    print(f"log: {REPORT}")


if __name__ == "__main__":
    sys.exit(main() or 0)
