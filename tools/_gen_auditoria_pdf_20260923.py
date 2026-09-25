# -*- coding: utf-8 -*-
"""Gera PDF legível da auditoria final (somente documentação)."""
from pathlib import Path
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
md_path = ROOT / "AUDITORIA_COMPLETA_HOMOLOGACAO_20260923.md"
pdf_path = ROOT / "AUDITORIA_COMPLETA_HOMOLOGACAO_20260923.pdf"
text = md_path.read_text(encoding="utf-8")

font_reg = "Helvetica"
font_bold = "Helvetica-Bold"
for candidate, bold in [
    (r"C:\Windows\Fonts\arial.ttf", r"C:\Windows\Fonts\arialbd.ttf"),
    (r"C:\Windows\Fonts\calibri.ttf", r"C:\Windows\Fonts\calibrib.ttf"),
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
        fontSize=18,
        leading=24,
        textColor=DARK,
        alignment=TA_CENTER,
        spaceAfter=8,
    )
)
styles.add(
    ParagraphStyle(
        name="CoverSub",
        fontName=font_reg,
        fontSize=11,
        leading=15,
        textColor=GRAY,
        alignment=TA_CENTER,
        spaceAfter=4,
    )
)
styles.add(
    ParagraphStyle(
        name="H1",
        fontName=font_bold,
        fontSize=14,
        leading=18,
        textColor=PINK,
        spaceBefore=14,
        spaceAfter=8,
    )
)
styles.add(
    ParagraphStyle(
        name="H2",
        fontName=font_bold,
        fontSize=12,
        leading=15,
        textColor=DARK,
        spaceBefore=10,
        spaceAfter=6,
    )
)
styles.add(
    ParagraphStyle(
        name="H3",
        fontName=font_bold,
        fontSize=10.5,
        leading=13,
        textColor=GRAY,
        spaceBefore=8,
        spaceAfter=4,
    )
)
styles.add(
    ParagraphStyle(
        name="DocBody",
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
        name="BulletItem",
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
        name="CodeBlock",
        fontName="Courier",
        fontSize=7.5,
        leading=10,
        textColor=DARK,
        backColor=LIGHT,
        leftIndent=4,
        rightIndent=4,
        spaceAfter=2,
    )
)
styles.add(
    ParagraphStyle(
        name="Cell", fontName=font_reg, fontSize=7.5, leading=9.5, textColor=DARK
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
        name="Verdict",
        fontName=font_bold,
        fontSize=10,
        leading=13,
        textColor=RED,
        alignment=TA_CENTER,
        spaceBefore=6,
        spaceAfter=6,
    )
)


def escape(s: str) -> str:
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def inline_md(s: str) -> str:
    s = escape(s)
    s = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", s)
    s = re.sub(
        r"`([^`]+)`",
        r"<font face='Courier' size='8'>\1</font>",
        s,
    )
    return s


def parse_table(lines):
    rows = []
    for line in lines:
        if re.match(r"^\|?\s*-+", line):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        rows.append(cells)
    return rows


def table_flowable(rows, col_widths=None):
    if not rows:
        return Spacer(1, 1)
    data = []
    hdr_style = ParagraphStyle(
        "Hdr", fontName=font_bold, fontSize=7.5, leading=9.5, textColor=white
    )
    for i, row in enumerate(rows):
        style = hdr_style if i == 0 else styles["Cell"]
        data.append([Paragraph(inline_md(c), style) for c in row])
    n = max(len(r) for r in data)
    for r in data:
        while len(r) < n:
            r.append(Paragraph("", styles["Cell"]))
    usable = A4[0] - 2.4 * cm
    if col_widths is None:
        col_widths = [usable / n] * n
    t = Table(data, colWidths=col_widths, repeatRows=1)
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), PINK),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [white, LIGHT]),
                ("GRID", (0, 0), (-1, -1), 0.3, HexColor("#DDD")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 3),
                ("RIGHTPADDING", (0, 0), (-1, -1), 3),
                ("TOPPADDING", (0, 0), (-1, -1), 3),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
            ]
        )
    )
    return t


story = []
story.append(Spacer(1, 1.5 * cm))
story.append(Paragraph("AUDITORIA COMPLETA", styles["CoverTitle"]))
story.append(Paragraph("Homologação Web/Android e Publicação", styles["CoverTitle"]))
story.append(Spacer(1, 0.4 * cm))
story.append(
    HRFlowable(width="80%", thickness=2, color=PINK, spaceBefore=4, spaceAfter=8)
)
story.append(Paragraph("Método 1 Dia de Cada Vez — Amanda Lopes", styles["CoverSub"]))
story.append(Paragraph("Diagnóstico somente — 23/09/2026 — sem correção de código", styles["CoverSub"]))
story.append(Spacer(1, 0.6 * cm))
story.append(
    Paragraph(
        "Produção NÃO alterada · Cobrança real NÃO ativada · E2E NÃO marcado como aprovado",
        styles["Verdict"],
    )
)
story.append(Spacer(1, 0.3 * cm))

vh = ParagraphStyle("vh", fontName=font_bold, fontSize=9, textColor=white)
verdict_data = [
    [Paragraph("Pergunta", vh), Paragraph("Resposta", vh)],
    [
        Paragraph("Pronto para homologar?", styles["Cell"]),
        Paragraph(
            "<b>SIM, com ressalvas</b> (AAB/APK e web existem; falta E2E 3 perfis e revalidação Voltar/Sair)",
            styles["Cell"],
        ),
    ],
    [
        Paragraph("Pronto para publicar Android?", styles["Cell"]),
        Paragraph("<b>NÃO — BLOQUEADO</b>", styles["Cell"]),
    ],
    [
        Paragraph("Pronto para publicar iOS?", styles["Cell"]),
        Paragraph("<b>NÃO — BLOQUEADO</b>", styles["Cell"]),
    ],
]
vt = Table(verdict_data, colWidths=[6 * cm, 11 * cm])
vt.setStyle(
    TableStyle(
        [
            ("BACKGROUND", (0, 0), (-1, 0), HexColor("#6B2D4B")),
            ("BACKGROUND", (0, 1), (-1, 1), HexColor("#FFF3E0")),
            ("BACKGROUND", (0, 2), (-1, 2), HexColor("#FFEBEE")),
            ("BACKGROUND", (0, 3), (-1, 3), HexColor("#FFEBEE")),
            ("GRID", (0, 0), (-1, -1), 0.4, HexColor("#CCC")),
            ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ("LEFTPADDING", (0, 0), (-1, -1), 6),
            ("RIGHTPADDING", (0, 0), (-1, -1), 6),
            ("TOPPADDING", (0, 0), (-1, -1), 6),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ]
    )
)
story.append(vt)
story.append(Spacer(1, 0.5 * cm))
story.append(
    Paragraph(
        "<b>Motivo do bloqueio:</b> E2E dos 3 perfis não documentado como PASSOU; "
        "falha observada Admin Voltar/Sair (código mitigado, E2E não reaprovado); "
        "iOS com REPLACE_ME; listing/Data Safety incompletos; working tree sujo (~971); "
        "cobrança real desligada.",
        styles["DocBody"],
    )
)
story.append(
    Paragraph(
        "Evidência: <font face='Courier' size='8'>tools/_auditoria_final_evidence_20260923.json</font> · "
        "Branch: <font face='Courier' size='8'>finalizacao-metodo-1-dia-de-cada-vez</font>",
        styles["DocBody"],
    )
)
story.append(PageBreak())

lines = text.splitlines()
i = 0
skip_until_section = True
in_code = False
code_buf = []
table_buf = []


def flush_table():
    global table_buf
    if not table_buf:
        return
    rows = parse_table(table_buf)
    n = max((len(r) for r in rows), default=2)
    usable = A4[0] - 2.4 * cm
    if n == 2:
        widths = [usable * 0.35, usable * 0.65]
    elif n == 3:
        widths = [usable * 0.28, usable * 0.36, usable * 0.36]
    elif n == 4:
        widths = [usable / 4] * 4
    elif n >= 9:
        fracs = [0.07, 0.06, 0.10, 0.12, 0.10, 0.10, 0.10, 0.10, 0.15]
        widths = [usable * w for w in fracs]
        while len(widths) < n:
            widths.append(usable / n)
        widths = widths[:n]
    else:
        widths = [usable / n] * n
    story.append(table_flowable(rows, widths))
    story.append(Spacer(1, 0.25 * cm))
    table_buf = []


def flush_code():
    global code_buf
    if not code_buf:
        return
    for cl in code_buf:
        story.append(Paragraph(escape(cl) if cl.strip() else "&nbsp;", styles["CodeBlock"]))
    story.append(Spacer(1, 0.2 * cm))
    code_buf = []


while i < len(lines):
    line = lines[i]
    if skip_until_section:
        if line.startswith("# A."):
            skip_until_section = False
            # cai no processamento normal desta linha
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
        code_buf.append(line)
        i += 1
        continue

    if line.strip().startswith("|"):
        table_buf.append(line)
        i += 1
        continue
    else:
        flush_table()

    if line.startswith("---"):
        story.append(
            HRFlowable(
                width="100%",
                thickness=0.5,
                color=HexColor("#DDD"),
                spaceBefore=6,
                spaceAfter=6,
            )
        )
        i += 1
        continue

    if line.startswith("# "):
        story.append(Paragraph(inline_md(line[2:]), styles["H1"]))
        i += 1
        continue
    if line.startswith("## "):
        story.append(Paragraph(inline_md(line[3:]), styles["H1"]))
        i += 1
        continue
    if line.startswith("### "):
        story.append(Paragraph(inline_md(line[4:]), styles["H2"]))
        i += 1
        continue
    if line.startswith("#### "):
        story.append(Paragraph(inline_md(line[5:]), styles["H3"]))
        i += 1
        continue

    if re.match(r"^[-*] ", line):
        story.append(Paragraph("• " + inline_md(line[2:]), styles["BulletItem"]))
        i += 1
        continue

    if line.strip() == "":
        story.append(Spacer(1, 0.12 * cm))
        i += 1
        continue

    if re.match(r"^\d+\.\s", line):
        story.append(Paragraph(inline_md(line), styles["BulletItem"]))
        i += 1
        continue

    story.append(Paragraph(inline_md(line), styles["DocBody"]))
    i += 1

flush_table()
flush_code()

story.append(Spacer(1, 0.4 * cm))
story.append(Paragraph("Arquivos gerados nesta entrega", styles["H2"]))
ents = [
    ["Arquivo", "Caminho"],
    ["Relatório MD", "AUDITORIA_COMPLETA_HOMOLOGACAO_20260923.md"],
    ["PDF", "AUDITORIA_COMPLETA_HOMOLOGACAO_20260923.pdf"],
    ["Evidência JSON", "tools/_auditoria_final_evidence_20260923.json"],
]
story.append(table_flowable(ents, [5 * cm, 12 * cm]))


def on_page(canvas, doc):
    canvas.saveState()
    canvas.setFont(font_reg, 7)
    canvas.setFillColor(GRAY)
    canvas.drawString(
        1.2 * cm, 1 * cm, "Método 1 Dia — Auditoria Completa 23/09/2026 — Sem senhas"
    )
    canvas.drawRightString(A4[0] - 1.2 * cm, 1 * cm, f"Pág. {doc.page}")
    canvas.restoreState()


doc = SimpleDocTemplate(
    str(pdf_path),
    pagesize=A4,
    leftMargin=1.2 * cm,
    rightMargin=1.2 * cm,
    topMargin=1.4 * cm,
    bottomMargin=1.6 * cm,
    title="Auditoria Completa — Método 1 Dia de Cada Vez",
    author="Pacote de entrega ao programador",
)
doc.build(story, onFirstPage=on_page, onLaterPages=on_page)
print("PDF_OK", pdf_path, pdf_path.stat().st_size)
