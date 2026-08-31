# AUDITORIA TÉCNICA — Método 1 Dia de Cada Vez
## Parte 1 — Relatório (classificado) · Parte 2 — Correções aplicadas

> **DECLARAÇÃO DE EXECUÇÃO (obrigatória).** Este ambiente **não tem** Flutter
> SDK, Android SDK, Xcode nem internet (reconfirmado nesta sessão). Portanto
> **NÃO foram executados** e ficam como PENDENTE-requer-SDK, nunca "aprovado":
> `dart format`, `flutter analyze`, `flutter test`, `flutter build
> apk/appbundle/web`, geração de APK/AAB. **Nenhum resultado de build foi
> inventado.** Tudo abaixo é auditoria ESTÁTICA (leitura/verificação do código),
> mais as correções que essa análise permite aplicar com segurança.

Métricas: 181 arquivos Dart, ~29.300 linhas, 39 módulos, 0 arquivos órfãos.

---

# PARTE 1 — PROBLEMAS CLASSIFICADOS

## 🔴 CRÍTICO

### C1 — Pastas nativas ausentes (`android/`, `ios/`, `web/`)
- **Arquivo:** raiz do projeto.
- **Problema:** não existem; o ZIP só tem `lib/`, `assets/`, `firebase/`, `test/`.
- **Impacto:** o app **não compila nem instala** em nenhum dispositivo.
- **Correção:** `flutter create . --platforms=android,ios,web` (preserva o resto).
- **Status:** ⏳ PENDENTE — exige SDK. Automatizado no CI (`.github/workflows/build.yml`).

### C2 — Projeto nunca compilado
- **Problema:** o código nunca passou por `flutter analyze`/`build`.
- **Impacto:** erros de tipo/null-safety/API só aparecem no 1º build; alta
  probabilidade de a 1ª tentativa acusar erros.
- **Correção:** rodar o ciclo analyze→corrigir→build (eu corrijo com o log em mãos).
- **Status:** ⏳ PENDENTE — exige SDK.

### C3 — Firebase não configurado (`REPLACE_ME`)
- **Arquivo:** `lib/firebase_options.dart` (apiKey: 'REPLACE_ME' ×3).
- **Problema:** sem credenciais reais do projeto Firebase.
- **Impacto:** login/nuvem não funcionam até configurar. **Mitigado:** o app
  **não trava** — `FirebaseService` cai em "modo local" (demonstração).
- **Correção:** `flutterfire configure` + `google-services.json` (android/app/)
  + `GoogleService-Info.plist` (ios/Runner/).
- **Status:** ⏳ PENDENTE — exige credenciais (Firebase).

### C4 — Pagamentos SIMULADOS (sem billing real)
- **Arquivo:** `lib/core/services/premium_service.dart` (`LocalPremiumService`).
- **Problema:** Premium é um mock em SharedPreferences; RevenueCat/Play Billing/
  Apple IAP **não** integrados.
- **Impacto:** **não há monetização real**; não considerar pagamento concluído.
- **Correção:** integrar RevenueCat (chaves + produtos nas lojas) e trocar o
  provider para `RevenueCatPremiumService`.
- **Status:** ⏳ PENDENTE — exige contas/credenciais externas.

## 🟠 ALTO

### A1 — Conteúdo Premium depende de URL de Cloud Function placeholder
- **Arquivo:** `app_constants.dart` (getContentUrl/getVideoUrl = `...SEU-PROJETO...`).
- **Problema:** vídeos, e-books, cursos, áudios e receitas resolvem a URL via
  Cloud Function; enquanto a URL é placeholder, o app retorna erro amigável.
- **Impacto:** conteúdo Premium não abre até configurar (mas não quebra a tela).
- **Correção:** publicar as functions e preencher a URL real.
- **Status:** ⏳ PENDENTE — exige deploy Firebase.

### A2 — "Editar perfil" sem ação
- **Arquivo:** `profile_screen.dart:147` (`() {}`).
- **Problema:** item de menu não abre nada (falta a tela de edição).
- **Impacto:** funcionalidade esperada ausente.
- **Correção:** criar `EditProfileScreen` + rota. **Status:** ⏳ PENDENTE (falta tela).

### A3 — Sino de notificações da Home sem ação — ✅ CORRIGIDO
- **Arquivo:** `home_screen.dart:94`.
- **Correção aplicada:** passou a abrir `Routes.reminders` (ajuste o destino se
  criar uma tela dedicada de notificações). **Status:** ✅ CORRIGIDO.

## 🟡 MÉDIO

### M1 — Login social não implementado
- **Arquivo:** `pubspec.yaml` (`google_sign_in` declarado, 0 usos).
- **Impacto:** botão/promessa de login Google/Apple ausente.
- **Correção:** implementar OAuth ou remover a dependência. **Status:** ⏳ PENDENTE.

### M2 — Animação Rive "em breve"
- **Arquivo:** `lili_assets_admin_screen.dart:70`, `rive_helper.dart`.
- **Impacto:** nenhum — há fallback Lottie/estático. **Status:** 🟢 aceitável.

### M3 — Ícones 3D na barra inferior (preferência visual)
- **Impacto:** possível peso visual; há fallback Material pronto.
- **Status:** 🟢 informativo (sua escolha).

## 🔵 BAIXO

### B1 — 4 assets sem referência direta
- `loading_geral.svg`, `desafios_iniciais.json`, `notificacoes_push.json`,
  `receitas_iniciais.json` — provavelmente carregados dinamicamente.
- **Correção:** revisar antes de excluir. **Status:** ⏳ revisão manual (não removidos).

### B2 — Botão demo vazio no showcase
- `asset_showcase_screen.dart:121` — tela de demonstração; aceitável. 🟢

---

# ✅ VERIFICADO E SAUDÁVEL (sem achados)

- **Segurança:** **0 segredos reais** no código. `firebase_options` usa
  placeholder; chave OpenAI fica **server-side** (`functions.config().openai.key`
  / `process.env`), nunca no app. Autenticação de conteúdo via `getIdToken` +
  Bearer (correto).
- **Regras Firestore:** protegem campos sensíveis (xp, level, isPremium, isAdmin
  não graváveis pelo cliente); conteúdo Premium isolado em `/private` servido por
  Cloud Function. Bypass do `pdf_recipes` (corrigido em sessão anterior) segue fechado.
- **Índices Firestore:** 6 índices compostos conferem com as queries do código.
- **Modo demonstração:** sem Firebase o app NÃO trava (degrada em modo local).
- **Assets:** todas as pastas declaradas no `pubspec` existem; 146 constantes de
  asset resolvem para arquivo real; mascote nova (18+7) e 42 ícones presentes.
- **Código morto:** 0 arquivos órfãos.
- **Providers/rotas:** 55 rotas com builder; 80 refs de provider resolvem.

---

# PARTE 2 — Correções aplicadas nesta auditoria
- ✅ `home_screen.dart` — sino de notificações agora abre os lembretes (era botão morto).
- (Correções estruturais anteriores mantidas: dispose/leaks, índices Firestore,
  segurança pdf_recipes, mascote nova, ícones, animação, acessibilidade.)

## O que NÃO pôde ser entregue aqui (exige ambiente/credenciais)
| Item pedido | Depende de |
|---|---|
| APK de teste / AAB | Flutter + Android SDK |
| Resultado `flutter analyze`/`test` | Flutter SDK |
| Build web / iOS | Flutter SDK / Xcode |
| Firebase real | credenciais (google-services / plist) |
| Pagamentos reais | RevenueCat + lojas |
| Conteúdo Premium abrindo | deploy das Cloud Functions |
| IPA assinado | conta Apple Developer + certificado |

**Caminho para executar tudo isso de verdade:** o workflow
`.github/workflows/build.yml` roda `flutter create . → pub get → analyze → test →
build apk/appbundle/web` num runner com SDK e entrega APK, AAB e os logs
`analyze.txt`/`test.txt` como artefatos. Traga o `analyze.txt` da primeira
execução e eu aplico as correções de compilação (C2) diretamente no código.
