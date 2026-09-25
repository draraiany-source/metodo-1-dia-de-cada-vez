# -*- coding: utf-8 -*-
"""Gera PDF da homologação pós-correção e tenta abrir."""
from pathlib import Path
import os
import re

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib.colors import HexColor, white
from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
    PageBreak,
    HRFlowable,
)
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

ROOT = Path(__file__).resolve().parents[1]
md_path = ROOT / "HOMOLOGACAO_POS_CORRECAO_20260924.md"
pdf_path = ROOT / "HOMOLOGACAO_POS_CORRECAO_20260924.pdf"
text = md_path.read_text(encoding="utf-8")

font_reg = "Helvetica"
font_bold = "Helvetica-Bold"
for candidate, bold in [
    (r"C:\Windows\Fonts\arial.ttf", r"C:\Windows\Fonts\arialbd.ttf"),
]:
    try:
        pdfmetrics.registerFont(TTFont("BodyFont", candidate))
        pdfmetrics.registerFont(TTFont("BodyFont-Bold", bold))
        font_reg = "BodyFont"
        font_bold = "BodyFont-Bold"
        break
    except Exception:
        pass

PINK = HexColor("#C45C8A")
DARK = HexColor("#1A1A1A")
GRAY = HexColor("#444444")
LIGHT = HexColor("#F7F2F5")
RED = HexColor("#B00020")

styles = getSampleStyleSheet()
styles.add(
    ParagraphStyle(
        name="CoverTitle",
        fontName=font_bold,
        fontSize=16,
        leading=20,
        textColor=DARK,
        alignment=TA_CENTER,
        spaceAfter=6,
    )
)
styles.add(
    ParagraphStyle(
        name="CoverSub",
        fontName=font_reg,
        fontSize=10,
        leading=13,
        textColor=GRAY,
        alignment=TA_CENTER,
        spaceAfter=3,
    )
)
styles.add(
    ParagraphStyle(
        name="H1",
        fontName=font_bold,
        fontSize=12,
        leading=15,
        textColor=PINK,
        spaceBefore=10,
        spaceAfter=6,
    )
)
styles.add(
    ParagraphStyle(
        name="H2",
        fontName=font_bold,
        fontSize=10.5,
        leading=13,
        textColor=DARK,
        spaceBefore=8,
        spaceAfter=4,
    )
)
styles.add(
    ParagraphStyle(
        name="DocBody",
        fontName=font_reg,
        fontSize=8.5,
        leading=11,
        textColor=DARK,
        alignment=TA_JUSTIFY,
        spaceAfter=3,
    )
)
styles.add(
    ParagraphStyle(
        name="BulletItem",
        fontName=font_reg,
        fontSize=8.5,
        leading=11,
        textColor=DARK,
        leftIndent=10,
        spaceAfter=2,
    )
)
styles.add(
    ParagraphStyle(
        name="CodeBlock",
        fontName="Courier",
        fontSize=7,
        leading=9,
        textColor=DARK,
        backColor=LIGHT,
        spaceAfter=1,
    )
)
styles.add(
    ParagraphStyle(
        name="Cell", fontName=font_reg, fontSize=7, leading=9, textColor=DARK
    )
)
styles.add(
    ParagraphStyle(
        name="Verdict",
        fontName=font_bold,
        fontSize=9,
        leading=12,
        textColor=RED,
        alignment=TA_CENTER,
        spaceBefore=4,
        spaceAfter=4,
    )
)


def esc(s: str) -> str:
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def inline(s: str) -> str:
    s = esc(s)
    s = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", s)
    s = re.sub(
        r"`([^`]+)`",
        r"<font face='Courier' size='7'>\1</font>",
        s,
    )
    return s


story = []
story.append(Spacer(1, 1 * cm))
story.append(Paragraph("HOMOLOGAÇÃO PÓS-CORREÇÃO", styles["CoverTitle"]))
story.append(
    Paragraph(
        "Método 1 Dia de Cada Vez — Relatório ao Programador", styles["CoverSub"]
    )
)
story.append(
    Paragraph(
        "24/09/2026 · Sem senhas · Sem publicação · Sem cobrança real",
        styles["CoverSub"],
    )
)
story.append(
    HRFlowable(width="80%", thickness=2, color=PINK, spaceBefore=6, spaceAfter=8)
)
story.append(
    Paragraph(
        "AMBIENTE WEB ATUALIZADO · E2E MANUAL NÃO EXECUTADO · PUBLICAÇÃO BLOQUEADA",
        styles["Verdict"],
    )
)

vh = ParagraphStyle("vh", fontName=font_bold, fontSize=8, textColor=white)
rows = [
    [Paragraph("Alvo", vh), Paragraph("Veredito", vh)],
    [
        Paragraph("Ambiente web homolog", styles["Cell"]),
        Paragraph("<b>ATUALIZADO</b> (stamp 20260924-nav)", styles["Cell"]),
    ],
    [
        Paragraph("Aceite E2E web/Android", styles["Cell"]),
        Paragraph("<b>BLOQUEADO</b> (sem contas / sem device)", styles["Cell"]),
    ],
    [
        Paragraph("Publicação iOS", styles["Cell"]),
        Paragraph("<b>BLOQUEADA</b> (REPLACE_ME)", styles["Cell"]),
    ],
    [
        Paragraph("Publicação Play", styles["Cell"]),
        Paragraph("<b>BLOQUEADA</b>", styles["Cell"]),
    ],
]
t = Table(rows, colWidths=[6 * cm, 11 * cm])
t.setStyle(
    TableStyle(
        [
            ("BACKGROUND", (0, 0), (-1, 0), HexColor("#6B2D4B")),
            ("BACKGROUND", (0, 1), (-1, 1), HexColor("#E8F5E9")),
            ("BACKGROUND", (0, 2), (-1, -1), HexColor("#FFEBEE")),
            ("GRID", (0, 0), (-1, -1), 0.4, HexColor("#CCC")),
            ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ("LEFTPADDING", (0, 0), (-1, -1), 5),
            ("TOPPADDING", (0, 0), (-1, -1), 5),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ]
    )
)
story.append(t)
story.append(Spacer(1, 0.4 * cm))
story.append(
    Paragraph(
        "Branch <b>finalizacao-metodo-1-dia-de-cada-vez</b> · HEAD "
        "<font face='Courier' size='8'>293ffa9</font> · working tree <b>sujo</b> "
        "(~1003) com correções não commitadas. Carimbo pretendido: "
        "<font face='Courier' size='8'>20260924-nav</font>.",
        styles["DocBody"],
    )
)
story.append(PageBreak())

lines = text.splitlines()
i = 0
skip = True
in_code = False
code: list[str] = []
table: list[str] = []


def flush_table():
    global table
    if not table:
        return
    rows = []
    for line in table:
        if re.match(r"^\|?\s*-+", line):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        rows.append(cells)
    if not rows:
        table = []
        return
    n = max(len(r) for r in rows)
    usable = A4[0] - 2.4 * cm
    widths = [usable / n] * n
    data = []
    for ri, row in enumerate(rows):
        st = (
            ParagraphStyle(
                "hdr",
                fontName=font_bold,
                fontSize=6.5,
                leading=8,
                textColor=white,
            )
            if ri == 0
            else styles["Cell"]
        )
        cells = [Paragraph(inline(c), st) for c in row]
        while len(cells) < n:
            cells.append(Paragraph("", styles["Cell"]))
        data.append(cells)
    tt = Table(data, colWidths=widths, repeatRows=1)
    tt.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), PINK),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [white, LIGHT]),
                ("GRID", (0, 0), (-1, -1), 0.25, HexColor("#DDD")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 2),
                ("RIGHTPADDING", (0, 0), (-1, -1), 2),
                ("TOPPADDING", (0, 0), (-1, -1), 2),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 2),
            ]
        )
    )
    story.append(tt)
    story.append(Spacer(1, 0.15 * cm))
    table = []


def flush_code():
    global code
    for cl in code:
        story.append(
            Paragraph(esc(cl) if cl.strip() else "&nbsp;", styles["CodeBlock"])
        )
    code = []
    story.append(Spacer(1, 0.1 * cm))


while i < len(lines):
    line = lines[i]
    if skip:
        if line.startswith("## 1."):
            skip = False
        else:
            i += 1
            continue
    if line.startswith("```"):
        if in_code:
            flush_code()
            in_code = False
        else:
            flush_table()
            in_code = True
        i += 1
        continue
    if in_code:
        code.append(line)
        i += 1
        continue
    if line.strip().startswith("|"):
        table.append(line)
        i += 1
        continue
    flush_table()
    if line.startswith("---"):
        story.append(
            HRFlowable(
                width="100%",
                thickness=0.4,
                color=HexColor("#DDD"),
                spaceBefore=4,
                spaceAfter=4,
            )
        )
        i += 1
        continue
    if line.startswith("## "):
        story.append(Paragraph(inline(line[3:]), styles["H1"]))
        i += 1
        continue
    if line.startswith("### "):
        story.append(Paragraph(inline(line[4:]), styles["H2"]))
        i += 1
        continue
    if re.match(r"^[-*] ", line):
        story.append(Paragraph("• " + inline(line[2:]), styles["BulletItem"]))
        i += 1
        continue
    if re.match(r"^\d+\.\s", line):
        story.append(Paragraph(inline(line), styles["BulletItem"]))
        i += 1
        continue
    if line.strip() == "":
        story.append(Spacer(1, 0.08 * cm))
        i += 1
        continue
    story.append(Paragraph(inline(line), styles["DocBody"]))
    i += 1

flush_table()
flush_code()


def on_page(canvas, doc):
    canvas.saveState()
    canvas.setFont(font_reg, 7)
    canvas.setFillColor(GRAY)
    canvas.drawString(
        1.2 * cm,
        1 * cm,
        "Método 1 Dia — Homologação pós-correção 24/09/2026 — Sem senhas",
    )
    canvas.drawRightString(A4[0] - 1.2 * cm, 1 * cm, f"Pág. {doc.page}")
    canvas.restoreState()


doc = SimpleDocTemplate(
    str(pdf_path),
    pagesize=A4,
    leftMargin=1.2 * cm,
    rightMargin=1.2 * cm,
    topMargin=1.3 * cm,
    bottomMargin=1.5 * cm,
    title="Homologação Pós-Correção — Método 1 Dia",
    author="Programador",
)
doc.build(story, onFirstPage=on_page, onLaterPages=on_page)
assert pdf_path.exists() and pdf_path.stat().st_size > 1000
try:
    os.startfile(str(pdf_path.resolve()))
    opened = True
except Exception as e:
    opened = False
    print("OPEN_FAIL", e)
print("PDF_OK", pdf_path.resolve(), pdf_path.stat().st_size, "OPENED=", opened)
