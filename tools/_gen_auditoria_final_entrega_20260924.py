# -*- coding: utf-8 -*-
"""Gera PDF da auditoria final entrega programador 20260924."""
from pathlib import Path
import os
import re
import subprocess

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib.colors import HexColor
from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
    PageBreak,
    HRFlowable,
    KeepTogether,
)
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

ROOT = Path(__file__).resolve().parents[1]
md_path = ROOT / "AUDITORIA_FINAL_ENTREGA_PROGRAMADOR_20260924.md"
pdf_path = ROOT / "AUDITORIA_FINAL_ENTREGA_PROGRAMADOR_20260924.pdf"
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
GREEN = HexColor("#1B5E20")
AMBER = HexColor("#E65100")

styles = getSampleStyleSheet()
styles.add(
    ParagraphStyle(
        name="CoverTitle",
        fontName=font_bold,
        fontSize=15,
        leading=19,
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
        name="AuditH1",
        fontName=font_bold,
        fontSize=12,
        leading=15,
        textColor=PINK,
        spaceBefore=12,
        spaceAfter=6,
    )
)
styles.add(
    ParagraphStyle(
        name="AuditH2",
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
        name="AuditBody",
        fontName=font_reg,
        fontSize=9,
        leading=12,
        textColor=DARK,
        alignment=TA_JUSTIFY,
        spaceAfter=4,
    )
)
styles.add(
    ParagraphStyle(
        name="AuditBullet",
        fontName=font_reg,
        fontSize=9,
        leading=12,
        textColor=DARK,
        leftIndent=12,
        spaceAfter=2,
    )
)
styles.add(
    ParagraphStyle(
        name="AuditCode",
        fontName="Courier",
        fontSize=7.5,
        leading=10,
        textColor=DARK,
        backColor=LIGHT,
        spaceAfter=4,
    )
)
styles.add(
    ParagraphStyle(
        name="Cell",
        fontName=font_reg,
        fontSize=7.5,
        leading=9.5,
        textColor=DARK,
    )
)
styles.add(
    ParagraphStyle(
        name="CellBold",
        fontName=font_bold,
        fontSize=7.5,
        leading=9.5,
        textColor=DARK,
    )
)
styles.add(
    ParagraphStyle(
        name="Warn",
        fontName=font_bold,
        fontSize=9.5,
        leading=12,
        textColor=RED,
        alignment=TA_CENTER,
        spaceBefore=6,
        spaceAfter=8,
    )
)


def esc(s: str) -> str:
    return (
        s.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )


def inline_md(s: str) -> str:
    s = esc(s)
    s = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", s)
    s = re.sub(r"`([^`]+)`", r"<font face='Courier' size='8'>\1</font>", s)
    return s


def parse_table(block_lines):
    rows = []
    for line in block_lines:
        line = line.strip()
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if all(re.match(r"^:?-+:?$", c) for c in cells):
            continue
        rows.append(cells)
    return rows


def table_flowable(rows, col_widths=None):
    if not rows:
        return Spacer(1, 1)
    data = []
    for i, row in enumerate(rows):
        style = styles["CellBold"] if i == 0 else styles["Cell"]
        data.append([Paragraph(inline_md(c), style) for c in row])
    t = Table(data, colWidths=col_widths, repeatRows=1)
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), PINK),
                ("TEXTCOLOR", (0, 0), (-1, 0), HexColor("#FFFFFF")),
                ("BACKGROUND", (0, 1), (-1, -1), LIGHT),
                ("GRID", (0, 0), (-1, -1), 0.4, HexColor("#D0C4CB")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 4),
                ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                ("TOPPADDING", (0, 0), (-1, -1), 3),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
            ]
        )
    )
    return t


story = []
story.append(Spacer(1, 1.2 * cm))
story.append(Paragraph("AUDITORIA FINAL — Entrega ao Programador", styles["CoverTitle"]))
story.append(Paragraph("Método 1 Dia de Cada Vez — Amanda Lopes", styles["CoverSub"]))
story.append(Paragraph("24/09/2026 · Commit 7aaf08b · Carimbo 20260924-nav", styles["CoverSub"]))
story.append(Spacer(1, 0.3 * cm))
story.append(HRFlowable(width="100%", thickness=1.5, color=PINK, spaceAfter=8))
story.append(
    Paragraph(
        "NÃO APROVADO PARA PUBLICAÇÃO NAS LOJAS — E2E três perfis NÃO TESTADO · iOS REPLACE_ME · cobrança real DESLIGADA",
        styles["Warn"],
    )
)

lines = text.splitlines()
i = 0
# skip title block already rendered
while i < len(lines) and not lines[i].startswith("## 1."):
    i += 1

in_code = False
code_buf = []
table_buf = []

while i < len(lines):
    line = lines[i]
    if line.startswith("```"):
        if not in_code:
            in_code = True
            code_buf = []
        else:
            in_code = False
            story.append(Paragraph(esc("\n".join(code_buf)), styles["AuditCode"]))
            code_buf = []
        i += 1
        continue
    if in_code:
        code_buf.append(line)
        i += 1
        continue

    if line.strip().startswith("|"):
        table_buf.append(line)
        i += 1
        if i >= len(lines) or not lines[i].strip().startswith("|"):
            rows = parse_table(table_buf)
            n = max((len(r) for r in rows), default=2)
            usable = 17.5 * cm
            if n == 2:
                widths = [5.5 * cm, 12 * cm]
            elif n == 3:
                widths = [usable / 3] * 3
            elif n == 4:
                widths = [2.8 * cm, 3.2 * cm, 5.5 * cm, 6 * cm]
            elif n == 5:
                widths = [1.8 * cm, 2.2 * cm, 5 * cm, 3 * cm, 5.5 * cm]
            else:
                widths = [usable / n] * n
            story.append(table_flowable(rows, widths))
            story.append(Spacer(1, 0.25 * cm))
            table_buf = []
        continue

    if line.startswith("## "):
        story.append(Paragraph(inline_md(line[3:]), styles["AuditH1"]))
    elif line.startswith("### "):
        story.append(Paragraph(inline_md(line[4:]), styles["AuditH2"]))
    elif line.startswith("---"):
        story.append(HRFlowable(width="100%", thickness=0.5, color=HexColor("#D0C4CB"), spaceBefore=4, spaceAfter=4))
    elif line.startswith("- [ ]"):
        story.append(Paragraph("☐ " + inline_md(line[5:].strip()), styles["AuditBullet"]))
    elif line.startswith("- "):
        story.append(Paragraph("• " + inline_md(line[2:]), styles["AuditBullet"]))
    elif line.strip() == "":
        story.append(Spacer(1, 0.12 * cm))
    else:
        story.append(Paragraph(inline_md(line), styles["AuditBody"]))
    i += 1

doc = SimpleDocTemplate(
    str(pdf_path),
    pagesize=A4,
    leftMargin=1.6 * cm,
    rightMargin=1.6 * cm,
    topMargin=1.4 * cm,
    bottomMargin=1.4 * cm,
    title="Auditoria Final Entrega Programador 20260924",
    author="Auditoria Método 1 Dia",
)
doc.build(story)
print(f"PDF={pdf_path}")
print(f"SIZE={pdf_path.stat().st_size}")

# try open
try:
    os.startfile(str(pdf_path))
except Exception as e:
    print(f"OPEN_ERR={e}")
