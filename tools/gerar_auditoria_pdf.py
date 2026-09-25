# -*- coding: utf-8 -*-
"""Gera o PDF da auditoria de pré-publicação — Método 1 Dia de Cada Vez."""

from pathlib import Path

from reportlab.lib.colors import Color, HexColor, white
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    KeepTogether,
    ListFlowable,
    ListItem,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "AUDITORIA_FINAL_METODO_1_DIA.pdf"

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
YELLOW = HexColor("#F7C948")
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
            letterSpacing=1.2,
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
            fontSize=7.8,
            leading=10.6,
            textColor=TEXT,
        ),
        "cell_b": ParagraphStyle(
            "cell_b",
            parent=base["Normal"],
            fontName=bold,
            fontSize=7.8,
            leading=10.6,
            textColor=TEXT,
        ),
        "head": ParagraphStyle(
            "head",
            parent=base["Normal"],
            fontName=bold,
            fontSize=8,
            leading=10.5,
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
            fontSize=9.2,
            leading=13,
            textColor=TEXT,
            leftIndent=8,
            spaceAfter=3,
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
    canvas.drawString(16 * mm, 6, "Método 1 Dia de Cada Vez — Auditoria de pré-publicação")
    canvas.drawRightString(w - 16 * mm, 6, f"Página {doc.page}")
    canvas.restoreState()


def section_banner(title: str, color: Color, s: dict) -> Table:
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


def kv_table(rows: list[tuple[str, str]], s: dict) -> Table:
    data = [
        [Paragraph(k, s["cell_b"]), Paragraph(v, s["cell"])]
        for k, v in rows
    ]
    t = Table(data, colWidths=[48 * mm, 130 * mm])
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
        ("TEXTCOLOR", (0, 0), (-1, 0), TEXT),
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


def bullets(items: list[str], s: dict) -> list:
    return [Paragraph(f"• {item}", s["bullet"]) for item in items]


def verdict_box(title: str, apto: bool, note: str, s: dict) -> Table:
    color = GREEN if apto else RED
    label = "APTO / APROVADO" if apto else "NÃO APTO / PENDÊNCIAS"
    data = [
        [Paragraph(f"<b>{title}</b>", s["cell_b"])],
        [Paragraph(label, s["badge"])],
        [Paragraph(note, s["muted"])],
    ]
    t = Table(data, colWidths=[178 * mm])
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), SURFACE),
                ("BACKGROUND", (0, 1), (-1, 1), color),
                ("BACKGROUND", (0, 2), (-1, 2), SURFACE),
                ("BOX", (0, 0), (-1, -1), 0.4, LINE),
                ("LEFTPADDING", (0, 0), (-1, -1), 8),
                ("RIGHTPADDING", (0, 0), (-1, -1), 8),
                ("TOPPADDING", (0, 0), (-1, -1), 6),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
            ]
        )
    )
    return t


def build() -> Path:
    regular, bold = register_fonts()
    s = styles(regular, bold)
    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=A4,
        leftMargin=16 * mm,
        rightMargin=16 * mm,
        topMargin=16 * mm,
        bottomMargin=16 * mm,
        title="Auditoria final — Método 1 Dia de Cada Vez",
        author="Auditoria técnica de pré-publicação",
        subject="Google Play e Apple App Store",
    )

    story: list = []

    story.append(Spacer(1, 28 * mm))
    story.append(Paragraph("AUDITORIA DE PRÉ-PUBLICAÇÃO", s["cover_kicker"]))
    story.append(Paragraph("Método 1 Dia<br/>de Cada Vez", s["cover_title"]))
    story.append(
        Paragraph(
            "Relatório técnico para Google Play e Apple App Store.<br/>"
            "Objetivo: descobrir, corrigir e validar bloqueios de publicação — "
            "sem criar funcionalidades novas e sem alterações destrutivas.",
            s["cover_sub"],
        )
    )
    story.append(Spacer(1, 8 * mm))
    story.append(
        kv_table(
            [
                ("Data", "18 de setembro de 2026"),
                ("Escopo", "50 fases — build, segurança, lojas, privacidade e fluxos críticos"),
                ("Regra", "Corrigir bugs, segurança, build, navegação e publicação. Sem redesenho."),
                ("Veredito geral", "NÃO APTO para publicação enquanto houver erros críticos"),
            ],
            s,
        )
    )
    story.append(Spacer(1, 10 * mm))
    story.append(
        Paragraph(
            "Nenhuma funcionalidade nova foi criada. A identidade visual não foi redesenhada. "
            "Firebase, usuários e conteúdo não foram apagados.",
            s["cover_sub"],
        )
    )

    story.append(PageBreak())
    story.append(Paragraph("1. Relatório técnico (Fase 1)", s["h1"]))
    story.append(
        Paragraph(
            "Identificação feita antes das correções. O projeto é Flutter — não é React Native, "
            "Expo, Android nativo isolado nem iOS nativo isolado.",
            s["body"],
        )
    )
    story.append(
        kv_table(
            [
                ("Tecnologia", "Flutter (Riverpod 2.x, go_router 14)"),
                ("Flutter / Dart", "3.44.4 / 3.12.2 (pubspec: Flutter ≥3.19, Dart ≥3.3)"),
                ("Android applicationId", "com.metodo1dia.app"),
                ("iOS bundle identifier", "com.metodo1dia.app"),
                ("Versão", "1.0.0+1 (versionName 1.0.0 / versionCode 1)"),
                ("Android SDKs", "minSdk 23/24 · compileSdk/targetSdk ≥ 36"),
                ("Gradle / AGP / Kotlin", "Gradle 9.1 · AGP 9.0.1 · Kotlin 2.3.20 · Java 17"),
                ("iOS deployment target", "13.0"),
                ("Firebase", "Projeto único metodo1dia-app"),
                ("Serviços Firebase", "Auth, Firestore, Storage, Functions (Node 22), FCM, Analytics, Crashlytics, App Check"),
                ("Ambientes", "Não há dev / staging / production separados. Hosting homologacao usa o mesmo backend."),
                ("Entrada do app", "lib/main.dart + lib/core/services/firebase_service.dart"),
                ("Regras", "firebase/firestore.rules e firebase/storage.rules"),
                ("IA", "OpenAI somente em Cloud Functions (amandaChat, calorieVision, accompanimentAi)"),
                ("Pagamentos", "RevenueCat via --dart-define"),
                ("Config Android", "android/app/build.gradle.kts"),
                ("Config iOS", "ios/Runner/Info.plist e project.pbxproj"),
            ],
            s,
        )
    )

    story.append(Paragraph("2. Correções aplicadas nesta auditoria", s["h1"]))
    story.extend(
        bullets(
            [
                "Pin de API 36+ no Gradle (compileSdk no bloco android {}, targetSdk ≥ 36).",
                "IMC: proteção contra zero, negativo e valores impossíveis.",
                "Disclaimer médico na análise de calorias por IA.",
                "Texto de exclusão de conta reforçado e purge de dados do dono + Storage users/{uid}.",
                "Mensagens de Configurações sem stack trace / Firebase cru.",
                "Sinal negativo no volume de treino (formatPercent).",
            ],
            s,
        )
    )

    story.append(Spacer(1, 4 * mm))
    story.append(section_banner("A. ERROS CRÍTICOS — impedem publicação", RED, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        issue_table(
            ["Arquivo / linha", "Problema e risco", "Correção / status"],
            [
                [
                    "lib/core/config/app_legal.dart ~15–32",
                    "Sem URL HTTPS pública de Política, Termos e e-mail de suporte. AppLegal não inventa domínio. Play e App Store rejeitam.",
                    "Telas internas /privacidade e /termos já são públicas sem login. Falta a proprietária publicar HTTPS e passar dart-defines. PENDENTE.",
                ],
                [
                    "lib/firebase_options.dart ~37–44",
                    "iOS com apiKey/appId = REPLACE_ME. Sem GoogleService-Info.plist. App iOS cai em modo local: sem Auth, push ou Crashlytics.",
                    "Não foram inventadas chaves. Rodar flutterfire configure no Mac. PENDENTE.",
                ],
                [
                    "Build Android AAB",
                    "AAB release não foi gerado/validado nesta auditoria. Sem AAB assinado a Play não recebe o app.",
                    "key.properties local existe e está no .gitignore. Rodar flutter build appbundle --release com dart-defines. PENDENTE.",
                ],
                [
                    "Build iOS / Archive",
                    "Windows não gera IPA. Sem Apple Team, certificados e APNs. Sem TestFlight.",
                    "Pasta ios/, Info.plist e Privacy Manifest já existem. PENDENTE (macOS + conta Apple).",
                ],
                [
                    "Firebase único",
                    "Homologação e produção no mesmo metodo1dia-app. Testes podem afetar dados reais.",
                    "Registrado. Separar projetos é mudança estrutural — não feita. PENDENTE (decisão da dona).",
                ],
            ],
            s,
            [42 * mm, 68 * mm, 68 * mm],
        )
    )

    story.append(Spacer(1, 6 * mm))
    story.append(section_banner("B. ERROS IMPORTANTES — corrigir antes do lançamento", ORANGE, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        issue_table(
            ["Arquivo / linha", "Problema e risco", "Correção / status"],
            [
                [
                    "assets/app_icon/app_icon.png",
                    "PNG 1024 ausente. Ícone/splash de loja pode ficar pixelado ou genérico.",
                    "Rasterizar o SVG e rodar flutter_launcher_icons + flutter_native_splash. PENDENTE.",
                ],
                [
                    "auth_repository.dart ~227–310",
                    "Exclusão apagava só users/{uid} + Auth. Play pede exclusão real dos dados pessoais.",
                    "Confirmação reforçada e purge de coleções do dono + Storage. Dados só-servidor continuam no Admin SDK. PARCIAL.",
                ],
                [
                    "functions/.../auth_helpers.js ~66–68",
                    "ENFORCE_APP_CHECK só vale se a env estiver true. Functions podem ser chamadas sem App Check.",
                    "Cliente já usa Play Integrity / DeviceCheck em release. Ligar a flag no deploy de produção. PENDENTE.",
                ],
                [
                    "app_config.dart vs app_constants.dart",
                    "IDs de produto divergentes: metodo1dia_premium_mensal/anual × metodo1dia_monthly/yearly.",
                    "Não alterados para não quebrar loja já cadastrada. Alinhar um único par. PENDENTE.",
                ],
                [
                    "flutter test",
                    "150 passaram e 6 falharam (textos de nutrição, validador do catálogo, 1 placeholder, 1 navegação).",
                    "formatPercent(-10) corrigido. Demais falhas são drift de teste. PARCIAL.",
                ],
                [
                    "Fases 45–47",
                    "Sem instalação limpa, Android físico ou TestFlight. Cache mascara bugs de primeira abertura.",
                    "Não executável neste ambiente. PENDENTE.",
                ],
            ],
            s,
            [42 * mm, 68 * mm, 68 * mm],
        )
    )

    story.append(Spacer(1, 6 * mm))
    story.append(section_banner("C. MELHORIAS — podem esperar depois do lançamento", YELLOW, s))
    story.append(Spacer(1, 3 * mm))
    story.extend(
        bullets(
            [
                "Separar Firebase em dev / staging / production.",
                "App Check no Web (reCAPTCHA) e App Attest além de DeviceCheck.",
                "Rate limit nas Functions de IA.",
                "Exclusão completa via Admin SDK (anamnese, chat, uploads PT).",
                "Comprimir ícones Personal-IA (~1,5 MB cada).",
                "Revisar flags legado android.builtInKotlin=false / android.newDsl=false.",
                "Restringir CORS Access-Control-Allow-Origin: * nas Functions.",
                "Reduzir debugPrint em repositórios.",
                "Contraste, Dynamic Type e paginação de listas grandes.",
                "Screenshots oficiais: Início, Treinos, Hidratação, Alimentação, Desafio, Perfil.",
                "Ajustar TreinoCatalogValidation.isValid (116 visíveis vs 117 totais; 053 arquivado).",
            ],
            s,
        )
    )

    story.append(Spacer(1, 6 * mm))
    story.append(section_banner("D. ITENS APROVADOS — já adequados", GREEN, s))
    story.append(Spacer(1, 3 * mm))
    story.append(
        issue_table(
            ["Área", "Por quê"],
            [
                ["Stack / IDs", "Flutter, com.metodo1dia.app no Android e no iOS, versão 1.0.0+1."],
                ["targetSdk 36", "compileSdk/targetSdk = maxOf(36, flutter.*) em android/app/build.gradle.kts."],
                ["Segredos no Git", "key.properties, *.jks, google-services.json, GoogleService-Info.plist e .env no .gitignore."],
                ["Firestore", "Sem allow if true no catch-all. Campos privilegiados só no servidor. Anamnese restrita. calendar_secrets deny-all."],
                ["Storage", "Auth + MIME + tamanho; dono em users/{uid}; catch-all deny."],
                ["OpenAI", "Chave só em OPENAI_API_KEY nas Functions. App chama backend com Bearer + App Check."],
                ["RBAC", "Aluno não entra em /admin. Personal só whitelist. Flags privilegiadas não graváveis pelo cliente."],
                ["Login / guest", "enableGuestMode = false e debugUnlockAllPremiumContent = false."],
                ["Exclusão na UI", "Configurações → Excluir minha conta + confirmação + digitar EXCLUIR."],
                ["Legais in-app", "/privacidade e /termos acessíveis sem login."],
                ["IMC", "Sem divisão por zero; rejeita vazio, ≤0 e faixas impossíveis."],
                ["IA calorias", "Texto de estimativa + aviso de que não substitui avaliação médica/nutricional."],
                ["Permissões", "Alinhadas ao uso. Sem AD_ID. iOS com textos de câmera, fotos, GPS e microfone."],
                ["Crashlytics / Analytics", "Crashlytics só em release. Analytics sem Advertising ID."],
                ["Áudios / Lily Fit", "Programa 7 dias com MP3s no bundle. 117 IDs de exercício resolvem asset."],
                ["Agenda", "Teste de sobreposição de horário passou."],
            ],
            s,
            [48 * mm, 130 * mm],
        )
    )

    story.append(Paragraph("3. Validação por fase (código)", s["h1"]))
    story.append(
        issue_table(
            ["Fases", "Resultado"],
            [
                ["4 Navegação", "Redirect global; legais públicas; /admin e CMS protegidos. Não testado em iPhone físico."],
                ["5 Login / perfis", "Cadastro nasce aluno. Personal/Admin só via staff. Recuperação por e-mail Firebase."],
                ["6 Exclusão", "Existe no app; confirmação reforçada; purge parcial."],
                ["7–10 Firebase", "Projeto metodo1dia-app. App Check Play Integrity + DeviceCheck em release. Enforce no servidor opcional."],
                ["11 Segredos", "Sem OpenAI/Stripe/service account no cliente. Chaves do firebase_options são de cliente FlutterFire."],
                ["12 IA", "Backend + autenticação; sem rate limit."],
                ["13–14 Áudio / vídeo", "Assets do programa 7 dias OK; YouTube parseado; CMS existente."],
                ["15–21 Módulos", "Regras e testes de domínio OK. UI completa não rodou em device."],
                ["22–23 Permissões", "Pedidos alinhados ao uso. Microfone descrito no iOS para chat."],
                ["24–27 Privacidade", "Resumo in-app existe. URL pública HTTPS ainda não. Avisos de bem-estar presentes."],
                ["28–39 Visual / a11y", "Sem redesenho. Inconsistências menores ficam para depois."],
                ["40–41 Deps / testes", "Sem upgrade estrutural. 150 testes ok / 6 falhas de drift."],
                ["42–44 Lojas", "Checklists em CHECKLIST_GOOGLE_PLAY.md e CHECKLIST_APP_STORE.md. Faltam screenshots e Data Safety na Console."],
                ["45–47 Device", "Não executado."],
            ],
            s,
            [42 * mm, 136 * mm],
        )
    )

    story.append(Paragraph("4. Data Safety / App Privacy", s["h1"]))
    story.append(
        Paragraph(
            "<b>Coletados e vinculados à conta:</b> nome, e-mail, foto, peso, altura, IMC, treinos, "
            "hidratação, alimentação, anamnese, fotos de progresso, mensagens, agenda e token FCM.",
            s["body"],
        )
    )
    story.append(
        Paragraph(
            "<b>Não vinculados / técnicos:</b> Crashlytics e Analytics de interação (sem Advertising ID).",
            s["body"],
        )
    )
    story.append(
        Paragraph(
            "<b>Compartilhados com terceiros:</b> Firebase (Google), RevenueCat (assinatura) e OpenAI "
            "via Cloud Functions (texto/foto de refeição).",
            s["body"],
        )
    )
    story.append(
        Paragraph(
            "<b>Localização:</b> somente se a usuária usar corrida com GPS (when-in-use). <b>Anúncios:</b> não.",
            s["body"],
        )
    )

    story.append(Paragraph("5. Veredito técnico (Fase 50)", s["h1"]))
    story.append(Spacer(1, 2 * mm))
    story.append(
        verdict_box(
            "ANDROID",
            False,
            "Falta URL HTTPS de privacidade, AAB assinado validado, ícone 1024 e teste em aparelho limpo.",
            s,
        )
    )
    story.append(Spacer(1, 3 * mm))
    story.append(
        verdict_box(
            "iOS",
            False,
            "Firebase iOS REPLACE_ME, sem plist, sem IPA/TestFlight, sem URL de privacidade/suporte.",
            s,
        )
    )
    story.append(Spacer(1, 3 * mm))
    story.append(
        verdict_box(
            "FIREBASE / SEGURANÇA",
            False,
            "Rules e Storage fechados. Pendente: App Check enforce em produção, iOS configurado e projeto único homolog=prod.",
            s,
        )
    )
    story.append(Spacer(1, 3 * mm))
    story.append(
        verdict_box(
            "PRIVACIDADE",
            False,
            "Resumo in-app ok. Política/Termos públicos HTTPS e contato oficial ainda não existem.",
            s,
        )
    )
    story.append(Spacer(1, 3 * mm))
    story.append(
        verdict_box(
            "FUNCIONALIDADES",
            False,
            "Fluxos críticos não rodaram em Android físico nem TestFlight. Exclusão ainda não cobre dados só-servidor.",
            s,
        )
    )

    story.append(Paragraph("6. Próximos 5 passos da proprietária", s["h1"]))
    story.append(
        Paragraph(
            "Nenhum domínio, e-mail ou credencial foi inventado neste relatório.",
            s["body"],
        )
    )
    story.extend(
        bullets(
            [
                "Publicar Política e Termos em HTTPS e informar e-mail de suporte.",
                "Rodar flutterfire configure (iOS) e manter GoogleService-Info.plist local (não commitar).",
                "Rasterizar assets/app_icon/app_icon.png (1024) e gerar ícones/splash.",
                "No PC: flutter build appbundle --release com dart-defines legais + RevenueCat.",
                "No Mac: pod install → Archive → TestFlight, com conta de aluna para a revisão.",
            ],
            s,
        )
    )
    story.append(Spacer(1, 4 * mm))
    story.append(
        Paragraph(
            "Enquanto a URL pública de privacidade não existir, nenhuma loja aceita o aplicativo — "
            "independentemente do restante do código.",
            s["body"],
        )
    )

    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
    return OUT


if __name__ == "__main__":
    path = build()
    print(path)
    print(path.stat().st_size)
