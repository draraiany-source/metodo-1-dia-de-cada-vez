from pathlib import Path
p = Path(r"lib/core/constants/app_assets.dart")
t = p.read_text(encoding="utf-8")
block = """
  static const String amandaAlongamento = 'assets/amanda/promo/amanda_alongamento.png';
  static const String amandaApontandoBaixo = 'assets/amanda/promo/amanda_apontando_baixo.png';
  static const String amandaApontandoCima = 'assets/amanda/promo/amanda_apontando_cima.png';
  static const String amandaApontandoDireita = 'assets/amanda/promo/amanda_apontando_direita.png';
  static const String amandaApontandoEsquerda = 'assets/amanda/promo/amanda_apontando_esquerda.png';
  static const String amandaApresentando = 'assets/amanda/promo/amanda_apresentando.png';
"""
if "amandaAlongamento" not in t:
    # insert after amandaVitoria if present
    if "amandaVitoria" in t:
        lines = t.splitlines(True)
        out = []
        for line in lines:
            out.append(line)
            if "amandaVitoria" in line:
                out.append(block)
        t = "".join(out)
        print("inserted after amandaVitoria")
    else:
        idx = t.rfind("}")
        t = t[:idx] + block + "\n" + t[idx:]
        print("appended before class end")
    p.write_text(t, encoding="utf-8")
else:
    print("already present")
