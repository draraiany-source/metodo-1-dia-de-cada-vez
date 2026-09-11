
from pathlib import Path

# --- detail screen ---
p = Path(r"lib/features/workouts/presentation/treino_catalog_detail_screen.dart")
t = p.read_text(encoding="utf-8")
if "LilyTreinoImage" in t:
    print("detail already wired")
else:
    t = t.replace(
        "import 'treino_catalog_visual.dart';",
        "import '../../../core/lily/lily_treino_assets.dart';\n"
        "import '../../../core/lily/lily_treino_image.dart';\n"
        "import 'treino_catalog_visual.dart';",
    )
    hero = (
        "            Center(\n"
        "              child: LilyTreinoImage(\n"
        "                asset: LilyTreinoAssets.resolve(\n"
        "                  '${treino.nome} ${treino.grupoMuscular ?? ''}"
        " ${treino.categoria ?? ''}',\n"
        "                  genericSeed: treino.nome.hashCode,\n"
        "                ),\n"
        "                maxHeight: 280,\n"
        "                maxWidth: 420,\n"
        "                semanticLabel: treino.nome,\n"
        "              ),\n"
        "            ),\n"
        "            const SizedBox(height: 16),\n"
    )
    # Fix hero: previous had accidental string concat mid-line. Build with chr dollar.
    d = chr(36)
    hero = (
        "            Center(\n"
        "              child: LilyTreinoImage(\n"
        "                asset: LilyTreinoAssets.resolve(\n"
        f"                  '{d}{{treino.nome}} {d}{{treino.grupoMuscular ?? ''}} {d}{{treino.categoria ?? ''}}',\n"
        "                  genericSeed: treino.nome.hashCode,\n"
        "                ),\n"
        "                maxHeight: 280,\n"
        "                maxWidth: 420,\n"
        "                semanticLabel: treino.nome,\n"
        "              ),\n"
        "            ),\n"
        "            const SizedBox(height: 16),\n"
    )
    start = t.find("TreinoSectionIcon")
    end_pat = "              ],\n            ),\n"
    end = t.find(end_pat, start)
    if end < 0:
        end_pat = "              ],\r\n            ),\r\n"
        end = t.find(end_pat, start)
    if end < 0:
        print("FAILED find row end")
        print(repr(t[start:start+500]))
    else:
        at = end + len(end_pat)
        t = t[:at] + hero + t[at:]
        p.write_text(t, encoding="utf-8")
        print("detail wired ok")

# --- visual helper ---
vis = Path(r"lib/features/workouts/presentation/treino_catalog_visual.dart")
vt = vis.read_text(encoding="utf-8")
if "lilyTreinoAssetFor" not in vt:
    if "lily_treino_assets.dart" not in vt:
        vt = vt.replace(
            "import '../domain/treino_catalog_models.dart';",
            "import '../../../core/lily/lily_treino_assets.dart';\n"
            "import '../domain/treino_catalog_models.dart';",
        )
    d = chr(36)
    vt += (
        "\n\n/// Asset Lily Fit (treino) para o exercício/treino do catálogo.\n"
        "String lilyTreinoAssetFor(TreinoCatalogEntry treino) {\n"
        "  return LilyTreinoAssets.resolve(\n"
        f"    '{d}{{treino.nome}} {d}{{treino.grupoMuscular ?? ''}} {d}{{treino.categoria ?? ''}}',\n"
        "    genericSeed: treino.nome.hashCode,\n"
        "  );\n"
        "}\n"
    )
    vis.write_text(vt, encoding="utf-8")
    print("visual helper added")
else:
    print("visual helper exists")

# --- workout detail: add Lily near current exercise if LiliAnimated or similar ---
wd = Path(r"lib/features/workouts/presentation/workout_detail_screen.dart")
w = wd.read_text(encoding="utf-8")
if "LilyTreinoImage" not in w:
    if "lily_treino_image.dart" not in w:
        w = w.replace(
            "import 'workout_category_visual.dart';",
            "import '../../../core/lily/lily_treino_assets.dart';\n"
            "import '../../../core/lily/lily_treino_image.dart';\n"
            "import 'workout_category_visual.dart';",
        )
    # Insert a helper method usage is harder; add comment marker widget factory at end of file before last
    # Patch exercise list tile if AppIconImage used with exercise name
    # Search for patterns
    print("workout_detail imports updated; scanning for insert points...")
    # Look for LiliAnimated or similar hero
    for needle in ["LiliAnimated", "LiliWidget", "AppIconImage(", "WorkoutCategory"]:
        print(needle, w.find(needle))
    wd.write_text(w, encoding="utf-8")
else:
    print("workout detail already has Lily")
