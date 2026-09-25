# -*- coding: utf-8 -*-
"""Atualiza Dart/pubspec para os JPG gerados e remove os PNG originais."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOG = ROOT / "docs" / "_otimizacao_imagens_pass2.json"
SKIP = {"assets/app_icon/app_icon.png"}


def main() -> None:
    data = json.loads(LOG.read_text(encoding="utf-8"))
    conv = [
        r
        for r in data["rows"]
        if r.get("kind") == "png-to-jpg" and r.get("saved", 0) > 0
        and r["path"] not in SKIP
    ]
    dart_files = list((ROOT / "lib").rglob("*.dart")) + list((ROOT / "test").rglob("*.dart"))
    dart_files.append(ROOT / "pubspec.yaml")
    replaced = 0
    deleted = 0
    names = []
    for row in conv:
        png_rel = row["path"]
        jpg_rel = row.get("dest") or png_rel.rsplit(".", 1)[0] + ".jpg"
        png_name = Path(png_rel).name
        jpg_name = Path(jpg_rel).name
        names.append((png_name, jpg_name, png_rel, jpg_rel))
        for f in dart_files:
            text = f.read_text(encoding="utf-8")
            if png_rel in text or png_name in text:
                new = text.replace(png_rel, jpg_rel).replace(png_name, jpg_name)
                if new != text:
                    f.write_text(new, encoding="utf-8")
                    replaced += 1
        png = ROOT / png_rel
        jpg = ROOT / jpg_rel
        if jpg.exists() and png.exists():
            png.unlink()
            deleted += 1
    extra = ROOT / "assets/app_icon/app_icon.jpg"
    if extra.exists():
        extra.unlink()
        print("removed leftover", extra)
    print("files_touched", replaced, "png_deleted", deleted, "converted", len(conv))


if __name__ == "__main__":
    main()
