from pathlib import Path
p = Path(r"lib/core/constants/app_assets.dart")
t = p.read_text(encoding="utf-8")
block = """
  static const String amandaOrientando = 'assets/amanda/promo/amanda_orientando.png';
  static const String amandaAcenando = 'assets/amanda/promo/amanda_acenando.png';
  static const String amandaCalendarioCheck = 'assets/amanda/promo/amanda_calendario_check.png';
  static const String amandaTrofeu = 'assets/amanda/promo/amanda_trofeu.png';
  static const String amandaCorrida = 'assets/amanda/promo/amanda_corrida.png';
  static const String amandaForca = 'assets/amanda/promo/amanda_forca.png';
"""
if "amandaAcenando" not in t:
    if "amandaApresentando" in t:
        lines = t.splitlines(True)
        out = []
        for line in lines:
            out.append(line)
            if "amandaApresentando" in line:
                out.append(block)
        t = "".join(out)
    else:
        idx = t.rfind("}")
        t = t[:idx] + block + "\n" + t[idx:]
    p.write_text(t, encoding="utf-8")
    print("constants added")
else:
    print("already")
