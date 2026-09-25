from pathlib import Path
p = Path(r"lib/core/assets/app_icons.dart")
t = p.read_text(encoding="utf-8")
# Point dedicated hydration pack to new extras
old_block = """  /// Pacote dedicado da tela Meta de água (alta resolução / proporção limpa).
  static const String _hydrationDir = 'assets/icons/hydration/';
  static const String hydrationProgress =
      '${_hydrationDir}hydration_progress.png';
  static const String hydrationCheck = '${_hydrationDir}hydration_check.png';
  static const String hydrationBottle = '${_hydrationDir}hydration_bottle.png';
  static const String hydrationGlass = '${_hydrationDir}hydration_glass.png';"""
new_block = """  /// Pacote dedicado da tela Meta de água (neon 3D gloss).
  static const String _hydrationDir = 'assets/icons/app/extras_hidratacao/';
  static const String hydrationProgress =
      '${_hydrationDir}hidratacao_rastreamento.png';
  static const String hydrationCheck = '${_hydrationDir}hidratacao_check.png';
  static const String hydrationBottle = '${_hydrationDir}hidratacao_garrafa.png';
  static const String hydrationGlass = '${_hydrationDir}hidratacao_extra_1.png';
  static const String hydrationExtra = hydrationGlass;"""
if old_block in t:
    t = t.replace(old_block, new_block)
    print("hydration block updated")
else:
    print("block not exact - trying line replaces")
    reps = [
        ("static const String _hydrationDir = 'assets/icons/hydration/';", "static const String _hydrationDir = 'assets/icons/app/extras_hidratacao/';"),
        ("'${_hydrationDir}hydration_progress.png';", "'${_hydrationDir}hidratacao_rastreamento.png';"),
        ("'${_hydrationDir}hydration_check.png';", "'${_hydrationDir}hidratacao_check.png';"),
        ("'${_hydrationDir}hydration_bottle.png';", "'${_hydrationDir}hidratacao_garrafa.png';"),
        ("'${_hydrationDir}hydration_glass.png';", "'${_hydrationDir}hidratacao_extra_1.png';"),
    ]
    for a,b in reps:
        if a in t:
            t = t.replace(a,b)
            print("OK", b)
        else:
            print("MISS", a)
p.write_text(t, encoding="utf-8")
print("done")
