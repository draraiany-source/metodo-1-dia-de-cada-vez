# -*- coding: utf-8 -*-
from pathlib import Path
import re
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib.colors import HexColor
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, HRFlowable
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

ROOT = Path(__file__).resolve().parents[1]
md = (ROOT / "HOMOLOGACAO_CONTINUACAO_20260924.md").read_text(encoding="utf-8")
pdf_path = ROOT / "HOMOLOGACAO_CONTINUACAO_20260924.pdf"

font, bold = "Helvetica", "Helvetica-Bold"
try:
    pdfmetrics.registerFont(TTFont("B", r"C:\Windows\Fonts\arial.ttf"))
    pdfmetrics.registerFont(TTFont("BB", r"C:\Windows\Fonts\arialbd.ttf"))
    font, bold = "B", "BB"
except Exception:
    pass

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name="T", fontName=bold, fontSize=14, leading=18, textColor=HexColor("#1A1A1A"), spaceAfter=8))
styles.add(ParagraphStyle(name="H", fontName=bold, fontSize=11, leading=14, textColor=HexColor("#C45C8A"), spaceBefore=10, spaceAfter=4))
styles.add(ParagraphStyle(name="P", fontName=font, fontSize=9, leading=12, textColor=HexColor("#222"), spaceAfter=3))
styles.add(ParagraphStyle(name="W", fontName=bold, fontSize=10, leading=13, textColor=HexColor("#B00020"), spaceAfter=8))


def esc(s: str) -> str:
    s = s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    s = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", s)
    s = re.sub(r"`([^`]+)`", r"<font face='Courier' size='8'>\1</font>", s)
    return s


story = [
    Paragraph("Homologação — Continuação 24/09/2026", styles["T"]),
    Paragraph("Método 1 Dia de Cada Vez · HEAD 33be30b · carimbo 20260924-nav", styles["P"]),
    Paragraph("NÃO PRONTO PARA PUBLICAÇÃO — E2E 3 perfis NÃO TESTADO", styles["W"]),
    HRFlowable(width="100%", thickness=1, color=HexColor("#C45C8A"), spaceAfter=8),
]

in_code = False
for line in md.splitlines():
    if line.startswith("```"):
        in_code = not in_code
        continue
    if in_code:
        story.append(Paragraph(esc(line), styles["P"]))
        continue
    if line.startswith("# "):
        continue
    if line.startswith("## "):
        story.append(Paragraph(esc(line[3:]), styles["H"]))
    elif line.startswith("|"):
        cells = [c.strip() for c in line.strip("|").split("|")]
        if all(re.match(r"^:?-+:?$", c or "") for c in cells):
            continue
        story.append(Paragraph(esc(" | ".join(cells)), styles["P"]))
    elif line.startswith("---"):
        story.append(Spacer(1, 0.15 * cm))
    elif line.startswith("- "):
        story.append(Paragraph("• " + esc(line[2:]), styles["P"]))
    elif line.strip() == "":
        story.append(Spacer(1, 0.1 * cm))
    else:
        story.append(Paragraph(esc(line), styles["P"]))

doc = SimpleDocTemplate(
    str(pdf_path),
    pagesize=A4,
    leftMargin=1.5 * cm,
    rightMargin=1.5 * cm,
    topMargin=1.4 * cm,
    bottomMargin=1.4 * cm,
)
doc.build(story)
print(f"PDF={pdf_path} SIZE={pdf_path.stat().st_size}")
