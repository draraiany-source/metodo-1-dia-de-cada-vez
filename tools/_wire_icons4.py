from pathlib import Path
p = Path(r"lib/core/assets/app_icons.dart")
t = p.read_text(encoding="utf-8")
reps = [
    ("static const String recipes = '${_nav}recipes.jpg';", "static const String recipes = '${_app}receitas.png';"),
    ("static const String water = '${_health}water.jpg';", "static const String water = '${_app}hidratacao.png';"),
    ("static const String sleep = '${_health}sleep.jpg';", "static const String sleep = '${_app}sono.png';"),
    ("static const String logout = '${_actions}logout.jpg';", "static const String logout = '${_app}sair.png';"),
]
for a, b in reps:
    if a in t:
        t = t.replace(a, b)
        print("OK", b)
    elif b in t:
        print("already", b)
    else:
        key = a.split("String ")[1].split(" ")[0]
        print("MISS", key)
        for line in t.splitlines():
            if f"String {key} " in line:
                print(" ", line.strip())
p.write_text(t, encoding="utf-8")
print("done")
