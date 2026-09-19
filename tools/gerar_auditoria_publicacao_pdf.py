# -*- coding: utf-8 -*-
"""Gera docs/AUDITORIA_FINAL_PUBLICACAO_METODO_1_DIA.pdf — 19/09/2026."""

from pathlib import Path

from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "AUDITORIA_FINAL_PUBLICACAO_METODO_1_DIA.pdf"

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
            "title", parent=base["Normal"], fontName=bold, fontSize=24,
            leading=30, textColor=TEXT, alignment=TA_CENTER, spaceAfter=8,
        ),
        "sub": ParagraphStyle(
            "sub", parent=base["Normal"], fontName=regular, fontSize=11,
            leading=16, textColor=MUTED, alignment=TA_CENTER, spaceAfter=6,
        ),
        "h1": ParagraphStyle(
            "h1", parent=base["Normal"], fontName=bold, fontSize=15,
            leading=20, textColor=TEXT, spaceBefore=12, spaceAfter=6,
        ),
        "h2": ParagraphStyle(
            "h2", parent=base["Normal"], fontName=bold, fontSize=12,
            leading=16, textColor=LILAC, spaceBefore=10, spaceAfter=5,
        ),
        "body": ParagraphStyle(
            "body", parent=base["Normal"], fontName=regular, fontSize=9.4,
            leading=13.4, textColor=TEXT, alignment=TA_JUSTIFY, spaceAfter=6,
        ),
        "muted": ParagraphStyle(
            "muted", parent=base["Normal"], fontName=regular, fontSize=8.2,
            leading=11.4, textColor=MUTED, spaceAfter=4,
        ),
        "cell": ParagraphStyle(
            "cell", parent=base["Normal"], fontName=regular, fontSize=7.5,
            leading=10.4, textColor=TEXT,
        ),
        "cell_b": ParagraphStyle(
            "cell_b", parent=base["Normal"], fontName=bold, fontSize=7.5,
            leading=10.4, textColor=TEXT,
        ),
        "head": ParagraphStyle(
            "head", parent=base["Normal"], fontName=bold, fontSize=7.6,
            leading=10.2, textColor=TEXT,
        ),
        "badge": ParagraphStyle(
            "badge", parent=base["Normal"], fontName=bold, fontSize=10,
            leading=14, textColor=TEXT, alignment=TA_CENTER,
        ),
        "bullet": ParagraphStyle(
            "bullet", parent=base["Normal"], fontName=regular, fontSize=9.0,
            leading=12.8, textColor=TEXT, leftIndent=8, spaceAfter=3,
        ),
        "footer": ParagraphStyle(
            "footer", parent=base["Normal"], fontName=regular, fontSize=8,
            textColor=MUTED, alignment=TA_CENTER,
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
    canvas.drawString(16 * mm, 6, "Método 1 Dia de Cada Vez — Auditoria final de publicação")
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
        ("LEFTPADDING", (0, 0), (-1, -1), 3.5),
        ("RIGHTPADDING", (0, 0), (-1, -1), 3.5),
        ("TOPPADDING", (0, 0), (-1, -1), 3.5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 3.5),
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
        title="Auditoria Final de Publicação — Método 1 Dia de Cada Vez",
        author="Auditoria técnica",
        subject="Google Play e App Store — 19/09/2026",
    )
    story: list = []

    story.append(Spacer(1, 16 * mm))
    story.append(Paragraph("AUDITORIA FINAL DE PUBLICAÇÃO", s["kicker"]))
    story.append(Paragraph("Método 1 Dia<br/>de Cada Vez", s["title"]))
    story.append(Paragraph(
        "Pode publicar agora na Google Play e na App Store?<br/>"
        "<b>NÃO.</b> Existem bloqueadores. Produção não foi alterada.",
        s["sub"],
    ))
    story.append(Spacer(1, 4 * mm))
    story.append(kv([
        ("Data", "19 de setembro de 2026"),
        ("Versão / build", "1.0.0+1"),
        ("Package / Bundle", "com.metodo1dia.app"),
        ("Branch / HEAD", "finalizacao-metodo-1-dia-de-cada-vez / 23b1c0a"),
        ("Backup", "tag backup-auditoria-publicacao-completa-20260919"),
        ("Firebase", "metodo1dia-app (homolog = produção)"),
        ("Cobrança", "PAYMENTS_ENABLED=false"),
        ("Testes após correções", "30 unitários passaram"),
        ("E2E 3 perfis", "Não executado — sem contas de teste"),
    ], s))

    story.append(PageBreak())
    story.append(banner("CLASSIFICAÇÃO FINAL", RED, s))
    story.append(Spacer(1, 4 * mm))
    story.append(Paragraph(
        "STATUS DO APLICATIVO: <b>NÃO PRONTO — EXISTEM BLOQUEADORES</b>",
        s["body"],
    ))
    story.append(verdict("Android pronto para Play", False, "Legais no ar, Functions, E2E, listing e ícone 1024.", s))
    story.append(Spacer(1, 2 * mm))
    story.append(verdict("iOS pronto para App Store", False, "Windows + Firebase REPLACE_ME + sem IPA.", s))
    story.append(Spacer(1, 2 * mm))
    story.append(verdict("Pode publicar agora?", False, "Google Play e App Store: não.", s))

    story.append(Paragraph("O que impede a publicação (só bloqueadores)", s["h2"]))
    story.extend(bullets([
        "1. Hosting legal sujo: Termos no ar com e-mail pessoal; privacidade com 2 &lt;/html&gt;. Locais estão limpos. Ação: firebase deploy --only hosting --project metodo1dia-app.",
        "2. Functions: amandaChat/calorieVision HTTP 400 sem token (código antigo). accompanimentAi 404. Deploy do repo + OpenAI só no servidor.",
        "3. E2E Aluno / Personal / Admin não feito (sem e-mail/senha/UID).",
        "4. Lojas: sem screenshots, feature graphic, Data Safety, App Privacy, revisor. Falta assets/app_icon/app_icon.png.",
        "5. iOS: REPLACE_ME, ios/ fora do GitHub, IPA só no Mac.",
        "6. Assinaturas: estrutura OK; sandbox sem compra; produção proibida. Conteúdo digital exige Play Billing / Apple IAP — sem Pix/Stripe.",
        "7. Um Firebase só (homolog=prod). Não criamos segundo projeto.",
    ], s))

    story.append(banner("PRECISA CONTRATAR PROGRAMADOR?", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(Paragraph(
        "<b>Não é obrigatório contratar programador</b> para o estado atual do código. "
        "Não recomendo contratação por precaução. Falta operação e acesso, não um buraco de arquitetura.",
        s["body"],
    ))
    story.append(grid(
        ["Tarefa", "Programador?"],
        [
            ["Deploy Hosting legal", "Não — quem tem o Firebase"],
            ["Deploy Functions + OpenAI no servidor", "Não. Se não souber CLI, 1 sessão guiada"],
            ["3 contas e teste no celular", "Não"],
            ["Listing Play / Data Safety", "Não (Data Safety com jurídico)"],
            ["PNG 1024 da loja", "Não"],
            ["IPA / TestFlight", "Não necessariamente. Precisa Mac + Xcode + Apple"],
            ["Sandbox RevenueCat", "Não — testers e chaves no build"],
        ],
        s, [118 * mm, 60 * mm],
    ))
    story.append(Spacer(1, 2 * mm))
    story.append(Paragraph(
        "Bloqueador de equipamento, não de contratação: IPA no macOS. "
        "Sem Mac, iOS não sai deste Windows (Mac próprio, conhecido ou CI tipo Codemagic).",
        s["body"],
    ))

    story.append(PageBreak())
    story.append(banner("ANDROID · iOS · FIREBASE · SEGURANÇA", PURPLE, s))
    story.append(Paragraph("Android", s["h2"]))
    story.append(grid(
        ["Item", "Achado"],
        [
            ["ID / versão", "com.metodo1dia.app · 1.0.0+1"],
            ["SDK", "min 23 · target/compile 36 · R8 ligado"],
            ["Keystore", "Local, gitignored. Sem ele a Play recusa."],
            ["Ícone loja 1024", "Falta assets/app_icon/app_icon.png"],
            ["AAB nesta auditoria", "Não gerado — bloqueadores 1–4 permanecem"],
        ],
        s, [48 * mm, 130 * mm],
    ))
    story.append(Paragraph("iOS", s["h2"]))
    story.append(grid(
        ["Item", "Achado"],
        [
            ["Bundle", "com.metodo1dia.app"],
            ["Firebase", "REPLACE_ME em firebase_options.dart"],
            ["Pasta ios/", "Quase toda só local — não está no GitHub"],
            ["IPA / TestFlight / Store", "Impossível neste Windows"],
        ],
        s, [48 * mm, 130 * mm],
    ))
    story.append(Paragraph("Firebase", s["h2"]))
    story.append(grid(
        ["Superfície", "Achado"],
        [
            ["Auth", "E-mail/senha, reset, disabled → sign-out (código)"],
            ["Firestore", "Catch-all deny. Sem allow-true. Admin = admins/{uid}"],
            ["Storage", "Auth + imagem + tamanho. /public leitura aberta"],
            ["Functions no ar", "amandaChat, calorieVision, getContentUrl, getVideoUrl, redeemCoupon + 3 triggers. Sem accompanimentAi"],
            ["App Check", "Cliente on; ENFORCE_APP_CHECK off"],
        ],
        s, [40 * mm, 138 * mm],
    ))
    story.append(Paragraph("Segurança", s["h2"]))
    story.append(grid(
        ["Tema", "Resultado"],
        [
            ["Secrets no git", "Nenhum .env, service account ou keystore versionado"],
            ["OpenAI no app", "Não"],
            ["Guest / debug / cobrança", "Tudo false (teste)"],
            ["Functions no ar", "POST sem token = 400 (não 401)"],
            ["subscriptions rule", "Qualquer Personal lê qualquer doc — não alterada"],
        ],
        s, [48 * mm, 130 * mm],
    ))

    story.append(banner("PERFIS · ANAMNESE · MÍDIA · PLANOS · LGPD", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(Paragraph(
        "Aluno não acessa /admin. Personal não acessa o painel técnico. "
        "Admin só com admins/{uid}. Cadastro público sempre aluno. "
        "Logout em Perfil, Configurações, Admin e Painel da Personal. "
        "E2E desses fatos: não executado.",
        s["body"],
    ))
    story.append(grid(
        ["Módulo", "Código", "Aparelho"],
        [
            ["Anamnese pt_anamnesis", "CRUD + rules por vínculo", "Não testado"],
            ["3 Shorts no seed", "Parser YouTube PASSOU", "Play nativo não revalidado"],
            ["Áudios", "Asset / Storage / getContentUrl + erros amigáveis", "Nenhum áudio tocado"],
            ["CMS Personal", "Vídeos, fotos, textos, alunos, Quem sou eu", "Sem login Personal"],
            ["Apostilas write", "Só Admin (rule). UI esconde FAB da Personal", "—"],
            ["Planos", "7 dias / mensal / trimestral / anual em breve", "Sem compra sandbox"],
            ["LGPD local", "HTML + exclusão EXCLUIR + suporte oficial", "Hosting no ar FALHOU"],
        ],
        s, [48 * mm, 70 * mm, 60 * mm],
    ))
    story.append(Spacer(1, 2 * mm))
    story.append(Paragraph(
        "Preços fallback em AppConstants — não definitivos. Com a loja ligada, o preço da Play/Apple manda. "
        "Conteúdo digital no app: obrigatório Play Billing e Apple IAP. Sem checkout externo.",
        s["body"],
    ))

    story.append(PageBreak())
    story.append(banner("CORREÇÕES · TESTES · ARQUIVOS", PURPLE, s))
    story.append(Paragraph("Corrigido nesta auditoria (só local)", s["h2"]))
    story.append(grid(
        ["Arquivo", "Motivo"],
        [
            ["splash_screen.dart", "Guest residual só vale se enableGuestMode=true"],
            ["ebooks_admin_screen.dart", "Personal consulta apostilas; não publica (rule Admin)"],
            ["personal_cms_hub_screen.dart", "Atalho Quem sou eu para a tela já existente"],
        ],
        s, [70 * mm, 108 * mm],
    ))
    story.append(Paragraph("Testes (19/09/2026, Windows)", s["h2"]))
    story.append(grid(
        ["Suite", "Resultado"],
        [
            ["etapa6 + 7 + 8 + Shorts + YouTube + planos", "30 passaram após as correções"],
            ["GET privacidade/termos no ar", "200 com conteúdo antigo"],
            ["POST Functions sem token", "400 / 400 / 404"],
            ["Fluxos aluno/personal/admin no aparelho", "Não executados"],
            ["flutter clean / AAB / IPA", "Não — não mudaria o veredito de loja"],
        ],
        s, [88 * mm, 90 * mm],
    ))
    story.append(Paragraph(
        "Admin: números do dashboard são placeholder; push e algumas abas são stub. "
        "79 pacotes com update disponível — não atualizados. Working tree sujo de homolog.",
        s["body"],
    ))

    story.append(banner("VEREDITO", RED, s))
    story.append(Spacer(1, 3 * mm))
    story.append(Paragraph(
        "Não publique agora na Google Play nem na App Store. "
        "Feche os 7 bloqueadores — a maior parte sem contratar programador — "
        "e só então gere AAB/IPA e envie para revisão.",
        s["body"],
    ))
    story.append(Spacer(1, 4 * mm))
    story.append(Paragraph(
        "Markdown: docs/AUDITORIA_FINAL_PUBLICACAO_METODO_1_DIA.md",
        s["footer"],
    ))

    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
    return OUT


if __name__ == "__main__":
    path = build()
    print(path)
    print(f"bytes={path.stat().st_size}")
