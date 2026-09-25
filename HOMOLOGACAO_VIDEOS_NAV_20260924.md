# Homologação — Vídeos ordem + Voltar/Sair — 24/09/2026
## Método 1 Dia de Cada Vez

| Campo | Valor |
|---|---|
| **Carimbo** | `HOMOLOG_BUILD_ID=20260924-videos-nav` |
| **Versão** | `1.0.0+2` |
| **Cobrança** | `PAYMENTS_ENABLED=false` (não ativada) |
| **Lojas** | **NÃO** publicadas |
| **Canal web** | https://metodo1dia-app--homologacao-cw9j2u83.web.app |

---

## 1. Ordem dos 3 Shorts

**Fonte de verdade:** coleção Firestore `videos` (merge sobre seed `assets/content/videos_biblioteca.json`).

| Ordem | Video ID | Doc ID | Nome |
|---|---|---|---|
| 1º | `3T0HDPX4jkk` | `yt_3T0HDPX4jkk` | Short 1 · order **10** |
| 2º | `zRSTnW3EMF8` | `yt_zRSTnW3EMF8` | Short 2 · order **11** |
| 3º | `34PHGKECMTY` | `yt_34PHGKECMTY` | Short 3 · order **12** |

Meditações `meditation_yt_*` (orders 1–7) **não** foram alteradas.

**Painel Amanda:** `VideosAdminScreen` — número de ordem visível, botões ▲/▼ e arrastar; grava Firestore via `videosAdminRepository.reorder` (permuta slots de `order`, sem colidir com meditações).

---

## 2. Links YouTube

| Link | HTTP | Reprodução in-app |
|---|---|---|
| https://youtube.com/shorts/3T0HDPX4jkk | **PASSOU** (GET 200) | **NÃO TESTADO** (sem device/player) |
| https://youtube.com/shorts/zRSTnW3EMF8 | **PASSOU** (GET 200) | **NÃO TESTADO** |
| https://youtube.com/shorts/34PHGKECMTY | **PASSOU** (GET 200) | **NÃO TESTADO** |

---

## 3. Navegação Voltar / Sair (revisão estática + código)

### Correções desta rodada
- 27 subpáginas migradas de `AppBar` → `PremiumAppBar` (Voltar via `AppNavigation.back`).
- Raízes Admin/Personal: `PopScope(canPop: false)` + Sair visível.
- Aluna: Sair em Home e Perfil; subpáginas com Voltar.

### Lista de telas (resultado)

**Aluna — principais**

| Tela | Voltar | Sair | Resultado |
|---|---|---|---|
| Home | N/A (raiz) | sim (menu) | **PASSOU** (código) |
| Treinos / Receitas / Evolução / Perfil (shell) | N/A | Perfil | **PASSOU** (código) |
| Configurações | PremiumAppBar | Sair da conta | **PASSOU** (código) |
| Login (após Sair) | bloqueado | — | **PASSOU** (código PopScope) |

**Aluna — subpáginas / conteúdo**

| Tela | Resultado |
|---|---|
| Vídeos | **PASSOU** (código) |
| Meditações / Áudios hub / Programa 7 dias / Player | **PASSOU** (código) |
| E-books / leitor | **PASSOU** (código) |
| PDFs receitas / viewer | **PASSOU** (código) |
| Amanda / Fale com Amanda | **PASSOU** (código) |
| Metas, Diário, Check-in, Hábitos, Hidratação, Corrida, Calendário, Lembretes, Sequência, Comunidade, Desafios, Conquistas, Planos, Assinatura | **PASSOU** (código) |
| Missões / Recompensas / Certificados / Relatórios / Indique / Health sync / Cursos / Dashboard premium / Scanner / IA | **PASSOU** (código) |
| Android back em subpágina → hub Aluna (não Personal/Admin) | **PASSOU** (código `AppNavigation`) |
| Android back na Home | **PASSOU** (código; não cruza perfil) |
| Fluxo E2E logado Aluna no device | **NÃO TESTADO** |

**Personal**

| Tela | Resultado |
|---|---|
| Dashboard Personal (raiz + Sair + PopScope) | **PASSOU** (código) |
| Painel CMS hub / Treinos CMS / Receitas CMS | **PASSOU** (código) |
| Biblioteca Vídeos admin / Meditações CMS | **PASSOU** (código) |
| Áudios CMS / E-books CMS / Amanda assets/perfil / Lily / Desafios CMS | **PASSOU** (código) |
| Alunos / detalhe / anamnese / inbox / agenda / builder / sessão | **PASSOU** (código) |
| Android back na raiz Personal | **PASSOU** (código PopScope) |
| E2E logado Personal no device | **NÃO TESTADO** |

**Admin**

| Tela | Resultado |
|---|---|
| Painel Técnico (raiz + Sair + PopScope) | **PASSOU** (código) |
| Usuários/roles / Assinaturas admin / Cupons | **PASSOU** (código) |
| E2E logado Admin no device | **NÃO TESTADO** |

**Ordem dos 3 Shorts no app (lista aluna)** | **PASSOU** (seed + Firestore atualizados; UI device **NÃO TESTADO**) |
| Reordenar no painel (persistência) | **PASSOU** (código; E2E painel **NÃO TESTADO**) |

---

## 4. Builds

### Web
```
flutter build web --release
  --dart-define=HOMOLOG_BUILD_ID=20260924-videos-nav
  --dart-define=PAYMENTS_ENABLED=false
```
- `√ Built build\web`
- Deploy canal: `firebase hosting:channel:deploy homologacao --config firebase.homolog.json`
- URL: https://metodo1dia-app--homologacao-cw9j2u83.web.app

### Android APK
Ver seção gerada após o build (arquivo APK arm64).

---

## 5. Arquivos alterados (desta entrega)

- `assets/content/videos_biblioteca.json` — ordem 1º/2º/3º Shorts
- `tools/_videos_firestore_all_dump.json` — dump alinhado
- Firestore `videos/yt_3T0HDPX4jkk`, `yt_zRSTnW3EMF8`, `yt_34PHGKECMTY` — order/name
- `lib/features/video_streaming/data/videos_admin_repository.dart` — reorder preserva slots
- `lib/features/video_streaming/presentation/videos_admin_screen.dart` — ordem visível + ▲▼
- `test/videos_biblioteca_seed_test.dart` — assert ordem correta
- 27 telas → `PremiumAppBar` (ebooks, pdf, video player, amanda, missions, rewards, etc.)

---

**Não feito:** publicação Play/App Store · `PAYMENTS_ENABLED=true` · E2E com contas reais nos 3 perfis.
