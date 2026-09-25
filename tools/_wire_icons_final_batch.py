from pathlib import Path
p = Path(r"lib/core/assets/app_icons.dart")
t = p.read_text(encoding="utf-8")
reps = [
    ("static const String checkin = '${_nav}checkin.jpg';", "static const String checkin = '${_app}checkin.png';"),
    ("static const String diary = '${_nav}diary.jpg';", "static const String diary = '${_app}diario.png';"),
    ("static const String evolution = '${_nav}evolution.jpg';", "static const String evolution = '${_app}evolucao.png';"),
    ("static const String trophy = '${_prem}achievement_trophy.jpg';", "static const String trophy = '${_app}desafios.png';"),
]
for a, b in reps:
    if a in t:
        t = t.replace(a, b)
        print("OK", b)
    elif b.split("'")[1] in t:
        print("already")
    else:
        key = a.split("String ")[1].split(" ")[0]
        print("MISS", key)
        for line in t.splitlines():
            if f"String {key} " in line:
                print(" ", line.strip())

if "desafios.png" in t and "desafios =" not in t:
    t = t.replace(
        "static const String trophy = '${_app}desafios.png';",
        "static const String trophy = '${_app}desafios.png';\n  static const String desafios = trophy;\n  static const String challenges = trophy;",
    )
    print("added desafios aliases")

# habits still missing file - leave habits=checkin for now but note
p.write_text(t, encoding="utf-8")
print("done")
