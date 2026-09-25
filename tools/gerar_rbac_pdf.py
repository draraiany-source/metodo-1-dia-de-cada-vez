# -*- coding: utf-8 -*-
"""PDF — teste dos 3 perfis (Aluno, Personal, Admin)."""

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
OUT = ROOT / "RBAC_TESTE_PERFIS_METODO_1_DIA.pdf"

PINK = HexColor("#E85A9B")
LILAC = HexColor("#B57BFF")
PURPLE = HexColor("#7B2CBF")
BG = HexColor("#141414")
SURFACE = HexColor("#1E1E22")
CARD = HexColor("#2A2A30")
TEXT = HexColor("#F5F5F7")
MUTED = HexColor("#C8C4D0")
RED = HexColor("#FF4D6D")
ORANGE = HexColor("#FF9F43")
GREEN = HexColor("#3DDC97")
LINE = HexColor("#3A3A44")


def register_fonts() -> None:
    fonts = Path(r"C:\Windows\Fonts")
    regular = fonts / "segoeui.ttf"
    bold = fonts / "segoeuib.ttf"
    if not regular.exists():
        regular = fonts / "arial.ttf"
        bold = fonts / "arialbd.ttf"
    pdfmetrics.registerFont(TTFont("AppSans", str(regular)))
    pdfmetrics.registerFont(TTFont("AppSans-Bold", str(bold)))


def styles() -> dict[str, ParagraphStyle]:
    base = getSampleStyleSheet()
    return {
        "kicker": ParagraphStyle(
            "kicker", parent=base["Normal"], fontName="AppSans-Bold",
            fontSize=10, textColor=PINK, alignment=TA_CENTER, spaceAfter=8,
        ),
        "title": ParagraphStyle(
            "title", parent=base["Normal"], fontName="AppSans-Bold",
            fontSize=24, leading=30, textColor=TEXT, alignment=TA_CENTER,
            spaceAfter=10,
        ),
        "sub": ParagraphStyle(
            "sub", parent=base["Normal"], fontName="AppSans",
            fontSize=11, leading=16, textColor=MUTED, alignment=TA_CENTER,
            spaceAfter=6,
        ),
        "h1": ParagraphStyle(
            "h1", parent=base["Normal"], fontName="AppSans-Bold",
            fontSize=15, leading=20, textColor=TEXT, spaceBefore=12, spaceAfter=7,
        ),
        "h2": ParagraphStyle(
            "h2", parent=base["Normal"], fontName="AppSans-Bold",
            fontSize=12, leading=16, textColor=LILAC, spaceBefore=10, spaceAfter=5,
        ),
        "body": ParagraphStyle(
            "body", parent=base["Normal"], fontName="AppSans",
            fontSize=9.4, leading=13.4, textColor=TEXT, alignment=TA_JUSTIFY,
            spaceAfter=6,
        ),
        "bullet": ParagraphStyle(
            "bullet", parent=base["Normal"], fontName="AppSans",
            fontSize=9.2, leading=13, textColor=TEXT, leftIndent=6, spaceAfter=3,
        ),
        "cell": ParagraphStyle(
            "cell", parent=base["Normal"], fontName="AppSans",
            fontSize=7.8, leading=10.6, textColor=TEXT,
        ),
        "cell_b": ParagraphStyle(
            "cell_b", parent=base["Normal"], fontName="AppSans-Bold",
            fontSize=7.8, leading=10.6, textColor=TEXT,
        ),
        "head": ParagraphStyle(
            "head", parent=base["Normal"], fontName="AppSans-Bold",
            fontSize=8, leading=10.5, textColor=TEXT,
        ),
        "badge": ParagraphStyle(
            "badge", parent=base["Normal"], fontName="AppSans-Bold",
            fontSize=10, leading=14, textColor=TEXT, alignment=TA_CENTER,
        ),
        "check": ParagraphStyle(
            "check", parent=base["Normal"], fontName="AppSans",
            fontSize=9.5, leading=14, textColor=TEXT, leftIndent=4, spaceAfter=2,
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
    canvas.drawString(16 * mm, 6, "Método 1 Dia de Cada Vez — RBAC / teste de perfis")
    canvas.drawRightString(w - 16 * mm, 6, f"Página {doc.page}")
    canvas.restoreState()


def banner(title: str, color, s) -> Table:
    t = Table([[Paragraph(title, s["badge"])]], colWidths=[178 * mm])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), color),
        ("LEFTPADDING", (0, 0), (-1, -1), 10),
        ("RIGHTPADDING", (0, 0), (-1, -1), 10),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))
    return t


def table(headers, rows, s, widths) -> Table:
    head = [Paragraph(h, s["head"]) for h in headers]
    body = [[Paragraph(c, s["cell"]) for c in row] for row in rows]
    t = Table([head, *body], colWidths=widths, repeatRows=1)
    style = [
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE),
        ("BOX", (0, 0), (-1, -1), 0.4, LINE),
        ("INNERGRID", (0, 0), (-1, -1), 0.25, LINE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 4),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]
    for i in range(1, len(body) + 1):
        style.append(("BACKGROUND", (0, i), (-1, i), SURFACE if i % 2 else CARD))
    t.setStyle(TableStyle(style))
    return t


def bullets(items, s):
    return [Paragraph(f"• {item}", s["bullet"]) for item in items]


def build() -> Path:
    register_fonts()
    s = styles()
    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=A4,
        leftMargin=16 * mm,
        rightMargin=16 * mm,
        topMargin=16 * mm,
        bottomMargin=16 * mm,
        title="RBAC — Teste dos 3 perfis — Método 1 Dia de Cada Vez",
        author="Auditoria técnica",
    )
    story = []

    story.append(Spacer(1, 22 * mm))
    story.append(Paragraph("TESTE DE PERFIS / RBAC", s["kicker"]))
    story.append(Paragraph("Aluno · Personal · Administrador", s["title"]))
    story.append(Paragraph(
        "Método 1 Dia de Cada Vez<br/>"
        "Procedimento seguro — sem abrir rules, sem debug e sem bypass de autenticação.",
        s["sub"],
    ))
    story.append(Spacer(1, 6 * mm))
    story.append(table(
        ["Item", "Status"],
        [
            ["Data", "18 de setembro de 2026"],
            ["Projeto Firebase", "metodo1dia-app (CLI autenticado)"],
            ["Rules alteradas", "Não"],
            ["Modo debug / guest / bypass", "Não"],
            ["Contas de teste criadas nesta sessão", "Não — UID pendente no Console"],
            ["RBAC no código e nas rules", "Modelo correto"],
            ["Veredito de teste real", "PENDÊNCIAS até criar as 3 contas e anotar os UIDs"],
        ],
        s,
        [70 * mm, 108 * mm],
    ))

    story.append(PageBreak())
    story.append(Paragraph("1. Como o projeto define os papéis", s["h1"]))
    story.append(Paragraph(
        "Não há custom claims. A autorização real está no Firestore. "
        "Flags no documento users sozinhas não bastam para Admin Técnico.",
        s["body"],
    ))
    story.append(table(
        ["Papel", "users.role", "Flags", "Fonte de verdade no servidor"],
        [
            [
                "Aluno",
                "student",
                "isAdmin false · isPersonalTrainer false",
                "Cadastro público sempre nasce aluno. Create bloqueia flags privilegiadas.",
            ],
            [
                "Personal",
                "trainer",
                "isPersonalTrainer true",
                "Campo privilegiado em users/{uid}. Cliente comum não grava (noPrivilegedFields).",
            ],
            [
                "Admin Técnico",
                "technical_admin",
                "isAdmin true e isPersonalTrainer true",
                "Coleção admins/{uid}. Sem esse documento o app não eleva, mesmo com isAdmin no perfil.",
            ],
        ],
        s,
        [32 * mm, 32 * mm, 48 * mm, 66 * mm],
    ))
    story.append(Paragraph("Arquivos", s["h2"]))
    story.extend(bullets([
        "lib/core/auth/user_role.dart — enum, resolveUserRole, RolePermissions, whitelist Personal.",
        "lib/features/auth/data/auth_repository.dart (~126–154) — lê admins/{uid} no login.",
        "firebase/firestore.rules — isAdmin(), isPersonalTrainer(), noPrivilegedFields, catch-all deny.",
        "lib/features/admin/data/roles_admin_repository.dart — setUserRole / createUser.",
        "functions/src/index.js — adminManageUser (só quem já está em admins/{uid}).",
        "lib/core/router/app_router.dart — redirect de /admin, /painel-personal e /personal-trainer/*.",
    ], s))

    story.append(Paragraph("2. Onde a informação fica", s["h1"]))
    story.extend(bullets([
        "Firestore users/{uid} — perfil, role, isPersonalTrainer, isAdmin (espelho).",
        "Firestore admins/{uid} — membership canônica do Admin Técnico.",
        "Não usa custom claims.",
        "Não existe coleção staff separada. Staff = admin OU users.isPersonalTrainer == true.",
        "O primeiro Admin não pode ser criado pelo app. Bootstrap: Console Firebase / Admin SDK.",
    ], s))

    story.append(Paragraph("3. Procedimento seguro para as 3 contas", s["h1"]))
    story.append(Paragraph(
        "E-mails sugeridos (complete o domínio se preferir outro): "
        "teste.aluno@metodo1dia.app · teste.personal@metodo1dia.app · "
        "teste.admin@metodo1dia.app. Senhas só no Console. Não gravar no Git.",
        s["body"],
    ))
    story.append(Paragraph("Caminho A — já existe um Admin Técnico", s["h2"]))
    story.extend(bullets([
        "Entrar com a conta Admin existente.",
        "Abrir Painel Técnico → Usuários e papéis.",
        "Criar as 3 contas pelo fluxo oficial (Cloud Function adminManageUser).",
        "Aluno = student. Personal = trainer. Admin = technical_admin + admins/{uid}.",
        "Não alterar nenhuma outra conta.",
    ], s))
    story.append(Paragraph("Caminho B — bootstrap (ainda não há Admin)", s["h2"]))
    story.extend(bullets([
        "Authentication → Users → Add user: criar as 3 contas e-mail/senha e anotar o UID.",
        "Firestore users/{uid-aluno}: role student, isAdmin false, isPersonalTrainer false.",
        "Firestore users/{uid-personal}: role trainer, isAdmin false, isPersonalTrainer true.",
        "Firestore users/{uid-admin}: role technical_admin, isAdmin true, isPersonalTrainer true.",
        "Obrigatório: criar admins/{uid-admin} com { uid, role: technical_admin }.",
        "Aluno não promover. Personal só a conta de teste Personal. Admin só a conta de teste Admin.",
    ], s))
    story.append(Paragraph(
        "Nesta sessão as contas não foram criadas. UIDs só existem depois do Console.",
        s["body"],
    ))

    story.append(Paragraph("4. Telas que cada perfil pode acessar", s["h1"]))
    story.append(table(
        ["Perfil", "Pode", "Não pode"],
        [
            [
                "Aluno",
                "Login, home, treinos, hidratação, alimentação/IA, vídeos, áudios, perfil, desafio, consultoria/anamnese próprias, logout.",
                "/admin, /painel-personal, gestão /personal-trainer/*. Em /personal-trainer vê a área do aluno, não o dashboard da Personal.",
            ],
            [
                "Personal",
                "Login, dashboard Personal, alunos vinculados, anamnese, agenda, inbox, /painel-personal, whitelist /admin/videos, ebooks, áudios, Amanda, Lily.",
                "/admin (painel técnico), /admin/users, cupons, criar/bloquear Admin, alterar rules.",
            ],
            [
                "Admin",
                "Tudo da Personal + /admin, usuários e papéis, cupons, catálogo, configurações administrativas, logout.",
                "Promover a si mesma para baixo. Bloquear a própria conta.",
            ],
        ],
        s,
        [32 * mm, 73 * mm, 73 * mm],
    ))

    story.append(Spacer(1, 5 * mm))
    story.append(banner("5. Checklist ALUNO", GREEN, s))
    story.append(Spacer(1, 3 * mm))
    for item in [
        "[ ] login",
        "[ ] home",
        "[ ] treinos",
        "[ ] hidratação",
        "[ ] alimentação/IA",
        "[ ] vídeos",
        "[ ] áudios",
        "[ ] perfil",
        "[ ] não acessa Personal (dashboard / CMS)",
        "[ ] não acessa Admin (/admin)",
        "[ ] logout",
    ]:
        story.append(Paragraph(item, s["check"]))

    story.append(Spacer(1, 4 * mm))
    story.append(banner("6. Checklist PERSONAL", ORANGE, s))
    story.append(Spacer(1, 3 * mm))
    for item in [
        "[ ] login",
        "[ ] área Personal",
        "[ ] alunos autorizados",
        "[ ] anamnese",
        "[ ] agenda",
        "[ ] conteúdo permitido (CMS / vídeos / Amanda)",
        "[ ] não acessa funções exclusivas de Admin (/admin, usuários, cupons)",
        "[ ] logout",
    ]:
        story.append(Paragraph(item, s["check"]))

    story.append(Spacer(1, 4 * mm))
    story.append(banner("7. Checklist ADMIN", PINK, s))
    story.append(Spacer(1, 3 * mm))
    for item in [
        "[ ] login",
        "[ ] painel administrativo",
        "[ ] gerenciamento permitido",
        "[ ] usuários",
        "[ ] conteúdos",
        "[ ] configurações administrativas",
        "[ ] logout",
    ]:
        story.append(Paragraph(item, s["check"]))

    story.append(Spacer(1, 6 * mm))
    story.append(banner("8. VEREDITO RBAC — PENDÊNCIAS", RED, s))
    story.append(Spacer(1, 3 * mm))
    story.append(Paragraph(
        "O modelo no código e nas rules está correto: aluno não se promove; "
        "Personal e Admin só via Admin Técnico, Console ou Admin SDK. "
        "As 3 contas de teste ainda não existem com UID confirmado. "
        "O teste real dos checklists fica pendente até criar as contas e anotar os UIDs.",
        s["body"],
    ))
    story.append(table(
        ["Conta", "Onde configurar", "UID", "Papel"],
        [
            ["teste.aluno@...", "Auth + users/{uid}", "PENDENTE", "Aluno / student"],
            ["teste.personal@...", "Auth + users.isPersonalTrainer", "PENDENTE", "Personal / trainer"],
            ["teste.admin@...", "Auth + users + admins/{uid}", "PENDENTE", "Admin Técnico"],
        ],
        s,
        [42 * mm, 56 * mm, 32 * mm, 48 * mm],
    ))

    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
    return OUT


if __name__ == "__main__":
    path = build()
    desktop = Path.home() / "Desktop" / path.name
    desktop.write_bytes(path.read_bytes())
    print(path)
    print(desktop)
    print(path.stat().st_size)
