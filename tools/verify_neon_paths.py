from pathlib import Path
import re
import json

ROOT = Path(__file__).resolve().parents[1]
text = (ROOT / "lib/core/assets/app_icons.dart").read_text(encoding="utf-8")
bases = dict(
    re.findall(
        r"static const String _(nav|saude|nutri|corrida|treino|conquista|perfil) = '([^']+)';",
        text,
    )
)
refs = re.findall(r"\$\{_(\w+)\}([A-Za-z0-9_\.]+\.png)", text)
paths = sorted({bases[k] + f for k, f in refs if k in bases})
missing = [p for p in paths if not (ROOT / p).exists()]
print("RESOLVED", len(paths))
print("MISSING", len(missing))
for m in missing:
    print("MISS", m)

neon = list((ROOT / "assets/icons/neon").rglob("*.png"))
print("NEON_FILES", len(neon))
for d in sorted((ROOT / "assets/icons/neon").iterdir()):
    if d.is_dir():
        print(f"DIR {d.name}: {len(list(d.glob('*.png')))}")

catalog = ROOT / "assets/content/treinos_catalogo_oficial.json"
if catalog.exists():
    data = json.loads(catalog.read_text(encoding="utf-8"))
    items = data if isinstance(data, list) else data.get("treinos") or data.get("items") or []
    print("CATALOG_ENTRIES", len(items))
