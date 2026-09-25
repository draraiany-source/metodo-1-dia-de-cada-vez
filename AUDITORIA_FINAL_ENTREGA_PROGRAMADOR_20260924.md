# AUDITORIA FINAL — Entrega ao Programador
## Método 1 Dia de Cada Vez (Amanda Lopes)

| Campo | Valor comprovado |
|---|---|
| **Data** | 24/09/2026 |
| **Branch** | `finalizacao-metodo-1-dia-de-cada-vez` |
| **Commit das correções Voltar/Sair** | `7aaf08bede993d77d2aa90ff990e8a90cae1e115` (`7aaf08b`) |
| **Mensagem** | `fix: navegacao staff Voltar/Sair, Admin sem stubs e homolog carimbada` (40 arquivos) |
| **Relação com origin** | Ahead **3** de `origin/finalizacao-metodo-1-dia-de-cada-vez` (não publicado nesta auditoria) |
| **Working tree** | **SUJO** (centenas de assets/docs fora do commit `7aaf08b`) |
| **Versão app** | `1.0.0+2` (`pubspec.yaml`) |
| **Carimbo homolog** | `HOMOLOG_BUILD_ID=20260924-nav` |
| **Cobrança real** | **DESLIGADA** (`PAYMENTS_ENABLED` default `false`; builds com `--dart-define=PAYMENTS_ENABLED=false`) |
| **Firebase projeto** | `metodo1dia-app` |
| **Baseline** | `HOMOLOGACAO_POS_CORRECAO_20260924.md` / `.pdf` |
| **Lojas** | **Não publicadas** nesta etapa |

**Regra desta auditoria:** só entra como PASSOU o que foi executado com evidência. Código presente ≠ E2E aprovado.

---

## 1. Resumo executivo

As correções de **Voltar/Sair** (Admin/Personal/CMS) e a remoção de stubs do painel Admin estão **commitadas** em `7aaf08b` e **presentes** nos artefatos de homologação carimbados `20260924-nav` (web no canal Firebase + APK arm64).

Testes automatizados de navegação/RBAC/meditações/cadeiras: **+20 PASS**.

Aceite E2E dos três perfis (login, permissões, Voltar, Sair, troca de contas, treinos, vídeos, 7 meditações, áudios, PDFs) no web e no Android: **NÃO TESTADO** — falta de contas homolog autorizadas e de device/emulador Android (`flutter devices` só Windows/Chrome/Edge).

iOS permanece bloqueado por `REPLACE_ME`. Paths legais sem `.html` ainda 404 em produção. **Não declarar pronto para Play Store / App Store.**

### Veredito por plataforma

| Alvo | Veredito | Evidência |
|---|---|---|
| **Web homolog (ambiente)** | Ambiente atualizado com carimbo | https://metodo1dia-app--homologacao-cw9j2u83.web.app — `main.dart.js` contém `20260924-nav` (HTTP 200) |
| **Aceite E2E web** | **BLOQUEADO** | Matriz abaixo = **NÃO TESTADO** |
| **Android homolog (APK)** | Artefato novo com carimbo | `app-arm64-v8a-release.apk` — string `20260924-nav` / `homolog 20260924-nav` encontrada no binário |
| **Aceite E2E Android** | **BLOQUEADO** | Sem device; matriz = **NÃO TESTADO** |
| **iOS** | **BLOQUEADO** | `apiKey`/`appId` = `REPLACE_ME`; ver `docs/IOS_REPLACE_ME_PENDENTE.md` |
| **Play Store / App Store** | **BLOQUEADO** | E2E + iOS + listing + AAB assinado + cobrança |

---

## 2. Identificação de versão e artefatos

### 2.1 Git

| Item | Valor |
|---|---|
| HEAD commit correções | `7aaf08bede993d77d2aa90ff990e8a90cae1e115` |
| Conteúdo do commit | 40 arquivos: `premium_app_bar`, `StaffSignOutButton`, telas Admin/Personal/CMS, `admin_screen` sem stubs, `app_config`/`login` carimbo, `firebase.json` redirects, `firebase.homolog.json`, `pubspec` 1.0.0+2, testes staff, docs iOS |
| Commit anterior (baseline sujo) | `293ffa9` — **não** continha as correções Voltar/Sair |
| Working tree residual | Alterações locais de assets/imagens/docs **não** fazem parte de `7aaf08b` |

**Honestidade sobre builds:** web e APK foram gerados em 24/09 a partir do working tree que **já continha** o código de navegação depois commitado em `7aaf08b`. O working tree também tinha (e ainda tem) mudanças locais extras; portanto o artefato **não é** um rebuild “git clean” só de `7aaf08b`. O carimbo `20260924-nav` e a presença das strings no JS/APK comprovam a identidade de homologação pedida. Para reprodução bit-a-bit do commit, fazer `git checkout` limpo + rebuild (fora do escopo se alterar o tree sujo).

### 2.2 Web

| Campo | Valor |
|---|---|
| Comando | `flutter build web --release` + dart-defines (`HOMOLOG_BUILD_ID=20260924-nav`, `PAYMENTS_ENABLED=false`, URLs legais `.html`, SUPPORT_EMAIL) |
| Saída | `build\web` |
| Carimbo local | `LOCAL_JS_STAMP=True` em `build\web\main.dart.js` (mtime 24/09/2026 07:51:07, ~6,6 MB) |
| Deploy | `firebase hosting:channel:deploy homologacao` via `firebase.homolog.json` → `build/web` (~736 arquivos) |
| URL | https://metodo1dia-app--homologacao-cw9j2u83.web.app |
| Carimbo remoto | `REMOTE_STAMP=True` (HTTP 200, mesmo tamanho do JS local) |

### 2.3 Android APK

| Campo | Valor |
|---|---|
| Comando | `flutter build apk --release --split-per-abi` + mesmos dart-defines |
| Arquivo principal | `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk` |
| Tamanho / mtime | 112 431 100 bytes · 24/09/2026 **08:06:15** |
| Outros ABI | `app-armeabi-v7a-release.apk`, `app-x86_64-release.apk` (mesmo horário) |
| APK antigo | `app-release.apk` mtime **23/09** — **não** usar como versão corrigida |
| Carimbo no binário | `APK_STAMP=True` + literal `homolog 20260924-nav` |

### 2.4 Inclusão das correções Voltar/Sair na versão compilada

| Checagem | Resultado |
|---|---|
| Código em HEAD `7aaf08b` | `showStaffSignOut` + `StaffSignOutButton` em Admin/Personal/CMS; `PopScope` + Sair no painel |
| Testes unitários staff | PASS (ver §3) |
| Carimbo no web homolog | Presente |
| Carimbo no APK arm64 08:06 | Presente |
| E2E UI logada Voltar/Sair | **NÃO TESTADO** |

---

## 3. Testes automatizados (reexecutados nesta auditoria)

Comando:

```text
flutter test test/premium_app_bar_staff_test.dart test/app_navigation_staff_back_test.dart test/user_role_permissions_test.dart test/meditations_association_order_test.dart test/cadeiras_lily_assets_test.dart
```

| Suite | Resultado |
|---|---|
| `premium_app_bar_staff_test` (2) | PASS |
| `app_navigation_staff_back_test` (4) | PASS |
| `user_role_permissions_test` (11) | PASS |
| `meditations_association_order_test` (1) | PASS |
| `cadeiras_lily_assets_test` (2) | PASS |
| **Total** | **+20 All tests passed! EXIT=0** |
| Log | `tools/_audit_tests_rebuild_20260924.txt` |

**PASS unitário ≠ aceite E2E.**

---

## 4. Matriz E2E manual — Web e Android

### 4.1 Impedimentos (bloqueiam execução)

| Impedimento | Status comprovado |
|---|---|
| Contas Auth homolog Admin / Personal / Aluna autorizadas | **Ausentes** nesta sessão (nenhuma senha solicitada/usada) |
| Device ou emulador Android | **Não conectado** — só Windows, Chrome, Edge |
| Mac / simulador iOS | Fora do escopo desta máquina |

### 4.2 Web (Chrome disponível; login não executado)

Versão alvo: homolog `20260924-nav` · URL acima · navegador Chrome 153 (listado).

| ID | Perfil | Cenário | Resultado | Evidência |
|---|---|---|---|---|
| W-A01 | Aluna | Login, permissões, treinos, vídeos, 7 meditações ordem, áudios, PDFs, Voltar, Sair | **NÃO TESTADO** | Sem conta |
| W-P01 | Personal | Login, CMS/Central, Voltar, Sair, sem cruzar Aluna | **NÃO TESTADO** | Sem conta |
| W-D01 | Admin | Login, painel sem stubs, filhas Voltar/Sair, Sair | **NÃO TESTADO** | Sem conta |
| W-X01 | Troca 3 contas | Logout sequencial sem sessão residual | **NÃO TESTADO** | Sem contas |
| W-S01 | — | Abrir login e ver carimbo na UI | **NÃO TESTADO** | Carimbo só comprovado no `main.dart.js` (rede), não screenshot UI |

### 4.3 Android

Versão alvo: APK arm64 `20260924-nav` · device: **nenhum**.

| ID | Perfil | Cenário | Resultado | Evidência |
|---|---|---|---|---|
| A-A01 | Aluna | Mesmo roteiro W-A01 | **NÃO TESTADO** | Sem device + sem conta |
| A-P01 | Personal | Mesmo roteiro W-P01 | **NÃO TESTADO** | Sem device + sem conta |
| A-D01 | Admin | Mesmo roteiro W-D01 | **NÃO TESTADO** | Sem device + sem conta |
| A-X01 | Troca 3 contas | Logout sequencial | **NÃO TESTADO** | Sem device + sem contas |
| A-S01 | — | Instalar APK e ver carimbo no login | **NÃO TESTADO** | Carimbo só comprovado por scan do binário |

**Nenhum cenário acima pode ser marcado PASSOU ou FALHOU.**

---

## 5. Links legais, iOS e bloqueios de loja

### 5.1 Privacidade e termos (produção `metodo1dia-app.web.app`)

| URL | HTTP |
|---|---|
| `/privacidade.html` | **200** |
| `/termos.html` | **200** |
| `/privacidade` | **404** |
| `/termos` | **404** |

Redirects já estão em `firebase.json` (`/privacidade`→`.html`, `/termos`→`.html`), mas **não estão ativos no hosting de produção** até um deploy de hosting permitido. App builds apontam para as URLs **`.html`** (funcionais).

### 5.2 iOS

- `lib/firebase_options.dart`: iOS `apiKey`/`appId` = `REPLACE_ME`; `iosFirebaseReady = false`.
- Instruções: `docs/IOS_REPLACE_ME_PENDENTE.md`, `docs/IOS_FIREBASE_SETUP_20260923.md`.
- Sem Mac nesta sessão → build/IPA **não gerado**.

### 5.3 O que ainda impede envio às lojas

**Play Store**

1. E2E 3 perfis no APK carimbado **não executado**.
2. AAB assinado de release + keystore/Play Console listing (fora desta auditoria).
3. Working tree sujo / necessidade de baseline Git limpa para rastreabilidade.
4. Decisão explícita de ligar cobrança (`PAYMENTS_ENABLED`) só após sandbox — **permanece false**.

**App Store**

1. Firebase iOS `REPLACE_ME`.
2. Build em Mac + certificados/perfil + listing.
3. Mesmos itens E2E/cobrança.

---

## 6. Falhas e pendências por prioridade

### Bloqueadores (BLK)

| ID | Tema | Status | Ação objetiva |
|---|---|---|---|
| **BLK-E2E-01** | Aceite E2E 3 perfis web+Android | Aberto | Amanda: 3 e-mails Auth homolog + papéis; aparelho Android; executar roteiro; registrar PASSOU/FALHOU |
| **BLK-IOS-01** | Firebase iOS REPLACE_ME | Aberto | Registrar app iOS no Console; `GoogleService-Info.plist`; `flutterfire configure`; confirmar `iosFirebaseReady` |
| **BLK-STORE-01** | Envio Play/App | Aberto | Só após E2E + iOS + AAB/IPA + listing |

### Altos (ALT)

| ID | Tema | Status | Ação |
|---|---|---|---|
| **ALT-LEGAL-01** | `/privacidade` e `/termos` 404 | Persistente | Deploy hosting produção com `firebase.json` redirects (quando autorizado) |
| **ALT-TREE-01** | Working tree sujo | Persistente | Separar commit de assets ou stash; não misturar com nav |
| **ALT-REPRO-01** | Artefato ≠ git clean de `7aaf08b` | Documentado | Rebuild opcional a partir de checkout limpo do commit |

### Médios (MED)

| ID | Tema | Status |
|---|---|---|
| **MED-PAY-01** | Cobrança real off | Intencional até sandbox |
| **MED-AAB-01** | AAB recente não revalidado nesta rodada | Usar APK arm64 08:06 para homolog; AAB à parte para Play |

### Mitigações de código já no commit `7aaf08b` (aceitação E2E ainda pendente)

| ID antigo | Tema | Código |
|---|---|---|
| BLK-01/02 | Voltar/Sair staff | Mitigado no código + testes VM |
| ALT-01/02 | Stubs/métricas Admin | Removidos no código |

---

## 7. Instruções objetivas de correção / próximo passo

1. **Contas:** criar 3 usuários no Firebase Auth do projeto `metodo1dia-app` (Admin técnico, Personal, Aluna) e configurar papéis (`admins/{uid}`, `isPersonalTrainer`, aluno). Enviar **apenas e-mails** por canal aberto; senhas só cofre.
2. **Web E2E:** abrir https://metodo1dia-app--homologacao-cw9j2u83.web.app — confirmar texto `homolog 20260924-nav` no login — executar matriz §4.2.
3. **Android E2E:** instalar **somente** `app-arm64-v8a-release.apk` de 24/09 08:06 (não o `app-release.apk` de 23/09) — confirmar carimbo — executar matriz §4.3.
4. **Legais:** quando liberado, `firebase deploy --only hosting` (produção) para ativar redirects.
5. **iOS:** seguir `docs/IOS_REPLACE_ME_PENDENTE.md` no Mac.
6. **Não** publicar lojas; **não** `PAYMENTS_ENABLED=true` sem etapa sandbox documentada.

---

## 8. Critérios de aceite (separados)

### 8.1 Web (homologação)

- [ ] Login mostra `v1.0.0+2 · homolog 20260924-nav` (ou versão+carimbo equivalentes do build sob teste).
- [ ] Aluna: treinos, vídeos, 7 meditações na ordem correta, áudios, PDFs, Sair — **PASSOU** com evidência.
- [ ] Personal: Central/CMS, Voltar em filhas, Sair visível, sem área exclusiva de Aluna indevida — **PASSOU**.
- [ ] Admin: painel sem stubs/métricas fictícias, Voltar/Sair em filhas, Sair na raiz — **PASSOU**.
- [ ] Troca sequencial das 3 contas sem sessão residual — **PASSOU**.
- [ ] Cobrança real continua desligada.

**Estado atual:** critérios **não satisfeitos** (E2E não executado). Ambiente com carimbo: **sim**.

### 8.2 Android

- [ ] APK instalado é o de 24/09 com carimbo `20260924-nav` (não build 23/09).
- [ ] Mesma matriz dos 3 perfis **PASSOU** em aparelho real ou emulador.
- [ ] Botão Voltar do sistema na raiz staff não “prende” / Sair funciona (validar PopScope).
- [ ] PAYMENTS off.

**Estado atual:** artefato carimbado **existe**; aceite E2E **não satisfeito**.

### 8.3 iOS

- [ ] `iosFirebaseReady == true` (sem REPLACE_ME).
- [ ] IPA/TestFlight buildado no Mac.
- [ ] Mesma matriz E2E 3 perfis **PASSOU**.
- [ ] Privacidade/termos e listing App Store preenchidos.

**Estado atual:** **não satisfeito**.

---

## 9. Evidências anexas (caminhos)

| Evidência | Caminho / URL |
|---|---|
| Commit | `7aaf08bede993d77d2aa90ff990e8a90cae1e115` |
| Coleta Git/APK/stamp/legais/devices | `tools/_audit_evidence_20260924.txt` |
| Testes +20 PASS | `tools/_audit_tests_rebuild_20260924.txt` |
| Web local | `build\web\main.dart.js` |
| Homolog | https://metodo1dia-app--homologacao-cw9j2u83.web.app |
| APK | `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk` |
| Docs iOS | `docs/IOS_REPLACE_ME_PENDENTE.md` |
| Baseline | `HOMOLOGACAO_POS_CORRECAO_20260924.md` |

**Este relatório não contém senhas, chaves API reais nem credenciais de loja.**

---

## 10. Conclusão

Homologação técnica **parcialmente concluída**: código de navegação commitado (`7aaf08b`), builds web+APK carimbados `20260924-nav` verificados, testes VM PASS, cobrança off, canal homolog atualizado.

**Entrega ao programador / produto:** app **ainda não aprovado** para publicação. Próximo gate obrigatório = E2E humano com contas + Android (e depois iOS).
