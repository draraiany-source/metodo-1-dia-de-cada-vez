# AUDITORIA COMPLETA — Método 1 Dia de Cada Vez
## Homologação web/Android e preparação para publicação

| Campo | Valor |
|---|---|
| **Data** | 23/09/2026 |
| **Escopo** | Diagnóstico somente — **sem alteração de código nesta etapa** |
| **Produção** | Não alterada |
| **Cobrança real** | Não executada (`PAYMENTS_ENABLED` default `false`) |
| **App** | Flutter `metodo_1_dia` **1.0.0+1** · Firebase **`metodo1dia-app`** |
| **IDs** | Android/iOS `com.metodo1dia.app` · minSdk ≥23 · targetSdk ≥36 |
| **Evidência** | `tools/_auditoria_final_evidence_20260923.json` + inspeção de código + unit tests |
| **Branch** | `finalizacao-metodo-1-dia-de-cada-vez` (~971 linhas dirty) |

**Regra desta auditoria:** existência de tela ≠ função pronta. Só “aprovado” o que foi testado. E2E dos 3 perfis **não** foi executado nesta etapa (sem contas de teste criadas aqui).

---

# A. RESUMO EXECUTIVO — ESTADO REAL

O aplicativo é um produto Flutter maduro em superfície (Auth, shell Aluna, treinos, CMS Personal, painel Admin, planos, Firebase Rules, AAB ~148 MB), mas **não está pronto para publicar**.

| Capacidade | Estado real |
|---|---|
| Homologação web | Canal HTTP **200**: https://metodo1dia-app--homologacao-cw9j2u83.web.app — **pode estar defasado** vs código local |
| Homologação Android | AAB/APK locais existem (~148 / ~156 MB) — instalação E2E **não testada nesta auditoria** |
| Admin Voltar/Sair | **Problema confirmado no relato; mitigação parcial no código; E2E não reaprovado** |
| Personal CMS | Rotas e CRUD reais para vários conteúdos; E2E **não testado** |
| Cobrança | UI de planos + SDK RevenueCat; **cobrança real desligada** |
| iOS loja | **Bloqueado** (`REPLACE_ME` em `firebase_options` iOS) |
| Working tree | Sujo — risco de build irreproduzível |

### Veredito

| Pergunta | Resposta |
|---|---|
| Pronto para **homologar** (começar testes E2E)? | **SIM, com ressalvas** — artefatos e canal existem |
| Pronto para **publicar Android**? | **NÃO — BLOQUEADO** |
| Pronto para **publicar iOS**? | **NÃO — BLOQUEADO** |

### Testes executados nesta auditoria

| Tipo | Resultado | Interpretação |
|---|---|---|
| `user_role_permissions_test.dart` | **PASS** (11) | RBAC unitário — **não** E2E UI |
| `app_navigation_staff_back_test.dart` | **PASS** (4) | Hubs Voltar por path — **não** E2E device |
| `meditations_association_order_test.dart` | **PASS** (1) | Seed meditações 1–7 |
| Login/cadastro/logout UI 3 perfis | **NÃO EXECUTADO** | Contas + device |
| Play YouTube / áudio Android | **NÃO EXECUTADO** | Device |
| Compra sandbox | **NÃO EXECUTADO** | Proibido cobrança real; sandbox pendente |
| HTTP homolog + legais `.html` | **200** (evidência 23/09) | Paths sem `.html` → **404** |

---

# B. CHECKLIST POR FUNCIONALIDADE

Legenda: **F** funciona (provado) · **I** incompleto · **Q** quebrado/stub · **N** não testado nesta etapa · **C** só código inspecionado

| Funcionalidade | Status | Notas |
|---|---|---|
| Cadastro | C / N | `register_screen` + Auth repo |
| Login | C / N | Firebase Auth |
| Recuperação de senha | C / N | Dialog no login → `resetPassword` |
| Logout Aluna | C / N | Perfil / Settings / Home |
| Logout Personal | C / N | `StaffSignOutButton` + chips |
| Logout Admin | C / N | `StaffSignOutButton` na raiz `/admin` — **E2E crítico** |
| Voltar Admin (raiz) | I | **Propositalmente sem Voltar** (`isRoleRoot` / `automaticallyImplyLeading: false`) |
| Voltar Admin (filhas) | C / N | `PremiumAppBar` em várias; AppBars Material em outras |
| Sair em telas filhas Admin | I / Q UX | Várias filhas **sem** `StaffSignOutButton` |
| Gesto Voltar Android raiz Admin | C / N | `PopScope(canPop: false)` |
| Pós-logout histórico | C / N | `context.go(login)` + Login `PopScope` + redirect |
| Permissões 3 papéis | F (unit) / N (E2E) | Rules + router + unit PASS |
| Treinos / 117 exercícios | C / N | Catálogo local |
| Imagens Lily Fit | C / N | Assets + CMS |
| Vídeos (área separada) | C / N | CMS + FS / seed |
| Reprodução YouTube | N | Não reproduzido nesta etapa |
| Cronômetro | C / N | `workout_timer` |
| Desafio semanal | I | Aba Admin stub; CMS Personal tem rotas |
| Meditações | C + unit seed / N play | Ordem 1–7 unit PASS |
| Áudio / Programa 7 dias | C / N | Seed/docs; play Android N |
| Hidratação + histórico | C / N | Feature no app (path feature a confirmar no shell) |
| Receitas / PDF | I | CMS real; aba Admin “Receitas” **stub** |
| Calendário / metas / conquistas | C / N | — |
| Anamnese | C / N | — |
| Agenda / consultoria | C / N | — |
| Chat | C / N | Functions exigem token (evidência prévia) |
| Quem sou eu | C / N | Edição Admin/Personal |
| Ferramentas Personal / CMS | C / N | Hub conteúdo |
| Planos UI | C | Telas prontas |
| Trial 7 dias | I | Modelo FS + copy; loja vs app |
| Assinatura / cobrança | I | Gate `PAYMENTS_ENABLED=false` |
| Métricas dashboard Admin | Q | Números **falsos** hardcoded |
| Ações rápidas Admin | Q | SnackBar “conecte ao Firestore” |
| iOS Firebase | Q | `REPLACE_ME` |
| Privacidade/Termos | I | `.html` 200; bare path 404 |

---

# C. LISTA DE PROBLEMAS PRIORIZADA

## C1. BLOQUEADOR — Admin sem Voltar/Sair (relato confirmado; mitigação parcial)

| Campo | Detalhe |
|---|---|
| **ID** | **BLK-01** |
| **Gravidade** | **Bloqueador** de homologação/publicação até E2E PASSOU |
| **Tela / perfil** | Painel Técnico `/admin` e telas filhas `/admin/*`, CMS, Central Personal abertas pelo Admin · **perfil Admin** · **Web + Android** |
| **Passos para reproduzir** | 1) Login como Admin Técnico (`admins/{uid}`) 2) Observar AppBar da raiz 3) Abrir Usuários / Assinaturas / Vídeos / etc. 4) Pressionar Voltar do Android na raiz e nas filhas 5) Tentar Sair e, após logout, Voltar do sistema |
| **Observado (relato + código)** | **Relato:** Admin entra e não encontra Voltar nem Sair. **Código atual:** na raiz há `StaffSignOutButton` (“Sair da conta”) e **não** há botão Voltar (raiz de papel). `PopScope(canPop: false)` impede o gesto Android de sair da raiz para outro perfil. Telas filhas (ex.: Usuários e papéis, Assinaturas) têm Voltar via `PremiumAppBar`, mas **muitas não têm Sair**. Telas como Vídeos Admin usam `AppBar` Material padrão **sem** `StaffSignOutButton`. Homolog canal pode ainda servir build antigo. |
| **Esperado** | Sair sempre visível e óbvio no Admin (raiz e filhas críticas); Voltar nas internas; na raiz o Voltar do sistema não abre Aluna/Personal; após logout, Voltar não reabre área restrita |
| **Arquivos** | `lib/features/admin/presentation/admin_screen.dart` (L28–77, L66–77); `lib/core/auth/staff_sign_out_button.dart`; `lib/core/auth/session_sign_out.dart`; `lib/core/router/app_navigation.dart`; `lib/core/router/premium_app_bar.dart`; filhas sem Sair: `admin_users_roles_screen.dart`, `admin_subscriptions_screen.dart`, `videos_admin_screen.dart`, etc. |
| **Correção proposta** | 1) Garantir Sair persistente (AppBar ou menu) em **todas** as rotas Admin/CMS usadas pelo Admin 2) UX: ícone logout sempre visível (evitar overflow em AppBar estreita) 3) Documentar que raiz **não** tem Voltar (só Sair) 4) Redeploy homolog + E2E web e Android com prints 5) Validar pós-logout |
| **Evidência** | Código 23/09; unit nav PASS; **E2E NÃO executado** — **não aprovado** |
| **Esforço** | 8–12 h (inclui E2E) |

### Telas afetadas (inventário Voltar/Sair Admin)

| Rota / tela | Voltar UI | Sair UI (código) |
|---|---|---|
| `/admin` raiz | Não (por desenho) | Sim — `StaffSignOutButton` |
| Gate “acesso restrito” | Não | Sim |
| `/admin/users` | PremiumAppBar | **Não** |
| `/admin/assinaturas` | PremiumAppBar | **Não** |
| `/admin/coupons` | AppBar típica | Verificar — tipicamente **não** |
| Vídeos / e-books / áudios admin | AppBar Material | **Não** (padrão) |
| `/painel-personal` | PremiumAppBar | Sim |
| `/personal-trainer` (aberto pelo Admin) | PopScope raiz Personal | Sim |
| Settings (ícone engrenagem no Admin) | Sim | Via Settings |

---

## C2. Demais problemas (prioridade)

| ID | Grav. | Tela/perfil/plat. | Repro resumido | Observado | Esperado | Arquivo | Correção | h |
|---|---|---|---|---|---|---|---|---:|
| **BLK-02** | Bloq. | Personal Web+Android | Login Personal; Sair; Voltar raiz | Mitigação no código; E2E pendente | Igual BLK-01 | `personal_dashboard_screen.dart` | E2E + Sair em filhas | 4–8 |
| **BLK-03** | Bloq. | 3 perfis | Roteiro E2E completo | Não executado | Checklist PASSOU | App + Auth | Contas + execução | 12–16 |
| **ALT-01** | Alta | Admin Dashboard | Abrir abas Receitas/Desafios; ações rápidas | Stub + SnackBar; listas fake | CRUD real ou remover UI enganosa | `admin_screen.dart` L93–99, L218–235, L371–421 | Ligar Firestore ou esconder stubs | 6–10 |
| **ALT-02** | Alta | Admin Dashboard | Ver métricas | “1.284 Usuárias” etc. **hardcoded** | Métricas reais ou “—” | `admin_screen.dart` L218–226 | Remover fake / query FS | 3–5 |
| **ALT-03** | Alta | Android loja | Build release | AAB local ~148 MB; tree dirty | Artefato = commit assinado | `build/.../app-release.aab` | Commit + rebuild + keystore | 6–10 |
| **ALT-04** | Alta | iOS | Abrir iOS options | `REPLACE_ME` | Firebase iOS real + IPA | `lib/firebase_options.dart` | flutterfire + Mac | 12–20 |
| **ALT-05** | Alta | Lojas | Listing | Incompleto | Data Safety, screenshots | — | Pacote Amanda | 8–12 |
| **ALT-06** | Alta | Pagamentos | Tentar Assinar | Gate off / mensagem | Sandbox se Amanda autorizar | `app_config.dart`, `plans_screen.dart` | Keys RC + sandbox | 8–12 |
| **MED-01** | Média | Legais | Abrir `/privacidade` sem .html | **404** | 200 ou redirect | Hosting `public/` | Redirects | 1–2 |
| **MED-02** | Média | Conteúdo | Short YouTube FS | Gap possível vs seed | URLs oficiais | CMS/FS | Amanda cadastra | 1–2 |
| **MED-03** | Média | Homolog web | Testar canal | 200 mas possivelmente velho | Build = branch atual | Hosting channel | Redeploy | 2–4 |
| **BAI-01** | Baixa | App Check | — | Activate sem enforce | Decisão | Firebase | Pós-lançamento | 4–6 |
| **BAI-02** | Baixa | Git | status | ~971 dirty | Histórico limpo | repo | PRs | 4–8 |

---

# D. PLANO DE CORREÇÃO EM ETAPAS

> **Esta etapa para aqui.** Correções só após revisão deste relatório.

### Etapa 1 — Desbloquear homologação (obrigatório)

1. **BLK-01 / BLK-02** — Sair global staff + E2E Voltar/Sair Admin e Personal (web + Android)  
2. **BLK-03** — Contas teste 3 perfis (senhas só canal seguro) + checklist E2E  
3. **MED-03** — Rebuild APK + redeploy canal homolog  
4. **ALT-01 / ALT-02** — Remover ou substituir stubs/métricas fake do Admin (evita falsa “pronto”)  

**Subtotal:** ~35–50 h

### Etapa 2 — Android Play

1. **ALT-03** — Commit estável + AAB assinado  
2. **ALT-05** — Listing / Data Safety / screenshots  
3. **MED-01** — Redirects legais  
4. **ALT-06** — só se Amanda autorizar cobrança  

**Subtotal:** ~24–36 h

### Etapa 3 — iOS

1. **ALT-04** — Firebase iOS + TestFlight  
2. App Privacy + E2E device  

**Subtotal:** ~16–28 h

### Etapa 4 — Pós-lançamento

BAI-01, BAI-02, polish UX  

**Subtotal:** ~8–16 h  

**Total orientativo:** **~80–120 h** (inclui E2E; exclui tempo de decisão da Amanda).

---

# E. CHECKLIST DE HOMOLOGAÇÃO (Admin · Personal · Aluna × Web · Android)

**Instrução:** marcar só com teste real. Senhas fora deste documento.

| Campo | Valor |
|---|---|
| Data / executor | |
| Commit / build | |
| Web | https://metodo1dia-app--homologacao-cw9j2u83.web.app |
| APK | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (ou regenerado) |

### E1. Aluna

| # | Caso | Web | Android |
|---|---|---|---|
| A1 | Cadastro | [ ] | [ ] |
| A2 | Login | [ ] | [ ] |
| A3 | Recuperar senha | [ ] | [ ] |
| A4 | Navegação shell / Voltar | [ ] | [ ] |
| A5 | Treino + exercício + Lily | [ ] | [ ] |
| A6 | Vídeos YouTube | [ ] | [ ] |
| A7 | Meditação + áudio | [ ] | [ ] |
| A8 | Cronômetro | [ ] | [ ] |
| A9 | Desafio | [ ] | [ ] |
| A10 | Hidratação + histórico | [ ] | [ ] |
| A11 | Receitas/PDF | [ ] | [ ] |
| A12 | Calendário / metas / conquistas | [ ] | [ ] |
| A13 | Anamnese / agenda / chat | [ ] | [ ] |
| A14 | Quem sou eu | [ ] | [ ] |
| A15 | Planos (sem pagar real) | [ ] | [ ] |
| A16 | Logout + Voltar não reabre | [ ] | [ ] |

### E2. Personal

| # | Caso | Web | Android |
|---|---|---|---|
| P1 | Login Personal | [ ] | [ ] |
| P2 | **Sair** visível | [ ] | [ ] |
| P3 | Voltar internos | [ ] | [ ] |
| P4 | Voltar sistema na raiz ≠ Aluna | [ ] | [ ] |
| P5 | CMS treino/vídeo/receita/meditação | [ ] | [ ] |
| P6 | Alunas / anamnese / agenda | [ ] | [ ] |
| P7 | Sem painel técnico restrito | [ ] | [ ] |
| P8 | Logout + histórico | [ ] | [ ] |

### E3. Admin (bloqueador histórico)

| # | Caso | Web | Android |
|---|---|---|---|
| D1 | Login Admin | [ ] | [ ] |
| D2 | **Sair** visível na raiz | [ ] | [ ] |
| D3 | **Sair** acessível nas filhas | [ ] | [ ] |
| D4 | Voltar nas filhas | [ ] | [ ] |
| D5 | Voltar sistema na raiz ≠ Aluna/Personal | [ ] | [ ] |
| D6 | Stubs Receitas/Desafios/ações (documentar ou falhar) | [ ] | [ ] |
| D7 | Usuários / assinaturas (leitura) | [ ] | [ ] |
| D8 | Logout + histórico | [ ] | [ ] |

**Status na auditoria 23/09:** todos os itens acima permanecem **não testados (E2E)**.

---

# F. ARTEFATOS E DEPENDÊNCIAS EXTERNAS

### Já existentes (comprovados)

| Item | Caminho / URL | Status |
|---|---|---|
| Homolog web | https://metodo1dia-app--homologacao-cw9j2u83.web.app | HTTP 200 |
| AAB | `build/app/outputs/bundle/release/app-release.aab` | ~148,43 MB |
| APK | `build/app/outputs/flutter-apk/app-release.apk` | ~155,77 MB |
| Privacidade | https://metodo1dia-app.web.app/privacidade.html | 200 |
| Termos | https://metodo1dia-app.web.app/termos.html | 200 |

### Depende de Amanda / acesso externo (não comprovado aqui)

- Contas teste 3 perfis + UID em `admins/{uid}`  
- Keystore Play + `key.properties`  
- Play Console / Apple Developer / Mac  
- GoogleService-Info.plist (iOS)  
- RevenueCat keys (se IAP)  
- Autorização escrita de cobrança  
- Screenshots e textos de loja  

### O que Amanda cadastra sozinha (painel)

Via **Painel da Personal** / rotas Admin reais: treinos (CMS), vídeos, meditações, receitas PDF, áudios/cursos, assets Lily/Amanda, Quem sou eu, e-books, cupons (admin), banco de alimentos.  
**Não** deve depender das abas stub “Receitas/Desafios” nem das ações rápidas do dashboard técnico (hoje só SnackBar).

### Assinaturas — UI vs cobrança

| Camada | Pronta? |
|---|---|
| Telas Planos / Minha Assinatura / Gate / Admin Assinaturas | Sim (UI) |
| Modelo trial 7 dias em Firestore | Sim (código) |
| RevenueCat SDK | Integrado |
| Cobrança / renovação / cancelamento loja | **Não ativo** em produção (`PAYMENTS_ENABLED=false`) |

---

# CONCLUSÃO

O app **pode entrar em homologação controlada** (APK + web), mas **permanece bloqueado para publicação** enquanto:

1. E2E Admin/Personal **Voltar/Sair/logout** não estiver **PASSOU** em web e Android  
2. Stubs/métricas fake do Admin não forem tratados  
3. iOS `REPLACE_ME` e material de loja não forem resolvidos  
4. Working tree não gerar AAB assinável alinhado a um commit  

**Nenhuma correção de código foi feita nesta etapa.** Aguardando revisão para iniciar o plano da seção D.

---

## Arquivos deste relatório

| Formato | Caminho |
|---|---|
| Markdown | `AUDITORIA_COMPLETA_HOMOLOGACAO_20260923.md` |
| PDF | `AUDITORIA_COMPLETA_HOMOLOGACAO_20260923.pdf` |
| Evidência JSON | `tools/_auditoria_final_evidence_20260923.json` |

---

## Adendo (23/09 — pós-evidências paralelas)

1. **Cadeiras Lily (abdutora/extensora):** evidência de assets **APROVADA** (SHA backup ≡ atual; preview Chrome; `test/cadeiras_lily_assets_test.dart` PASS). Flexora intacta. Relatório: `TROCA_CADEIRAS_LILY_20260923.md`. **Não** equivale a E2E do catálogo no Android device (ainda **N** na checklist Aluna A5).
2. **Navegação Admin/Personal:** inspeção atual confirma mitigações já no código (`PopScope` + `StaffSignOutButton` nas raízes; `AppNavigation.hubForPath`). Relatos exploratórios de “sem PopScope / Voltar sempre cai em `/home`” **não descrevem o estado atual do working tree**. Permanecem válidos: **Sair ausente em várias telas filhas**, **E2E não executado**, e **BLK-01** até reaprovação UI.

---

## Adendo de CORREÇÃO (23–24/09/2026)

Correções de código aplicadas — ver **`CORRECAO_BLOQUEIOS_PUBLICACAO_20260923.md`**.

| Item auditoria | Após correção |
|---|---|
| BLK-01 Sair/Voltar filhas staff | **Mitigado no código** (`showStaffSignOut` em 23+ telas) — E2E ainda pendente |
| ALT-01/02 stubs Admin | **Corrigido** (stubs removidos; links CMS reais) |
| Cobrança real | **Continua off** (`PAYMENTS_ENABLED=false`) |
| iOS REPLACE_ME | **Ainda bloqueado** — doc `docs/IOS_FIREBASE_SETUP_20260923.md` |
| E2E 3 perfis | **Não executado** (sem contas; sem device Android nesta sessão) |

### Veredito atualizado

| Alvo | Veredito |
|---|---|
| Homologação web | **Apto para iniciar** (código ok; E2E contas pendente; redeploy recomendado) |
| Homologação Android | **Apto para iniciar em device** (rebuild APK; E2E pendente) |
| Publicação iOS | **Bloqueado** (`REPLACE_ME`) |
| Publicação Play | **Bloqueado** (E2E + listing + AAB assinado) |
