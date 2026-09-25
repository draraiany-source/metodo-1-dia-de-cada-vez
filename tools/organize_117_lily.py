# -*- coding: utf-8 -*-
"""Copy mapped Lily JPGs to assets/lily_exercicios/ as treino_XXX.jpg and emit Dart map."""
import csv
import shutil
from pathlib import Path

root = Path(r"C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2")
src_dir = root / "assets" / "lily" / "treinos lily fit"
dst_dir = root / "assets" / "lily_exercicios"
map_csv = root / "tools" / "_map_117_lily_fit.csv"
dart_out = root / "lib" / "core" / "lily" / "lily_exercicio_assets.dart"

dst_dir.mkdir(parents=True, exist_ok=True)

rows = list(csv.DictReader(map_csv.open(encoding="utf-8")))
assert len(rows) == 117, len(rows)

copied = 0
shared = 0
missing = []
lines = []
lines.append("// GENERATED — do not edit by hand.")
lines.append("// Fonte: tools/_map_117_lily_fit.csv + assets/lily/treinos lily fit/")
lines.append("// Thumbnails por id do catálogo oficial (treino_001..treino_117).")
lines.append("")
lines.append("/// Assets Lily Fit por exercício do catálogo (117).")
lines.append("class LilyExercicioAssets {")
lines.append("  LilyExercicioAssets._();")
lines.append("")
lines.append("  static const String base = 'assets/lily_exercicios/';")
lines.append("")
lines.append("  /// Path do asset JPG para o [id] do catálogo, ou null se ausente.")
lines.append("  static String? pathForId(String? id) {")
lines.append("    if (id == null || id.isEmpty) return null;")
lines.append("    return byId[id];")
lines.append("  }")
lines.append("")
lines.append("  /// Mapa id → asset. Sempre JPG em lily_exercicios/.")
lines.append("  static const Map<String, String> byId = {")

for r in rows:
    eid = r["id"].strip()
    src_name = (r.get("imagem") or "").strip()
    if not src_name:
        missing.append(eid)
        continue
    src = src_dir / src_name
    if not src.exists():
        missing.append("%s missing source %s" % (eid, src_name))
        continue
    dst_name = "%s.jpg" % eid
    dst = dst_dir / dst_name
    # Always copy (overwrite) so shared sources become distinct files
    shutil.copy2(src, dst)
    copied += 1
    if r.get("status") == "override_shared":
        shared += 1
    asset_path = "assets/lily_exercicios/%s" % dst_name
    lines.append("    '%s': '%s'," % (eid, asset_path))

lines.append("  };")
lines.append("}")
lines.append("")

dart_out.write_text("\n".join(lines), encoding="utf-8")

# Count final jpgs
n = len(list(dst_dir.glob("treino_*.jpg")))
print("copied:", copied)
print("shared_status_rows:", shared)
print("missing:", len(missing))
for m in missing[:20]:
    print("  ", m)
print("treino_*.jpg in lily_exercicios:", n)
print("dart:", dart_out)
print("dart lines:", len(lines))
