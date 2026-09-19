# -*- coding: utf-8 -*-
"""Gera docs/AUDITORIA_FINAL_METODO_1_DIA.pdf — evidência real da auditoria 19/09/2026."""

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
OUT = ROOT / "docs" / "AUDITORIA_FINAL_METODO_1_DIA.pdf"

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
        "cover_kicker": ParagraphStyle(
            "cover_kicker",
            parent=base["Normal"],
            fontName=bold,
            fontSize=10,
            textColor=PINK,
            alignment=TA_CENTER,
            spaceAfter=8,
        ),
        "cover_title": ParagraphStyle(
            "cover_title",
            parent=base["Normal"],
            fontName=bold,
            fontSize=26,
            leading=32,
            textColor=TEXT,
            alignment=TA_CENTER,
            spaceAfter=10,
        ),
        "cover_sub": ParagraphStyle(
            "cover_sub",
            parent=base["Normal"],
            fontName=regular,
            fontSize=12,
            leading=17,
            textColor=MUTED,
            alignment=TA_CENTER,
            spaceAfter=6,
        ),
        "h1": ParagraphStyle(
            "h1",
            parent=base["Normal"],
            fontName=bold,
            fontSize=16,
            leading=21,
            textColor=TEXT,
            spaceBefore=14,
            spaceAfter=8,
        ),
        "h2": ParagraphStyle(
            "h2",
            parent=base["Normal"],
            fontName=bold,
            fontSize=13,
            leading=18,
            textColor=LILAC,
            spaceBefore=12,
            spaceAfter=6,
        ),
        "body": ParagraphStyle(
            "body",
            parent=base["Normal"],
            fontName=regular,
            fontSize=9.5,
            leading=13.5,
            textColor=TEXT,
            alignment=TA_JUSTIFY,
            spaceAfter=6,
        ),
        "small": ParagraphStyle(
            "small",
            parent=base["Normal"],
            fontName=regular,
            fontSize=8.4,
            leading=11.6,
            textColor=TEXT,
            alignment=TA_LEFT,
            spaceAfter=4,
        ),
        "muted": ParagraphStyle(
            "muted",
            parent=base["Normal"],
            fontName=regular,
            fontSize=8.4,
            leading=11.6,
            textColor=MUTED,
        ),
        "cell": ParagraphStyle(
            "cell",
            parent=base["Normal"],
            fontName=regular,
            fontSize=7.4,
            leading=10.2,
            textColor=TEXT,
        ),
        "cell_b": ParagraphStyle(
            "cell_b",
            parent=base["Normal"],
            fontName=bold,
            fontSize=7.4,
            leading=10.2,
            textColor=TEXT,
        ),
        "head": ParagraphStyle(
            "head",
            parent=base["Normal"],
            fontName=bold,
            fontSize=7.6,
            leading=10.2,
            textColor=TEXT,
        ),
        "badge": ParagraphStyle(
            "badge",
            parent=base["Normal"],
            fontName=bold,
            fontSize=10,
            leading=14,
            textColor=TEXT,
            alignment=TA_CENTER,
        ),
        "footer": ParagraphStyle(
            "footer",
            parent=base["Normal"],
            fontName=regular,
            fontSize=8,
            textColor=MUTED,
            alignment=TA_CENTER,
        ),
        "bullet": ParagraphStyle(
            "bullet",
            parent=base["Normal"],
            fontName=regular,
            fontSize=9.0,
            leading=12.8,
            textColor=TEXT,
            leftIndent=8,
            spaceAfter=3,
        ),
        "feat_title": ParagraphStyle(
            "feat_title",
            parent=base["Normal"],
            fontName=bold,
            fontSize=10,
            leading=13,
            textColor=PINK,
            spaceBefore=8,
            spaceAfter=3,
        ),
        "verdict": ParagraphStyle(
            "verdict",
            parent=base["Normal"],
            fontName=bold,
            fontSize=11,
            leading=15,
            textColor=TEXT,
            alignment=TA_CENTER,
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
    canvas.drawString(16 * mm, 6, "Método 1 Dia de Cada Vez — Auditoria Final para Publicação")
    canvas.drawRightString(w - 16 * mm, 6, f"Página {doc.page}")
    canvas.restoreState()


def section_banner(title: str, color, s: dict) -> Table:
    data = [[Paragraph(title, s["badge"])]]
    t = Table(data, colWidths=[178 * mm])
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), color),
                ("LEFTPADDING", (0, 0), (-1, -1), 10),
                ("RIGHTPADDING", (0, 0), (-1, -1), 10),
                ("TOPPADDING", (0, 0), (-1, -1), 8),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ]
        )
    )
    return t


def kv_table(rows: list[tuple[str, str]], s: dict, w1: float = 48, w2: float = 130) -> Table:
    data = [[Paragraph(k, s["cell_b"]), Paragraph(v, s["cell"])] for k, v in rows]
    t = Table(data, colWidths=[w1 * mm, w2 * mm])
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), SURFACE),
                ("BOX", (0, 0), (-1, -1), 0.4, LINE),
                ("INNERGRID", (0, 0), (-1, -1), 0.3, LINE),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
            ]
        )
    )
    return t


def issue_table(headers: list[str], rows: list[list[str]], s: dict, widths: list[float]) -> Table:
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


def verdict_row(label: str, sim: bool, note: str, s: dict) -> Table:
    color = GREEN if sim else RED
    value = "SIM" if sim else "NÃO"
    data = [
        [
            Paragraph(f"<b>{label}</b>", s["cell_b"]),
            Paragraph(value, s["badge"]),
            Paragraph(note, s["cell"]),
        ]
    ]
    t = Table(data, colWidths=[62 * mm, 22 * mm, 94 * mm])
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (0, 0), SURFACE),
                ("BACKGROUND", (1, 0), (1, 0), color),
                ("BACKGROUND", (2, 0), (2, 0), SURFACE),
                ("BOX", (0, 0), (-1, -1), 0.4, LINE),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 6),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
            ]
        )
    )
    return t


def bullets(items: list[str], s: dict) -> list:
    return [Paragraph(f"• {item}", s["bullet"]) for item in items]


def feat_block(title: str, rows: list[tuple[str, str]], s: dict) -> list:
    return [
        Paragraph(title, s["feat_title"]),
        kv_table(rows, s, 42, 136),
        Spacer(1, 2 * mm),
    ]


def build() -> Path:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    regular, bold = register_fonts()
    s = styles(regular, bold)
    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=A4,
        leftMargin=16 * mm,
        rightMargin=16 * mm,
        topMargin=16 * mm,
        bottomMargin=16 * mm,
        title="Auditoria Final para Publicação — Método 1 Dia de Cada Vez",
        author="Auditoria técnica",
        subject="Relatório para desenvolvedor — 19/09/2026",
    )
    story: list = []

    # --- CAPA ---
    story.append(Spacer(1, 22 * mm))
    story.append(Paragraph("RELATÓRIO TÉCNICO PARA DESENVOLVEDOR", s["cover_kicker"]))
    story.append(Paragraph("Método 1 Dia<br/>de Cada Vez", s["cover_title"]))
    story.append(Paragraph("Auditoria Final para Publicação", s["cover_sub"]))
    story.append(
        Paragraph(
            "Somente o que foi encontrado e testado neste repositório.<br/>"
            "Nenhum item foi marcado PASSOU sem evidência de código, teste unitário ou sonda HTTP.<br/>"
            "Sem senhas, tokens, secrets ou chaves privadas.",
            s["cover_sub"],
        )
    )
    story.append(Spacer(1, 8 * mm))
    story.append(
        kv_table(
            [
                ("Data da auditoria", "19 de setembro de 2026"),
                ("Versão / build", "1.0.0+1 (pubspec.yaml)"),
                ("Branch", "finalizacao-metodo-1-dia-de-cada-vez (ahead do origin)"),
                ("Commit de referência", "23b1c0a (docs) / ccd3a51 (segurança)"),
                ("Backup", "tag backup-etapa-auditoria-final-20260919"),
                ("Projeto Firebase", "metodo1dia-app (único — homolog = produção)"),
                ("Package / Bundle", "com.metodo1dia.app"),
                ("Cobrança real", "DESLIGADA (PAYMENTS_ENABLED=false)"),
                ("Guest / debug premium", "DESLIGADOS"),
                ("Veredito geral", "NÃO APTO para Google Play nem TestFlight"),
            ],
            s,
        )
    )

    # --- RESUMO ---
    story.append(PageBreak())
    story.append(section_banner("1. RESUMO EXECUTIVO", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        Paragraph(
            "A base de produto (Flutter + Firebase + RBAC no código e nas rules) é sólida, "
            "mas o aplicativo <b>não está aprovado</b> para Google Play nem TestFlight. "
            "Login real dos 3 perfis não foi executado nesta máquina — sem e-mail, senha ou UID de teste. "
            "Portanto fluxos de aparelho constam PENDENTE ou FALHOU, nunca PASSOU.",
            s["body"],
        )
    )
    story.append(
        issue_table(
            ["Frente", "Situação auditada"],
            [
                [
                    "Situação geral",
                    "Código avançado; publicação bloqueada. Um Firebase só (homolog = prod). Sem AAB/IPA de loja.",
                ],
                [
                    "Módulos no código",
                    "Auth e-mail/senha, RBAC, logout, rules deny, exclusão de conta, legais locais, compressão de foto, rejeição de placeholder de calorias, guest/debug off em release.",
                ],
                [
                    "Pendências principais",
                    "E2E 3 perfis; Functions IA na nuvem sem Bearer (400) e accompanimentAi 404; Hosting legal antigo; OpenAI não confirmada; iOS REPLACE_ME; sandbox RC; listing das lojas.",
                ],
                ["Quantidade de bloqueadores", "8 bloqueadores de publicação (ver tabela geral e veredito)."],
                ["Android", "NÃO PRONTO — sem AAB de produção e sem listing Play."],
                ["iOS", "NÃO PRONTO — Firebase incompleto, ios/ quase ausente no GitHub, sem Mac/IPA."],
                [
                    "Segurança",
                    "NÃO APROVADA — Functions sem auth no ar; Termos com e-mail pessoal; App Check sem enforce.",
                ],
                [
                    "RBAC",
                    "Aprovado no código e nas rules (admins/{uid}). Não aprovado em E2E.",
                ],
                [
                    "Assinaturas",
                    "PAYMENTS_ENABLED=false. Sandbox não validado. Produção proibida.",
                ],
                [
                    "Integrações de IA",
                    "Cliente correto no repo; nuvem antiga/404; sem OpenAI confirmada. Não pronto.",
                ],
            ],
            s,
            [48 * mm, 130 * mm],
        )
    )

    # --- ARQUITETURA ---
    story.append(Spacer(1, 5 * mm))
    story.append(section_banner("2. ARQUITETURA ATUAL", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        issue_table(
            ["Camada", "Tecnologia", "Observação"],
            [
                ["App", "Flutter ≥3.19 / Dart ≥3.3 / Riverpod / go_router", "pubspec.yaml"],
                ["Auth", "Firebase Authentication (e-mail/senha)", "lib/features/auth/data/auth_repository.dart"],
                ["Banco", "Cloud Firestore", "firebase/firestore.rules — catch-all deny"],
                ["Arquivos", "Cloud Storage", "firebase/storage.rules — auth + image/* + 8 MB"],
                ["Backend", "Cloud Functions Gen-1, Node 22, us-central1", "functions/src/index.js"],
                ["Push", "FCM + notificações locais", "Não E2E nesta auditoria"],
                ["Qualidade", "Analytics, Crashlytics, App Check", "App Check sem ENFORCE_APP_CHECK"],
                ["Hosting", "metodo1dia-app.web.app", "Páginas legais DESATUALIZADAS no ar"],
                ["Pagamentos", "RevenueCat purchases_flutter 8.11.0", "PAYMENTS_ENABLED=false"],
                ["IA", "OpenAI só via Functions (gpt-4o-mini no código)", "Chave NÃO no cliente"],
                ["Mapas", "geolocator + flutter_map", "Google Maps SDK não usado; MAPS_API_KEY vazia"],
                ["Mídia", "just_audio, video_player/chewie, YouTube", "Play nativo não revalidado agora"],
                ["Assinatura Android", "key.properties + upload-keystore.jks", "Só local, gitignored — não versionar"],
            ],
            s,
            [36 * mm, 68 * mm, 74 * mm],
        )
    )

    # --- RBAC ---
    story.append(PageBreak())
    story.append(section_banner("3. PERFIS / RBAC", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        Paragraph(
            "Fonte: <b>lib/core/auth/user_role.dart</b>, <b>firebase/firestore.rules</b>, "
            "<b>lib/features/auth/data/auth_repository.dart</b>. "
            "Admin só se existir <b>admins/{uid}</b>. Flag órfã users.isAdmin não eleva. "
            "Personal = users.isPersonalTrainer == true. Caso contrário Aluno.",
            s["body"],
        )
    )
    story.append(
        issue_table(
            ["Perfil", "Permissões (RolePermissions + rules)", "Teste"],
            [
                [
                    "Aluno (student)",
                    "App do aluno; dono dos próprios docs; não escreve isAdmin/isPersonalTrainer/isPremium; /admin redireciona para /home.",
                    "Unitário etapa 8: aluno não é staff. E2E login: NÃO executado.",
                ],
                [
                    "Personal (trainer)",
                    "Central da Personal; CMS (vídeos, áudios, e-books, Amanda); alunos vinculados. Sem /admin técnico. Sem promover papéis.",
                    "Rotas kPersonalAllowedAdminPaths no código. E2E: NÃO executado.",
                ],
                [
                    "Admin Técnico",
                    "Painel /admin; criar/bloquear/ligar aluno; cupons; config crítica. Verdade em admins/{uid}.",
                    "Load exige doc em admins/{uid}. E2E: NÃO executado.",
                ],
            ],
            s,
            [32 * mm, 86 * mm, 60 * mm],
        )
    )
    story.append(Spacer(1, 3 * mm))
    story.append(
        Paragraph(
            "Login/logout: <b>lib/core/auth/session_sign_out.dart</b> (signOut + limpa sessão + context.go(login)). "
            "Tela de login com PopScope(canPop: false). Troca de contas: código prevê sessão limpa; "
            "não houve 3 logins consecutivos nesta auditoria — PENDENTE.",
            s["body"],
        )
    )

    # --- FUNCIONALIDADES ---
    story.append(section_banner("4. FUNCIONALIDADES", PURPLE, s))
    story.append(Spacer(1, 2 * mm))
    story.append(
        Paragraph(
            "Critério: PASSOU só com evidência. E2E de aparelho = não feito, exceto sondas HTTP das Functions e Hosting.",
            s["muted"],
        )
    )

    features = [
        (
            "Home",
            [
                ("Status", "PENDENTE E2E. Código com homeGreeting (evita “Olá, !”)."),
                ("Teste", "Unitário de greeting em etapa anterior. Não reaberto em aparelho agora."),
                ("Problema", "Saudação vazia existia; corrigida no código."),
                ("Correção", "lib/models/app_user.dart — homeGreeting."),
                ("Pendência", "Abrir Home logada nos 3 perfis."),
            ],
        ),
        (
            "Treinos",
            [
                ("Status", "PENDENTE E2E. Catálogo + persistência no código."),
                ("Teste", "Leitura de workout_history e rules. Sem treino concluído agora."),
                ("Problema", "Sem evidência de aparelho."),
                ("Correção", "Nenhuma nesta sessão (já existia)."),
                ("Pendência", "Fluxo aluno no aparelho."),
            ],
        ),
        (
            "Cronômetro",
            [
                ("Status", "PENDENTE E2E."),
                ("Teste", "Código: persistência ao concluir + PopScope em workout_timer_screen.dart."),
                ("Problema", "Não concluído em aparelho nesta auditoria."),
                ("Correção", "Aplicada na etapa da área do aluno (sessão anterior)."),
                ("Pendência", "Concluir treino e ver histórico."),
            ],
        ),
        (
            "Hidratação",
            [
                ("Status", "PENDENTE E2E."),
                ("Teste", "Meta unificada (custom vs 35 ml/kg) em test/aluno_area_fixes_test.dart quando presente."),
                ("Problema", "Sem registro de copos logada agora."),
                ("Correção", "Código da meta na etapa aluno."),
                ("Pendência", "Registrar copos com conta real."),
            ],
        ),
        (
            "Receitas",
            [
                ("Status", "PENDENTE E2E. CMS Personal + leitura aluna nas rules."),
                ("Teste", "Rules + código. Sem abrir receita agora."),
                ("Problema", "Sem E2E."),
                ("Correção", "Nenhuma nesta sessão."),
                ("Pendência", "Abrir receita e PDF se houver."),
            ],
        ),
        (
            "Desafio semanal",
            [
                ("Status", "PENDENTE E2E."),
                ("Teste", "Guard de dia futuro no código."),
                ("Problema", "Sem marcar dia hoje/futuro em aparelho."),
                ("Correção", "Guard aplicado na etapa aluno."),
                ("Pendência", "Marcar hoje; não marcar futuro."),
            ],
        ),
        (
            "Evolução",
            [
                ("Status", "PENDENTE E2E. Peso/medidas/fotos no código."),
                ("Teste", "Leitura de código/rules. Sem gravar medida agora."),
                ("Problema", "Sem E2E."),
                ("Correção", "Nenhuma nesta sessão."),
                ("Pendência", "Gravar e apagar medida com conta real."),
            ],
        ),
        (
            "Vídeos",
            [
                ("Status", "PARCIAL — não PASSOU."),
                ("Teste", "Seed de 3 Shorts (yt_34PHGKECMTY, yt_3T0HDPX4jkk, yt_zRSTnW3EMF8). Play iframe Cursor falhou (YouTube 153)."),
                ("Problema", "Player nativo não revalidado agora."),
                ("Correção", "Seed na etapa de conteúdo."),
                ("Pendência", "Play no aparelho + CMS."),
            ],
        ),
        (
            "Áudios",
            [
                ("Status", "PENDENTE E2E."),
                ("Teste", "just_audio + Storage audio_programs (leitura autenticada)."),
                ("Problema", "Play e lock-screen não testados agora."),
                ("Correção", "Nenhuma nesta sessão."),
                ("Pendência", "Play autenticado no aparelho."),
            ],
        ),
        (
            "Fotos",
            [
                ("Status", "PENDENTE E2E."),
                ("Teste", "Rules: users/{uid} auth + image/* + 8 MB. pt_photos privada por vínculo."),
                ("Problema", "Upload real não executado."),
                ("Correção", "Compressão 1024/quality 70 no scanner de calorias."),
                ("Pendência", "Upload perfil/progresso/refeição."),
            ],
        ),
        (
            "Quem Sou Eu",
            [
                ("Status", "PENDENTE E2E. amanda_profile / assets públicos de marca."),
                ("Teste", "Código CMS Personal/Admin."),
                ("Problema", "Sem salvar como Personal."),
                ("Correção", "Nenhuma nesta sessão."),
                ("Pendência", "Salvar texto/foto como Personal."),
            ],
        ),
        (
            "Anamnese",
            [
                ("Status", "PENDENTE E2E."),
                ("Teste", "Rules pt_anamnesis com acesso trainer/aluno vinculado. Não abriu rules."),
                ("Problema", "Fluxo completo não executado."),
                ("Correção", "CMS/anamnese em etapa anterior."),
                ("Pendência", "Preencher, reabrir, editar. Bloqueador se for vitrine."),
            ],
        ),
        (
            "Agenda",
            [
                ("Status", "PENDENTE E2E."),
                ("Teste", "pt_appointments no código. Google Calendar Function NÃO está no deploy."),
                ("Problema", "Calendário Google ausente na nuvem."),
                ("Correção", "Nenhuma (não inventar integração)."),
                ("Pendência", "Marcar horário; Calendar é extra."),
            ],
        ),
        (
            "Mensagens",
            [
                ("Status", "PENDENTE E2E."),
                ("Teste", "Rules: aluno/personal criam; delete só Admin."),
                ("Problema", "Exclusão de conta NÃO apaga pt_messages (documentado)."),
                ("Correção", "Purge limitado ao permitido em auth_repository."),
                ("Pendência", "Enviar/receber. Limpeza órfã = pós-lançamento/Admin."),
            ],
        ),
        (
            "IA (aluno — amandaChat)",
            [
                ("Status", "FALHOU na nuvem."),
                ("Teste", "curl 19/09/2026: POST sem token → HTTP 400 “message ausente” (auth ausente no código publicado)."),
                ("Problema", "Deploy antigo; OpenAI não confirmada. Código local devolve 503 sem chave."),
                ("Correção", "functions/src/index.js sem HTTP 200 falso; loading “Preparando resposta...”."),
                ("Pendência", "Deploy + chave no servidor + E2E autenticado."),
            ],
        ),
        (
            "Calorias por foto",
            [
                ("Status", "FALHOU na nuvem."),
                ("Teste", "curl 19/09/2026: calorieVision POST sem token → HTTP 400. Cliente rejeita 0 kcal / “Refeição”."),
                ("Problema", "Mesmo deploy antigo; sem OpenAI confirmada."),
                ("Correção", "calorie_vision_repository + compressão + cancelar + “Analisando sua refeição...”."),
                ("Pendência", "Deploy + OpenAI + foto real."),
            ],
        ),
        (
            "IA Personal / Assistente",
            [
                ("Status", "FALHOU."),
                ("Teste", "accompanimentAi → HTTP 404 (não implantada)."),
                ("Problema", "Function nova só no repo local."),
                ("Correção", "accompaniment_ai_repository sem resumo fictício; requirePersonalOrAdmin."),
                ("Pendência", "Primeiro deploy da Function."),
            ],
        ),
        (
            "Painel da Personal",
            [
                ("Status", "PASSOU rotas no código; FALHOU E2E."),
                ("Teste", "Redirect aluno → /home. Whitelist /admin/videos etc."),
                ("Problema", "Sem login Personal real."),
                ("Correção", "Guards no app_router.dart."),
                ("Pendência", "Login Personal + CMS."),
            ],
        ),
        (
            "Painel Admin",
            [
                ("Status", "PASSOU rotas + exigência admins/{uid}; FALHOU E2E."),
                ("Teste", "Unitário: /admin não está na whitelist da Personal."),
                ("Problema", "Sem UID admin de teste."),
                ("Correção", "isAdmin só após admins/{uid}."),
                ("Pendência", "Login Admin real."),
            ],
        ),
    ]
    for title, rows in features:
        story.extend(feat_block(title, rows, s))

    # --- FIREBASE ---
    story.append(PageBreak())
    story.append(section_banner("5. FIREBASE", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        issue_table(
            ["Superfície", "Achado", "Evidência"],
            [
                ["Authentication", "E-mail/senha, reset, disabled, too-many-requests.", "auth_repository.dart"],
                [
                    "Auth local falso",
                    "Bloqueado em release / init falho (allowLocalDevAuth).",
                    "FirebaseService + etapa 8",
                ],
                [
                    "Firestore",
                    "Catch-all if false; noPrivilegedFields.",
                    "firestore.rules + test/etapa8_seguranca_test.dart",
                ],
                ["Rules", "Não enfraquecidas nesta auditoria.", "firebase/firestore.rules"],
                [
                    "Storage",
                    "Auth + tipo + tamanho; /public leitura aberta (covers).",
                    "firebase/storage.rules",
                ],
                [
                    "Functions",
                    "amandaChat/calorieVision ativas SEM Bearer (400). accompanimentAi 404.",
                    "curl 19/09/2026 us-central1",
                ],
                [
                    "App Check",
                    "Play Integrity / DeviceCheck em release; Web pulado; ENFORCE_APP_CHECK off.",
                    "firebase_service.dart, auth_helpers.js",
                ],
                ["Ambientes", "Um projeto só — homolog = produção.", "metodo1dia-app"],
                ["iOS Firebase", "apiKey/appId = REPLACE_ME.", "lib/firebase_options.dart"],
                ["Segurança", "Cliente AIza… é chave pública — restringir no Cloud. Sem secrets no git.", "Não citar valor da chave"],
            ],
            s,
            [36 * mm, 72 * mm, 70 * mm],
        )
    )

    # --- ASSINATURAS ---
    story.append(Spacer(1, 5 * mm))
    story.append(section_banner("6. ASSINATURAS", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        issue_table(
            ["Item", "Status", "Nota"],
            [
                ["RevenueCat SDK", "PASSOU (dependência)", "purchases_flutter 8.11.0"],
                ["Entitlement", "PASSOU (código)", "premium"],
                ["Offerings", "PENDENTE painel", "default no app; console RC não validado"],
                [
                    "Planos",
                    "PASSOU (IDs no código)",
                    "metodo1dia_premium_mensal / _trimestral / _anual",
                ],
                ["Sandbox", "FALHOU", "Sem testers/chaves no build; sem compra real"],
                ["Restore purchases", "PASSOU código / FALHOU E2E", "Tela de planos"],
                ["Produção", "NÃO SE APLICA / PROIBIDO", "PAYMENTS_ENABLED=false"],
            ],
            s,
            [40 * mm, 52 * mm, 86 * mm],
        )
    )

    # --- SEGURANÇA ---
    story.append(Spacer(1, 5 * mm))
    story.append(section_banner("7. SEGURANÇA", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        Paragraph(
            "Nenhuma senha, token, service account, senha de keystore ou chave privada está neste PDF.",
            s["muted"],
        )
    )
    story.append(
        issue_table(
            ["Tema", "Achado", "Severidade"],
            [
                ["Functions sem auth (nuvem)", "POST anônimo chega no payload (400 por campo, não 401).", "BLOQUEADOR"],
                ["Termos no ar", "Cabeçalho com e-mail pessoal (Hosting antigo).", "BLOQUEADOR"],
                ["Privacidade no ar", "HTML duplicado (2 &lt;/html&gt;).", "BLOQUEADOR"],
                ["App Check", "Tokens opcionais; ENFORCE_APP_CHECK não definido.", "IMPORTANTE"],
                ["API keys Firebase", "Chave de cliente no app (padrão Firebase). Restringir no Cloud.", "IMPORTANTE"],
                ["Secrets no git", "OpenAI/RC secret/keystore não versionados. .env ausente.", "OK no repo"],
                ["Logs", "Sem senha/token/anamnese no debugPrint auditado.", "OK"],
                ["Guest / demo login", "Bloqueados em release (etapa 8).", "Corrigido"],
                ["Rule subscriptions", "Qualquer Personal lê qualquer doc — não alterada.", "IMPORTANTE"],
                ["Dados sensíveis", "Anamnese privada por vínculo. Exclusão não apaga pt_messages.", "IMPORTANTE"],
            ],
            s,
            [48 * mm, 90 * mm, 40 * mm],
        )
    )

    # --- PRIVACIDADE ---
    story.append(PageBreak())
    story.append(section_banner("8. PRIVACIDADE / DOCUMENTOS", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        issue_table(
            ["Documento", "Local / teste", "No ar 19/09/2026"],
            [
                [
                    "Política de Privacidade",
                    "public/privacidade.html limpa (test/etapa7_legal_test.dart PASSOU)",
                    "HTTP 200 — ainda duplicada",
                ],
                [
                    "Termos de Uso",
                    "public/termos.html limpo (teste PASSOU)",
                    "HTTP 200 — ainda com e-mail pessoal",
                ],
                ["Suporte", "1diadecadavezsuporte@gmail.com no app", "Igual"],
                ["Exclusão de conta", "Configurações + confirmação EXCLUIR (código)", "E2E PENDENTE"],
                ["Exclusão pontual", "mailto suporte; sem wipe de pt_messages", "Documentado"],
                ["Consentimentos", "Checkbox no cadastro", "Não E2E agora"],
                ["Google Play Data Safety", "Não preenchido na Console", "PENDENTE — bloqueia Play"],
                ["App Store App Privacy", "Não preenchido", "PENDENTE — bloqueia Store"],
            ],
            s,
            [44 * mm, 72 * mm, 62 * mm],
        )
    )
    story.append(Spacer(1, 2 * mm))
    story.append(
        Paragraph(
            "Ação de Hosting (não é publicar o app): "
            "<b>firebase deploy --only hosting --project metodo1dia-app</b>",
            s["body"],
        )
    )

    # --- ANDROID ---
    story.append(section_banner("9. ANDROID", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        issue_table(
            ["Item", "Achado"],
            [
                ["Configuração", "applicationId com.metodo1dia.app; minSdk 23; target/compile 36; 1.0.0+1"],
                ["Build", "R8/minify release ligado. Ícones mipmap presentes."],
                ["AAB", "NÃO PRONTO para loja. Falta PNG 1024 em assets/app_icon/app_icon.png."],
                ["Keystore", "Existe localmente (gitignored). Não versionar."],
                [
                    "Google Play",
                    "Faltam listing, screenshots, feature graphic, Data Safety, conta revisor, Hosting legal, Functions.",
                ],
                ["Bloqueadores", "E2E, legal no ar, Functions, material de loja, IAP off (não vender como ativo)."],
            ],
            s,
            [40 * mm, 138 * mm],
        )
    )
    story.append(Spacer(1, 2 * mm))
    story.append(
        Paragraph(
            "Comando técnico quando autorizado (não enviar à Play): "
            "flutter build appbundle --release com SUPPORT_EMAIL / PRIVACY_POLICY_URL / TERMS_URL. "
            "Não usar PAYMENTS_ENABLED=true.",
            s["small"],
        )
    )

    # --- IOS ---
    story.append(Spacer(1, 4 * mm))
    story.append(section_banner("10. iOS", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        issue_table(
            ["Item", "Achado"],
            [
                ["Configuração", "Bundle com.metodo1dia.app. Firebase iOS REPLACE_ME."],
                ["Build", "IPA impossível neste Windows. Pasta ios/ em grande parte fora do GitHub."],
                ["TestFlight", "NÃO — sem IPA, sem Firebase iOS, sem Mac."],
                ["App Store", "NÃO — depende de TestFlight + App Privacy + revisão."],
                ["Info.plist", "NSMicrophoneUsageDescription removido (sem gravação no código)."],
                ["Bloqueadores", "REPLACE_ME, ios/ no git, Mac/Xcode, App Privacy, E2E iPhone."],
            ],
            s,
            [40 * mm, 138 * mm],
        )
    )

    # --- TABELA GERAL ---
    story.append(PageBreak())
    story.append(section_banner("11. TABELA GERAL", PURPLE, s))
    story.append(Spacer(1, 2 * mm))
    story.append(
        Paragraph(
            "Status: PASSOU · FALHOU · PENDENTE · NÃO SE APLICA. "
            "Severidade: BLOQUEADOR · IMPORTANTE · PÓS-LANÇAMENTO.",
            s["muted"],
        )
    )
    story.append(
        issue_table(
            ["ITEM", "STATUS", "SEVERIDADE", "BLOQUEIA?", "AÇÃO NECESSÁRIA"],
            [
                ["Aluno E2E", "FALHOU", "BLOQUEADOR", "Sim", "Contas + aparelho"],
                ["Personal E2E", "FALHOU", "BLOQUEADOR", "Sim", "Idem"],
                ["Admin E2E", "FALHOU", "BLOQUEADOR", "Sim", "Idem + admins/{uid}"],
                ["RBAC código/rules", "PASSOU", "—", "Não", "Manter; testar E2E"],
                ["Logout / troca", "PENDENTE", "BLOQUEADOR", "Sim", "3 trocas de conta"],
                ["Treinos", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "QA aparelho"],
                ["Cronômetro", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "Concluir e persistir"],
                ["Hidratação", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "QA"],
                ["Receitas", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "QA"],
                ["Desafio", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "QA"],
                ["Evolução", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "QA"],
                ["Vídeos", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "Play no aparelho"],
                ["Áudios", "PENDENTE", "IMPORTANTE", "Sim p/ loja", "Play"],
                ["Fotos Storage", "PENDENTE", "IMPORTANTE", "Não isolado", "Upload"],
                ["Quem Sou Eu", "PENDENTE", "IMPORTANTE", "Não isolado", "Salvar CMS"],
                ["Anamnese", "PENDENTE", "BLOQUEADOR*", "Se for vitrine", "Fluxo completo"],
                ["Agenda", "PENDENTE", "IMPORTANTE", "Não isolado", "Horário"],
                ["Mensagens", "PENDENTE", "IMPORTANTE", "Não isolado", "Chat"],
                ["IA aluno", "FALHOU", "BLOQUEADOR", "Se for vitrine", "Deploy + OpenAI"],
                ["Foto/calorias", "FALHOU", "BLOQUEADOR", "Se for vitrine", "Deploy + OpenAI"],
                ["Painel Personal", "PENDENTE", "BLOQUEADOR", "Sim", "Login Personal"],
                ["Painel Admin", "PENDENTE", "BLOQUEADOR", "Sim", "Login Admin"],
                ["Firebase Auth", "PASSOU código", "—", "Não", "E2E senha"],
                ["Firestore Rules", "PASSOU", "—", "Não", "Não abrir"],
                ["Storage Rules", "PASSOU", "—", "Não", "—"],
                ["Functions nuvem", "FALHOU", "BLOQUEADOR", "Sim", "Deploy com auth"],
                ["App Check", "PENDENTE", "IMPORTANTE", "Não imediato", "Monitor → enforce"],
                ["Secrets no git", "PASSOU", "—", "Não", "Restringir AIza no Cloud"],
                ["RC sandbox", "FALHOU", "IMPORTANTE", "Não se IAP off", "Testers"],
                ["Privacidade local", "PASSOU", "—", "Não", "—"],
                ["Legais no ar", "FALHOU", "BLOQUEADOR", "Sim", "Deploy Hosting"],
                ["Exclusão conta", "PASSOU código", "IMPORTANTE", "Não", "Teste descartável"],
                ["Data Safety / Privacy", "PENDENTE", "BLOQUEADOR", "Sim p/ loja", "Jurídico + Console"],
                ["Android / Play", "FALHOU", "BLOQUEADOR", "Sim", "Listing + E2E"],
                ["iOS / TestFlight", "FALHOU", "BLOQUEADOR", "Sim", "Mac + Firebase iOS"],
                ["Guest/debug", "PASSOU (off)", "—", "Não", "Manter off"],
            ],
            s,
            [38 * mm, 28 * mm, 28 * mm, 26 * mm, 58 * mm],
        )
    )
    story.append(
        Paragraph(
            "* Anamnese é BLOQUEADOR se o acompanhamento for vendido na vitrine das lojas.",
            s["muted"],
        )
    )

    # --- ARQUIVOS ---
    story.append(PageBreak())
    story.append(section_banner("12. ARQUIVOS ALTERADOS (ETAPAS 6–9)", PURPLE, s))
    story.append(Spacer(1, 2 * mm))
    story.append(
        Paragraph(
            "Lista dos arquivos desta sequência de auditoria (commits 13f0688 → 23b1c0a). "
            "Não inclui working tree sujo de homolog (.gradle-homolog, caches).",
            s["muted"],
        )
    )
    story.append(
        issue_table(
            ["Arquivo", "Motivo da alteração"],
            [
                ["functions/src/index.js", "IA/foto: sem 200 falso; POST; 503/413/429"],
                ["functions/src/ai_helpers.js", "Cota, tamanho de imagem, timeout OpenAI"],
                ["functions/src/auth_helpers.js", "requirePersonalOrAdmin"],
                ["lib/core/services/cloud_function_http.dart", "Erro amigável da Function"],
                ["lib/features/nutrition/data/calorie_vision_repository.dart", "Mapeia 401/413/429/503"],
                ["lib/features/ai_trainer/data/ai_trainer_repository.dart", "Sessão expirada; rejeita placeholder"],
                ["lib/features/accompaniment/data/accompaniment_ai_repository.dart", "Sem resumo fictício de Personal"],
                ["lib/features/nutrition/presentation/calorie_scanner_screen.dart", "Loading, cancelar, tamanho"],
                ["lib/features/ai_trainer/presentation/ai_trainer_screen.dart", "Preparando resposta..."],
                ["lib/features/accompaniment/presentation/assistant_and_ai_screens.dart", "Banner modo local"],
                [".env.example", "OpenAI só no servidor (sem secret)"],
                ["test/etapa6_ia_functions_test.dart", "Placeholder e macros"],
                ["public/privacidade.html", "Política real; o que some/fica na exclusão"],
                ["public/termos.html", "Removeu vazamento de e-mail; sem promessa de resultado"],
                ["public/index.html", "Landing legal"],
                ["lib/core/config/app_legal.dart", "Resumos e exclusão honesta"],
                ["lib/features/profile/presentation/settings_screen.dart", "Exclusão pontual + gerenciar assinatura"],
                ["lib/features/auth/data/auth_repository.dart", "Purge permitido + auth remota obrigatória"],
                ["ios/Runner/Info.plist", "Removeu microfone não usado"],
                ["release_config/LOJAS_ETAPA7.md", "Material de lojas"],
                ["test/etapa7_legal_test.dart", "HTML sem e-mail pessoal"],
                ["lib/core/services/firebase_service.dart", "allowLocalDevAuth"],
                ["lib/features/auth/providers/auth_providers.dart", "Guest residual off"],
                ["lib/core/router/app_router.dart", "Ignora visitante se flag off"],
                [".gitignore", ".gradle-homolog/ e .firebase/"],
                ["test/etapa8_seguranca_test.dart", "Flags e rules"],
                ["release_config/SEGURANCA_ETAPA8.md", "Auditoria de segurança"],
                ["release_config/AUDITORIA_FINAL_PUBLICACAO.md", "Veredito etapa 9"],
            ],
            s,
            [88 * mm, 90 * mm],
        )
    )

    # --- TESTES ---
    story.append(Spacer(1, 5 * mm))
    story.append(section_banner("13. TESTES", PURPLE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        Paragraph(
            "Ambiente: Windows 10, 19/09/2026, flutter test (unitário). Sem emulador/iPhone nesta rodada.",
            s["body"],
        )
    )
    story.append(
        issue_table(
            ["Teste", "Resultado", "Ambiente"],
            [
                ["test/etapa6_ia_functions_test.dart", "5 passaram", "Windows / Flutter"],
                ["test/etapa7_legal_test.dart", "3 passaram", "Windows / Flutter"],
                ["test/etapa8_seguranca_test.dart", "4 passaram", "Windows / Flutter"],
                ["Total reexecutado na auditoria final", "12 passaram", "19/09/2026"],
                ["curl amandaChat POST sem token", "HTTP 400 (auth ausente no deploy)", "us-central1"],
                ["curl calorieVision POST sem token", "HTTP 400", "us-central1"],
                ["curl accompanimentAi", "HTTP 404 (não implantada)", "us-central1"],
                ["GET privacidade.html / termos.html", "200 com conteúdo ANTIGO", "Hosting produção"],
            ],
            s,
            [72 * mm, 58 * mm, 48 * mm],
        )
    )
    story.append(Spacer(1, 2 * mm))
    story.append(Paragraph("<b>O que não pôde ser testado (não marcar PASSOU):</b>", s["h2"]))
    story.extend(
        bullets(
            [
                "Login dos 3 perfis e troca de contas (sem e-mail/senha/UID).",
                "Câmera, galeria, upload Storage, anamnese, agenda, mensagens em aparelho.",
                "Resposta real da OpenAI (chave só no servidor; não confirmada).",
                "Compra sandbox RevenueCat / restore / gerenciar assinatura.",
                "AAB instalado, Crashlytics Console, tempo de abertura.",
                "iPhone / TestFlight / IPA (Windows).",
            ],
            s,
        )
    )

    # --- VEREDITO ---
    story.append(PageBreak())
    story.append(section_banner("14. VEREDITO FINAL", RED, s))
    story.append(Spacer(1, 4 * mm))
    story.append(Paragraph("ANDROID", s["h2"]))
    story.append(verdict_row("Pronto para gerar AAB de loja", False, "Faltam E2E, legal no ar, Functions e ícone 1024.", s))
    story.append(Spacer(1, 2 * mm))
    story.append(verdict_row("Pronto para Google Play", False, "Listing, Data Safety, revisor, Hosting e IA no ar.", s))
    story.append(Paragraph("iOS", s["h2"]))
    story.append(verdict_row("Pronto para gerar build", False, "Firebase iOS REPLACE_ME; sem Mac nesta auditoria.", s))
    story.append(Spacer(1, 2 * mm))
    story.append(verdict_row("Pronto para TestFlight", False, "Sem IPA, sem ios/ completo no remote, sem Firebase iOS.", s))
    story.append(Spacer(1, 2 * mm))
    story.append(verdict_row("Pronto para App Store", False, "Depende de TestFlight + App Privacy + revisão.", s))
    story.append(Paragraph("SISTEMA", s["h2"]))
    story.append(
        verdict_row(
            "RBAC aprovado",
            False,
            "SIM no código/rules. NÃO em E2E — veredito de publicação: NÃO.",
            s,
        )
    )
    story.append(Spacer(1, 2 * mm))
    story.append(verdict_row("Segurança aprovada", False, "Functions + legais no ar + App Check sem enforce.", s))
    story.append(Spacer(1, 2 * mm))
    story.append(verdict_row("Conteúdo aprovado", False, "Sem QA de aparelho; vídeos só parciais.", s))
    story.append(Spacer(1, 2 * mm))
    story.append(verdict_row("Pagamentos sandbox aprovados", False, "Sem compra/restore real. Produção proibida.", s))

    # --- PROGRAMADOR ---
    story.append(Spacer(1, 6 * mm))
    story.append(section_banner("15. PENDÊNCIAS PARA O PROGRAMADOR", PINK, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        Paragraph(
            "Somente o que precisa ser entregue. Sem teoria. Sem secrets.",
            s["muted"],
        )
    )
    story.append(Paragraph("1. Obrigatório antes da publicação", s["h2"]))
    story.extend(
        bullets(
            [
                "firebase deploy --only hosting --project metodo1dia-app e conferir que Termos NÃO mostram e-mail pessoal.",
                "Deploy amandaChat, calorieVision e accompanimentAi (código com requireAuth). POST sem token deve ser 401.",
                "Configurar OpenAI só no servidor (não no app, não no git).",
                "Provisionar 3 contas (Aluno, Personal, Admin com admins/{uid}) e rodar E2E + troca de sessão.",
                "flutterfire configure no iOS; gerar IPA em macOS.",
                "PNG 1024, screenshots, feature graphic, Data Safety / App Privacy (com jurídico).",
                "Conta de revisão das lojas.",
                "Manter PAYMENTS_ENABLED=false até autorização explícita.",
                "Commitar só o release (sem keystore/.env) e decidir push da branch.",
            ],
            s,
        )
    )
    story.append(Paragraph("2. Recomendado", s["h2"]))
    story.extend(
        bullets(
            [
                "App Check em modo monitor, depois enforce.",
                "Restringir API keys Firebase no Google Cloud (Android package + SHA; iOS bundle).",
                "Apertar rule de subscriptions para aluno vinculado.",
                "Staging Firebase separado ou aceite por escrito de um projeto só.",
                "Produtos Play/ASC + testers se for sandbox (ainda sem produção).",
            ],
            s,
        )
    )
    story.append(Paragraph("3. Pode ficar para pós-lançamento", s["h2"]))
    story.extend(
        bullets(
            [
                "Exportação automática LGPD.",
                "Apagar pt_messages órfãos via Admin/Function.",
                "Lock-screen de áudio.",
                "Remover google_sign_in se continuar sem uso.",
                "Upgrade pontual de pacotes com teste.",
                "Profiling de imagens/queries.",
            ],
            s,
        )
    )
    story.append(Spacer(1, 8 * mm))
    story.append(
        Paragraph(
            "Fim do relatório. Markdown irmão: docs/AUDITORIA_FINAL_METODO_1_DIA.md",
            s["footer"],
        )
    )

    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
    return OUT


if __name__ == "__main__":
    path = build()
    print(path)
    print(f"bytes={path.stat().st_size}")
