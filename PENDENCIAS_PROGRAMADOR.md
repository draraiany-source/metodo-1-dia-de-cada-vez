# PENDÊNCIAS DO PROGRAMADOR
## Método 1 Dia de Cada Vez

**Data:** 22/09/2026  
**Escopo:** apenas itens técnicos. Itens da proprietária → `PENDENCIAS_AMANDA.md`.

---

## P0 — Bloqueia publicação

### P0-00 — Personal e Admin sem Voltar/Sair confiáveis (BLOQUEADORA)
- **Status (23/09/2026):** CORREÇÃO NO CÓDIGO APLICADA — **ainda BLOQUEADORA DE PUBLICAÇÃO** até E2E Personal + Admin (web e Android) marcados PASSOU.
- **Problema:** Perfis Personal e Administradora sem Voltar/Sair confiáveis; `AppNavigation.back` caía na Home da Aluna; raiz do perfil podia cruzar áreas.
- **Localização:** `lib/core/router/app_navigation.dart`, `premium_app_bar.dart`, `admin_screen.dart`, `personal_dashboard_screen.dart`, `session_sign_out.dart`.
- **Correção no código:** hub por perfil; `PopScope(canPop: false)` nas raízes; `StaffSignOutButton` visível; logout → login sem reabrir protegida; CMS com `PremiumAppBar`.
- **Testes unitários:** `test/app_navigation_staff_back_test.dart`.
- **Aceite publicação:** E2E Personal e Admin em **web** e **Android** (Voltar interno, Voltar Android na raiz, Sair → login, Voltar pós-logout não reabre área). Sem isso = **não publicar**.
- **Evidência parcial:** ver `CORRECAO_NAV_LOGOUT_STAFF_20260923.md`.

### P0-01 — E2E dos 3 perfis não documentado como PASSOU
- **Problema:** Sem evidência de login/conteúdo/logout/troca de papel no aparelho nesta fase.
- **Localização:** App inteiro + Firebase Auth/roles.
- **Causa provável:** Falta de contas de teste entregues à sessão de QA.
- **Correção proposta:** Criar 3 contas; executar `CHECKLIST_HOMOLOGACAO_FINAL.md`; anexar prints.
- **Risco:** Revisor da loja quebra no fluxo básico.
- **Aceite:** Checklist H-01…H-76 críticos marcados PASSOU com evidência.

### P0-02 — AAB assinado pós-otimização ausente
- **Problema:** Após compressão PNG→JPG, só APKs foram gerados; AAB atual não está em `build/app/outputs/bundle/release/`.
- **Localização:** Build Android release.
- **Causa:** Build focado em APK/split-per-abi.
- **Correção:** Commit/consolidar assets; `flutter clean`; `flutter build appbundle --release --split-debug-info=build/app/debug-info` com dart-defines oficiais (sem `PAYMENTS_ENABLED=true`).
- **Risco:** Enviar AAB antigo à Play.
- **Aceite:** AAB novo + tamanho registrado + assinatura upload keystore.

### P0-03 — Material / formulários das lojas incompletos (apoio técnico)
- **Problema:** Data Safety, screenshots dimensionados, feature graphic, textos — pipeline técnico incompleto.
- **Localização:** Play Console / App Store Connect.
- **Correção:** Montar pacote de assets a partir do app + checklist `CHECKLIST_PUBLICACAO_ANDROID_IOS.md`.
- **Risco:** Rejeição na revisão.
- **Aceite:** Pacote de store assets entregue; formulários preenchíveis.

### P0-04 — iOS não buildável para loja (se iOS for no mesmo lançamento)
- **Problema:** `lib/firebase_options.dart` iOS com `REPLACE_ME`; IPA exige Mac.
- **Localização:** `lib/firebase_options.dart`, pasta `ios/`.
- **Correção:** `flutterfire configure` no projeto `metodo1dia-app`; signing; Archive; TestFlight.
- **Risco:** Bloqueia App Store.
- **Aceite:** IPA sobe no TestFlight sem crash no launch.

### P0-05 — Confirmar estado real das Cloud Functions / Hosting
- **Problema:** Auditorias anteriores apontaram Functions/Hosting desalinhados do repo.
- **Localização:** Firebase `metodo1dia-app` (Functions + Hosting).
- **Correção:** Revalidar endpoints (auth obrigatória); deploy **somente com autorização**; conferir `privacidade.html`/`termos.html` no ar.
- **Risco:** Feature IA insegura ou legais rejeitados pela loja.
- **Aceite:** GET legais OK; Functions exigem auth; sem fake 200.

---

## P1 — Corrigir antes da publicação

### P1-01 — Commit / tag das otimizações de tamanho
- **Problema:** Working tree com centenas de PNG→JPG e refs Dart não commitadas; HEAD ainda `293ffa9`.
- **Localização:** `assets/**`, `lib/core/**` paths, `pubspec.yaml`.
- **Correção:** Commit organizado (ou PR) + tag; não incluir `key.properties`/keystore.
- **Risco:** Build irreproduzível; perda de trabalho.
- **Aceite:** `git status` limpo nos paths de release; CI/local gera APK ~150 MB fat.

### P1-02 — Substituir Shorts `lLfcuiW32iI` → `akKcU1UVUYw` (se estiver no Firestore)
- **Problema:** ID antigo **não está no repositório**. Provável documento na collection `videos`.
- **Localização:** Firestore `videos/{id}` ou CMS Personal.
- **Correção:** Atualizar só `youtubeUrl`/`videoId`/`thumbnailUrl` mantendo título, order, category, active.
- **Risco:** Usuário abre vídeo errado/indisponível.
- **Aceite:** Busca global `lLfcuiW32iI` = 0 no repo **e** no Firestore; thumb + play + voltar OK no Android.

### P1-03 — Regenerar AAB + arquivar símbolos
- **Problema:** Precisa de artefato único de loja alinhado ao código commitado.
- **Correção:** AAB + `build/app/debug-info` guardado fora do git se necessário.
- **Aceite:** AAB assinado com versionCode acordado.

### P1-04 — App Check enforce (decisão)
- **Problema:** Activate sem enforce (relatórios anteriores).
- **Correção:** Plano gradual; não ligar enforce sem teste.
- **Aceite:** Documento de decisão + teste Auth/Firestore.

### P1-05 — Sandbox RevenueCat (se assinatura na vitrine)
- **Problema:** Compra real off (correto); sandbox não revalidado.
- **Correção:** License testers + offering; **sem** `PAYMENTS_ENABLED=true` em prod até autorização.
- **Aceite:** 1 compra sandbox registrada.

---

## P2 — Pode após publicação

### P2-01 — Limpar pastas de arte não empacotadas no disco
- `assets/images/icons_3d`, `icons_3d_pack2`, neon extras, `lily/treinos lily fit` (já fora do pubspec).
- **Aceite:** Disco limpo sem mudar APK.

### P2-02 — Warnings do `flutter analyze` (prefer_const, unused locals)
- Não bloqueiam build release.
- **Aceite:** Redução gradual; 0 errors mantido.

### P2-03 — Atualizar plugins KGP / dependências major
- Warning Flutter sobre Kotlin Gradle Plugin em plugins.
- **Aceite:** Build verde após upgrades controlados.

### P2-04 — Segundo projeto Firebase (homolog separado)
- Homolog = prod hoje.
- **Aceite:** Projeto `*-dev` opcional pós-lançamento.

### P2-05 — Remover arquivos temporários de auditoria na raiz
- Dezenas de `audit_*.txt`, `homolog_*.txt`, screenshots soltos.
- **Aceite:** Repo limpo; docs oficiais em `docs/` ou raiz acordada.

---

## Notas de segurança (programador)

- **Não** versionar `android/key.properties` nem `.jks` (já gitignored).
- **Não** imprimir senhas/tokens em relatórios.
- API keys Firebase cliente em `google-services.json` / `firebase_options` são de cliente — ainda assim restringir no Console.
- OpenAI **nunca** no app.
