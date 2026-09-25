from pathlib import Path
p = Path(r"lib/core/assets/app_icons.dart")
t = p.read_text(encoding="utf-8")
reps = [
    ("static const String settings = '${_nav}settings.jpg';", "static const String settings = '${_app}configuracoes.png';"),
    ("static const String running = '${_health}running_gps.jpg';", "static const String running = '${_app}corrida_gps.png';"),
    ("static const String cameraFood = '${_health}food_ai.jpg';", "static const String cameraFood = '${_app}analisar_refeicao_ia.png';"),
    ("static const String healthFitness = healthHeart;", "static const String healthFitness = '${_app}bem_estar.png';"),
    ("static const String support = community;", "static const String support = '${_app}suporte.png';"),
    ("static const String messages = community;", "static const String messages = '${_app}suporte.png';"),
]
# help may not exist - add after support if needed
for a, b in reps:
    if a in t:
        t = t.replace(a, b)
        print("OK", b.split("'")[1] if "'" in b else b[:60])
    elif "${_app}" in b and b.split("'")[1] in t:
        print("already", b)
    else:
        key = a.split("String ")[1].split(" ")[0]
        print("MISS", key)
        for line in t.splitlines():
            if f"String {key} " in line or f"String {key}=" in line:
                print(" ", line.strip())

# Add help/ajuda alias if missing
if "ajuda.png" not in t:
    needle = "static const String support = '${_app}suporte.png';"
    if needle in t:
        t = t.replace(
            needle,
            needle + "\n  static const String help = '${_app}ajuda.png';\n  static const String ajuda = help;",
        )
        print("added help/ajuda")
    else:
        # try insert near security
        if "static const String security = settings;" in t:
            t = t.replace(
                "static const String security = settings;",
                "static const String help = '${_app}ajuda.png';\n  static const String ajuda = help;\n  static const String security = settings;",
            )
            print("added help near security")

# wellness alias
if "bemEstar" not in t and "bem_estar.png" in t:
    if "static const String healthFitness =" in t:
        t = t.replace(
            "static const String healthFitness = '${_app}bem_estar.png';",
            "static const String healthFitness = '${_app}bem_estar.png';\n  static const String bemEstar = healthFitness;",
        )
        print("added bemEstar")

p.write_text(t, encoding="utf-8")
print("done")
