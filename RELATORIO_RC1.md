# 🔍 RELATÓRIO TÉCNICO — Release Candidate 1 (RC1)

Auditoria técnica completa. **Nenhum módulo novo.** Foco: encontrar e corrigir
defeitos reais antes do lançamento.

> ⚠️ **Limite deste ambiente**: não há SDK do Flutter nem device. Portanto
> **não foi possível executar** `flutter analyze`, `flutter test`, nem validar em
> Android/iOS reais. Tudo abaixo foi obtido por **auditoria estática do código**
> (que pega a maioria dos defeitos) e os testes foram **escritos**, não executados.

---

## 🐛 DEFEITOS ENCONTRADOS E CORRIGIDOS

### 🔴 Críticos (causariam crash ou falha em produção)

| # | Defeito | Consequência | Correção |
|---|---|---|---|
| 1 | **`jsonDecode` sem `try/catch`** em Loja, Missões, Metas, Diário e Chat da IA | Um único registro corrompido (app morto no meio da escrita, mudança de schema) causaria **crash no boot, em loop permanente** — o usuário precisaria reinstalar | Parse defensivo: registro inválido é descartado, o app carrega |
| 2 | **`setState` após `await` sem checar `mounted`** em `running_screen` | Crash "setState called after dispose" se a usuária saísse da tela durante o diálogo de permissão de GPS | Guardas `if (!mounted) return;` no `_start`, no `Timer` e no stream |
| 3 | **`http.post` sem timeout** (IA e Amanda) | Se a rede pendurasse, a requisição ficava **infinita**: UI travada e bateria drenando | `.timeout(Duration(seconds: 20))` + fallback local já existente |
| 4 | **`auth_repository` sem `try/catch`** | Erro cru exibido à usuária: `[firebase_auth/wrong-password] The password is invalid...` | `AuthFailure` + tradução de 9 códigos para pt-BR; `cred.user!` blindado |

### 🔴 Segurança — Firestore

| # | Defeito | Consequência | Correção |
|---|---|---|---|
| 5 | **Escalação de privilégio**: `users/{userId}` permitia `update` livre pelo dono | Usuária podia setar `isAdmin: true`, `isPremium: true` e **XP arbitrário** | `noPrivilegedFields()` bloqueia `xp, level, streak, isPremium, isAdmin, coins, totalWorkouts` |
| 6 | `progress`: usava `resource.data` no **create** (onde `resource` é null) | **Todo create falharia** | Separado: `ownsIncoming()` no create, `ownsExisting()` no read/update |
| 7 | `running_sessions`: usava `request.resource.data` no **read** (null no read) | **Toda leitura falharia** | Idem |
| 8 | `community_posts` create sem validar `userId` | Dava para **postar se passando por outra pessoa** | `ownsIncoming()` no create |
| 9 | **8 coleções sem regra** (`workout_history`, `habits`, `badges`, `comments`, `notifications`, `subscriptions`, `amanda_messages`, `admins`) | Caíam no `deny` final → **gravações falhariam silenciosamente** com Firebase ligado | Regras específicas para cada uma |

### 🔴 Segurança — Storage

| # | Defeito | Consequência | Correção |
|---|---|---|---|
| 10 | `/public/`: `allow write: if request.auth != null` | **Qualquer usuária logada** podia sobrescrever assets do app ou hospedar arquivos | Escrita restrita a **admin** |
| 11 | Uploads sem limite de tamanho nem tipo | Upload de arquivos gigantes / não-imagem → **custo e abuso** | `isImage()` + `underSize(8 MB)` |

### 🟠 Privacidade e logs

| # | Defeito | Consequência | Correção |
|---|---|---|---|
| 12 | `debugPrint` do **token FCM completo** | `debugPrint` **roda em release**. O token permite enviar push ao device — vazava no logcat | Log só em `kDebugMode`, e apenas os 6 últimos caracteres |
| 13 | Log de **título e corpo** das notificações | Poderia vazar dados pessoais nos logs | Loga só o `messageId` |

### 🟡 Performance / bateria

| # | Defeito | Correção |
|---|---|---|
| 14 | `LocationAccuracy.best` na corrida | Trocado por `high` (≈10 m): precisão suficiente, **consumo bem menor** |
| 15 | Saltos de GPS inflavam a distância | Descarta deltas > 100 m em um update |
| 16 | Stream de GPS sem `onError` | Adicionado (mostra erro de permissão em vez de morrer em silêncio) |

### 🟡 Qualidade

| # | Defeito | Correção |
|---|---|---|
| 17 | `_formatDate` **duplicado em 3 telas** e `_ago` em uma 4ª | Extraído para `core/utils/date_format.dart` (`DateFormatBr`) |

---

## ✅ ITENS AUDITADOS — RESULTADO

| Item | Resultado |
|---|---|
| Erros de compilação (estático) | 0 imports quebrados · 0 símbolos inexistentes |
| Warnings | `withOpacity` (27×) é deprecado em Flutter novo, mas **silenciado** no `analysis_options.yaml` e **não bloqueia build** |
| Imports | 0 quebrados · 0 duplicados |
| Dependências | **0 declaradas sem uso** |
| `pubspec.yaml` | Nome, versão `1.0.0+1`, SDK `>=3.3.0`, assets — OK |
| Assets não usados | 6 arquivos / **32 KB de 8,7 MB (0,3%)** — 5 seeds JSON + 1 SVG. **Mantidos**: ganho nulo, risco de quebrar seeding futuro |
| Assets quebrados | 0 (os 5 `.riv` são referências intencionais; `RiveHelper` nunca os carrega — usa fallback Lottie) |
| Código duplicado | Corrigido (item 17) |
| Memória | **0 controllers/timers/subscriptions sem `dispose`/`cancel`** |
| Performance | Listas com `builder`, `const` em widgets estáticos, animações leves |
| Animações | 9 Lottie válidas (JSON verificado) · `FadeInUp`/`PopIn`/`Shimmer` com `dispose` |
| Responsividade | `Expanded`/`Flexible`/scroll; bolhas de chat limitadas a % da largura |
| Acessibilidade | `semanticLabel` nas 15 poses da mascote + ícones |
| Navegação | 27 rotas · **0 órfãs · 0 quebradas** |
| Tratamento de exceções | Corrigido (itens 1–4) |
| Logs | 0 `print()` · logs sensíveis eliminados |
| Segurança Firebase | Regras reescritas (itens 5–11) |
| Autenticação | Erros traduzidos, `null` blindado, modo local preservado |
| Consumo de bateria | GPS otimizado (item 14) |
| Consumo de internet | Timeout de 20 s; IA cai no motor local offline |

---

## 🧪 TESTES

**34 testes escritos** em 3 arquivos:
- `test/integration_test.dart` — gamificação, Loja, Missões, IA, Health Sync, **integração cruzada** (missão → XP + moedas; XP → nível → ranking)
- `test/regression_test.dart` — **trava as correções desta auditoria**: parse defensivo com dados corrompidos, renovação de período das missões, `DateFormatBr`, saldo nunca negativo
- `test/smoke_test.dart` — boot e billing

Validei estaticamente que **todos os símbolos e assinaturas existem**.

> ❌ **Não executei os testes** — sem SDK aqui. Rode `flutter test`.
> ❌ **Testes de navegação e de UI** exigem `flutter test` / `integration_test` com device. Os fluxos de rota foram validados **estaticamente** (0 órfãs, 0 quebradas).

---

## 📋 PENDÊNCIAS

### Pendências de CÓDIGO (posso resolver)
1. **Layout dedicado para tablet** — hoje herda o de telefone (funcional, não ideal).
2. **Tema claro** — o app é dark-only por decisão de identidade; não estava previsto.
3. **Ranking real via Firestore** — hoje: adversárias fixas + a usuária com XP real.
4. **Ação "concluir desafio"** — o evento `desafioConcluido` já existe na API, falta a UI.
5. `withOpacity` → `withValues()` se você migrar para Flutter 3.27+.
6. Streaming de tokens da IA (hoje a Function retorna a resposta completa).

### Pendências EXTERNAS (só você pode resolver)
| Item | Onde |
|---|---|
| Pastas nativas `android/ ios/ web/` | `flutter create --org com.suaempresa .` |
| Projeto Firebase + `flutterfire configure` | console.firebase.google.com |
| Chave OpenAI (na Cloud Function, **nunca no app**) | platform.openai.com |
| Chave Google Maps | console.cloud.google.com |
| Conta e chaves RevenueCat + produtos nas lojas | app.revenuecat.com |
| Google Play Console (US$ 25) / Apple Developer (US$ 99/ano) | contas de desenvolvedor |
| Keystore Android (`.jks`) + certificados iOS | você gera |
| Pacote `health` + permissões nativas | ver `release_config/health_permissions.md` |
| Arquivos Rive `.riv` | editor Rive (há fallback Lottie funcionando) |
| Política de privacidade (obrigatória — app lê dados de saúde) | seu site |

---

## 🚦 O projeto está pronto para gerar APK, AAB e IPA?

**Não ainda — e o motivo não é o código.**

- ❌ **Bloqueador absoluto**: não existem as pastas `android/`, `ios/`, `web/`.
  Elas são geradas por `flutter create .` na sua máquina. Sem elas **nenhum build
  acontece**, por melhor que o Dart esteja.
- ❌ **Bloqueador**: assinatura (keystore Android, certificados iOS).
- ❌ **Não verificado**: `flutter analyze` e `flutter test` nunca rodaram. A
  auditoria estática é forte, mas **não substitui o compilador**.
- ⚠️ Chaves externas: sem elas o app **roda** (modo local com degradação
  graciosa), mas Firebase/IA/Maps/compras não funcionam de verdade.

### Caminho até o RC1 buildável (ordem)
```bash
flutter create --org com.suaempresa .
flutter pub get
flutter analyze          # ← me mande a saída se houver erro
flutter test             # ← 34 testes
flutterfire configure
firebase deploy --only firestore:rules,storage,functions
flutter build apk --release       # smoke test em device
flutter build appbundle --release # Play Store
flutter build ipa --release       # App Store (macOS + Xcode)
```

---

## Veredito honesto

Esta auditoria encontrou **17 defeitos reais**, incluindo **4 que causariam crash
ou falha silenciosa em produção** e **7 falhas de segurança** nas regras do
Firebase — entre elas uma **escalação de privilégio** (usuária virar admin) e
**escrita pública no Storage**. Todos foram corrigidos.

O código está em estado de **Release Candidate**. O que falta para o RC1 ser
efetivamente *buildável e testável* são passos que **só rodam na sua máquina**:
`flutter create`, `flutter analyze`, `flutter test` e a assinatura.

Rode os três primeiros e me traga a saída. Qualquer erro que o compilador
apontar, eu corrijo no ponto exato.
