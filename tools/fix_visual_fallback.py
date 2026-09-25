# -*- coding: utf-8 -*-
from pathlib import Path

p = Path(r"C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\lib\features\workouts\presentation\treino_catalog_visual.dart")
t = p.read_text(encoding="utf-8")

old = """return LilyTreinoAssets.resolve(
    '  ',
    genericSeed: treino.nome.hashCode,
  );"""

new = (
    "return LilyTreinoAssets.resolve(\n"
    "    '${treino.nome} ${treino.grupoMuscular ?? ''} ${treino.categoria ?? ''}',\n"
    "    genericSeed: treino.nome.hashCode,\n"
    "  );"
)

if old not in t:
    # try CRLF
    old2 = old.replace("\n", "\r\n")
    new2 = new.replace("\n", "\r\n")
    if old2 in t:
        t = t.replace(old2, new2, 1)
        p.write_text(t, encoding="utf-8")
        print("fixed CRLF")
    else:
        # show nearby
        idx = t.find("lilyTreinoAssetFor")
        print("NOT FOUND")
        print(repr(t[idx:idx+400]))
        raise SystemExit(1)
else:
    t = t.replace(old, new, 1)
    p.write_text(t, encoding="utf-8")
    print("fixed LF")

# verify
t2 = p.read_text(encoding="utf-8")
assert "${treino.nome}" in t2
print("ok contains dart interpolation")
# print function
i = t2.find("String lilyTreinoAssetFor")
print(t2[i:i+280])
