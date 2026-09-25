# -*- coding: utf-8 -*-
from pathlib import Path

p = Path(r"C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\lib\features\workouts\presentation\treino_catalog_detail_screen.dart")
t = p.read_text(encoding="utf-8")

old = """              child: LilyTreinoImage(
                asset: LilyTreinoAssets.resolve(
                  '${treino.nome} ${treino.grupoMuscular ?? ''} ${treino.categoria ?? ''}',
                  genericSeed: treino.nome.hashCode,
                ),
                maxHeight: 280,
                maxWidth: 420,
                semanticLabel: treino.nome,
              ),"""

new = """              child: LilyTreinoImage(
                asset: lilyTreinoAssetFor(treino),
                maxHeight: 280,
                maxWidth: 420,
                semanticLabel: treino.nome,
              ),"""

if old not in t:
    old = old.replace("\n", "\r\n")
    new = new.replace("\n", "\r\n")
if old not in t:
    raise SystemExit("block not found")

t = t.replace(old, new, 1)

# Remove unused lily_treino_assets import if LilyTreinoAssets no longer referenced
if "LilyTreinoAssets" not in t.split("import")[0] and t.count("LilyTreinoAssets") == 0:
    pass
# After replace, check remaining LilyTreinoAssets refs
if "LilyTreinoAssets" not in t:
    t = t.replace("import '../../../core/lily/lily_treino_assets.dart';\n", "")
    t = t.replace("import '../../../core/lily/lily_treino_assets.dart';\r\n", "")

p.write_text(t, encoding="utf-8")
print("detail patched")
print("still has LilyTreinoAssets:", "LilyTreinoAssets" in t)
print("has lilyTreinoAssetFor:", "lilyTreinoAssetFor(treino)" in t)
