from pathlib import Path

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
    # Rebuild hero without broken concat
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