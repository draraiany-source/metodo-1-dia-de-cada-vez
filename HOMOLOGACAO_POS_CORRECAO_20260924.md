# HOMOLOGAÇÃO PÓS-CORREÇÃO — Relatório ao Programador
## Método 1 Dia de Cada Vez — Amanda Lopes

| Campo | Valor |
|---|---|
| **Data** | 24/09/2026 |
| **Branch** | `finalizacao-metodo-1-dia-de-cada-vez` |
| **Commit HEAD** | `293ffa999870a26a0ce837e2e5484b66de6da31f` (`293ffa9`) |
| **Working tree** | **SUJO** (~1003 linhas) — correções Voltar/Sair/Admin **ainda não commitadas** |
| **Carimbo de build pretendido** | `HOMOLOG_BUILD_ID=20260924-nav` |
| **Cobrança real** | **DESATIVADA** (`PAYMENTS_ENABLED` default `false`) |
| **iOS Firebase** | **`REPLACE_ME`** (`iosFirebaseReady = false`) |
| **Publicação lojas** | **BLOQUEADA** nesta etapa |

---

## 1. Qual versão os testes devem usar

**ATENÇÃO — risco de testar build antigo:**

| Fonte | Contém correções Voltar/Sair + Admin stubs? |
|---|---|
| Commit `293ffa9` | **NÃO** — snapshot anterior às correções desta sessão |
| Working tree local (arquivos modificados) | **SIM** — `premium_app_bar.dart`, `admin_screen.dart`, 23+ telas staff, etc. |
| Canal web antigo `…--homologacao-cw9j2u83.web.app` | **PROVAVELMENTE NÃO** — sem evidência de redeploy pós-correção |
| APK/AAB em `build/` de 23/09 | **PROVAVELMENTE NÃO** — gerados antes do carimbo `20260924-nav` |

**Regra:** só declarar BLK-01 resolvido após E2E em artefato **novo** gerado a partir do working tree atual (ou commit que inclua as correções), com carimbo `homolog 20260924-nav` na tela de login.

Arquivos-chave modificados (não commitados no HEAD):
- `lib/core/router/premium_app_bar.dart` (`showStaffSignOut`)
- `lib/core/auth/staff_sign_out_button.dart`
- `lib/features/admin/presentation/admin_screen.dart` (stubs removidos)
- 23 telas Admin/Personal/CMS com Voltar + Sair
- `lib/core/config/app_config.dart` + `login_screen.dart` (carimbo homolog)
- `lib/firebase_options.dart` (`iosFirebaseReady`)

---

## 2. Builds de homologação (esta sessão)

| Artefato | Status | Detalhe |
|---|---|---|
| `flutter build web --release` + `HOMOLOG_BUILD_ID=20260924-nav` | **OK** | `√ Built build\web` (~741 s). Carimbo em `main.dart.js` |
| Deploy canal `homologacao` (Flutter) | **OK** | 736 arquivos de `build/web` via `firebase.homolog.json` → https://metodo1dia-app--homologacao-cw9j2u83.web.app |
| Deploy anterior só `public/` (4 arquivos) | **Descartado** | Não era o app Flutter — corrigido com config homolog |
| APK split ABI + carimbo | **OK** | `app-arm64-v8a-release.apk` ~107,2 MB (e demais ABIs) |
| `firebase.json` produção | **Inalterado** (`public` = legais) | Homolog usa `firebase.homolog.json` |

**Procedimento exato para regenerar (quando a máquina estiver livre):**

```bat
cd /d "C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2"

flutter build web --release ^
  --dart-define=HOMOLOG_BUILD_ID=20260924-nav ^
  --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com ^
  --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html ^
  --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html ^
  --dart-define=PAYMENTS_ENABLED=false

firebase hosting:channel:deploy homologacao --project metodo1dia-app

set GRADLE_USER_HOME=C:\Users\Lenovo\.gradle
flutter build apk --release --split-per-abi ^
  --dart-define=HOMOLOG_BUILD_ID=20260924-nav ^
  --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com ^
  --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html ^
  --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html ^
  --dart-define=PAYMENTS_ENABLED=false
```

Confirmar carimbo: na tela de login deve aparecer `v1.0.0+1 · homolog 20260924-nav`.

---

## 3. Testes automatizados

| Suite | Resultado nesta sessão |
|---|---|
| `premium_app_bar_staff_test` (2) | **PASS** |
| `app_navigation_staff_back_test` (4) | **PASS** |
| `user_role_permissions_test` (11) | **PASS** |
| `meditations_association_order_test` (1) | **PASS** |
| `cadeiras_lily_assets_test` (2) | **PASS** |
| **Total** | **+20 All tests passed! EXIT=0** — log `tools/_homolog_tests_20260924.log` |

**Regra:** testes VM **PASS ≠** E2E web/Android aprovado.

---

## 4. Testes manuais E2E — Web e Android

### 4.1 Pré-requisitos faltando (bloqueia E2E)

| Item | Status | O que você precisa providenciar |
|---|---|---|
| 3 contas Auth homolog (Admin / Personal / Aluna) | **AUSENTES** nesta sessão | Criar no Firebase Auth + papel (`admins/{uid}`, `isPersonalTrainer`, aluno). Enviar **e-mails** por canal aberto; **senhas só cofre** |
| Autorização escrita para usar contas | Pendente | Confirmação da Amanda |
| Device ou emulador Android | **NÃO CONECTADO** | Só Windows / Chrome / Edge listados em `flutter devices` |
| Web build novo no canal homolog | **Não atualizado** | Acesso Firebase CLI logado no projeto `metodo1dia-app` + rebuild |
| APK carimbado instalável | **Não gerado** | Rebuild APK (acima) |
| Mac / iOS | Fora do escopo E2E atual | `GoogleService-Info.plist` / `flutterfire configure` |

**Não** foram usadas contas reais de produção. **Nenhuma senha** neste relatório.

### 4.2 Matriz E2E (todos NÃO TESTADO)

Legenda: **NT** = Não testado.

#### Web — Aluna | Personal | Admin

| ID | Plataforma | Perfil | Versão | Passos | Esperado | Obtido | Evidência |
|---|---|---|---|---|---|---|---|
| W-A01 | Web | Aluna | — | Login → home → treinos/vídeos/meditações/PDF → Sair → Voltar | Funções OK; logout seguro | **NT** | Sem conta + canal possivelmente antigo |
| W-P01 | Web | Personal | — | Login → Central → CMS → Voltar/Sair → relogin | Sair visível; sem cruzar Aluna | **NT** | Sem conta |
| W-D01 | Web | Admin | — | Login → Painel → filhas Voltar/Sair → métricas reais → Sair | Sem stubs; Sair/Voltar OK | **NT** | Sem conta |
| W-X01 | Web | Troca 3 perfis | — | Sequência logout entre papéis | Sem sessão residual | **NT** | Sem contas |

#### Android — Aluna | Personal | Admin

| ID | Plataforma | Perfil | Versão | Passos | Esperado | Obtido | Evidência |
|---|---|---|---|---|---|---|---|
| AN-A01 | Android | Aluna | — | APK novo + fluxos + botão Voltar físico | Voltar não prende / não troca perfil indevido | **NT** | Sem device + sem APK novo |
| AN-P01 | Android | Personal | — | Idem + Voltar na raiz | `PopScope` não abre Aluna | **NT** | Sem device |
| AN-D01 | Android | Admin | — | Idem + Sair nas filhas | Logout → login; Voltar não reabre | **NT** | Sem device |

### 4.3 Conteúdos específicos (vídeos, meditações, áudios, PDFs, treinos, Lily)

| Conteúdo | Status | Nota |
|---|---|---|
| Ordem meditações 1–7 (seed) | Unit **PASS** em sessões anteriores | Play E2E **NT** |
| Cadeiras Lily abdutora/extensora | Asset **APROVADO** (SHA) | Catálogo no device **NT** |
| Vídeos YouTube / áudios / PDFs | Código/CMS existem | Reprodução E2E **NT** |
| Painel Admin dados reais | Stubs removidos no código | Validação com login Admin **NT** |

---

## 5. Estado cobrança e iOS (revalidado 24/09)

| Item | Estado atual no código |
|---|---|
| `PAYMENTS_ENABLED` | default **`false`** — cobrança real **não** ativada |
| `BILLING_SANDBOX` | default **`false`** |
| iOS `apiKey` / `appId` | **`REPLACE_ME`** |
| `DefaultFirebaseOptions.iosFirebaseReady` | **`false`** |
| `GoogleService-Info.plist` | **Ausente** no repo |

---

## 6. Correções confirmadas no código (não no E2E)

| Correção | Confirmado como |
|---|---|
| `showStaffSignOut` em filhas Admin/Personal/CMS | **Código presente** (grep/revisão) |
| Sair + `PopScope` nas raízes | **Código presente** |
| Remoção métricas/ações fake Admin | **Código presente** |
| Links CMS Receitas/Desafios | **Código presente** |
| Carimbo `HOMOLOG_BUILD_ID` no login | **Código presente** |
| BLK-01 “resolvido em produção/homolog” | **NÃO** — falta E2E no artefato novo |

---

## 7. Falhas / pendências por prioridade

| Pri | ID | Problema |
|---|---|---|
| **BLK** | H-01 | E2E 3 perfis web **NT** (sem contas autorizadas) — ambiente já atualizado |
| **BLK** | H-02 | E2E 3 perfis Android **NT** (sem device; APK novo pronto em `build/app/outputs/flutter-apk/`) |
| **—** | H-03 | ~~Artefato web defasado~~ → **resolvido** (canal com 736 arquivos + stamp) |
| **ALT** | H-04 | Working tree sujo — HEAD `293ffa9` ≠ código do artefato; commit recomendado |
| **BLK** | H-05 | iOS `REPLACE_ME` — publicação iOS impossível |
| **—** | H-06 | ~~Rebuild falhou~~ → web + APK **OK** nesta sessão |
| **MED** | H-08 | Paths legais sem `.html` → 404 (produção) |

---

## 8. Veredito separado

| Alvo | Veredito | Motivo |
|---|---|---|
| **Homologação web (ambiente)** | **ATUALIZADO** — pronto para E2E humano | Canal com app Flutter carimbado `20260924-nav` (JS confirma stamp) |
| **Aceite E2E web** | **BLOQUEADO** | Sem contas Admin/Personal/Aluna autorizadas — fluxos manuais **NT** |
| **Homologação Android (artefato)** | **APK NOVO DISPONÍVEL** | `app-arm64-v8a-release.apk` ~107 MB carimbado; **sem device** nesta sessão |
| **Aceite E2E Android** | **BLOQUEADO** | Sem aparelho/emulador + sem contas |
| **Publicação iOS** | **BLOQUEADA** | `REPLACE_ME` + sem Mac/plist |
| **Publicação Play** | **BLOQUEADA** | E2E + listing + AAB assinado + decisão cobrança |

Código das correções + artefatos novos existem. **Não** declarar “homologado / bloqueio resolvido” sem E2E manual nos 3 perfis.

---

## 9. Checklist do que a Amanda / programador deve enviar agora

1. **3 e-mails** de contas homolog (Admin, Personal, Aluna) — senhas só no cofre.  
2. Confirmação de papéis no Firestore (`admins/{uid}`, `isPersonalTrainer`).  
3. **Aparelho Android** ou emulador conectado (`flutter devices` deve listar).  
4. Acesso Firebase CLI / Console para `firebase hosting:channel:deploy homologacao`.  
5. (iOS, depois) `GoogleService-Info.plist` ou sessão Mac com `flutterfire configure`.  
6. Autorização escrita se for ligar sandbox de cobrança (`BILLING_SANDBOX`) — **não** produção.

---

## 10. Arquivos relacionados

- Este relatório MD: `HOMOLOGACAO_POS_CORRECAO_20260924.md`
- PDF: `HOMOLOGACAO_POS_CORRECAO_20260924.pdf`
- Auditoria base: `AUDITORIA_COMPLETA_HOMOLOGACAO_20260923.md`
- Correções código: `CORRECAO_BLOQUEIOS_PUBLICACAO_20260923.md`
- Roteiro E2E: `ROTEIRO_E2E_TRES_PERFIS_EXECUCAO.md` / `CHECKLIST_E2E_TRES_PERFIS_ENTREGA_20260923.md`

**Fim.** Sem publicação. Sem cobrança real. Sem senhas.
