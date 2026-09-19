# -*- coding: utf-8 -*-
"""Gera docs/AUDITORIA_SEC15_OBRIGATORIOS_20260919.pdf."""

from pathlib import Path

from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "AUDITORIA_SEC15_OBRIGATORIOS_20260919.pdf"

PINK = HexColor("#E85A9B")
LILAC = HexColor("#B57BFF")
PURPLE = HexColor("#7B2CBF")
BG = HexColor("#141414")
SURFACE = HexColor("#1E1E22")
CARD = HexColor("#2A2A30")
TEXT = HexColor("#F5F5F7")
MUTED = HexColor("#C8C4D0")
RED = HexColor("#FF4D6D")
GREEN = HexColor("#3DDC97")
LINE = HexColor("#3A3A44")


def register_fonts() -> tuple[str, str]:
    fonts = Path(r"C:\Windows\Fonts")
    regular = fonts / "segoeui.ttf"
    bold = fonts / "segoeuib.ttf"
    if not regular.exists():
        regular = fonts / "arial.ttf"
        bold = fonts / "arialbd.ttf"
    pdfmetrics.registerFont(TTFont("AppSans", str(regular)))
    pdfmetrics.registerFont(TTFont("AppSans-Bold", str(bold)))
    return "AppSans", "AppSans-Bold"


def styles(regular: str, bold: str) -> dict[str, ParagraphStyle]:
    base = getSampleStyleSheet()
    return {
        "kicker": ParagraphStyle(
            "kicker", parent=base["Normal"], fontName=bold, fontSize=10,
            textColor=PINK, alignment=TA_CENTER, spaceAfter=8,
        ),
        "title": ParagraphStyle(
            "title", parent=base["Normal"], fontName=bold, fontSize=22,
            leading=28, textColor=TEXT, alignment=TA_CENTER, spaceAfter=8,
        ),
        "sub": ParagraphStyle(
            "sub", parent=base["Normal"], fontName=regular, fontSize=11,
            leading=16, textColor=MUTED, alignment=TA_CENTER, spaceAfter=6,
        ),
        "h2": ParagraphStyle(
            "h2", parent=base["Normal"], fontName=bold, fontSize=12,
            leading=16, textColor=LILAC, spaceBefore=10, spaceAfter=5,
        ),
        "body": ParagraphStyle(
            "body", parent=base["Normal"], fontName=regular, fontSize=9.3,
            leading=13.2, textColor=TEXT, alignment=TA_JUSTIFY, spaceAfter=6,
        ),
        "muted": ParagraphStyle(
            "muted", parent=base["Normal"], fontName=regular, fontSize=8.2,
            leading=11.4, textColor=MUTED, spaceAfter=4,
        ),
        "cell": ParagraphStyle(
            "cell", parent=base["Normal"], fontName=regular, fontSize=7.4,
            leading=10.2, textColor=TEXT,
        ),
        "cell_b": ParagraphStyle(
            "cell_b", parent=base["Normal"], fontName=bold, fontSize=7.4,
            leading=10.2, textColor=TEXT,
        ),
        "head": ParagraphStyle(
            "head", parent=base["Normal"], fontName=bold, fontSize=7.5,
            leading=10.0, textColor=TEXT,
        ),
        "badge": ParagraphStyle(
            "badge", parent=base["Normal"], fontName=bold, fontSize=10,
            leading=14, textColor=TEXT, alignment=TA_CENTER,
        ),
        "bullet": ParagraphStyle(
            "bullet", parent=base["Normal"], fontName=regular, fontSize=9.0,
            leading=12.6, textColor=TEXT, leftIndent=8, spaceAfter=3,
        ),
        "code": ParagraphStyle(
            "code", parent=base["Normal"], fontName=regular, fontSize=7.4,
            leading=10.4, textColor=TEXT,
        ),
    }


def header_footer(canvas, doc) -> None:
    canvas.saveState()
    w, h = A4
    canvas.setFillColor(BG)
    canvas.rect(0, 0, w, h, fill=1, stroke=0)
    canvas.setFillColor(PINK)
    canvas.rect(0, h - 8, w, 8, fill=1, stroke=0)
    canvas.setFillColor(PURPLE)
    canvas.rect(0, 0, w, 18, fill=1, stroke=0)
    canvas.setFillColor(MUTED)
    canvas.setFont("AppSans", 7.5)
    canvas.drawString(16 * mm, 6, "Método 1 Dia de Cada Vez — Seção 15 obrigatória")
    canvas.drawRightString(w - 16 * mm, 6, f"Página {doc.page}")
    canvas.restoreState()


def banner(title: str, color, s: dict) -> Table:
    t = Table([[Paragraph(title, s["badge"])]], colWidths=[178 * mm])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), color),
        ("LEFTPADDING", (0, 0), (-1, -1), 10),
        ("RIGHTPADDING", (0, 0), (-1, -1), 10),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))
    return t


def kv(rows: list[tuple[str, str]], s: dict) -> Table:
    data = [[Paragraph(k, s["cell_b"]), Paragraph(v, s["cell"])] for k, v in rows]
    t = Table(data, colWidths=[48 * mm, 130 * mm])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), SURFACE),
        ("BOX", (0, 0), (-1, -1), 0.4, LINE),
        ("INNERGRID", (0, 0), (-1, -1), 0.3, LINE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]))
    return t


def grid(headers: list[str], rows: list[list[str]], s: dict, widths: list[float]) -> Table:
    head = [Paragraph(h, s["head"]) for h in headers]
    body = [[Paragraph(c, s["cell"]) for c in row] for row in rows]
    t = Table([head, *body], colWidths=widths, repeatRows=1)
    style = [
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE),
        ("BOX", (0, 0), (-1, -1), 0.4, LINE),
        ("INNERGRID", (0, 0), (-1, -1), 0.25, LINE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 3.2),
        ("RIGHTPADDING", (0, 0), (-1, -1), 3.2),
        ("TOPPADDING", (0, 0), (-1, -1), 3.2),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 3.2),
    ]
    for i in range(1, len(body) + 1):
        style.append(("BACKGROUND", (0, i), (-1, i), SURFACE if i % 2 else CARD))
    t.setStyle(TableStyle(style))
    return t


def verdict(label: str, sim: bool, note: str, s: dict) -> Table:
    t = Table([[
        Paragraph(f"<b>{label}</b>", s["cell_b"]),
        Paragraph("SIM" if sim else "NÃO", s["badge"]),
        Paragraph(note, s["cell"]),
    ]], colWidths=[62 * mm, 22 * mm, 94 * mm])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (0, 0), SURFACE),
        ("BACKGROUND", (1, 0), (1, 0), GREEN if sim else RED),
        ("BACKGROUND", (2, 0), (2, 0), SURFACE),
        ("BOX", (0, 0), (-1, -1), 0.4, LINE),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ]))
    return t


def bullets(items: list[str], s: dict) -> list:
    return [Paragraph(f"• {item}", s["bullet"]) for item in items]


def build() -> Path:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    regular, bold = register_fonts()
    s = styles(regular, bold)
    doc = SimpleDocTemplate(
        str(OUT), pagesize=A4,
        leftMargin=16 * mm, rightMargin=16 * mm,
        topMargin=16 * mm, bottomMargin=16 * mm,
        title="Auditoria Seção 15 — Método 1 Dia de Cada Vez",
        author="Auditoria técnica",
        subject="Pendências obrigatórias — 19/09/2026",
    )
    story: list = []

    story.append(Spacer(1, 10 * mm))
    story.append(Paragraph("RELATÓRIO TÉCNICO", s["kicker"]))
    story.append(Paragraph("Seção 15 — Obrigatório<br/>antes da publicação", s["title"]))
    story.append(Paragraph(
        "Método 1 Dia de Cada Vez · 19/09/2026<br/>"
        "Loja não publicada · cobrança desligada · sem secrets neste PDF",
        s["sub"],
    ))
    story.append(kv([
        ("Backup", "tag backup-sec15-obrigatorio-20260919 (23b1c0a)"),
        ("Hosting legal", "PASSOU — páginas no ar limpas"),
        ("Functions + 401", "PASSOU — amandaChat, calorieVision, accompanimentAi"),
        ("OpenAI no cliente", "PASSOU — nenhuma chave em lib/"),
        ("Chave OpenAI no servidor", "PENDENTE — config remoto não lido"),
        ("E2E 3 perfis", "PENDENTE — roteiro pronto; sem contas"),
        ("Gerar AAB Android", "SIM"),
        ("Enviar à Google Play", "NÃO"),
    ], s))

    story.append(Spacer(1, 5 * mm))
    story.append(banner("PRIORIDADE 1–6 — RESULTADO", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(grid(
        ["#", "Tarefa", "Resultado"],
        [
            ["1", "Publicar Hosting legal", "PASSOU"],
            ["2", "Deploy Functions com auth; POST sem token = 401", "PASSOU"],
            ["3", "OpenAI só no servidor (código)", "PASSOU; chave no Firebase PENDENTE"],
            ["4", "Contas + roteiro E2E", "Roteiro PASSOU; contas PENDENTE"],
            ["5", "QA desta etapa", "Hosting/401/legais PASSOU; E2E PENDENTE"],
            ["6", "Preparar AAB com PAYMENTS_ENABLED=false", "PASSOU (gerar; não enviar)"],
        ],
        s, [12 * mm, 108 * mm, 58 * mm],
    ))

    story.append(Paragraph("Evidências", s["h2"]))
    story.extend(bullets([
        "Hosting: firebase deploy --only hosting --project metodo1dia-app.",
        "privacidade.html e termos.html: HTTP 200, 1 html, suporte oficial, sem e-mail pessoal.",
        "Functions us-central1 Node 22: amandaChat e calorieVision atualizadas; accompanimentAi criada.",
        "POST sem token e Bearer inválido → HTTP 401 nas três.",
        "Cliente sem OPENAI_API_KEY. Function lê só config/env do servidor.",
        "Roteiro: release_config/ROTEIRO_E2E_TRES_PERFIS.md. Sem e-mail/senha/UID.",
        "AAB: ícone 1024, keystore local, PAYMENTS_ENABLED=false, URLs legais válidas.",
        "test/etapa7_legal_test.dart: 3 passaram.",
    ], s))
    story.append(Paragraph(
        "Comando AAB (não enviar à Play; não usar PAYMENTS_ENABLED=true): "
        "flutter build appbundle --release "
        "--dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com "
        "--dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html "
        "--dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html",
        s["code"],
    ))

    story.append(Spacer(1, 4 * mm))
    story.append(banner("ANDROID — GERAR AAB?", GREEN, s))
    story.append(Spacer(1, 3 * mm))
    story.append(verdict("Pronto para gerar AAB", True, "Técnico local. Keystore e ícone 1024 presentes.", s))
    story.append(Spacer(1, 2 * mm))
    story.append(verdict("Pronto para Google Play", False, "Faltam E2E, Data Safety, listing e OpenAI se IA for vitrine.", s))

    story.append(Spacer(1, 5 * mm))
    story.append(banner("TABELA GERAL (PÁGINA 9 ATUALIZADA)", PURPLE, s))
    story.append(Spacer(1, 2 * mm))
    story.append(Paragraph(
        "PASSOU só com evidência. Anamnese é bloqueador se o acompanhamento for vitrine.",
        s["muted"],
    ))
    story.append(grid(
        ["ITEM", "STATUS", "SEVERIDADE", "BLOQUEIA?", "AÇÃO"],
        [
            ["Aluno E2E", "PENDENTE", "BLOQUEADOR", "Sim", "Roteiro + conta Aluno"],
            ["Personal E2E", "PENDENTE", "BLOQUEADOR", "Sim", "Idem Personal"],
            ["Admin E2E", "PENDENTE", "BLOQUEADOR", "Sim", "Idem + admins/{uid}"],
            ["RBAC código/rules", "PASSOU", "—", "Não", "Manter"],
            ["Logout / troca", "PENDENTE", "BLOQUEADOR", "Sim", "3 trocas no aparelho"],
            ["Treinos", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "QA aparelho"],
            ["Cronômetro", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "QA aparelho"],
            ["Hidratação", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "QA aparelho"],
            ["Receitas", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "QA aparelho"],
            ["Desafio", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "QA aparelho"],
            ["Evolução", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "QA aparelho"],
            ["Vídeos", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "Play no aparelho"],
            ["Áudios", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "Play no aparelho"],
            ["Fotos Storage", "PENDENTE", "IMPORTANTE", "Não isolado", "Upload"],
            ["Quem Sou Eu", "PENDENTE", "IMPORTANTE", "Não isolado", "Salvar CMS"],
            ["Anamnese", "PENDENTE", "BLOQUEADOR*", "Se for vitrine", "Fluxo com conta"],
            ["Agenda", "PENDENTE", "IMPORTANTE", "Não isolado", "Horário"],
            ["Mensagens", "PENDENTE", "IMPORTANTE", "Não isolado", "Chat"],
            ["IA aluno", "PENDENTE", "BLOQUEADOR", "Se for vitrine", "401 OK; falta OpenAI+E2E"],
            ["Foto/calorias", "PENDENTE", "BLOQUEADOR", "Se for vitrine", "401 OK; falta OpenAI+foto"],
            ["Painel Personal", "PENDENTE", "BLOQUEADOR", "Sim", "Login Personal"],
            ["Painel Admin", "PENDENTE", "BLOQUEADOR", "Sim", "Login Admin"],
            ["Firebase Auth", "PASSOU código", "—", "Não", "E2E senha"],
            ["Firestore Rules", "PASSOU", "—", "Não", "Não abrir"],
            ["Storage Rules", "PASSOU", "—", "Não", "—"],
            ["Functions nuvem", "PASSOU", "—", "Não (auth)", "401 nas 3"],
            ["App Check", "PENDENTE", "IMPORTANTE", "Não imediato", "Monitor → enforce"],
            ["Secrets no git", "PASSOU", "—", "Não", "Manter"],
            ["RevenueCat sandbox", "FALHOU", "IMPORTANTE", "Não se IAP off", "Testers"],
            ["Privacidade local", "PASSOU", "—", "Não", "Teste etapa 7"],
            ["Privacidade/Termos no ar", "PASSOU", "—", "Não", "Hosting 19/09/2026"],
            ["Exclusão conta", "PASSOU código", "IMPORTANTE", "Não", "Teste descartável"],
            ["Data Safety / App Privacy", "PENDENTE", "BLOQUEADOR", "Sim p/ loja", "Jurídico + Console"],
            ["Android / Play", "PENDENTE", "BLOQUEADOR", "Sim p/ loja", "AAB gerável; listing falta"],
            ["iOS / TestFlight", "FALHOU", "BLOQUEADOR", "Sim", "Mac — fora desta etapa"],
            ["Guest/debug", "PASSOU (off)", "—", "Não", "Manter off"],
        ],
        s, [40 * mm, 28 * mm, 28 * mm, 26 * mm, 56 * mm],
    ))

    story.append(Paragraph("Ainda falta do obrigatório original (15.1)", s["h2"]))
    story.extend(bullets([
        "Hosting legal — concluído.",
        "Functions + 401 — concluído.",
        "OpenAI no servidor — código OK; confirmar chave no Firebase sem commitar.",
        "3 contas + E2E — roteiro pronto; falta executar.",
        "iOS Firebase/IPA — não feito (Windows).",
        "Screenshots / Data Safety / conta revisor — não feitos; ainda bloqueiam a loja.",
        "PAYMENTS_ENABLED=false — mantido.",
        "Commit/push do release — não feito (working tree sujo; tag de backup sim).",
    ], s))
    story.append(Paragraph(
        "Markdown irmão: docs/AUDITORIA_SEC15_OBRIGATORIOS_20260919.md",
        s["muted"],
    ))

    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
    return OUT


if __name__ == "__main__":
    path = build()
    print(path)
    print(f"bytes={path.stat().st_size}")
