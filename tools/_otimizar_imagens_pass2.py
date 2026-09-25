# -*- coding: utf-8 -*-
"""Passo 2: comprime imagens empacotadas.

- PNG opaco: gera .jpg irmao (q=80) e remove o .png so depois do Dart
  apontar para o jpg. Este script so GRAVA o jpg e registra o mapeamento.
- PNG com alpha: redimensiona e otimiza no mesmo arquivo.
- JPG: recomprime se ainda grande.
Nao mexe em _backup/_incoming/icons_3d nem no pack 'treinos lily fit'.
"""
from __future__ import annotations

import io
import json
import sys
from pathlib import Path

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "docs" / "_otimizacao_imagens_pass2.json"

# Somente pastas que o pubspec empacota (nao recursivo alem do declarado).
TARGETS = [
    ROOT / "assets" / "icons",
    ROOT / "assets" / "images" / "mascote",
    ROOT / "assets" / "images" / "home",
    ROOT / "assets" / "images" / "treinos",
    ROOT / "assets" / "images" / "corrida",
    ROOT / "assets" / "images" / "hidratacao",
    ROOT / "assets" / "images" / "receitas",
    ROOT / "assets" / "images" / "recipes",
    ROOT / "assets" / "images" / "alimentacao",
    ROOT / "assets" / "images" / "progresso",
    ROOT / "assets" / "images" / "rotina",
    ROOT / "assets" / "images" / "bem_estar",
    ROOT / "assets" / "images" / "lily_fit",
    ROOT / "assets" / "images" / "referencias",
    ROOT / "assets" / "mascot" / "png",
    ROOT / "assets" / "mascot" / "extras",
    ROOT / "assets" / "lily",
    ROOT / "assets" / "lily_treinos",
    ROOT / "assets" / "lily_exercicios",
    ROOT / "assets" / "amanda",
    ROOT / "assets" / "app_icon",
    ROOT / "assets" / "illustrations" / "banners",
    ROOT / "assets" / "onboarding",
]

SKIP_PARTS = {
    "_incoming",
    "_backup",
    "originals",
    "_orig",
    "_lily_backup",
    "_lily_trim",
    "_validation",
    "icons_3d",
    "icons_3d_pack2",
    "treinos lily fit",
    "neon/navegacao",
    "neon/saude",
    "neon/nutricao",
    "neon/conquistas",
    "neon/perfil",
}

IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".webp"}


def should_skip(path: Path) -> bool:
    rel = str(path.relative_to(ROOT)).replace("\\", "/")
    return any(part in rel for part in SKIP_PARTS)


def is_icon(path: Path) -> bool:
    rel = str(path).replace("\\", "/").lower()
    return any(h in rel for h in ("/icons/", "app_icon", "/recipes/"))


def has_real_alpha(im: Image.Image) -> bool:
    if im.mode not in ("RGBA", "LA", "PA"):
        return False
    if im.mode == "PA":
        im = im.convert("RGBA")
    return im.getchannel("A").getextrema()[0] < 255


def max_side(path: Path, alpha: bool) -> int:
    if is_icon(path):
        return 512
    if alpha:
        return 900
    return 1080


def optimize_one(path: Path) -> dict | None:
    before = path.stat().st_size
    if before < 20_000:
        return None
    try:
        with Image.open(path) as src:
            im = ImageOps.exif_transpose(src)
            im.load()
            orig_mode = im.mode
            w, h = im.size
            alpha = has_real_alpha(im)
            limit = max_side(path, alpha)
            if max(w, h) > limit:
                ratio = limit / max(w, h)
                im = im.resize(
                    (max(1, int(w * ratio)), max(1, int(h * ratio))),
                    Image.Resampling.LANCZOS,
                )
            ext = path.suffix.lower()
            buf = io.BytesIO()
            kind = "keep"
            dest = path
            if ext == ".png" and not alpha:
                if im.mode not in ("RGB", "L"):
                    im = im.convert("RGB")
                im.save(buf, format="JPEG", quality=80, optimize=True, progressive=True)
                kind = "png-to-jpg"
                dest = path.with_suffix(".jpg")
            elif ext in {".jpg", ".jpeg"}:
                if im.mode not in ("RGB", "L"):
                    im = im.convert("RGB")
                im.save(buf, format="JPEG", quality=80, optimize=True, progressive=True)
                kind = "jpeg"
            elif ext == ".webp":
                im.save(buf, format="WEBP", quality=78, method=6)
                kind = "webp"
            else:
                if im.mode == "P":
                    im = im.convert("RGBA" if alpha else "RGB")
                elif im.mode == "LA":
                    im = im.convert("RGBA")
                if alpha and im.mode != "RGBA":
                    im = im.convert("RGBA")
                im.save(buf, format="PNG", optimize=True, compress_level=9)
                kind = "png"
                if is_icon(path) and buf.tell() > 80_000:
                    q = im.quantize(
                        colors=256,
                        method=Image.Quantize.MEDIANCUT,
                        dither=Image.Dither.FLOYDSTEINBERG,
                    )
                    buf2 = io.BytesIO()
                    q.save(buf2, format="PNG", optimize=True, compress_level=9)
                    if 0 < buf2.tell() < buf.tell() * 0.85:
                        buf = buf2
                        kind = "png-q"
            data = buf.getvalue()
            after = len(data)
            if after < 32:
                return None
            if dest == path and after >= before * 0.97:
                return {
                    "path": str(path.relative_to(ROOT)).replace("\\", "/"),
                    "dest": str(dest.relative_to(ROOT)).replace("\\", "/"),
                    "before": before,
                    "after": before,
                    "saved": 0,
                    "kind": kind,
                    "skipped": "sem ganho",
                    "wh": f"{w}x{h}",
                    "mode": orig_mode,
                    "alpha": alpha,
                }
            dest.write_bytes(data)
            return {
                "path": str(path.relative_to(ROOT)).replace("\\", "/"),
                "dest": str(dest.relative_to(ROOT)).replace("\\", "/"),
                "before": before,
                "after": after,
                "saved": max(0, before - after),
                "kind": kind,
                "skipped": None,
                "wh": f"{w}x{h}",
                "mode": orig_mode,
                "alpha": alpha,
            }
    except Exception as e:  # noqa: BLE001
        return {
            "path": str(path.relative_to(ROOT)).replace("\\", "/"),
            "before": before,
            "after": before,
            "saved": 0,
            "kind": "erro",
            "skipped": str(e),
            "wh": "",
            "mode": "",
            "alpha": False,
        }


def main() -> None:
    files: list[Path] = []
    for folder in TARGETS:
        if not folder.exists():
            continue
        for f in folder.rglob("*"):
            if not f.is_file() or f.suffix.lower() not in IMAGE_EXTS:
                continue
            if should_skip(f):
                continue
            files.append(f)
    files.sort()
    rows = []
    saved = 0
    changed = 0
    for i, f in enumerate(files, 1):
        row = optimize_one(f)
        if row is None:
            continue
        rows.append(row)
        saved += row["saved"]
        if row["saved"] > 0:
            changed += 1
        if i % 50 == 0:
            print(f"... {i}/{len(files)} saved_mb={saved/1024/1024:.1f}", flush=True)
    summary = {
        "files_seen": len(files),
        "files_logged": len(rows),
        "files_rewritten": changed,
        "saved_bytes": saved,
        "saved_mb": round(saved / 1024 / 1024, 2),
        "rows": sorted(rows, key=lambda r: -r["saved"]),
    }
    REPORT.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps({k: summary[k] for k in summary if k != "rows"}, indent=2))
    print("top saved:")
    for r in summary["rows"][:15]:
        if r["saved"] > 0:
            print(f"  {r['saved']/1024/1024:6.2f} MB  {r['kind']:7}  {r['path']}")


if __name__ == "__main__":
    sys.exit(main() or 0)
