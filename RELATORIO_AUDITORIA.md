# Relatório de Auditoria Técnica — Método 1 Dia de Cada Vez (Lili Fit)
### Passo v33 · Auditoria completa, correções aplicadas e prontidão de publicação

> **Aviso de escopo (leia primeiro).** Esta auditoria foi feita em um ambiente
> **sem Flutter SDK e sem acesso à internet**. Isso significa que toda a
> validação foi **análise estática** (leitura e verificação do código-fonte),
> **não** compilação. Não foi possível — nem é possível aqui — rodar
> `flutter analyze`, `flutter build`, `flutter create .`, gerar `android/`/`ios/`,
> produzir AAB/IPA ou assinar. Esses passos só rodam na sua máquina com o SDK.
> Nada neste relatório finge o contrário.

---

## 1. Retrato do projeto

| Métrica | Valor |
|---|---|
| Arquivos Dart | 169 (era 168; +1 módulo de estados de UI) |
| Linhas de Dart | ~27.400 |
| Módulos de feature | 39 |
| Rotas | 53, todas com transições customizadas |
| Constantes de asset | 146 — **todas resolvem para arquivos reais** |
| `print()` soltos | 0 |
| Pastas nativas (`android/`/`ios/`) | **AUSENTES** ← bloqueador nº 1 |

A base é **madura e bem organizada**: separação clara `core/` vs `features/`,
cada feature com `data/domain/presentation/providers`, design system tokenizado,
Riverpod + GoRouter, Firebase completo, e conteúdo dirigido por assets (JSON),
não hardcoded. A qualidade estrutural é alta.

---

## 2. O que foi CORRIGIDO nesta passagem

### 2.1 Memory leaks (controllers sem `dispose()`)
Corrigidos **11 arquivos**:

- **Leaks reais (controller como campo de State):**
  - `onboarding_screen.dart` — `PageController` sem dispose → **corrigido**.
  - `workout_builder_screen.dart` — `_nameController`, `_objectiveController` → **corrigido**.
- **Leaks de diálogo (`TextEditingController` local não descartado):**
  `evolution_screen`, `goals_screen`, `community_screen`, `reminders_screen`,
  `calendar_screen`, `shopping_list_screen`, `food_database_screen` (7 ctrls),
  `exercise_library_screen` (7 ctrls), `personal_dashboard_screen` (3 ctrls) →
  **todos corrigidos** (dispose após o fecho do diálogo / `whenComplete`).

> Pendente (baixa prioridade, admin-only): telas `*_admin_screen` usam o mesmo
> padrão de diálogo. A correção é idêntica (uma linha por controller). Como são
> telas usadas só por você no painel, o impacto é desprezível — listadas aqui
> por transparência, não aplicadas para não inflar mudanças não compiláveis.

### 2.2 Segurança — bypass de Premium em `pdf_recipes` (falha real)
A regra usava wildcard recursivo `match /pdf_recipes/{document=**}` com
`allow read: if signedIn()`, o que exporia **qualquer** subdocumento `/private`
a qualquer usuário logado — quebrando o Premium.
- **Regra corrigida** para o padrão seguro aninhado (igual a `ebooks`/`courses`/`videos`).
- **Cloud Function `getContentUrl`** passou a reconhecer `pdf_recipes`
  (`{ privateDoc: 'file', urlField: 'pdfUrl' }`).
- **Pendente (exige build):** hoje o cliente lê `pdfUrl` direto do documento
  público (`pdf_recipes_repository.dart`). Para fechar 100% o bypass falta:
  (a) migrar `pdfUrl` para `pdf_recipes/{id}/private/file`;
  (b) trocar o cliente para chamar `getContentUrl` (mesmo fluxo dos ebooks).
  Não apliquei essa troca de runtime porque, sem compilar/testar, um erro
  sutil quebraria as receitas para todas as usuárias. Está especificado abaixo
  em §5.2.

### 2.3 Índices do Firestore (crash real em produção evitado)
`firestore.indexes.json` estava **incorreto/incompleto**:
- `running_sessions` tinha índice em `createdAt`, mas a query ordena por `date`
  (e `createdAt` nem é gravado) → a query lançaria `FAILED_PRECONDITION`.
  **Corrigido** para `(userId ASC, date DESC)`.
- Faltavam índices compostos para queries `where('active') + orderBy('order')`:
  **adicionados** para `videos`, `courses`, `ebooks`.
- Faltava índice para `pt_students` `where('trainerId') + where('active')`:
  **adicionado**.

### 2.4 Erros silenciosos
4 blocos `catch (_) {}` (em `notifications_service` e `analytics_service`)
engoliam exceções sem rastro. **Corrigidos** para logar em debug (`_log`/`debugPrint`).
Agora não há nenhum `catch (_) {}` vazio no projeto.

### 2.5 Dependência não usada
`geocoding` estava declarada mas com **0 imports** em `lib/`. **Comentada** no
`pubspec.yaml` (reduz peso de build; reative se for exibir endereço).
`google_sign_in` também está sem uso, mas é uma integração planejada — mantida.

---

## 3. O que foi OTIMIZADO / ADICIONADO (sem quebrar o existente)

### Módulo de estados de UI — `lib/core/widgets/app_states.dart` (novo)
O app **já tinha** primitivas ótimas (`Shimmer`, `SkeletonBox`, `PressableScale`,
`FadeInUp`, `AnimatedCounter`, `Pulse`) — mas **0 telas as usavam**; 35 telas
ainda mostram `CircularProgressIndicator` cru. Criei componentes prontos,
100% aditivos, com a identidade da Lili e os tokens do design system:

- `AppEmptyState` — vazio acolhedor (mascote + título + mensagem + ação opcional).
- `AppErrorState` — erro amigável (mascote triste + "Tentar novamente"), nunca stack trace cru.
- `AppListSkeleton` — placeholder de lista em shimmer (reusa `SkeletonBox`).
- `AppAsyncView<T>` — mapeia um `AsyncValue` para skeleton/erro/vazio/dados de forma uniforme.

**Guia de adoção** (aplicar tela a tela, validando com build):
```dart
final async = ref.watch(meuProvider);
return AppAsyncView<List<X>>(
  value: async,
  onRetry: () => ref.invalidate(meuProvider),
  isEmpty: (d) => d.isEmpty,
  emptyBuilder: (_) => const AppEmptyState(
    title: 'Nada por aqui ainda',
    message: 'Assim que houver conteúdo, aparece aqui.',
  ),
  data: (d) => ListView(/* ... */),
);
```
> **Não** reescrevi as 35 telas automaticamente: sem compilador, trocas visuais
> em massa arriscariam a estabilidade que você pediu para preservar. O módulo
> está pronto; a adoção é incremental e segura, uma tela por vez.

---

## 4. O que foi VERIFICADO e está saudável

- **Assets:** 146 constantes → arquivos reais. Os únicos "faltando" são os `.riv`
  (Rive), **intencional**: o pacote `rive` está comentado e há fallback em Lottie
  documentado (`rive_helper.dart`). Não é bug.
- **Telas "em breve":** são **estados vazios funcionais** das bibliotecas
  (vídeos/ebooks/cursos/áudios/receitas). As telas existem e populam sozinhas
  quando o conteúdo é cadastrado. Não são telas incompletas.
- **Monetização:** arquitetura limpa — interface `PremiumService` + mock local
  + caminho documentado para `RevenueCatPremiumService`, com `restore()` no
  contrato. Só falta plugar RevenueCat + chaves de loja em produção.
- **Roteamento:** 53 rotas, 50 transições customizadas.
- **Design system:** cores, tipografia, espaçamento, sombras, gradientes, raios
  tokenizados e completos.
- **Logs:** 0 `print()`; logging seguro (só em debug) já implementado.

---

## 5. O que AINDA precisa ser feito (honesto)

### 5.1 BLOQUEADOR — projeto nativo e build (só na sua máquina, com SDK)
Sem isso o app é **0% publicável**, independentemente da qualidade do Dart:
```bash
flutter create .            # gera android/, ios/, web/ (preserva lib/ e pubspec)
flutter pub get
dart format .
flutter analyze             # 1ª compilação real — vai revelar erros ocultos
flutter test                # roda a suíte existente (test/)
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```
> **Importante:** como este código **nunca** passou por um compilador, é esperado
> que `flutter analyze` aponte alguns erros na primeira vez (imports, tipos,
> APIs). Isso é normal e não contradiz a qualidade estrutural — é a etapa que só
> o SDK faz.

### 5.2 Fechar 100% o Premium de receitas (após build)
1. Migrar docs `pdf_recipes`: mover `pdfUrl` → subdoc `private/file`.
2. No `pdf_recipes_repository.dart`, trocar a leitura direta por uma chamada
   HTTP à Cloud Function `getContentUrl` (copie o fluxo do `ebooks_repository`).
3. Deploy: `firebase deploy --only firestore:rules,firestore:indexes,functions`.

### 5.3 Ícones e splash (PENDÊNCIA já registrada no pubspec)
Exportar `assets/app_icon/app_icon.svg` como **PNG 1024×1024** (+ foreground
adaptativo) antes de rodar os geradores da §5.1.

### 5.4 Integrações externas (contas/OAuth)
RevenueCat (chaves + produtos nas lojas), Google Sign-In (OAuth), wearables
(Garmin/Fitbit/Polar/Strava), OpenAI (chave na Cloud Function). Todas já têm
o "encaixe" no código; falta credencial + configuração.

### 5.5 Conteúdo
Popular bibliotecas (receitas, e-books, vídeos, áudios, cursos) — deferido por
você. As telas já lidam com lista vazia graciosamente.

### 5.6 Adoção incremental do `app_states.dart`
Trocar `CircularProgressIndicator` por skeleton/estado nas 35 telas, validando
cada uma com build.

---

## 6. Nota final

| Dimensão | Nota | Comentário |
|---|---|---|
| Qualidade estrutural do código | **9.0 / 10** | Arquitetura madura, organizada, consistente. |
| Segurança (rules/functions) | **8.5 / 10** | Padrão forte; falta só a migração de dados das receitas. |
| UX / polimento | **8.0 / 10** | Primitivas excelentes; adoção de skeletons pendente. |
| Prontidão de PUBLICAÇÃO | **≈ 55 / 100** | Gargalo: nativo + build + assinatura, não verificáveis aqui. |

> **Leitura honesta:** como *codebase*, o projeto é forte (nota ~8.7/10). Como
> *produto publicável hoje*, está a algumas horas de trabalho **na sua máquina**
> (build, correção dos erros que o `analyze` revelar, ícones, assinatura). O
> maior risco não são bugs conhecidos — é o conjunto de erros de compilação
> ainda **desconhecidos**, que só aparecem na primeira build real.

---

## 7. Checklist de publicação

**Pré-build (feito aqui)**
- [x] Auditoria estática completa
- [x] Memory leaks de telas de usuário corrigidos
- [x] Falha de Premium em `pdf_recipes` (rules + function) corrigida
- [x] Índices Firestore corrigidos e completados
- [x] Erros silenciosos logados
- [x] Dependência morta removida
- [x] Módulo de estados de UI pronto

**Build (você, com SDK)**
- [ ] `flutter create .` → pastas nativas
- [ ] `flutter pub get` · `flutter analyze` · corrigir erros revelados
- [ ] `flutter test`
- [ ] Ícones (PNG 1024²) + `flutter_launcher_icons`
- [ ] Splash + `flutter_native_splash:create`

**Firebase**
- [ ] `firebase deploy --only firestore:rules,firestore:indexes,functions`
- [ ] Migração de dados das receitas (§5.2)
- [ ] Testar offline/persistência

**Monetização / integrações**
- [ ] RevenueCat (produtos + chaves) e trocar `LocalPremiumService`
- [ ] Google Sign-In / wearables / chave OpenAI

**Android**
- [ ] `applicationId`, versionCode/Name, permissões (ver `release_config/`)
- [ ] Keystore + assinatura · `flutter build appbundle --release` → **AAB**
- [ ] Ficha na Play Console (política de privacidade, data safety)

**iOS**
- [ ] Bundle ID, capabilities, permissões (`Info.plist`, ver `release_config/`)
- [ ] Certificados/provisioning · `flutter build ipa --release` → **IPA**
- [ ] App Store Connect (privacy nutrition labels)

**Final**
- [ ] Teste em dispositivo físico (Android + iOS)
- [ ] Crashlytics recebendo eventos
- [ ] Revisão de conteúdo (bibliotecas populadas)

---

*Gerado na passagem de auditoria v33. Todas as correções de código estão
aplicadas no fonte; nenhuma funcionalidade, asset, cor ou a mascote Lili foi
removida ou alterada em identidade.*

---

## Adendo v34 — adoção de referência dos estados de UI

Aplicado o módulo `app_states.dart` em **5 telas de usuário** das bibliotecas de
conteúdo, como implementação de referência (troca segura, só nos ramos
`loading`/`error`, preservando todo o layout e o tratamento de vazio existente):

- `videos_screen.dart`
- `courses_screen.dart`
- `ebooks_screen.dart`
- `audio_courses_screen.dart`
- `pdf_recipes_screen.dart`

Em cada uma: `CircularProgressIndicator` → `AppListSkeleton`; texto de erro cru →
`AppErrorState(onRetry: ref.invalidate(...))`. Balanceamento de chaves/parênteses
verificado; nenhum import órfão. As demais ~30 telas seguem o mesmo padrão de
adoção incremental (uma por vez, validando com build).

---

## Adendo v35 — execução do prompt master (com declaração de ambiente)

**Declaração obrigatória de ambiente:** verificado nesta sessão — `flutter` e
`dart` NÃO existem no container e a rede é bloqueada (`x-deny-reason:
host_not_allowed`). Portanto §2–§5 e a execução de §7 (analyzer, builds, geradores
de ícone/splash) **não foram executadas** e não são declaradas como feitas.
Validações reais possíveis aqui: análise estática de Dart e `node --check` nas
Cloud Functions (executado, sintaxe OK).

### §1 — Preservação e backup ✅
Backup íntegro em `/home/claude/backup_pre_v35`; inventário inicial registrado em
`REGISTRO_INICIAL_v35.md` (169 arquivos Dart, ~27,4k linhas, 53 rotas, deps).

### §8–§15 — Sistema centralizado de mascote ✅ (estrutura)
- **`lib/core/mascot/`** criado: `MascotConfig` (nome + flag `useNewMascot`),
  `MascotAssets` (catálogo pose→caminho, novo→legado), `MascotWidget`
  (fallback automático: arte nova → `LiliMascot` legado → nunca quebrado).
- **`assets/mascot/png/`** criado com **15 placeholders** (cópias da arte atual
  sob os nomes padronizados `mascot_*.png`, documentados como provisórios em
  `assets/mascot/README.md`) + entrada no `pubspec.yaml`.
- **Nome centralizado (§11):** strings visíveis "Lili Fit"/"Lili" em
  `home_screen`, `lili_audios_screen` e `admin_screen` agora usam
  `MascotConfig.name`/`shortName`. Nome novo provisório: `NOVA MASCOTE`
  (marcado; nenhum nome definitivo foi escolhido por conta própria).
- **Auditoria (§15):** 0 menções nos 1.565 textos JSON; 0 nas Cloud Functions;
  ~51 arquivos Dart com identificadores internos (`LiliMascot`, `mascot_lili/`
  etc.) — **mantidos deliberadamente**: são invisíveis ao usuário e renomeá-los
  em massa sem compilador violaria a estabilidade. Renomear (opcional) após a
  primeira build verde.
- **Não feito e não simulado:** arte nova (depende do ilustrador), animações
  Lottie/Rive novas, nome definitivo, guia visual da personagem (§16 — requer
  decisões criativas suas; posso redigir o documento quando você definir a
  direção).

### §28 — Premium das receitas ✅ (código completo; execução pendente)
- `pdf_recipes_repository.dart`: novo `resolveFileUrl()` espelhando o fluxo
  protegido dos e-books (token + Cloud Function `getContentUrl`).
- `pdf_viewer_screen.dart`: carregamento e os dois botões "Abrir externamente"
  usam SOMENTE a URL resolvida — **zero** leitura do `pdfUrl` público, sem
  fallback de bypass.
- `getContentUrl` agora **registra tentativas indevidas** (console.warn com
  uid/coleção/doc) nos dois pontos de negação Premium (§28 item 10).
- **`functions/tools/migrate_pdf_recipes.js`** (sintaxe validada): migra
  `pdfUrl` → `private/file` com dry-run e `--apply`, idempotente.
- **Pendente (sua máquina):** rodar a migração com credencial admin e
  `firebase deploy --only firestore:rules,firestore:indexes,functions`.

### Arquivos modificados nesta passagem (§1 item 8)
Novos: `lib/core/mascot/{mascot_config,mascot_assets,mascot_widget}.dart`,
`assets/mascot/**` (15 png + README), `functions/tools/migrate_pdf_recipes.js`,
`REGISTRO_INICIAL_v35.md`. Editados: `pubspec.yaml`, `home_screen.dart`,
`lili_audios_screen.dart`, `admin_screen.dart`, `pdf_recipes_repository.dart`,
`pdf_viewer_screen.dart`, `functions/src/index.js`.

### Pendências que dependem do seu ambiente/decisões
1. `flutter create .` + `pub get` + `analyze` + `test` + builds (§2–§5).
2. Ícones/splash: exportar PNG 1024² e rodar os geradores (§7).
3. Nome definitivo da mascote + arte nova + guia visual (§10/§11/§16).
4. Migração das receitas + deploy Firebase (§28).
5. Credenciais: RevenueCat, Google/Apple Sign-In, wearables, OpenAI (§30–§35).

---

## Adendo v36 — SPRINT PREMIUM (evolução de produto)

**Ambiente (declaração honesta, §13/§14):** sem Flutter SDK e sem rede neste
container — `flutter analyze`, `flutter test`, APK e AAB são impossíveis aqui e
NÃO estão sendo entregues. O que se entrega é código novo de produto, validado
por análise estática. A primeira compilação continua sendo o passo da sua máquina.

### Novas funcionalidades (§3 — Gamificação estilo Duolingo)
**Sistema de Ligas semanais** — Bronze, Prata, Ouro e Diamante:
- `domain/league_models.dart`: tiers com cores, emojis, metas de promoção
  (300/700/1200 XP semanais) e regra de permanência; Bronze nunca rebaixa
  (a liga acolhe, não pune — coerente com o tom do app).
- `providers/league_providers.dart`: XP semanal derivado da fonte única de XP
  (snapshot no início da semana, virada segunda-feira), promoção/rebaixamento
  automáticos na virada, persistência local, flags de transição exibidas uma vez.
- `presentation/leagues_screen.dart`: tela premium com cartão-herói em
  gradiente do tier, contador de XP animado, barra de progresso até a próxima
  liga, dias restantes, escada de tiers com stagger animation e badge "VOCÊ".
- Promoção dispara **celebração com confete**; rebaixamento recebe mensagem
  acolhedora (sem punição visual).
- Rota `/leagues` registrada com a transição padrão + cartão de entrada na
  tela de Conquistas.

### Kit de experiência premium (§2) — `core/widgets/app_feedback.dart`
- `AppSnack.success/error/info`: snackbars flutuantes modernos com ícone,
  borda colorida e feedback tátil.
- `showAppSheet`: bottom sheet padrão premium (alça, cantos 24, safe area,
  teclado).
- `CelebrationOverlay`: celebração de vitória em Flutter puro — confete
  animado (CustomPainter, 64 partículas determinísticas, cores da marca),
  mascote via `MascotWidget` (já usa o sistema centralizado da v35), háptica.
  **Acessibilidade:** com `disableAnimations` ativo no sistema, o confete é
  suprimido e a transição zera (§24 do prompt anterior, respeitado).

### Arquivos desta sprint
Novos: `league_models.dart`, `league_providers.dart`, `leagues_screen.dart`,
`app_feedback.dart`. Editados: `app_router.dart` (rota `/leagues`),
`gamification_screen.dart` (cartão de liga).

### Sugestões para a V37 (em ordem de retorno)
1. **Primeira build real** — desbloqueia tudo; sem ela, cada sprint acumula
   código não compilado (o risco cresce a cada versão).
2. Ligar as celebrações do kit aos eventos existentes (conquista, streak,
   treino concluído) — 1 linha por ponto, após a build.
3. Home §4: reordenar o dashboard com resumo do dia/semana usando os providers
   existentes + skeletons já criados.
4. Perfil §5: consolidar medidas/IMC/tempo treinado (dados já existem em
   evolution/nutrition/running).
5. Baús de recompensa (§3): sortear itens da loja LiliMood existente ao fechar
   missões semanais — encaixa no rewards atual.

---

## Adendo v37 — Baús de recompensa diários (§3)

Evolução de produto (código novo, validado por análise estática; sem SDK/rede
neste ambiente, então analyze/test/APK/AAB seguem para a sua máquina).

**Nova funcionalidade: Baú diário** — recompensa de constância no estilo dos
grandes apps de hábitos:
- `domain/daily_chest_models.dart`: raridades (Comum/Raro/Épico/Lendário) com
  cor, emoji, faixa de moedas LiliMood e XP; sorteio por peso em que a
  **sequência (streak) melhora as chances** de raridades melhores — sem nunca
  zerar a comum.
- `providers/daily_chest_providers.dart`: resgate **uma vez por dia**
  (local-first), creditando moedas via `rewardsProvider.earn()` e XP via
  `gamificationProvider.addXp()` — reaproveita as economias existentes, nada
  duplicado.
- `presentation/daily_chest_screen.dart`: baú que "chama" (balança) quando
  disponível; ao abrir, háptica + `CelebrationOverlay` (confete da v36) revela
  a recompensa. Estado "já aberto hoje" com mensagem gentil de volta amanhã.
- Rota `/rewards/daily-chest` + banner de entrada na loja de recompensas
  (aparece só quando há baú disponível).

**Verificação estática (mesma da v36):** balanceamento OK; APIs cruzadas
(`earn`, `addXp`, `streak`) existem; um import órfão (`animations.dart`)
detectado e removido; zero imports não usados nos arquivos novos.

**Arquivos v37** — novos: `daily_chest_models.dart`, `daily_chest_providers.dart`,
`daily_chest_screen.dart`. Editados: `app_router.dart`, `rewards_store_screen.dart`.
