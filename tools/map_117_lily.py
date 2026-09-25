# -*- coding: utf-8 -*-
import csv, re, unicodedata
from pathlib import Path

root = Path(r"C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2")
pack = root / "assets" / "lily" / "treinos lily fit"
audit = root / "tools" / "_audit_117_exercicios.csv"
out_map = root / "tools" / "_map_117_lily_fit.csv"
out_miss = root / "tools" / "_map_117_lily_fit_missing.txt"
out_unused = root / "tools" / "_map_117_lily_fit_unused.txt"

def norm(s):
    s = (s or "").lower().replace("–", "-").replace("—", "-")
    s = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r"[^a-z0-9]+", "_", s)
    return re.sub(r"_+", "_", s).strip("_")

imgs = sorted([p for p in pack.iterdir() if p.suffix.lower() in {".jpg", ".jpeg", ".png", ".webp"}])
img_norms = [(p, norm(p.stem)) for p in imgs]

ALIASES = {
    "bike_horizontal": ["bike_horizontal", "bicicleta_reclinada", "reclinada"],
    "bike": ["bike", "bicicleta", "cicl", "spinning"],
    "eliptico": ["eliptico", "elipt"],
    "escada": ["escada", "simulador"],
    "caminhada": ["caminhada"],
    "esteira": ["esteira", "corrida"],
    "corda": ["corda", "pulando_corda", "saltando"],
    "prancha": ["prancha"],
    "afundo": ["afundo", "lunge"],
    "bulgaro": ["bulgaro"],
    "agachamento": ["agachamento"],
    "sumo": ["sumo"],
    "hack": ["hack"],
    "smith": ["smith"],
    "pendular": ["pendular"],
    "leg_press": ["leg_press"],
    "extensora": ["extensora"],
    "flexora": ["flexora", "leg_curl"],
    "adutor": ["adutor"],
    "abduc": ["abduc"],
    "panturrilha": ["calf", "panturrilha"],
    "hip_thrust": ["hip_thrust", "ponte", "elevacao_pelvica", "glute"],
    "stiff": ["levantamento_terra", "stiff", "terra"],
    "remada": ["remada"],
    "puxada": ["puxada", "graviton"],
    "supino": ["supino", "pressao_de_peito", "prensa_de_peito"],
    "crucifixo": ["peck_deck", "crucifixo"],
    "desenvolvimento": ["desenvolvimento", "press_de_ombros", "pressao_de_ombros"],
    "elevacao_frontal": ["elevacao_frontal", "frontal"],
    "rosca": ["rosca", "biceps"],
    "triceps": ["triceps"],
    "abdominal": ["abdominal", "crunch", "abdomen", "abdumen", "core", "remador"],
    "mountain": ["mountain_climber"],
    "face_pull": ["face_pull"],
    "trx": ["trx", "suspens"],
    "kickback": ["kickback", "chute"],
    "alongamento": ["alongamento"],
    "peck": ["peck_deck"],
    "romana": ["cadeira_romana", "romana"],
    "graviton": ["graviton"],
}

NOISE = {
    "treino", "fitness", "neon", "roxo", "roxa", "luz", "luzes", "brilho", "halo",
    "estilo", "academia", "estudio", "ginasio", "mulher", "atleta", "instrutora",
    "lily", "fit", "com", "sob", "em", "na", "no", "de", "da", "do", "e", "a",
    "high", "quality", "studio", "promotional", "portrait", "clean", "scene",
    "stylized", "gym", "single", "imagegen", "visual", "extra", "pose", "queima",
    "gordura", "intenso", "poderoso", "energetico", "dinamico", "purpura", "violeta",
    "lilas", "gloss",
}

rows = list(csv.DictReader(audit.open(encoding="utf-8")))

def score(ex_norm, ex_name_norm, img_norm):
    sc = 0
    et = set(ex_norm.split("_")) | set(ex_name_norm.split("_"))
    it = set(img_norm.split("_"))
    et -= NOISE
    it -= NOISE
    sc += 10 * len(et & it)
    for key, vals in ALIASES.items():
        if key in ex_norm or key in ex_name_norm:
            if any(v in img_norm for v in vals):
                sc += 25
    if ex_norm and (ex_norm in img_norm or img_norm in ex_norm):
        sc += 40
    if "bike_horizontal" in ex_norm and any(x in img_norm for x in ("reclinada", "horizontal")):
        sc += 50
    if "bike" in ex_norm and "horizontal" not in ex_norm:
        if "bike" in img_norm or "bicicleta" in img_norm or "spinning" in img_norm or "cicl" in img_norm:
            if "reclinada" not in img_norm:
                sc += 20
    return sc

used = set()
mapped = []
missing = []

for r in rows:
    eid = r["id"]
    nome = r["nome"]
    slug = r.get("slug") or ""
    en = norm(nome)
    es = norm(slug)
    best = None
    best_sc = -1
    for p, inn in img_norms:
        if p.name in used:
            continue
        s = score(es, en, inn)
        if s > best_sc:
            best_sc = s
            best = (p, inn, s)
    if best and best_sc >= 20:
        used.add(best[0].name)
        mapped.append({
            "id": eid, "nome": nome, "slug": slug,
            "imagem": best[0].name, "score": best_sc, "status": "mapped",
        })
    else:
        missing.append(r)
        mapped.append({
            "id": eid, "nome": nome, "slug": slug,
            "imagem": best[0].name if best else "",
            "score": best_sc if best else 0,
            "status": "missing_or_weak",
        })

with out_map.open("w", encoding="utf-8", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["id", "nome", "slug", "imagem", "score", "status"])
    w.writeheader()
    w.writerows(mapped)

out_miss.write_text(
    "\n".join("%s|%s|%s" % (m["id"], m["nome"], m.get("slug", "")) for m in missing),
    encoding="utf-8",
)
unused = [p.name for p, _ in img_norms if p.name not in used]
out_unused.write_text("\n".join(unused), encoding="utf-8")

n_ok = sum(1 for m in mapped if m["status"] == "mapped")
n_weak = sum(1 for m in mapped if m["status"] != "mapped")
print("Total catalog:", len(rows))
print("Mapped strong:", n_ok)
print("Missing/weak:", n_weak)
print("Images used:", len(used), "/", len(imgs))
print("Unused images:", len(unused))
print("--- weak ---")
for m in mapped:
    if m["status"] != "mapped":
        print("%s | %s | best=%s score=%s" % (m["id"], m["nome"], m["imagem"], m["score"]))
print("--- first 20 mapped ---")
for m in mapped[:20]:
    print("%s -> %s (%s) [%s]" % (m["id"], m["imagem"], m["score"], m["status"]))
