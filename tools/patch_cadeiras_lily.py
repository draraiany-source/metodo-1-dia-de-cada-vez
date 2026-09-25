# -*- coding: utf-8 -*-
from pathlib import Path
import shutil

root = Path(r"C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2")
assets = root / "assets" / "lily_exercicios"
dart = root / "lib" / "core" / "lily" / "lily_exercicio_assets.dart"

abdutora = assets / "lily_fit_cadeira_abdutora.jpeg"
extensora = assets / "lily_fit_cadeira_extensora.jpeg"
assert abdutora.exists() and abdutora.stat().st_size > 10000, abdutora
assert extensora.exists() and extensora.stat().st_size > 10000, extensora

# Backup old id-based files once
bak = assets / "_backup_before_cadeiras_20260922"
bak.mkdir(exist_ok=True)
for name in ("treino_034.jpg", "treino_046.jpg", "treino_063.jpg"):
    src = assets / name
    if src.exists():
        shutil.copy2(src, bak / name)

# Also keep id-based filenames in sync (byId fallback + any hard refs)
shutil.copy2(extensora, assets / "treino_034.jpg")
shutil.copy2(abdutora, assets / "treino_046.jpg")

text = dart.read_text(encoding="utf-8")

old_046 = "    // 046 (cadeira abdutora): a máquina abdutora estava no arquivo 013.\n    'treino_046': 'assets/lily_exercicios/treino_013.jpg',"
# tolerate encoding variants of "maquina"
import re
pat_046 = re.compile(
    r"    // 046 \(cadeira abdutora\):[^\n]*\n    'treino_046': 'assets/lily_exercicios/[^']+',",
    re.M,
)
new_046 = (
    "    // 046 (cadeira abdutora): arte Lily Fit biomecanicamente correta "
    "(2026-09-22).\n"
    "    'treino_046': 'assets/lily_exercicios/lily_fit_cadeira_abdutora.jpeg',"
)
if not pat_046.search(text):
    raise SystemExit("treino_046 reatribuicao not found")
text = pat_046.sub(new_046, text, count=1)

# Insert treino_034 override near abdutora if missing
if "lily_fit_cadeira_extensora.jpeg" not in text:
    insert = (
        "    // 034 (cadeira extensora): arte Lily Fit com rolo anterior "
        "(2026-09-22). NÃO usar em flexora.\n"
        "    'treino_034': 'assets/lily_exercicios/lily_fit_cadeira_extensora.jpeg',\n"
    )
    # place before the 046 block we just wrote
    marker = "    'treino_046': 'assets/lily_exercicios/lily_fit_cadeira_abdutora.jpeg',"
    if marker not in text:
        raise SystemExit("marker after 046 patch missing")
    # insert before the // 046 comment that precedes marker
    idx = text.find("    // 046 (cadeira abdutora): arte Lily Fit")
    if idx < 0:
        raise SystemExit("046 comment not found for insert")
    text = text[:idx] + insert + text[idx:]

# Update byId entries too (generated map) so both layers agree
text = text.replace(
    "'treino_034': 'assets/lily_exercicios/treino_034.jpg'",
    "'treino_034': 'assets/lily_exercicios/lily_fit_cadeira_extensora.jpeg'",
)
text = text.replace(
    "'treino_046': 'assets/lily_exercicios/treino_046.jpg'",
    "'treino_046': 'assets/lily_exercicios/lily_fit_cadeira_abdutora.jpeg'",
)

dart.write_text(text, encoding="utf-8")

# Verify flexora untouched
flex_hash_path = bak / "treino_063.jpg"
import hashlib
def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()
cur = sha(assets / "treino_063.jpg")
old = sha(flex_hash_path)
print("abdutora bytes", abdutora.stat().st_size)
print("extensora bytes", extensora.stat().st_size)
print("treino_034 overwritten", (assets / "treino_034.jpg").stat().st_size)
print("treino_046 overwritten", (assets / "treino_046.jpg").stat().st_size)
print("flexora unchanged", cur == old, cur)
print("dart has abdutora jpeg", "lily_fit_cadeira_abdutora.jpeg" in text)
print("dart has extensora jpeg", "lily_fit_cadeira_extensora.jpeg" in text)
print("dart flexora still 063.jpg", "'treino_063': 'assets/lily_exercicios/treino_063.jpg'" in text)
# ensure no flexora points to extensora
if "treino_063" in text and "lily_fit_cadeira_extensora" in text:
    # check specifically flexora line
    for line in text.splitlines():
        if "treino_063" in line and "extensora" in line:
            raise SystemExit("Flexora wrongly points to extensora: " + line)
print("OK")
