# Método 1 Dia de Cada Vez
# Auditoria Final para Publicação

| Campo | Valor |
|---|---|
| Aplicativo | Método 1 Dia de Cada Vez |
| Data da auditoria | 19 de setembro de 2026 |
| Versão / build auditada | `1.0.0+1` (`pubspec.yaml`) |
| Branch | `finalizacao-metodo-1-dia-de-cada-vez` |
| Commit da auditoria | `23b1c0a` (relatório) / trabalho em `ccd3a51` |
| Remote | `https://github.com/draraiany-source/metodo-1-dia-de-cada-vez.git` (branch **ahead**, não enviada) |
| Backup | tag `backup-etapa-auditoria-final-20260919` |
| Projeto Firebase | `metodo1dia-app` (único — homolog = produção) |
| Package / Bundle | `com.metodo1dia.app` |
| Cobrança real | **Desligada** (`PAYMENTS_ENABLED=false`) |
| Guest / debug premium | **Desligados** |

**Critério:** nenhum item foi marcado PASSOU sem evidência (código, teste unitário ou sonda HTTP). Fluxos com login real dos 3 perfis **não foram executados** — constam FALHOU/PENDENTE.

Não houve publicação nas lojas nem ativação de cobrança nesta auditoria.

---

## 1. Resumo executivo

O aplicativo tem base sólida de produto (Flutter + Firebase + RBAC no código e nas rules), mas **não está aprovado para Google Play nem TestFlight**.

**Funcionando no código (com teste unitário ou leitura de rules):** autenticação e-mail/senha, RBAC (`admins/{uid}` + `isPersonalTrainer`), logout centralizado, catch-all deny no Firestore/Storage, exclusão de conta no app, documentos legais locais, compressão de foto, rejeição de placeholder de calorias, guest/debug/auth local falso bloqueados em release.

**Principais pendências:** E2E dos 3 perfis sem contas; Cloud Functions de IA na nuvem sem Bearer (400 sem token) e `accompanimentAi` 404; Hosting legal ainda com e-mail pessoal e HTML duplicado; OpenAI no servidor não confirmada; iOS Firebase `REPLACE_ME`; RevenueCat sandbox sem compra real; material das lojas incompleto.

**Quantidade de bloqueadores de publicação:** 8 (legal no ar, Functions, OpenAI se IA for vitrine, E2E 3 perfis, iOS Firebase/IPA, listing das lojas, um projeto Firebase só, cobrança continua off — IAP não deve ir para review como ativo).

| Frente | Status |
|---|---|
| Android / AAB de loja | **NÃO PRONTO** |
| Google Play | **NÃO PRONTO** |
| iOS / TestFlight / App Store | **NÃO PRONTO** |
| Segurança | **NÃO APROVADA** (Functions + legal no ar + App Check sem enforce) |
| RBAC | **Aprovado no código/rules; não aprovado em E2E** |
| Assinaturas | **Sandbox não validado; produção proibida** |
| IA / foto | **Não pronto** (nuvem antiga / 404 / sem OpenAI confirmada) |

---

## 2. Arquitetura atual

| Camada | Tecnologia | Observação auditada |
|---|---|---|
| App | Flutter `>=3.19`, Dart `>=3.3`, Riverpod, go_router | `pubspec.yaml` |
| Auth | Firebase Authentication (e-mail/senha) | `lib/features/auth/data/auth_repository.dart` |
| Banco | Cloud Firestore | `firebase/firestore.rules` |
| Arquivos | Cloud Storage | `firebase/storage.rules` |
| Backend | Cloud Functions Gen-1, Node 22, `us-central1` | `functions/src/index.js` |
| Push | FCM + notificações locais | |
| Qualidade | Analytics, Crashlytics, App Check | App Check **sem enforcement** |
| Hosting | `metodo1dia-app.web.app` | Páginas legais **desatualizadas** |
| Pagamentos | RevenueCat (`purchases_flutter` 8.11.0) | `PAYMENTS_ENABLED=false` |
| IA | OpenAI via Functions (`gpt-4o-mini` no código) | Chave **não** no cliente |
| Mapas | `geolocator` + `flutter_map` | Google Maps SDK **não usado**; `MAPS_API_KEY` vazia |
| Áudio / vídeo | just_audio, video_player/chewie, YouTube | |
| Assinatura Android | `android/key.properties` + `android/keystore/upload-keystore.jks` | Só local, gitignored |

---

## 3. Perfis / RBAC

Fonte: `lib/core/auth/user_role.dart`, `firebase/firestore.rules`, `lib/features/auth/data/auth_repository.dart`.

| Perfil | Código | Verdade no servidor |
|---|---|---|
| Aluno (`student`) | `resolveUserRole` se não for admin/personal | Dono dos próprios docs; não escreve flags privilegiadas |
| Personal (`trainer`) | `users.isPersonalTrainer == true` | CMS, alunos vinculados, whitelist `/admin/videos` etc. Sem painel técnico `/admin` |
| Admin Técnico (`technical_admin`) | Só se existir `admins/{uid}` | Flag `users.isAdmin` **órfã não eleva** |

Permissões de UX (`RolePermissions`): aluno não abre painel técnico nem gerencia papéis; Personal não promove usuários; Admin cria/bloqueia/liga aluno.

**Testes:** unitário etapa 8 — aluno não é staff; `/admin` não está na whitelist da Personal; `/admin/videos` está. E2E login/logout/troca **não executado** (sem e-mail/senha/UID).

Logout: `lib/core/auth/session_sign_out.dart` (`signOut` + limpa sessão + `context.go(login)`). Login com `PopScope(canPop: false)`.

---

## 4. Funcionalidades

Para cada item: status = código e/ou teste; E2E de aparelho = não feito, salvo sonda HTTP.

### Home
- **Status:** PENDENTE E2E. Código com saudação `homeGreeting` (evita “Olá, !”) em `lib/models/app_user.dart`.
- **Teste:** unitário de greeting em etapa anterior; não reaberto em aparelho agora.
- **Problema / correção:** “Olá, !” corrigido no código. Sem regressão visual nesta sessão.
- **Pendência:** abrir Home logada nos 3 perfis.

### Treinos
- **Status:** PENDENTE E2E. Catálogo + persistência previstos.
- **Teste:** código (`workout_history`, rules). Sem treino concluído real agora.
- **Pendência:** fluxo aluno no aparelho.

### Cronômetro
- **Status:** PENDENTE E2E. Persistência ao concluir e `PopScope` aplicados na etapa aluno (`lib/features/workout_timer/presentation/workout_timer_screen.dart`).
- **Pendência:** concluir treino e ver histórico.

### Hidratação
- **Status:** PENDENTE E2E. Meta unificada (custom vs 35 ml/kg) testada em `test/aluno_area_fixes_test.dart` (quando o arquivo está no working tree).
- **Pendência:** registrar copos logada.

### Receitas
- **Status:** PENDENTE E2E. CMS Personal + leitura aluna nas rules.
- **Pendência:** abrir receita e PDF se houver.

### Desafio semanal
- **Status:** PENDENTE E2E. Guard de dia futuro no código.
- **Pendência:** marcar dia de hoje; não marcar futuro.

### Evolução
- **Status:** PENDENTE E2E. Peso/medidas/fotos de progresso no código.
- **Pendência:** gravar e apagar medida com conta real.

### Vídeos
- **Status:** PARCIAL. Seed de 3 Shorts no conteúdo (`yt_34PHGKECMTY`, `yt_3T0HDPX4jkk`, `yt_zRSTnW3EMF8`). Play em iframe Cursor falhou (YouTube 153); player nativo não revalidado agora.
- **Pendência:** play no aparelho + CMS.

### Áudios
- **Status:** PENDENTE E2E. `just_audio` + Storage `audio_programs` (leitura autenticada).
- **Pendência:** play e lock-screen.

### Fotos (perfil / progresso / refeição)
- **Status:** PENDENTE E2E. Storage `users/{uid}`: auth + `image/*` + 8 MB. Evolução `pt_photos` privada por vínculo.
- **Pendência:** upload real.

### Quem Sou Eu
- **Status:** PENDENTE E2E. `amanda_profile` / assets públicos de marca. Edição Personal/Admin.
- **Pendência:** salvar texto/foto como Personal.

### Anamnese
- **Status:** PENDENTE E2E. `pt_anamnesis` com acesso trainer/aluno vinculado. Não abriu rules.
- **Pendência:** preencher, reabrir, editar.

### Agenda
- **Status:** PENDENTE E2E. `pt_appointments`. Google Calendar Function **não está no deploy**.
- **Pendência:** marcar horário; calendário Google é extra.

### Mensagens
- **Status:** PENDENTE E2E. `pt_messages`: aluno/personal criam; **delete só Admin**.
- **Pendência:** enviar e receber. Exclusão de conta **não** apaga mensagens (documentado).

### IA (aluno)
- **Status:** FALHOU nuvem. Cliente chama `amandaChat` com Bearer. Produção POST sem token → **HTTP 400** `message ausente` (auth ausente no código publicado). Código local devolve 503 sem OpenAI.
- **Teste:** curl 19/09/2026; unitário placeholder Amanda.
- **Correção local:** sem HTTP 200 falso; loading “Preparando resposta...”.
- **Pendência:** deploy + chave + E2E.

### Calorias por foto
- **Status:** FALHOU nuvem. Mesmo padrão: **400** sem token. Cliente rejeita 0 kcal / “Refeição”. Compressão 1024 / quality 70.
- **Pendência:** deploy + OpenAI + foto real.

### IA Personal / Assistente
- **Status:** FALHOU. `accompanimentAi` **404** na nuvem. Ações de inbox restritas no código novo.
- **Pendência:** primeiro deploy da Function.

### Painel da Personal
- **Status:** PASSOU rotas no código; FALHOU E2E. Redirect aluno → `/home`.
- **Pendência:** login Personal real.

### Painel Admin
- **Status:** PASSOU rotas + `admins/{uid}` no load; FALHOU E2E.
- **Pendência:** login Admin real.

---

## 5. Firebase

| Superfície | Achado | Evidência |
|---|---|---|
| Authentication | E-mail/senha, reset, disabled, too-many-requests | `auth_repository.dart` |
| Auth local falso | Bloqueado em release / init falho | `FirebaseService.allowLocalDevAuth` |
| Firestore | Catch-all `if false`; `noPrivilegedFields` | `test/etapa8_seguranca_test.dart` |
| Storage | Auth + tipo + tamanho; `/public` leitura aberta | `firebase/storage.rules` |
| Functions | `amandaChat`/`calorieVision` ativas sem Bearer; `accompanimentAi` 404 | curl 19/09/2026 |
| App Check | Play Integrity / DeviceCheck em release; Web pulado; `ENFORCE_APP_CHECK` off | `firebase_service.dart`, `auth_helpers.js` |
| Ambientes | Um projeto só | `metodo1dia-app` |
| iOS | `apiKey`/`appId` = `REPLACE_ME` | `lib/firebase_options.dart` |

---

## 6. Assinaturas

| Item | Status |
|---|---|
| SDK | PASSOU (8.11.0) |
| Entitlement código | `premium` |
| Product IDs | `metodo1dia_premium_mensal`, `_trimestral`, `_anual` |
| Offering `default` | Estrutura no app; painel RC **não validado** |
| Paywall / restore / gerenciar | Código PASSOU; E2E FALHOU |
| Sandbox compra | FALHOU (sem testers/chaves no build) |
| Produção | **Não autorizada** |

---

## 7. Segurança

| Tema | Achado | Severidade |
|---|---|---|
| Functions sem auth na nuvem | POST anônimo chega no payload | BLOQUEADOR |
| Termos no ar | Cabeçalho com e-mail pessoal | BLOQUEADOR |
| Privacidade no ar | HTML duplicado (2 `</html>`) | BLOQUEADOR |
| App Check sem enforce | Tokens opcionais | IMPORTANTE |
| Firebase client `AIza…` | Chave pública de cliente em `firebase_options.dart` — restringir no Cloud | IMPORTANTE |
| OpenAI / RC secret / keystore | Não no git; keystore só local | OK no repo |
| Logs | Sem senha/token/anamnese no `debugPrint` auditado | OK |
| Guest / demo login | Bloqueados em release | Corrigido etapa 8 |
| Rule `subscriptions` | Qualquer Personal lê qualquer doc | IMPORTANTE (não alterada) |

Nenhuma senha, token ou service account foi colocada neste relatório.

---

## 8. Privacidade / documentos

| Documento | Local | No ar (19/09/2026) |
|---|---|---|
| Política | `public/privacidade.html` limpa (teste) | 200, **ainda duplicada** |
| Termos | `public/termos.html` limpo (teste) | 200, **ainda com e-mail pessoal** |
| Suporte | `1diadecadavezsuporte@gmail.com` | Igual no app |
| Exclusão de conta | Configurações + `EXCLUIR` | E2E PENDENTE |
| Exclusão pontual | mailto suporte | Sem wipe de `pt_messages` |
| Consentimento | Checkbox no cadastro | |
| Data Safety / App Privacy | **Não preenchidos nas consoles** | PENDENTE |

Ação de Hosting (não é publicar o app):  
`firebase deploy --only hosting --project metodo1dia-app`

---

## 9. Android

- applicationId `com.metodo1dia.app`, minSdk 23, target/compile 36, version `1.0.0+1`
- R8/minify release ligado
- Ícones mipmap presentes; **falta PNG 1024** `assets/app_icon/app_icon.png`
- Keystore local existe; **não versionar**
- AAB de produção para Play: **NÃO PRONTO**
- Play: faltam listing, screenshots, feature graphic, Data Safety, conta revisor, Hosting legal, Functions

Comando técnico (quando autorizado; **não enviar à Play**):

```bat
flutter build appbundle --release --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html
```

Não usar `PAYMENTS_ENABLED=true`.

---

## 10. iOS

- Bundle `com.metodo1dia.app`
- Firebase iOS incompleto
- Pasta `ios/` em grande parte **não está no GitHub**
- Sem IPA nesta máquina (Windows)
- TestFlight / App Store: **NÃO**
- Microfone removido do `Info.plist` (sem gravação no código)

---

## 11. Tabela geral

| ITEM | STATUS | SEVERIDADE | BLOQUEIA? | AÇÃO |
|---|---|---|---|---|
| Aluno E2E | FALHOU | BLOQUEADOR | Sim | Contas + aparelho |
| Personal E2E | FALHOU | BLOQUEADOR | Sim | Idem |
| Admin E2E | FALHOU | BLOQUEADOR | Sim | Idem + `admins/{uid}` |
| RBAC código/rules | PASSOU | — | Não | Manter; testar E2E |
| Logout / troca | PENDENTE | BLOQUEADOR | Sim | 3 trocas de conta |
| Treinos | PENDENTE | IMPORTANTE | Sim p/ loja | QA |
| Cronômetro | PENDENTE | IMPORTANTE | Sim p/ loja | Concluir e persistir |
| Hidratação | PENDENTE | IMPORTANTE | Sim p/ loja | QA |
| Receitas | PENDENTE | IMPORTANTE | Sim p/ loja | QA |
| Desafio | PENDENTE | IMPORTANTE | Sim p/ loja | QA |
| Evolução | PENDENTE | IMPORTANTE | Sim p/ loja | QA |
| Vídeos | PENDENTE | IMPORTANTE | Sim p/ loja | Play no aparelho |
| Áudios | PENDENTE | IMPORTANTE | Sim p/ loja | Play |
| Fotos Storage | PENDENTE | IMPORTANTE | Não isolado | Upload |
| Quem Sou Eu | PENDENTE | IMPORTANTE | Não isolado | Salvar CMS |
| Anamnese | PENDENTE | BLOQUEADOR* | Se for vitrine | Fluxo completo |
| Agenda | PENDENTE | IMPORTANTE | Não isolado | Horário |
| Mensagens | PENDENTE | IMPORTANTE | Não isolado | Chat |
| IA aluno | FALHOU | BLOQUEADOR | Se for vitrine | Deploy + OpenAI |
| Foto/calorias | FALHOU | BLOQUEADOR | Se for vitrine | Deploy + OpenAI |
| Painel Personal | PENDENTE | BLOQUEADOR | Sim | Login Personal |
| Painel Admin | PENDENTE | BLOQUEADOR | Sim | Login Admin |
| Firebase Auth | PASSOU código | — | Não | E2E senha |
| Firestore Rules | PASSOU | — | Não | Não abrir |
| Storage Rules | PASSOU | — | Não | — |
| Functions nuvem | FALHOU | BLOQUEADOR | Sim | Deploy auth |
| App Check | PENDENTE | IMPORTANTE | Não imediato | Monitor → enforce |
| Secrets no git | PASSOU | — | Não | Restringir AIza no Cloud |
| RevenueCat sandbox | FALHOU | IMPORTANTE | Não se IAP off | Testers |
| Privacidade local | PASSOU | — | Não | — |
| Privacidade/Termos no ar | FALHOU | BLOQUEADOR | Sim | Deploy Hosting |
| Exclusão conta | PASSOU código | IMPORTANTE | Não | Teste descartável |
| Data Safety / App Privacy | PENDENTE | BLOQUEADOR | Sim p/ loja | Jurídico + Console |
| Android / Play | FALHOU | BLOQUEADOR | Sim | Listing + E2E |
| iOS / TestFlight | FALHOU | BLOQUEADOR | Sim | Mac + Firebase iOS |
| Guest/debug | PASSOU (off) | — | Não | Manter off |

\*Anamnese é bloqueador se o acompanhamento for vendido na vitrine.

---

## 12. Arquivos alterados nesta sequência (etapas 6–9)

Não inclui working tree sujo não commitado (dezenas de arquivos de homolog).

| Arquivo | Motivo |
|---|---|
| `functions/src/index.js` | IA/foto: sem 200 falso; POST; 503/413/429 |
| `functions/src/ai_helpers.js` | Cota, tamanho de imagem, OpenAI timeout |
| `functions/src/auth_helpers.js` | `requirePersonalOrAdmin` |
| `lib/core/services/cloud_function_http.dart` | Erro amigável da Function |
| `lib/features/nutrition/data/calorie_vision_repository.dart` | Mapeia 401/413/429/503 |
| `lib/features/ai_trainer/data/ai_trainer_repository.dart` | Sessão expirada; rejeita placeholder |
| `lib/features/accompaniment/data/accompaniment_ai_repository.dart` | Sem resumo fictício de Personal |
| `lib/features/nutrition/presentation/calorie_scanner_screen.dart` | Loading, cancelar, tamanho |
| `lib/features/ai_trainer/presentation/ai_trainer_screen.dart` | “Preparando resposta...” |
| `lib/features/accompaniment/presentation/assistant_and_ai_screens.dart` | Banner modo local |
| `.env.example` | OpenAI só no servidor (sem secret) |
| `test/etapa6_ia_functions_test.dart` | Placeholder e macros |
| `public/privacidade.html` | Política real; o que some/fica na exclusão |
| `public/termos.html` | Removeu vazamento de e-mail; sem promessa de resultado |
| `public/index.html` | Landing legal |
| `lib/core/config/app_legal.dart` | Resumos e exclusão honesta |
| `lib/features/profile/presentation/settings_screen.dart` | Exclusão pontual + gerenciar assinatura |
| `lib/features/auth/data/auth_repository.dart` | Purge permitido + auth remota obrigatória |
| `ios/Runner/Info.plist` | Removeu microfone não usado |
| `release_config/LOJAS_ETAPA7.md` | Material de lojas |
| `test/etapa7_legal_test.dart` | HTML sem e-mail pessoal |
| `lib/core/services/firebase_service.dart` | `allowLocalDevAuth` |
| `lib/features/auth/providers/auth_providers.dart` | Guest residual off |
| `lib/core/router/app_router.dart` | Ignora visitante se flag off |
| `.gitignore` | `.gradle-homolog/`, `.firebase/` |
| `test/etapa8_seguranca_test.dart` | Flags e rules |
| `release_config/SEGURANCA_ETAPA8.md` | Auditoria segurança |
| `release_config/AUDITORIA_FINAL_PUBLICACAO.md` | Veredito etapa 9 |

---

## 13. Testes

**Executados (19/09/2026, Windows, `flutter test`):**

- `test/etapa6_ia_functions_test.dart` — 5 passaram  
- `test/etapa7_legal_test.dart` — 3 passaram  
- `test/etapa8_seguranca_test.dart` — 4 passaram  
- Total reexecutado na auditoria final: **12 passaram**

**Sondas HTTP (sem credencial):**  
`amandaChat` 400, `calorieVision` 400, `accompanimentAi` 404; privacidade/termos 200 com conteúdo antigo.

**Não testado (sem evidência = não PASSOU):**  
login dos 3 perfis; troca de conta; câmera/galeria; upload; OpenAI real; compra sandbox; TestFlight; AAB instalado; Crashlytics Console; tempo de abertura; iPhone.

---

## 14. Veredito final

### ANDROID
- Pronto para gerar AAB de **loja**: **NÃO**
- Pronto para Google Play: **NÃO**

### iOS
- Pronto para gerar build: **NÃO**
- Pronto para TestFlight: **NÃO**
- Pronto para App Store: **NÃO**

### SISTEMA
- RBAC aprovado: **SIM no código/rules** / **NÃO em E2E**
- Segurança aprovada: **NÃO**
- Conteúdo aprovado: **NÃO** (sem QA de aparelho; vídeos só parciais)
- Pagamentos sandbox aprovados: **NÃO**

---

## 15. Pendências para o programador

### 1. Obrigatório antes da publicação

1. `firebase deploy --only hosting --project metodo1dia-app` e conferir que Termos **não** mostram e-mail pessoal.  
2. Deploy `amandaChat`, `calorieVision`, `accompanimentAi` (código com `requireAuth`). Confirmar POST sem token = **401**.  
3. Configurar OpenAI **só no servidor** (não no app, não no git).  
4. Provisionar 3 contas (Aluno, Personal, Admin com `admins/{uid}`) e rodar E2E + troca de sessão.  
5. `flutterfire configure` no iOS; gerar IPA **em macOS**.  
6. PNG 1024, screenshots, feature graphic, Data Safety / App Privacy (com jurídico).  
7. Conta de revisão das lojas.  
8. Manter `PAYMENTS_ENABLED=false` até autorização.  
9. Commitar só o release (sem keystore/`.env`) e decidir push.

### 2. Recomendado

- App Check em modo monitor, depois enforce.  
- Restringir API keys Firebase no Google Cloud (Android package + SHA; iOS bundle).  
- Apertar rule de `subscriptions` para aluno vinculado.  
- Staging Firebase separado **ou** aceite por escrito de um projeto só.  
- Produtos Play/ASC + testers se for sandbox (ainda sem produção).

### 3. Pós-lançamento

- Exportação automática LGPD.  
- Apagar `pt_messages` órfãos via Admin/Function.  
- Lock-screen de áudio.  
- Remover `google_sign_in` se continuar sem uso.  
- Upgrade pontual de pacotes com teste.  
- Profiling de imagens/queries.
