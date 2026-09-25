from pathlib import Path
p = Path(r"lib/core/constants/app_assets.dart")
t = p.read_text(encoding="utf-8")
block = """
  static const String amandaJoinha = 'assets/amanda/promo/amanda_joinha.png';
  static const String amandaLembreteHidratacao = 'assets/amanda/promo/amanda_lembrete_hidratacao.png';
  static const String amandaMeditacao = 'assets/amanda/promo/amanda_meditacao.png';
  static const String amandaMetaConcluida = 'assets/amanda/promo/amanda_meta_concluida.png';
  static const String amandaMostrandoApp = 'assets/amanda/promo/amanda_mostrando_app.png';
  static const String amandaAlongamentoAlt = 'assets/amanda/promo/amanda_alongamento_alt.png';
"""
if "amandaJoinha" not in t:
    if "amandaForca" in t:
        lines = t.splitlines(True)
        out = []
        for line in lines:
            out.append(line)
            if "amandaForca" in line:
                out.append(block)
        t = "".join(out)
    else:
        idx = t.rfind("}")
        t = t[:idx] + block + "\n" + t[idx:]
    p.write_text(t, encoding="utf-8")
    print("added")
else:
    print("already")
