# -*- coding: utf-8 -*-
import csv
from pathlib import Path

root = Path(r"C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2")
pack = root / "assets" / "lily" / "treinos lily fit"
map_csv = root / "tools" / "_map_117_lily_fit.csv"
out_csv = root / "tools" / "_map_117_lily_fit.csv"
out_report = root / "tools" / "_map_117_lily_fit_report.txt"

# Preferred image filename substrings / exact names for weak IDs (order = preference)
OVERRIDES = {
    "treino_015": ["pressao_de_ombros", "press_de_ombros", "desenvolvimento", "ombros"],
    "treino_023": ["estrela_fitness", "salto_fitness", "polichinelo", "treino_dinamico"],
    "treino_024": ["treino_dinamico", "salto_fitness", "treino_energetico", "treino_intenso_sob"],
    "treino_025": ["mountain_climber"],
    "treino_046": ["abduc", "abdut"],
    "treino_048": ["chute_de_gluteo", "kickback", "gluteos_em_destaque", "treino_de_gluteos"],
    "treino_049": ["kickback", "chute_de_gluteo", "treino_de_gluteos", "gluteos"],
    "treino_051": ["chute_de_gluteo", "kickback", "coice"],
    "treino_055": ["kickback", "chute_de_gluteo", "gluteos"],
    "treino_056": ["treino_de_gluteos", "gluteos_em_destaque", "kickback"],
    "treino_060": ["bulgaro", "afundo", "agachamento_bulgaro", "lunge"],
    "treino_061": ["hip_thrust", "ponte_de_gluteos", "ponte_glutea", "elevacao_pelvica"],
    "treino_062": ["hip_thrust", "ponte_de_gluteos", "ponte_glutea"],
    "treino_065": ["levantamento_terra", "stiff", "terra"],
    "treino_067": ["escada", "salto", "treino_neon_com_salto", "afundo"],
    "treino_075": ["supino_inclinado", "peito", "supino"],
    "treino_079": ["puxada", "graviton", "costas", "pulldown"],
    "treino_080": ["puxada", "costas", "barra"],
    "treino_082": ["puxada", "graviton", "costas"],
    "treino_088": ["biceps", "rosca", "unilateral"],
    "treino_089": ["rosca", "biceps"],
    "treino_090": ["rosca", "biceps"],
    "treino_092": ["rosca", "biceps", "unilateral"],
    "treino_097": ["desenvolvimento", "press_de_ombros", "pressao_de_ombros", "ombros"],
    "treino_098": ["press_de_ombros", "pressao_de_ombros", "desenvolvimento", "ombros"],
    "treino_101": ["elevacao", "desenvolvimento", "ombros"],
    "treino_103": ["elevacao", "frontal", "ombros"],
    "treino_104": ["elevacao", "frontal"],
    "treino_105": ["elevacao_frontal", "frontal"],
    "treino_106": ["elevacao", "halteres"],
    "treino_110": ["triceps", "corda"],
    "treino_111": ["triceps"],
    "treino_112": ["triceps", "corda"],
    "treino_116": ["bulgaro", "afundo", "lunge", "agachamento_bulgaro"],
    "treino_117": ["remada_articulada", "remada"],
}

def fold(s):
    import unicodedata, re
    s = unicodedata.normalize("NFKD", s.lower())
    s = "".join(c for c in s if not unicodedata.combining(c))
    return re.sub(r"[^a-z0-9]+", "_", s)

imgs = {p.name: p for p in pack.iterdir() if p.suffix.lower() in {".jpg", ".jpeg", ".png"}}
img_folds = {name: fold(name) for name in imgs}

rows = list(csv.DictReader(map_csv.open(encoding="utf-8")))
used = {r["imagem"] for r in rows if r["status"] == "mapped" and r["imagem"]}

def pick(prefs):
    # exact/substring against unused first
    for pref in prefs:
        pf = fold(pref)
        for name, nf in img_folds.items():
            if name in used:
                continue
            if pf in nf:
                return name, "override_unused"
    # then allow already-used as shared (approximate reuse)
    for pref in prefs:
        pf = fold(pref)
        for name, nf in img_folds.items():
            if pf in nf:
                return name, "override_shared"
    return "", "still_missing"

changed = 0
for r in rows:
    if r["status"] == "mapped":
        continue
    prefs = OVERRIDES.get(r["id"], [])
    name, how = pick(prefs)
    if name:
        r["imagem"] = name
        r["status"] = how
        r["score"] = 30 if how == "override_unused" else 15
        if how == "override_unused":
            used.add(name)
        changed += 1

with out_csv.open("w", encoding="utf-8", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["id", "nome", "slug", "imagem", "score", "status"])
    w.writeheader()
    w.writerows(rows)

n_mapped = sum(1 for r in rows if r["status"] == "mapped")
n_over_u = sum(1 for r in rows if r["status"] == "override_unused")
n_over_s = sum(1 for r in rows if r["status"] == "override_shared")
n_miss = sum(1 for r in rows if r["status"] in ("missing_or_weak", "still_missing") or not r["imagem"])
unique_imgs = len({r["imagem"] for r in rows if r["imagem"]})

lines = []
lines.append("MAP 117 x Lily Fit")
lines.append("Pasta: assets/lily/treinos lily fit (%d imagens)" % len(imgs))
lines.append("Mapeados auto (forte): %d" % n_mapped)
lines.append("Override imagem exclusiva: %d" % n_over_u)
lines.append("Override imagem compartilhada: %d" % n_over_s)
lines.append("Ainda sem imagem: %d" % n_miss)
lines.append("Imagens unicas usadas: %d" % unique_imgs)
lines.append("")
lines.append("--- por status ---")
for r in rows:
    lines.append("%s | %s | %s | %s" % (r["id"], r["status"], r["nome"], r["imagem"]))

out_report.write_text("\n".join(lines), encoding="utf-8")
print("changed:", changed)
print("mapped:", n_mapped, "override_unused:", n_over_u, "override_shared:", n_over_s, "miss:", n_miss)
print("unique images:", unique_imgs)
print("--- remaining miss ---")
for r in rows:
    if not r["imagem"] or r["status"] in ("missing_or_weak", "still_missing"):
        print(r["id"], r["nome"], r["status"], r["imagem"])
