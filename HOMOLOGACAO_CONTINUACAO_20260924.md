# Homologação — Continuação 24/09/2026
## Método 1 Dia de Cada Vez

| Campo | Valor |
|---|---|
| **Base** | `HOMOLOGACAO_POS_CORRECAO_20260924.pdf` |
| **HEAD** | `33be30bf21aaab4e4451cd048fe8cfef72d34f03` (`33be30b`) |
| **Commits desta rodada** | `325f482` (hub Voltar + legais homolog + login 1.0.0+2) · `33be30b` (script cópia HTML) |
| **Versão** | `1.0.0+2` |
| **Carimbo** | `HOMOLOG_BUILD_ID=20260924-nav` |
| **Cobrança** | `PAYMENTS_ENABLED=false` |
| **Publicação lojas** | **NÃO** — sem E2E dos 3 perfis |

---

## 1. Alterações locais e commit

Working tree ainda contém mudanças de assets/meditações/vídeos **fora** destes commits (não incluídas).

**Commitados (aprovados para homolog):**
- `lib/core/router/app_navigation.dart` — `hubForPath` / Voltar por perfil (faltava no `7aaf08b`)
- `lib/features/auth/presentation/login_screen.dart` — label `v1.0.0+2`
- `firebase.homolog.json` — redirects `/privacidade` e `/termos` → `.html`
- `firebase.json` — `cleanUrls: true` (produção **ainda não redeployada**)
- `public/404.html`, `tools/_copy_legal_to_web.ps1`

**Testes automatizados:** `+23 All tests passed`  
(`premium_app_bar_staff`, `app_navigation_staff_back`, `user_role_permissions`, `meditations_association_order`, `cadeiras_lily_assets`, `etapa7_legal`)  
Log: `tools/_homolog_tests_continue_20260924.txt`

---

## 2. Rotas privacidade / termos

| URL | Resultado |
|---|---|
| Homolog `/privacidade` | **200** (HTML legal) |
| Homolog `/termos` | **200** |
| Homolog `/privacidade.html` · `/termos.html` | **200** |
| Produção `/privacidade.html` · `/termos.html` | **200** |
| Produção `/privacidade` · `/termos` | **404** — exige deploy hosting **produção** (não feito: só canal homolog autorizado) |
| In-app `#/privacidade` no homolog | **PASSOU** (tela “Política de privacidade” + botão oficial) |

App builds apontam para URLs `.html` (funcionais em produção).

---

## 3. Builds (sequenciais)

### Web
```
flutter build web --release
  --dart-define=HOMOLOG_BUILD_ID=20260924-nav
  --dart-define=PAYMENTS_ENABLED=false
  (+ SUPPORT_EMAIL, PRIVACY/TERMS .html)
```
- Resultado: `√ Built build\web` · `WEB_EXIT=0` · JS contém `20260924-nav` e `v1.0.0+2`
- Cópia HTML: `tools/_copy_legal_to_web.ps1`
- Deploy: `firebase hosting:channel:deploy homologacao --config firebase.homolog.json` · **736 arquivos** · `DEPLOY_EXIT=0`

**Link homolog:** https://metodo1dia-app--homologacao-cw9j2u83.web.app  
(expira ~2026-10-24)

### Android APK (depois do web)
```
flutter build apk --release --split-per-abi
  --dart-define=HOMOLOG_BUILD_ID=20260924-nav
  --dart-define=PAYMENTS_ENABLED=false
```
- `APK_EXIT=0`
- **APK principal:**  
  `C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk`  
  · 112 431 100 bytes · mtime **24/09/2026 13:53:59**
- Carimbo no binário: `APK_STAMP=True` · `homolog 20260924-nav` · `v1.0.0+2`
- **Não usar** `app-release.apk` de 23/09

---

## 4. Carimbo na tela de login (comprovado)

| Plataforma | Resultado | Evidência |
|---|---|---|
| **Web homolog** | **PASSOU** | UI: `v1.0.0+2 · homolog 20260924-nav` · screenshot `homologacao_evidencias_20260924b/web_login_carimbo_20260924-nav.png` |
| **Android** | **NÃO TESTADO** (UI) | Sem device/emulador; carimbo **comprovado no binário** do APK novo |

---

## 5. Matriz E2E — Aluna / Personal / Admin

**Dispositivos disponíveis:** Windows desktop, Chrome, Edge. **Sem Android.**  
**Contas homolog autorizadas:** **ausentes** (ver `LISTA_ACESSOS_AMANDA_ENTREGA_20260923.md`).

### Web (Chrome · homolog `20260924-nav`)

| Perfil | Login / permissões / Voltar / Sair / treinos / vídeos / 7 meditações / áudios / PDFs | Resultado |
|---|---|---|
| Aluna | — | **NÃO TESTADO** (sem conta) |
| Personal | — | **NÃO TESTADO** (sem conta) |
| Admin | — | **NÃO TESTADO** (sem conta) |
| Troca de contas | — | **NÃO TESTADO** |
| Login (sem autenticação) + carimbo | Abrir login | **PASSOU** |
| Privacidade in-app | `#/privacidade` | **PASSOU** |
| Termos in-app | — | **NÃO TESTADO** (espelho do fluxo privacidade; HTTP homolog `/termos` = 200) |

### Android

| Perfil / cenário | Resultado |
|---|---|
| Todos os cenários dos 3 perfis | **NÃO TESTADO** — sem aparelho/emulador + sem contas |
| Instalação do APK novo | **NÃO TESTADO** |

### iOS
**NÃO TESTADO** — `REPLACE_ME` + sem Mac.

---

## 6. Veredito

| Item | Status |
|---|---|
| Ambiente homolog web atualizado + carimbo na login | **Sim** |
| APK novo carimbado | **Sim** (artefato) |
| Aceite E2E 3 perfis | **Não** — NÃO TESTADO |
| Pronto para publicação nas lojas | **Não** |

**Não declarar o aplicativo pronto para publicação** até E2E manual dos três perfis com evidência.
