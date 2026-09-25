# -*- coding: utf-8 -*-
"""Auditoria somente-leitura do APK atual e assets empacotados."""
from __future__ import annotations

import hashlib
import json
import zipfile
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APK = ROOT / "build" / "app" / "outputs" / "flutter-apk" / "app-release.apk"
OUT = ROOT / "docs" / "_audit_tamanho_20260921.json"

PACKED_ROOTS = [
    "assets/images",
    "assets/mascot/png",
    "assets/mascot/extras",
    "assets/icons",
    "assets/content",
    "assets/animations",
    "assets/rive",
    "assets/avatars",
    "assets/stickers",
    "assets/badges",
    "assets/backgrounds",
    "assets/illustrations/banners",
    "assets/onboarding",
    "assets/loading",
    "assets/empty",
    "assets/success",
    "assets/error",
    "assets/premium",
    "assets/exercises",
    "assets/recipes",
    "assets/habits",
    "assets/challenges",
    "assets/lily",
    "assets/lily_treinos",
    "assets/lily_exercicios",
    "assets/amanda",
    "assets/app_icon",
]

SKIP_PARTS = {"_incoming", "_backup", "originals", "_orig", "_lily_backup", "_lily_trim", "_validation"}


def mb(n: int) -> float:
    return round(n / (1024 * 1024), 2)


def skip(rel: str) -> bool:
    return any(p in rel.replace("\\", "/") for p in SKIP_PARTS)


def files_under(rel: str) -> list[Path]:
    p = ROOT / rel
    if not p.exists():
        return []
    if p.is_file():
        return [p]
    out = []
    for f in p.rglob("*"):
        if f.is_file() and not skip(str(f.relative_to(ROOT))):
            out.append(f)
    return out


def main() -> None:
    report: dict = {}

    # --- APK internals ---
    apk_info: dict = {"exists": APK.exists()}
    if APK.exists():
        apk_info["bytes"] = APK.stat().st_size
        apk_info["mb"] = mb(APK.stat().st_size)
        with zipfile.ZipFile(APK) as z:
            infos = z.infolist()
            top: dict[str, int] = defaultdict(int)
            ext: dict[str, int] = defaultdict(int)
            abi: dict[str, int] = defaultdict(int)
            flutter_ext: dict[str, int] = defaultdict(int)
            entries = []
            for i in infos:
                n = i.filename.replace("\\", "/")
                sz = i.file_size
                entries.append((sz, n))
                top[n.split("/")[0]] += sz
                suf = Path(n).suffix.lower() or "(none)"
                ext[suf] += sz
                if n.startswith("lib/"):
                    parts = n.split("/")
                    if len(parts) >= 2:
                        abi[parts[1]] += sz
                if "flutter_assets/" in n:
                    flutter_ext[suf] += sz
            entries.sort(reverse=True)
            apk_info["top20"] = [
                {"bytes": s, "mb": mb(s), "path": n} for s, n in entries[:20]
            ]
            apk_info["top_dirs"] = {k: {"bytes": v, "mb": mb(v)} for k, v in sorted(top.items(), key=lambda x: -x[1])}
            apk_info["by_ext"] = {k: {"bytes": v, "mb": mb(v)} for k, v in sorted(ext.items(), key=lambda x: -x[1])}
            apk_info["native_abi"] = {k: {"bytes": v, "mb": mb(v)} for k, v in sorted(abi.items(), key=lambda x: -x[1])}
            apk_info["flutter_assets_ext"] = {
                k: {"bytes": v, "mb": mb(v)} for k, v in sorted(flutter_ext.items(), key=lambda x: -x[1])
            }
            apk_info["native_files"] = [
                {"bytes": s, "mb": mb(s), "path": n}
                for s, n in entries
                if n.startswith("lib/") and n.endswith(".so")
            ]
    report["apk"] = apk_info

    # --- Packed disk assets ---
    by_ext: dict[str, int] = defaultdict(int)
    by_folder: dict[str, int] = defaultdict(int)
    disk_files: list[tuple[int, str]] = []
    hashes: dict[str, list[str]] = defaultdict(list)
    for rel in PACKED_ROOTS:
        for f in files_under(rel):
            r = str(f.relative_to(ROOT)).replace("\\", "/")
            sz = f.stat().st_size
            disk_files.append((sz, r))
            by_ext[f.suffix.lower() or "(none)"] += sz
            # folder 2 levels
            parts = r.split("/")
            folder = "/".join(parts[:3]) if len(parts) >= 3 else "/".join(parts[:2])
            by_folder[folder] += sz
            if sz >= 50_000:
                h = hashlib.md5(f.read_bytes()).hexdigest()
                hashes[h].append(r)

    disk_files.sort(reverse=True)
    report["packed_disk_top20"] = [{"bytes": s, "mb": mb(s), "path": n} for s, n in disk_files[:20]]
    report["packed_by_ext"] = {k: {"bytes": v, "mb": mb(v)} for k, v in sorted(by_ext.items(), key=lambda x: -x[1])}
    report["packed_by_folder"] = {
        k: {"bytes": v, "mb": mb(v)} for k, v in sorted(by_folder.items(), key=lambda x: -x[1])[:40]
    }
    report["packed_total"] = {"bytes": sum(s for s, _ in disk_files), "mb": mb(sum(s for s, _ in disk_files)), "count": len(disk_files)}
    dups = {h: paths for h, paths in hashes.items() if len(paths) > 1}
    report["duplicates"] = [
        {"md5": h, "count": len(p), "mb": mb(Path(ROOT / p[0]).stat().st_size), "paths": p}
        for h, p in sorted(dups.items(), key=lambda x: -Path(ROOT / x[1][0]).stat().st_size)[:30]
    ]

    media = {".mp4": 0, ".mov": 0, ".webm": 0, ".mp3": 0, ".wav": 0, ".m4a": 0, ".aac": 0, ".pdf": 0, ".ttf": 0, ".otf": 0, ".json": 0, ".riv": 0, ".lottie": 0}
    media_files: dict[str, list] = defaultdict(list)
    for s, n in disk_files:
        ext = Path(n).suffix.lower()
        if ext in media:
            media[ext] += s
            media_files[ext].append({"bytes": s, "mb": mb(s), "path": n})
    report["media_ext_totals"] = {k: {"bytes": v, "mb": mb(v)} for k, v in media.items() if v}
    report["media_files"] = {k: v[:20] for k, v in media_files.items()}

    large_png = [{"bytes": s, "mb": mb(s), "path": n} for s, n in disk_files if Path(n).suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"} and s >= 400_000][:40]
    report["images_over_400kb"] = large_png

    OUT.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print("APK", apk_info.get("mb"), "MB")
    print("packed", report["packed_total"])
    print("native_abi", apk_info.get("native_abi"))
    print("flutter_ext", apk_info.get("flutter_assets_ext"))
    print("TOP20 APK:")
    for row in apk_info.get("top20", []):
        print(f"  {row['mb']:8.2f}  {row['path']}")
    print("TOP20 DISK PACKED:")
    for row in report["packed_disk_top20"]:
        print(f"  {row['mb']:8.2f}  {row['path']}")
    print("dups", len(report["duplicates"]))
    print("wrote", OUT)


if __name__ == "__main__":
    main()
