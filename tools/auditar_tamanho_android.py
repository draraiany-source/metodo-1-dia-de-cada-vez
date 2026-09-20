# -*- coding: utf-8 -*-
"""Auditoria somente-leitura do tamanho AAB/APK e assets. Nao altera o app."""
from __future__ import annotations

import hashlib
import json
import zipfile
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "_audit_tamanho_android.json"
AAB = ROOT / "build" / "app" / "outputs" / "bundle" / "release" / "app-release.aab"
APK = ROOT / "build" / "app" / "outputs" / "flutter-apk" / "app-release.apk"

DECLARED = [
    "assets/images",
    "assets/images/icons_3d",
    "assets/images/icons_3d_pack2",
    "assets/images/mascote",
    "assets/images/home",
    "assets/images/treinos",
    "assets/images/corrida",
    "assets/images/hidratacao",
    "assets/images/receitas",
    "assets/images/recipes",
    "assets/images/recipes/neon",
    "assets/images/alimentacao",
    "assets/images/progresso",
    "assets/images/rotina",
    "assets/images/bem_estar",
    "assets/images/lily_fit",
    "assets/images/referencias",
    "assets/mascot/png",
    "assets/mascot/extras",
    "assets/icons",
    "assets/icons/personal-ai",
    "assets/icons/app",
    "assets/icons/app/extras_hidratacao",
    "assets/icons/navigation",
    "assets/icons/health",
    "assets/icons/hydration",
    "assets/icons/actions",
    "assets/icons/mood",
    "assets/icons/achievements",
    "assets/icons/premium",
    "assets/icons/neon",
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
    "assets/audio_programs",
    "assets/lily",
    "assets/lily_treinos",
    "assets/lily_exercicios",
    "assets/amanda",
    "assets/amanda/promo",
    "assets/amanda/optimized",
    "assets/amanda/thumbs",
    "assets/app_icon",
]

SKIP_DIR_NAMES = {
    ".git",
    "build",
    ".dart_tool",
    "node_modules",
    ".gradle",
    "RECUPERACAO_PROJETO_COMPLETO",
    "homologacao_visual_android",
    "homologacao_web_screenshots",
}


def mb(n: int) -> float:
    return round(n / (1024 * 1024), 2)


def dir_bytes(path: Path) -> tuple[int, int]:
    total = 0
    count = 0
    if not path.exists():
        return 0, 0
    if path.is_file():
        return path.stat().st_size, 1
    for f in path.rglob("*"):
        if f.is_file():
            total += f.stat().st_size
            count += 1
    return total, count


def ext_of(name: str) -> str:
    p = name.lower()
    if "." not in Path(p).name:
        return "(sem extensao)"
    return Path(p).suffix or "(sem extensao)"


def analyze_zip(path: Path) -> dict:
    if not path.exists():
        return {"exists": False, "path": str(path)}
    top: dict[str, int] = defaultdict(int)
    ext: dict[str, int] = defaultdict(int)
    flutter: dict[str, int] = defaultdict(int)
    natives: dict[str, int] = defaultdict(int)
    largest: list[tuple[int, str]] = []
    total = path.stat().st_size
    with zipfile.ZipFile(path) as z:
        for info in z.infolist():
            n = info.filename.replace("\\", "/")
            c = info.file_size
            top[n.split("/", 1)[0] if "/" in n else n] += c
            ext[ext_of(n)] += c
            if "flutter_assets" in n:
                rest = n.split("flutter_assets/", 1)[-1]
                first = rest.split("/", 1)[0] if rest else "(root)"
                flutter[first] += c
            if n.startswith("lib/") or "/lib/" in n and n.endswith(".so"):
                parts = n.split("/")
                abi = "lib"
                for i, p in enumerate(parts):
                    if p == "lib" and i + 1 < len(parts):
                        abi = parts[i + 1]
                        break
                natives[abi] += c
            largest.append((c, n))
    largest.sort(reverse=True)
    return {
        "exists": True,
        "path": str(path),
        "archive_bytes": total,
        "archive_mb": mb(total),
        "uncompressed_top": {k: {"bytes": v, "mb": mb(v)} for k, v in sorted(top.items(), key=lambda x: -x[1])},
        "by_ext": {k: {"bytes": v, "mb": mb(v)} for k, v in sorted(ext.items(), key=lambda x: -x[1])[:25]},
        "flutter_assets_top": {k: {"bytes": v, "mb": mb(v)} for k, v in sorted(flutter.items(), key=lambda x: -x[1])[:40]},
        "native_abi": {k: {"bytes": v, "mb": mb(v)} for k, v in sorted(natives.items(), key=lambda x: -x[1])},
        "largest_20": [{"path": p, "bytes": b, "mb": mb(b)} for b, p in largest[:20]],
    }


def disk_declared() -> list[dict]:
    rows = []
    seen: set[Path] = set()
    for rel in DECLARED:
        p = ROOT / rel
        # skip nested if parent already counted? we want both parent and children
        # for ranking; later we also do top-level assets children
        b, c = dir_bytes(p)
        rows.append({"path": rel, "bytes": b, "mb": mb(b), "files": c, "exists": p.exists()})
        seen.add(p.resolve() if p.exists() else p)
    rows.sort(key=lambda r: -r["bytes"])
    return rows


def assets_children() -> list[dict]:
    base = ROOT / "assets"
    rows = []
    if not base.exists():
        return rows
    for child in sorted(base.iterdir(), key=lambda p: p.name.lower()):
        b, c = dir_bytes(child)
        packed = any(
            str(child.relative_to(ROOT)).replace("\\", "/").startswith(d.rstrip("/"))
            or d.rstrip("/") == str(child.relative_to(ROOT)).replace("\\", "/")
            for d in DECLARED
        )
        # backup / incoming never in pubspec
        name = child.name
        in_pubspec = packed and not name.startswith("_")
        rows.append(
            {
                "path": str(child.relative_to(ROOT)).replace("\\", "/"),
                "bytes": b,
                "mb": mb(b),
                "files": c,
                "in_pubspec": in_pubspec,
            }
        )
    rows.sort(key=lambda r: -r["bytes"])
    return rows


def type_breakdown(folder: Path) -> dict[str, dict]:
    buckets: dict[str, int] = defaultdict(int)
    counts: dict[str, int] = defaultdict(int)
    if not folder.exists():
        return {}
    for f in folder.rglob("*"):
        if not f.is_file():
            continue
        e = ext_of(f.name)
        buckets[e] += f.stat().st_size
        counts[e] += 1
    return {
        k: {"bytes": buckets[k], "mb": mb(buckets[k]), "files": counts[k]}
        for k in sorted(buckets, key=lambda x: -buckets[x])
    }


def largest_on_disk(folder: Path, n: int = 40) -> list[dict]:
    files: list[tuple[int, str]] = []
    if not folder.exists():
        return []
    for f in folder.rglob("*"):
        if f.is_file():
            files.append((f.stat().st_size, str(f.relative_to(ROOT)).replace("\\", "/")))
    files.sort(reverse=True)
    return [{"path": p, "bytes": b, "mb": mb(b)} for b, p in files[:n]]


def duplicates(folder: Path, min_bytes: int = 20_000) -> list[dict]:
    """Hash files >= min_bytes. Report groups that share content."""
    by_hash: dict[str, list[tuple[int, str]]] = defaultdict(list)
    if not folder.exists():
        return []
    for f in folder.rglob("*"):
        if not f.is_file():
            continue
        size = f.stat().st_size
        if size < min_bytes:
            continue
        h = hashlib.md5()
        with f.open("rb") as fh:
            for chunk in iter(lambda: fh.read(1024 * 1024), b""):
                h.update(chunk)
        rel = str(f.relative_to(ROOT)).replace("\\", "/")
        by_hash[h.hexdigest()].append((size, rel))
    groups = []
    for digest, items in by_hash.items():
        if len(items) < 2:
            continue
        size = items[0][0]
        paths = [p for _, p in items]
        waste = size * (len(items) - 1)
        groups.append({"md5": digest, "bytes_each": size, "mb_each": mb(size), "copies": len(items), "waste_bytes": waste, "waste_mb": mb(waste), "paths": paths})
    groups.sort(key=lambda g: -g["waste_bytes"])
    return groups[:40]


def main() -> None:
    print("Analisando APK/AAB (zip listing)...")
    data = {
        "aab": analyze_zip(AAB),
        "apk": analyze_zip(APK),
        "declared_dirs": disk_declared(),
        "assets_top_level": assets_children(),
        "assets_by_ext": type_breakdown(ROOT / "assets"),
        "largest_assets": largest_on_disk(ROOT / "assets", 50),
        "duplicates_assets": duplicates(ROOT / "assets", 30_000),
    }
    # lily / amanda / audio / backups extras
    extra_dirs = [
        "assets/lily",
        "assets/lily_treinos",
        "assets/lily_exercicios",
        "assets/images/lily_fit",
        "assets/audio_programs",
        "assets/amanda",
        "assets/amanda/promo",
        "assets/amanda/optimized",
        "assets/amanda/thumbs",
        "assets/_lily_backup_before_frame_fix",
        "assets/_lily_backup_before_pack_20260911_002213",
        "assets/_lily_trim_preview",
        "assets/lily/treinos lily fit",
        "tools/audio_seed/assets_audio",
    ]
    extras = []
    for rel in extra_dirs:
        p = ROOT / rel
        b, c = dir_bytes(p)
        extras.append({"path": rel, "bytes": b, "mb": mb(b), "files": c, "exists": p.exists()})
    extras.sort(key=lambda r: -r["bytes"])
    data["focus_dirs"] = extras
    data["notes"] = {
        "no_local_media_glob": "glob nao achou mp3/mp4/pdf em assets/",
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {OUT}")
    print("AAB", data["aab"].get("archive_mb"), "APK", data["apk"].get("archive_mb"))
    print("Top assets folders:")
    for row in data["assets_top_level"][:15]:
        print(f"  {row['mb']:>8} MB  pubspec={row['in_pubspec']}  {row['path']}  ({row['files']} files)")


if __name__ == "__main__":
    main()
