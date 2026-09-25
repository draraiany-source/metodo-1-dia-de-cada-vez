# AUDITORIA FINAL E PACOTE DE ENTREGA AO PROGRAMADOR
## Método 1 Dia de Cada Vez — Amanda Lopes

| Campo | Valor |
|---|---|
| **Data** | 23/09/2026 |
| **Tipo** | Diagnóstico e documentação (sem correção nesta etapa) |
| **Produção alterada?** | **Não** |
| **Cobrança real?** | **Não** (`PAYMENTS_ENABLED` default `false`) |
| **Guest mode** | **Off** (`enableGuestMode = false`) |
| **Evidência técnica** | `tools/_auditoria_final_evidence_20260923.json` |
| **Branch** | `finalizacao-metodo-1-dia-de-cada-vez` |
| **Tag backup** | `backup-pre-homologacao-final-20260922` |
| **Working tree** | ~971 linhas em `git status --short` (não consolidado) |

### Conclusão objetiva

| Pergunta | Resposta |
|---|---|
| **Pronto para homologar?** | **SIM, com ressalvas** — AAB/APK e canal web existem; faltam contas E2E dos 3 perfis e revalidação UI de Voltar/Sair staff |
| **Pronto para publicar Android?** | **NÃO — BLOQUEADO** |
| **Pronto para publicar iOS?** | **NÃO — BLOQUEADO** |

**Motivo do bloqueio de publicação:** E2E dos 3 perfis não documentado como PASSOU; falha observada de Voltar/Sair no Admin (código com mitigação, **E2E não reaprovado**); iOS com `REPLACE_ME`; listing/Data Safety/screenshots incompletos; working tree sujo; cobrança real desligada (decisão comercial).

---

## 1. INVENTÁRIO DO PROJETO

### 1.1 Tecnologias

| Camada | Stack |
|---|---|
| App | Flutter ≥3.19 / Dart ≥3.3 — `metodo_1_dia` **1.0.0+1** |
| Estado / rotas | Riverpod 2.x, go_router 14 |
| Backend | Firebase project **`metodo1dia-app`** (Auth, Firestore, Storage, Functions, FCM, Analytics, Crashlytics, App Check, Hosting) |
| Pagamentos | `purchases_flutter` (RevenueCat) — **gate** `PAYMENTS_ENABLED=false` |
| Outros | Geolocator, just_audio, pdfx/pdf/printing, video_player/chewie, google_fonts |

### 1.2 Identificadores

| Plataforma | ID |
|---|---|
| Android `applicationId` | `com.metodo1dia.app` |
| minSdk / targetSdk | ≥23 / ≥36 |
| iOS bundle | `com.metodo1dia.app` |
| Firebase Android/Web | Credenciais reais em `lib/firebase_options.dart` |
| Firebase iOS | **`apiKey` / `appId` = `REPLACE_ME`** (sem inventar) |

### 1.3 Estrutura relevante

```
lib/features/{auth,home,workouts,nutrition,video_streaming,audio_*,
  personal_trainer,personal_cms,admin,subscriptions,profile,...}
firebase/{firestore.rules,storage.rules}
functions/          # Cloud Functions (IA, trial, URLs)
assets/             # imagens, content JSON, seed vídeos/meditações
android/ / ios/ / public/
```

### 1.4 Ambientes

| Ambiente | URL / artefato | Status (23/09) |
|---|---|---|
| Hosting produção (legais) | https://metodo1dia-app.web.app/privacidade.html | HTTP **200** |
| | https://metodo1dia-app.web.app/termos.html | HTTP **200** |
| | `/privacidade` e `/termos` sem `.html` | HTTP **404** |
| Homologação web (canal) | https://metodo1dia-app--homologacao-cw9j2u83.web.app | HTTP **200** |
| AAB release | `build/app/outputs/bundle/release/app-release.aab` | **~148,43 MB** |
| APK release | `build/app/outputs/flutter-apk/app-release.apk` | **~155,77 MB** |
| APK arm64 | `.../app-arm64-v8a-release.apk` | **~104,61 MB** |

**Atenção:** o canal web de homologação **pode estar defasado** em relação ao working tree atual (último deploy ≠ código sujo local). Validar data do build ao testar.

### 1.5 Comandos essenciais

```bat
flutter pub get
flutter run -d chrome
flutter run -d <android_device>
flutter test
flutter build apk --release --split-per-abi ^
  --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com ^
  --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html ^
  --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html
flutter build appbundle --release --split-debug-info=build/app/debug-info ^
  --dart-define=SUPPORT_EMAIL=... --dart-define=PRIVACY_POLICY_URL=... --dart-define=TERMS_URL=...
REM NÃO passar PAYMENTS_ENABLED=true sem autorização escrita da Amanda
```

Homolog web (quando autorizado):

```bat
flutter build web --release
firebase hosting:channel:deploy homologacao --project metodo1dia-app
```

### 1.6 Acessos / arquivos que o programador precisa da proprietária

**Não incluir senhas nem chaves privadas neste relatório.**

| Item | Quem fornece | Como entregar |
|---|---|---|
| Firebase Console Owner / Editor | Amanda | Convite IAM |
| Google Play Console | Amanda | Conta dela + acesso desenvolvedor |
| Apple Developer | Amanda | Conta dela + Mac |
| Keystore Android + `key.properties` | Amanda / cofre | Canal seguro (1Password/Bitwarden) — **fora do Git** |
| RevenueCat (se IAP) | Amanda | Dashboard + keys via `--dart-define` / CI secrets |
| Contas teste Aluna / Personal / Admin | Amanda + tech | E-mails; senhas só canal seguro |
| UID Admin → `admins/{uid}` | Amanda autoriza; tech grava | Sem senha no PDF |
| Textos listing / screenshots | Amanda | Drive |
| Autorização escrita cobrança | Amanda | E-mail/contrato |

Arquivos locais sensíveis (nunca no Git): `android/key.properties`, `*.jks`, `google-services.json` (já no ignore parcial), `.env`, service accounts.

---

## 2. AUDITORIA FUNCIONAL POR PERFIL

### 2.1 Testes automatizados executados nesta auditoria

| Suite | Resultado | Interpretação |
|---|---|---|
| `user_role_permissions_test.dart` | **PASS** | RBAC unitário (não E2E UI) |
| `app_navigation_staff_back_test.dart` | **PASS** | Hubs Voltar por path |
| `meditations_association_order_test.dart` | **PASS** | Seed meditações 1–7 |
| E2E Aluna / Personal / Admin (web+Android) | **NÃO EXECUTADO** | Contas reais + device |

### 2.2 Matriz por perfil (status honesto)

| Fluxo | Aluna | Personal | Admin | Evidência |
|---|---|---|---|---|
| Cadastro / login | Código + router | Idem | Idem | Unit RBAC; **E2E PENDENTE** |
| Recuperação senha | UI Firebase Auth | — | — | **NÃO retestado UI** |
| Logout | Perfil/Config | `StaffSignOutButton` + chips | `StaffSignOutButton` AppBar | Código presente; **E2E PENDENTE** |
| Voltar interno | Shell + PremiumAppBar | PremiumAppBar / hub | PremiumAppBar filhos | **E2E PENDENTE** |
| Voltar Android na raiz | Shell | `PopScope(canPop:false)` | `PopScope(canPop:false)` | Código; **E2E PENDENTE** |
| Pós-logout não reabre protegida | Login `PopScope` + redirect | Idem | Idem | Código; **E2E PENDENTE** |
| Só dados/funções do papel | Rules + router | Whitelist admin paths | Admin técnico | Unit + rules no repo |

### 2.3 Falha observada: Admin sem Voltar / Sair

| Campo | Detalhe |
|---|---|
| **ID** | BLK-NAV-ADMIN-001 |
| **Prioridade** | **Bloqueador de publicação** até E2E PASSOU |
| **Observado (relato)** | Administradora entra e **não encontra** opção clara de Voltar nem de Sair |
| **Estado do código (23/09)** | Mitigação aplicada: `StaffSignOutButton` no AppBar do Admin; `PopScope(canPop:false)` na raiz; `AppNavigation.hubForPath` evita cair na Home da Aluna |
| **Comportamento esperado** | Sair visível; Voltar em telas internas; raiz não abre Aluna/Personal; logout → login sem histórico protegido |
| **Aceite** | Checklist E2E Admin web **e** Android PASSOU com prints |
| **Nesta auditoria** | **NÃO marcado como aprovado** — só evidência de código + unit |

Personal: mesma família de risco (BLK-NAV-PERSONAL-001) — mitigações no dashboard; E2E pendente.

### 2.4 Módulos de conteúdo (amostra)

| Área | Situação | Teste nesta etapa |
|---|---|---|
| Treinos / 117 exercícios / Lily Fit | Catálogo local + assets; cadeiras mapeadas | Imagens/cadeiras auditadas antes; **E2E UI pendente** |
| Vídeos YouTube | Firestore 3 Shorts + seed; CMS Personal | Leitura FS; play **pendente** |
| Meditações | Seed 7 Shorts ordem 1–7; FS 0 meditacao | Unit PASS; play **pendente** |
| Programa 7 Dias | Mesmos IDs YouTube | Unit/integração parcial |
| Cronômetro / desafio / hidratação | Features no código | **Não retestado UI** |
| Receitas PDF | Remotos / CMS | **Não retestado** |
| Anamnese / agenda / chat IA | Functions 401 sem token (leitura prévia) | **E2E pendente** |
| Quem sou eu / fotos Amanda | CMS Admin/Personal | **E2E pendente** |

### 2.5 O que Amanda cadastra sozinha (painel)

Via **Personal CMS** / Admin (conforme papel): vídeos, meditações (categoria), receitas PDF, e-books, áudios/cursos, assets Lily/Amanda, treinos (catálogo/CMS), cupons (admin), assinaturas **somente visualização** (admin).  
**Não** edita cobrança paga no app; **não** altera `admins/{uid}` pelo cliente aluno.

---

## 3. ASSINATURAS E PAGAMENTOS

| Camada | Existe hoje? | Funcional? |
|---|---|---|
| UI Planos (trial 7d, mensal, trimestral, anual) | Sim | Catálogo / copy |
| Minha Assinatura | Sim | Status / restore UI |
| Admin Assinaturas | Sim | Totais/filtro — sem editar pago |
| Gate Premium (modal) | Sim | Depende de trial/Firestore/RC |
| RevenueCat SDK | Integrado | Precisa keys `--dart-define` |
| **Cobrança real** | **Desligada** | `PAYMENTS_ENABLED=false` |
| Renovação / cancelamento loja | Via Play/App Store | Não validado sandbox nesta etapa |
| Acesso pós-vencimento | Modelo em `subscription_models` + backend | **E2E sandbox PENDENTE** |

**Decisões pendentes com Amanda:** ligar IAP? preços finais? países? trial na loja vs trial app? autorização escrita.

**Lojas:** produtos Play Billing / StoreKit + RevenueCat offerings; Data Safety / App Privacy; sem `PAYMENTS_ENABLED=true` em build de produção sem autorização.

---

## 4. QUALIDADE, SEGURANÇA E PUBLICAÇÃO

| Tema | Status |
|---|---|
| Compilação Android (artefatos locais) | AAB/APK presentes |
| Compilação iOS loja | **Bloqueada** (`REPLACE_ME` + Mac) |
| Tamanho AAB | ~148 MB (meta Play install-time ok-ish; ainda monitorar) |
| Working tree | ~971 alterações — risco de build irreproduzível |
| Guest / login falso | Off |
| Firestore rules | Catch-all deny no repo |
| Functions sem token | 401 (evidência prévia) |
| Privacidade/Termos | HTML 200; paths sem `.html` 404 |
| Exclusão de conta | Código presente — **E2E PENDENTE** |
| Conteúdo provisório | Possível em CMS/FS; Amanda revisa |

**Plataformas:** teste web **≠** Android **≠** iOS. Nunca cruzar aprovação.

---

## 5. HOMOLOGAÇÃO

### 5.1 Já existentes

| Entrega | Caminho / URL |
|---|---|
| Web homolog | https://metodo1dia-app--homologacao-cw9j2u83.web.app |
| AAB | `build/app/outputs/bundle/release/app-release.aab` (~148,43 MB) |
| APK | `build/app/outputs/flutter-apk/app-release.apk` (~155,77 MB) |
| APK arm64 (teste celular) | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (~104,61 MB) |

### 5.2 Contas de teste

**Não criadas nesta auditoria** (sem escrita Auth/FS).  
Procedimento: Amanda cria 3 e-mails → tech promove Admin em `admins/{uid}` e Personal via flag/doc → senhas **somente** canal seguro → preencher `ROTEIRO_E2E_TRES_PERFIS_EXECUCAO.md`.

### 5.3 Regenerar artefatos (se defasados)

Ver §1.5. Assinar AAB com keystore da Amanda antes da Play.

---

## 6. PENDÊNCIAS PARA ORÇAMENTO (com horas)

### Legenda de prioridade

- **BLK** = bloqueador de publicação  
- **A** = obrigatório homologação  
- **B** = obrigatório Android store  
- **C** = obrigatório iOS store  
- **D** = pós-lançamento  

| ID | Pri | Perfil/Plat | Problema | Repro | Esperado | Observado | Módulo | Correção / aceite | h |
|---|---|---|---|---|---|---|---|---|---:|
| BLK-01 | BLK/A | Admin+Personal / Web+Android | Voltar/Sair / pós-logout | Entrar Admin; buscar Sair; Voltar raiz; logout; Voltar sistema | Sair+voltar seguros | Relato falha; código mitigado **sem E2E** | `admin_screen`, `personal_dashboard`, `app_navigation`, `session_sign_out` | E2E PASSOU c/ prints | 8–12 |
| BLK-02 | BLK/A | 3 perfis | E2E não documentado | Roteiro E2E completo | Checklist PASSOU | Pendente contas | App + Auth | Contas + execução | 12–16 |
| BLK-03 | B | Android | Working tree / AAB alinhado commit | `git status`; rebuild AAB | Artefato = código release | 971 dirty; AAB local existe | assets/lib/git | Commit + AAB assinado | 6–10 |
| BLK-04 | B | Android loja | Listing / Data Safety / screenshots | Play Console | Pacote completo | Incompleto | Store | Pacote + formulários | 8–12 |
| BLK-05 | C | iOS | REPLACE_ME + IPA | `flutterfire` + Archive | TestFlight ok | REPLACE_ME | `firebase_options`, ios/ | Mac + configure + IPA | 12–20 |
| BLK-06 | A/B | Todos | Legais URL sem .html 404 | Abrir /privacidade | 200 ou redirect | 404 bare path | Hosting | Redirect ou docs só .html | 1–2 |
| P1-01 | B | Conteúdo | Short `lLfcuiW32iI` no FS? | CMS/FS | Só URL nova | Não no repo | videos | Amanda/CMS | 1–2 |
| P1-02 | B/C | Pagamentos | Sandbox RC | Compra teste | Trial/restore ok | Não feito | subscriptions | RC keys + sandbox | 8–12 |
| P1-03 | D | App Check | Enforce | Decisão | Plano | Activate sem enforce | Firebase | Decisão+teste | 4–6 |
| P2-01 | D | UX | Hub meditações copy | — | Claridade | Ajustado em seed antes | meditations | Já mitigado seed | 0 |
| P2-02 | D | Git | Limpeza commits | — | Histórico limpo | Dirty | repo | PRs pequenos | 4–8 |

**Estimativa total (faixas):**  

| Bloco | Horas |
|---|---:|
| A — Homologação | 20–30 |
| B — Android publicar | 24–36 |
| C — iOS publicar | 16–28 |
| D — Melhorias | 8–16 |
| **Total orientativo** | **~70–110 h** |

(Não inclui tempo de Amanda em conteúdo/decisão comercial.)

### Separação A/B/C/D

**A — Homologação:** BLK-01, BLK-02, contas teste, APK/canal atualizados, legais .html ok.  
**B — Android:** BLK-03, BLK-04, AAB assinado, Data Safety, P1-01 se aplicável, sandbox se IAP.  
**C — iOS:** BLK-05, App Privacy, TestFlight, Mac.  
**D — Depois:** P1-03, P2-*, polish UX, App Check enforce.

### Ordem de execução sugerida

1. Contas teste + E2E Voltar/Sair/Logout (BLK-01/02)  
2. Commit working tree + rebuild AAB/APK  
3. Fix redirect legais + material Play  
4. Decisão IAP + sandbox  
5. iOS flutterfire + TestFlight  
6. Submissão lojas  

---

## 7. ENTREGÁVEIS DESTE PACOTE

| Arquivo | Caminho |
|---|---|
| Relatório Markdown (este) | `AUDITORIA_FINAL_ENTREGA_PROGRAMADOR_20260923.md` |
| PDF | `AUDITORIA_FINAL_ENTREGA_PROGRAMADOR_20260923.pdf` |
| Checklist perfis | `CHECKLIST_E2E_TRES_PERFIS_ENTREGA_20260923.md` |
| Checklist lojas | `CHECKLIST_PUBLICACAO_ANDROID_IOS_ENTREGA_20260923.md` |
| Acessos Amanda | `LISTA_ACESSOS_AMANDA_ENTREGA_20260923.md` |
| Evidência JSON | `tools/_auditoria_final_evidence_20260923.json` |

Documentos auxiliares já existentes: `PENDENCIAS_PROGRAMADOR.md`, `PENDENCIAS_AMANDA.md`, `ROTEIRO_E2E_TRES_PERFIS_EXECUCAO.md`, `RELATORIO_PLANOS_ASSINATURAS.md`, `CORRECAO_NAV_LOGOUT_STAFF_20260923.md`.

---

## 8. O QUE NÃO FOI FEITO NESTA ETAPA

- Correção de bugs (apenas documentação)  
- Deploy / alteração produção  
- Ativação de cobrança  
- Criação de contas de teste  
- Marcação de E2E como aprovado  

**Fim do relatório.**
