from pathlib import Path
p = Path(r"lib/core/assets/app_icons.dart")
t = p.read_text(encoding="utf-8")
# habits currently aliases checkin
if "static const String habits = checkin;" in t:
    t = t.replace(
        "static const String habits = checkin;",
        "static const String habits = '${_app}habitos.png';\n  static const String habitos = habits;",
    )
    print("habits wired")
elif "habitos.png" in t:
    print("already")
else:
    print("insert near checkin")
    t = t.replace(
        "static const String checkin = '${_app}checkin.png';",
        "static const String checkin = '${_app}checkin.png';\n  static const String habits = '${_app}habitos.png';\n  static const String habitos = habits;",
    )
p.write_text(t, encoding="utf-8")
print("png count", len(list(Path("assets/icons/app").glob("*.png"))))
