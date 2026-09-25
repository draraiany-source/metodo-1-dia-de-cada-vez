# AUDITORIA FINAL — Método 1 Dia de Cada Vez
## Relatório para o programador

| Campo | Valor |
|---|---|
| **Data da auditoria** | 24/09/2026 |
| **Escopo** | Somente diagnóstico e documentação — **código não alterado nesta tarefa** |
| **Produção / lojas** | Não publicadas |
| **Cobrança real** | **Desativada** (`PAYMENTS_ENABLED` default `false`) |
| **Branch** | `finalizacao-metodo-1-dia-de-cada-vez` |
| **Commit HEAD** | `293ffa999870a26a0ce837e2e5484b66de6da31f` (`293ffa9`) — 20/09/2026 |
| **Working tree** | **SUJO** (~1008 linhas) — correções de nav/Admin **presentes no disco, não commitadas** |
| **Versão app** | `metodo_1_dia` **1.0.0+1** |
| **IDs** | Android/iOS `com.metodo1dia.app` · minSdk ≥23 · targetSdk ≥36 |
| **Firebase** | `metodo1dia-app` |
| **Carimbo homolog** | `HOMOLOG_BUILD_ID=20260924-nav` |
| **Auditoria anterior** | `AUDITORIA_COMPLETA_HOMOLOGACAO_20260923.md` |
| **Homolog pós-correção** | `HOMOLOGACAO_POS_CORRECAO_20260924.md` |

**Regra:** leitura de código ≠ aprovação E2E. Sem evidência de execução = **não testado**.

---

## 1. Resumo executivo

O app Flutter está funcionalmente amplo (Auth, Aluna, Personal/CMS, Admin, planos, Firebase). Desde a auditoria de 23/09 houve **mitigações de código** (Voltar/Sair staff, remoção de stubs Admin) e **artefatos novos** (web no canal homolog + APK arm64) com carimbo `20260924-nav`.

**Contudo:** o aceite E2E dos três perfis **não foi executado** (sem contas homolog autorizadas; sem device Android nesta sessão). iOS permanece `REPLACE_ME`. Cobrança real permanece off. Working tree sujo impede reproduzir exatamente o HEAD do Git.

### Veredito por plataforma

| Alvo | Veredito | Evidência |
|---|---|---|
| **Homologação web (ambiente)** | **Ambiente atualizado** — apto a E2E humano | Canal https://metodo1dia-app--homologacao-cw9j2u83.web.app HTTP 200; `main.dart.js` contém `20260924-nav` (24/09) |
| **Aceite E2E web** | **BLOQUEADO** | Login 3 perfis **não testado** (sem contas) |
| **Homologação Android (artefato)** | **APK disponível** | `app-arm64-v8a-release.apk` ~107,2 MB (24/09 00:14) |
| **Aceite E2E Android** | **BLOQUEADO** | Sem device/emulador; E2E **não testado** |
| **Homologação / publicação iOS** | **BLOQUEADO** | `apiKey`/`appId` = `REPLACE_ME`; sem Mac/simulador nesta sessão |
| **Publicação Play Store** | **BLOQUEADO** | E2E + listing + AAB assinado + decisão cobrança |

**Não declarar pronto para publicar.**

---

## 2. Inventário de funções

Legenda: **F** funciona (provado em teste real) · **P** parcial · **X** falha · **NI** não implementada / stub · **C** só código · **NT** não testado (execução)

| Função | Status | Evidência / nota |
|---|---|---|
| Cadastro / login / reset senha | NT / C | Telas + Auth repo; E2E sem contas |
| Logout Aluna | NT / C | `signOutAndGoToLogin` |
| Logout Admin / Personal (raiz) | C — E2E NT | `StaffSignOutButton` + `PopScope` |
| Voltar filhas Admin/Personal | C — E2E NT | `PremiumAppBar` + `showStaffSignOut` (~23 telas) |
| Voltar Android raiz staff | C — E2E NT | `PopScope(canPop:false)` — **sem device** |
| Pós-logout histórico | C — E2E NT | Login `PopScope` + redirect |
| Permissões 3 papéis | F (unit) / NT (UI) | `user_role_permissions_test` PASS |
| Cruzamento indevido de perfil | NT | Precisa login real |
| Expiração de sessão | NT | Não exercitado |
| Treinos / exercícios | NT / C | Catálogo local |
| Imagens Lily (cadeiras) | F (asset unit) / NT (UI app) | `cadeiras_lily_assets_test` PASS; SHA ok relatório Lily |
| Vídeos YouTube (play) | NT | — |
| Meditações ordem 1–7 | F (seed unit) / NT (play) | `meditations_association_order_test` PASS |
| Áudios / Programa 7 dias | NT / C | — |
| PDFs / receitas | NT / C | CMS existe |
| Hidratação / calendário / metas / corrida | NT / C | Features no código |
| Anamnese / agenda / chat | NT / C | Chat Functions exigem token (evid. prévia) |
| Quem sou eu (edição) | NT / C | Rotas Admin/Personal |
| CMS Amanda (CRUD vídeo/foto) | NT / C | Hub + admins |
| Painel Admin métricas fake | **Corrigido no código** | Removido; aviso “métricas não ligadas” |
| Admin stubs Receitas/Desafios | **Corrigido no código** | Links CMS reais; abas Dashboard+Treinos |
| Planos UI | C | Telas existem |
| Cobrança / trial loja / restore | P / NT | UI + SDK; **PAYMENTS_ENABLED=false** |
| iOS Firebase | X | `REPLACE_ME` |
| Privacidade/Termos `.html` | F (HTTP) | 200 |
| Paths sem `.html` | X | 404 |

---

## 3. Comparação com bloqueios da auditoria 23/09

| ID anterior | Tema | Status 24/09 |
|---|---|---|
| **BLK-01** Admin Voltar/Sair | Mitigação código + filhas com `showStaffSignOut` + canal/APK novos | **Persistente para aceite** — E2E **NT** (sem evidência de UI logada) |
| **BLK-02** Personal Voltar/Sair | Idem | **Persistente para aceite** — E2E NT |
| **BLK-03** E2E 3 perfis | Contas + device | **Persistente** — NT |
| **ALT-01/02** Stubs/métricas Admin | Removidos no working tree | **Corrigido no código** — validação Admin logado **NT** |
| **ALT-03** AAB/working tree | APK novo ok; AAB 22/09; tree sujo | **Parcial** — commit ainda necessário |
| **ALT-04** iOS REPLACE_ME | Inalterado | **Persistente** |
| **ALT-05** Listing lojas | — | **Persistente** (fora do código) |
| **ALT-06** Sandbox cobrança | Não executado | **Persistente / NT** |
| **MED-01** Legais bare path 404 | Confirmado 24/09 | **Persistente** |
| **MED-03** Canal homolog defasado | Redeploy Flutter 736 arquivos + stamp | **Corrigido (ambiente)** |

---

## 4. Problemas priorizados (restantes)

### BLK-E2E-01 — Aceite E2E três perfis não executado
| Campo | Detalhe |
|---|---|
| Prioridade | **Bloqueador** de aceite homologação / publicação |
| Plataforma | Web + Android |
| Passos | Login Admin → filhas Voltar/Sair → logout → Personal → Aluna (roteiro E2E) |
| Esperado | Checklist PASSOU com prints |
| Observado | **Não testado** — sem contas Auth homolog; Android sem device |
| Rota/arquivo | App inteiro; `ROTEIRO_E2E_TRES_PERFIS_EXECUCAO.md` |
| Evidência | `flutter devices` só Windows/Chrome/Edge; ausência de credenciais na sessão |

### BLK-IOS-01 — Firebase iOS REPLACE_ME
| Campo | Detalhe |
|---|---|
| Prioridade | **Bloqueador** iOS |
| Observado | `lib/firebase_options.dart` apiKey/appId = `REPLACE_ME`; `iosFirebaseReady=false` |
| Esperado | Credenciais reais após `flutterfire configure` |
| Evidência | Grep 24/09 |

### BLK-PAY-01 — Cobrança real desligada / sandbox não validado
| Campo | Detalhe |
|---|---|
| Prioridade | Bloqueador se lançamento exigir IAP; caso contrário decisão comercial |
| Observado | `PAYMENTS_ENABLED=false`; UI de planos existe |
| Esperado | Autorização Amanda + sandbox + produtos loja |
| Evidência | `app_config.dart`; builds com `--dart-define=PAYMENTS_ENABLED=false` |

### ALT-GIT-01 — Working tree ≠ HEAD
| Campo | Detalhe |
|---|---|
| Prioridade | Alta |
| Observado | ~1008 dirty; HEAD `293ffa9` sem correções |
| Esperado | Commit/tag do estado carimbado `20260924-nav` |
| Evidência | `git status` |

### MED-LEGAL-01 — `/privacidade` e `/termos` sem `.html` → 404
| Campo | Detalhe |
|---|---|
| Prioridade | Média |
| Evidência | HTTP 24/09: `.html` 200; bare 404 |

### BLK-01 (legado) — Aceite UI Admin/Personal Voltar/Sair
| Campo | Detalhe |
|---|---|
| Prioridade | Bloqueador até E2E |
| Código | Mitigado (`showStaffSignOut` em ≥22 arquivos; raízes com Sair) |
| Aceite | **Sem evidência suficiente** de teste logado |

---

## 5. Testes e builds executados

### 5.1 Automatizados (VM)

| Comando | Data | Resultado |
|---|---|---|
| `flutter test test/premium_app_bar_staff_test.dart test/app_navigation_staff_back_test.dart test/user_role_permissions_test.dart test/meditations_association_order_test.dart test/cadeiras_lily_assets_test.dart` | 24/09/2026 | **+20 All tests passed! EXIT=0** — logs `tools/_homolog_tests_20260924.log` e `tools/_auditoria_final_tests_20260924.log` |

**Não** interpretado como E2E de perfil.

### 5.2 HTTP / artefatos

| Item | Resultado 24/09 |
|---|---|
| Homolog index | **200** |
| Homolog `main.dart.js` contém `20260924-nav` | **True** |
| `privacidade.html` / `termos.html` | **200** |
| `/privacidade` / `/termos` | **404** |
| APK arm64 | ~107,22 MB — 24/09 00:14 |
| AAB release | ~148,43 MB — 22/09 (possivelmente anterior às últimas correções de nav) |
| Devices | Windows, Chrome, Edge — **sem Android/iOS** |

### 5.3 Manuais E2E (web / Android / iOS)

| Plataforma | Perfil | Resultado |
|---|---|---|
| Web | Admin / Personal / Aluna | **NÃO TESTADO** — sem contas |
| Android | Admin / Personal / Aluna | **NÃO TESTADO** — sem device + sem instalação nesta auditoria |
| iOS | — | **NÃO TESTADO** — sem ambiente; `REPLACE_ME` |

---

## 6. Checklist de correções para o programador (ordem)

1. **Commit** do working tree das correções nav/Admin + tag alinhada a `20260924-nav`.  
2. Com contas homolog: executar **E2E completo** web + Android (`CHECKLIST_E2E_TRES_PERFIS_ENTREGA_20260923.md`) — Voltar/Sair/logout/permissões.  
3. Confirmar no Admin logado: ausência de stubs; CMS Receitas/Desafios; Sair nas filhas.  
4. Validar conteúdos Aluna: play YouTube, meditações ordem, Lily, PDF, hidratação (device).  
5. Redirect legais bare path → `.html`.  
6. Decisão Amanda: IAP; se sim, sandbox (`BILLING_SANDBOX`) **sem** produção.  
7. iOS: registrar app + `flutterfire configure` + TestFlight.  
8. Listing Play/App Store + AAB assinado (keystore Amanda).  

---

## 7. Pendências da proprietária (Amanda)

| # | Item |
|---|---|
| 1 | 3 contas Auth homolog (e-mails); senhas só cofre |
| 2 | UIDs Admin (`admins/{uid}`) e Personal (`isPersonalTrainer`) |
| 3 | Autorização escrita para testes com essas contas |
| 4 | Device Android ou emulador para QA |
| 5 | Decisão final de planos / preços / ativar cobrança |
| 6 | Keystore Play + acesso Console |
| 7 | Apple Developer + Mac + GoogleService-Info.plist |
| 8 | Textos/screenshots Data Safety / App Privacy |

---

## 8. Critérios para nova homologação / liberação

### Nova homologação (aceite)
- [ ] Login carimbado `homolog 20260924-nav` (ou carimbo posterior documentado)  
- [ ] E2E Aluna + Personal + Admin **PASSOU** em **web e Android** com prints  
- [ ] BLK-01/02 Voltar/Sair/logout documentados PASSOU  
- [ ] Sem stubs enganosos no Admin (validado logado)  
- [ ] Cobrança real continua off **ou** sandbox autorizado e testado  

### Liberar Android (Play)
- [ ] Homologação aceite acima  
- [ ] AAB assinado = commit de release  
- [ ] Listing + Data Safety  
- [ ] Decisão IAP cumprida  

### Liberar iOS
- [ ] `REPLACE_ME` removido  
- [ ] TestFlight E2E 3 perfis  
- [ ] App Privacy  

### Liberar web “produção app”
- [ ] Decisão se o app Flutter deve ir ao hosting live (hoje `public/` = legais)  
- [ ] Separar canal legais vs app  

---

## 9. Conclusão

| Afirmação | Sustentada? |
|---|---|
| Código de Voltar/Sair staff melhorou vs auditoria 23/09 | **Sim** (grep `showStaffSignOut`, Admin sem stubs) |
| Ambiente web homolog contém build carimbado | **Sim** (HTTP + stamp) |
| APK novo existe | **Sim** |
| BLK-01 “resolvido em uso real” | **Não** — E2E NT |
| Pronto para publicar | **Não** |

**Arquivos desta entrega:**  
- Markdown: `AUDITORIA_FINAL_METODO_1_DIA_PARA_PROGRAMADOR.md`  
- PDF: `AUDITORIA_FINAL_METODO_1_DIA_PARA_PROGRAMADOR.pdf`

Sem senhas. Sem publicação. Sem cobrança real. Sem alteração de código nesta tarefa.
