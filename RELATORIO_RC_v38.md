# RELATÓRIO RELEASE CANDIDATE — Método 1 Dia de Cada Vez
### Versão V38 · Consolidação e validação de integração

> **DECLARAÇÃO DE AMBIENTE (obrigatória, conforme seu "IMPORTANTE").**
> Este ambiente **não possui Flutter SDK, Android SDK, Xcode nem acesso à
> internet** (verificado nesta sessão). Portanto, as etapas abaixo **NÃO foram
> executadas e NÃO estão marcadas como concluídas**:
> - §1 `flutter create .`, `pub get`, `dart format`, `flutter analyze`, `flutter test`
> - §2 APK Debug/Release, AAB, Web, iOS/IPA
> - §11 execução de testes
>
> Nenhum resultado de compilação foi inventado. O que este relatório entrega é a
> **consolidação e validação estática** que É possível fazer sem SDK — e que
> reduz o trabalho da primeira build real na sua máquina.

---

## O que foi VALIDADO nesta consolidação (verificação estática real)

### §3 — Rotas: ✅ íntegras
- **55 `GoRoute`**, cada uma com `builder`/`pageBuilder` (nenhuma rota sem corpo).
- **49 telas** referenciadas no router — **todas com classe existente e
  arquivo importado**. Zero rota apontando para tela inexistente.
- 2 `ShellRoute` (navegação com barra inferior) presentes.

### §3 — Providers: ✅ íntegros
- **81 providers definidos**, **80 referenciados** via `ref.watch/read/listen`.
- **Todas as 80 referências resolvem** para um provider definido. A única
  ocorrência "não definida" (`algumProvider`) está em comentário de
  documentação — inofensiva.

### §6 — Código morto: ✅ limpo
- **0 arquivos Dart órfãos** (todos os 172 arquivos são importados por ao menos
  outro, exceto o entrypoint).
- Os 11 arquivos novos da sessão (mascote, ligas, baús, kits de UX) estão todos
  referenciados/roteados — nada solto.
- Imports órfãos nos arquivos novos: detectados e removidos durante o
  desenvolvimento (ex.: `animations.dart` em `daily_chest_screen`).

### §9 — Segurança Premium: ✅ consistente
- **Todos** os repositórios de conteúdo (vídeos, e-books, cursos, áudios,
  receitas) resolvem a URL real **via Cloud Function protegida**
  (`getVideoUrl`/`getContentUrl`), que valida autenticação e direito Premium no
  servidor. **Nenhum** lê URL sensível direto do documento público.
- A falha do `pdf_recipes` (corrigida na v35) se mantém fechada: regra sem
  wildcard recursivo, URL isolada em `/private/file`, cliente via função.
- Tentativas indevidas de acesso Premium são registradas (`console.warn`).

### §4 — Sistema centralizado da mascote: ✅ ponto único pronto
- `lib/core/mascot/` (`MascotConfig`, `MascotAssets`, `MascotWidget`) é o ponto
  ÚNICO de troca; `MascotWidget` cai automaticamente no `LiliMascot` legado
  enquanto `useNewMascot == false` — **fallback garantido, nada quebra**.
- Nome exibido centralizado em `MascotConfig.name` (0 menções à Lili nos 1.565
  textos JSON; 0 nas Cloud Functions).
- **Pendência honesta:** ~16 telas ainda chamam `LiliMascot` diretamente (que É
  o sistema atual — `MascotWidget` delega a ele). Migrar cada call-site para
  `MascotWidget` é mecânico e de baixo risco, mas deixei para ser feito **com o
  compilador** (validação tela a tela), para não arriscar a estabilidade que um
  RC exige. Não é bug: é refino cosmético.

### §6 — Assets: candidatos de revisão (não removidos)
4 arquivos sem referência direta por nome — `loading_geral.svg` e 3 JSONs de
conteúdo (`desafios_iniciais`, `notificacoes_push`, `receitas_iniciais`).
**Não removidos**: provavelmente carregados dinamicamente (via `AssetManifest`
ou caminho de diretório). Removê-los às cegas quebraria conteúdo de runtime.
Revisar manualmente antes de excluir.

---

## Estado das seções que dependem de SDK/credenciais

| Seção | Estado | Depende de |
|---|---|---|
| §1 analyze/test | ⏳ não executável aqui | Flutter SDK |
| §2 builds (APK/AAB/Web/IPA) | ⏳ não executável aqui | Flutter+Android SDK / Xcode |
| §5 Firebase (deploy/App Check) | ⏳ estruturado | credencial + `firebase deploy` |
| §7 UX (dark/tablet/overflow) | ⏳ inspeção visual | dispositivo/emulador |
| §8 Acessibilidade (TalkBack/VoiceOver) | ⏳ parcial no código | dispositivo real |
| §10 Publicação (ícone/splash/permissões) | ⏳ config pronta | SDK + contas de loja |
| §11 testes | ⏳ não executável aqui | Flutter SDK |

---

## Lista de arquivos modificados/criados NA SESSÃO (v33→v38) — §12

**Novos (14):**
`lib/core/widgets/app_states.dart`, `lib/core/widgets/app_feedback.dart`,
`lib/core/mascot/mascot_config.dart`, `lib/core/mascot/mascot_assets.dart`,
`lib/core/mascot/mascot_widget.dart`,
`lib/features/gamification/domain/league_models.dart`,
`lib/features/gamification/providers/league_providers.dart`,
`lib/features/gamification/presentation/leagues_screen.dart`,
`lib/features/rewards/domain/daily_chest_models.dart`,
`lib/features/rewards/providers/daily_chest_providers.dart`,
`lib/features/rewards/presentation/daily_chest_screen.dart`,
`functions/tools/migrate_pdf_recipes.js`,
`assets/mascot/**` (15 png + README), documentos de relatório.

**Editados (principais):**
`pubspec.yaml` (geocoding removida, pasta mascot), `firebase/firestore.rules`
(pdf_recipes seguro), `firebase/firestore.indexes.json` (6 índices corretos),
`functions/src/index.js` (pdf_recipes + logs de auditoria),
`lib/core/router/app_router.dart` (rotas leagues, daily-chest),
`lib/features/pdf_recipes/data/pdf_recipes_repository.dart`,
`lib/features/pdf_recipes/presentation/pdf_viewer_screen.dart`,
`lib/features/gamification/presentation/gamification_screen.dart`,
`lib/features/rewards/presentation/rewards_store_screen.dart`,
`lib/features/home/presentation/home_screen.dart`,
`lib/features/audio_courses/presentation/lili_audios_screen.dart`,
`lib/features/admin/presentation/admin_screen.dart`,
+ 11 telas com correção de `dispose()` (v33) e 5 telas com adoção de
skeleton/erro (v34), 2 serviços com logs (v33).

---

## Prontidão de RC — leitura honesta

O projeto está **estruturalmente pronto para virar RC**, mas **ainda não é um
RC**, por uma razão só e sempre a mesma: nada disto passou por um compilador.
A validação estática desta versão é forte (rotas ✅, providers ✅, sem órfãos ✅,
segurança ✅), o que significa que a classe de erros "referência quebrada" está
muito reduzida. Mas erros que só o `analyze` revela (inferência de tipo, fluxo
de null-safety, APIs depreciadas) permanecem desconhecidos.

**Nota de prontidão para RC: ~60/100.** Sobe para RC de verdade assim que o
ciclo `flutter create . → pub get → analyze → corrigir → build` rodar uma vez.

### Caminho crítico para o RC (na sua máquina)
1. `flutter create .` · `flutter pub get` · `dart format .`
2. `flutter analyze` → me traga a saída; corrijo os erros reais em lote.
3. `flutter test` → ajusto os testes que quebrarem.
4. Migração das receitas + `firebase deploy --only firestore:rules,firestore:indexes,functions`.
5. Ícone (PNG 1024²) + splash → geradores.
6. `flutter build appbundle --release` (AAB) e `apk --release`.
7. Teste em device físico (claro/escuro, tablet, sem internet, free/Premium).

---

## Adendo V48 — Home redesenhada (referência visual do mockup "Lili Fit")

Você enviou um mockup completo de app (~13 telas). Implementei o coração dela —
a Home — com dois componentes novos, **usando dados 100% reais** (nada
inventado), e sinalizando o que não pude reproduzir.

### O que descobri sobre a paleta
O rosa do mockup (`#F4377F`) é a MESMA família do Rosa já oficial da marca
(`#F15BB5`) — mais saturado, não é uma cor nova. Não houve ruptura de
identidade: criei `AppColors.heroPinkGradient` como token **aditivo**.

### O que NÃO pude fazer (honestidade)
As fotos da modelo real no mockup **não têm como ser geradas por mim** — não
tenho ferramenta de geração de imagem fotográfica neste ambiente. Usei a
mascote Lily Fit ilustrada (já integrada) nos lugares equivalentes.

### Componentes novos (dados reais, sem número fabricado)
- **`DailyGoalCard`** (`features/home/presentation/widgets/daily_goal_card.dart`)
  — cartão-herói em rosa intenso com anel de progresso. O percentual é a MÉDIA
  REAL das 3 missões diárias já existentes (`d_treino`, `d_refeicao`, `d_agua`).
  CTA "Ver meu plano" → `/missions` (destino real).
- **`TodaySummaryGrid`** (`.../widgets/today_summary_grid.dart`) — grade 2×2:
  - Treino: progresso real da missão `d_treino`.
  - Água: `waterLogProvider` × meta calculada do peso cadastrado (mesma fórmula
    já usada em Nutrição).
  - Calorias: `todayKcalProvider` vs a meta TDEE real do `trainerProfileProvider`.
  - Passos: `healthSummaryProvider` SE houver wearable conectado; **sem
    inventar um número de passos**, cai para "Sequência" (streak real).
- Inseridos na Home na mesma ordem do mockup: saudação → Meta do dia → Resumo
  de hoje → cartão da Lily (já existia e já cumpre esse papel, mantido).

### Verificação
- ✅ Balanceamento OK nos 3 arquivos tocados + `app_colors.dart`.
- ✅ Todos os 8 providers/classes referenciados existem com esses nomes exatos.
- ✅ Todos os ícones (`AppIcons.workout/hydration/calories/running/streak`) existem.
- ✅ Profundidade dos imports relativos (`../../../../core/...`) conferida.
- ✅ `HealthSnapshot.has()/.formatted()` e `metaCalorica` (double) usados com a
  assinatura real.

### Próximos passos possíveis (seguindo a mesma referência, um de cada vez)
1. Tela "Meu Plano" (abas Hoje/Semana/Mês) — dá pra montar com o que já existe
   em treinos + missões.
2. Restilizar listas de Treinos/Receitas com cards de foto maiores (padrão do
   mockup) — usa os assets que já existem.
3. Definir fonte das fotos "estilo modelo real": (a) manter a Lily ilustrada
   em todo lugar, (b) contratar/licenciar fotografia real seguindo o mesmo
   estilo do mockup. Isso muda o resultado visual final — vale sua decisão
   antes de eu seguir para as próximas telas.

---

## Adendo V49 — Tela "Meu Plano" (Hoje / Semana / Mês)

Segunda tela da referência visual, seguindo a decisão de manter a Lily Fit
ilustrada (sem fotos reais, que não posso gerar).

### Nova tela: `lib/features/plan/presentation/my_plan_screen.dart`
Rota `/plan`; o botão "Ver meu plano" do cartão da Home agora aponta pra cá
(antes ia para `/missions`).

**Aba Hoje** (100% real):
- Treino em destaque: catálogo real (`SeedData.workouts`), rotacionado pelo
  dia da semana — não é aleatório nem fixo, muda de forma previsível dia a dia.
  Botão "Iniciar treino" abre a tela de detalhe de verdade.
- Checklist de refeições: **usei o campo `MealType` que já existia** no modelo
  `FoodEntry` (café/almoço/lanche/jantar) — o check ✓ aparece só se você
  registrou algo de verdade naquele horário hoje. Nenhuma "meta de refeição"
  fake, é o diário real agrupado.

**Aba Semana** (100% real): treinos concluídos e XP ganho nos últimos 7 dias,
calculados do histórico real de missões (`missionsProvider.history`, filtrado
por data). Mini-gráfico de água dos últimos 7 dias vindo de
`WaterLogNotifier.history()` (já existia, só nunca tinha virado gráfico).

**Aba Mês** (100% real): mesmos agregados filtrados pelo mês corrente, mais
sequência atual e evolução de peso (`currentWeight - startWeight`) quando a
usuária tem os dois valores cadastrados.

### Por que não uma "meta calórica por refeição" ou "treinos da semana"
fabricados
Cheguei a considerar simular esses números para bater mais com o mockup, mas
não existe um provider de "plano semanal" real no app — construir isso teria
sido inventar dado, o que os relatórios anteriores já sinalizaram como risco.
Preferi ancorar toda a tela em fontes de dado que já existem.

### Verificação
- ✅ Balanceamento OK nos 3 arquivos.
- ✅ `SeedData.workouts`, `WorkoutDetailScreen(workout:)`, `foodLogProvider`,
  `WaterLogNotifier.history()` (static), `missionsProvider.history` (tipo
  `List<MissionRecord>`) — todos conferidos com a assinatura real.
- ✅ Sem imports não utilizados.

---

## Adendo V50 — Ícones (verificação) + Lily Fit maior nos pontos-chave

### Ícones (`Metodo_1_Dia_Icones_Completos_1_.zip`)
Comparei os 42 arquivos com o que já está integrado (byte a byte, após
normalizar transparência e resolução): **pixel-idênticos** em todos os 42 —
é o mesmo material, reexportado em 1254px em vez de 1024px. Nada novo para
integrar; já está tudo ativo no app.

### Lily Fit maior — 4 pontos de alto impacto, sem risco de overflow
Mapeei todos os ~35 usos da mascote no app antes de mexer. Decidi **não**
aumentar universalmente — telas com avatares pequenos (menus, chips, cards de
lista) mantêm o tamanho correto de propósito; blowup ali quebraria alinhamento
(mesma lógica já aplicada aos ícones: 3D grande só onde é hero, não em contexto
compacto). Aumentei nos 4 lugares que são realmente vitrine:

| Tela | Antes | Depois | Por quê |
|---|---|---|---|
| Splash (1ª impressão) | 180 | **240** | `Column` centralizada em tela cheia — cresce sem risco |
| Premium (venda) | 160 | **210** | `ListView` rolável — pedido explícito "vender premium" |
| Onboarding | 200 | **220** | aumento moderado (há elementos fixos abaixo: pontos + botão) |
| `LiliGuide` (cartão da Home) | 110 | **130** | só a Home usa o tamanho padrão puro; os outros 3 usos já tinham tamanho ajustado ao contexto apertado e ficaram intocados |

### Verificação
- ✅ Balanceamento OK nos 4 arquivos.
- ✅ Nenhum dos pontos aumentados está em container de altura fixa (todos
  `Column`/`Row` dentro de `ListView`/`Center` — crescimento vertical seguro).
- ✅ Confirmado: `LiliGuide` só tem 2 chamadas sem override — a Home (afetada,
  como pretendido) e o próprio arquivo (definição do padrão); os outros 3 usos
  (`ai_trainer`, `rewards_store`, `missions`) mantêm o tamanho customizado que
  já tinham, intactos.

### Sobre "deixar tudo completo"
Sendo direto: isso eu não prometo em uma resposta — o app tem pendências reais
(Firebase, pagamento real, primeira build) documentadas nos relatórios
anteriores. O que fiz aqui é concreto e verificável: ícones confirmados,
mascote redimensionada nos pontos certos. Sigo com mais passos assim que você
indicar prioridade.

---

## Adendo V51 — Resposta à V50: por que não builds, e auditoria estática rigorosa

### Sobre a Prioridade 1 (compilar)
Reconfirmado nesta sessão: sem Flutter SDK/Android SDK/Xcode/rede aqui.
`flutter analyze/test/build` continuam impossíveis de executar neste ambiente.
**Respeitando sua própria instrução** ("não adicione funcionalidades antes de
corrigir"), NÃO construí as Prioridades 4–7 (Home/Treinos/Receitas/Evolução)
nesta passagem — seria empilhar código não verificado exatamente onde você
pediu o oposto. Isso fica para depois de termos o `analyze.txt` real.

### O que fiz em troca: auditoria estática de verdade (Prioridade 9)
Fiz uma varredura sistemática nos 184 arquivos `.dart` — símbolo por símbolo,
não "olhando por cima". Para ser transparente sobre o processo:

**1ª tentativa (script simples): 107 "imports suspeitos".** Ao investigar,
descobri um bug no MEU script — ele não reconhecia declarações estilo
`final xProvider = StateNotifierProvider(...)` (sem tipo explícito antes do
nome, o padrão Riverpod dominante no projeto). Corrigi o script.

**2ª tentativa (corrigida): 4 candidatos.** Verifiquei cada um manualmente:
- 2 eram falso-positivo de `extension` (`.label`/`.emoji`/`.color` usados sem
  citar o nome da extensão — import correto, script não reconhecia esse padrão).
- 1 era falso-positivo de função top-level (`foodKcalHistory`) — outro gap do
  script.
- **1 era real:** `health_sync_screen.dart` importava `health_service.dart`
  sem usar nada de lá (só usa símbolos de `health_models.dart`, já importado
  à parte). **Corrigido.**

Relato o processo completo, incluindo os erros do meu próprio script, porque
prefiro isso a apresentar um número inflado como se fosse "achado".

**Classes duplicadas:** 7 nomes repetidos entre arquivos, mas 6 são classes
privadas (`_Bubble`, `_Chip`, `_PremiumLock`, `_CategoryChip`, `_CourseCard`,
`_StatChip`) — em Dart, `_Nome` é privado por ARQUIVO, repetir entre arquivos
diferentes é normal e correto, não é bug. Só `WorkoutPlan` (sem `_`) existe em
dois arquivos (`trainer_engine.dart` e `pt_models.dart`); confirmei que
**nenhum arquivo importa os dois ao mesmo tempo**, então não há colisão real
hoje — fica como observação de arquitetura, não como correção forçada.

**Rotas:** 56 `GoRoute`, zero duplicadas, todas as constantes `Routes.X`
usadas estão definidas.

### Sobre as Prioridades 2, 3, 8 (qualidade visual, Lily, performance)
Já em andamento nas versões anteriores (kit de animação/skeleton v34,
ligas/baús/celebração v36-37, mascote nova + maior nos pontos-chave v41/v50,
ícones reais v43-45). Não vou reempacotar tudo de novo aqui — o ZIP mais
recente (v50) já contém isso. Continuo essa linha assim que Priority 1 destravar.

### Próximo passo real
Preciso do `analyze.txt` (via GitHub Actions ou seu Android Studio) para dar
sequência à Prioridade 1 de verdade. Sem ele, o que resta fazer aqui é mais
desta auditoria estática — que tem teto: já capturei o que dá pra achar sem
compilador.

---

## Adendo V52 — Varredura final ampla + checklist de validação manual

Sem `flutter analyze` novo ainda (você confirmou que não rodou desta vez).
Fiz a última rodada de verificação estática possível antes de precisar do
resultado real:

- **Balanceamento em TODOS os 184 arquivos** (não só os que editei): 2
  sinalizados inicialmente, ambos confirmados como falso-positivo (blocos de
  código de exemplo dentro de comentário `///`, no `premium_service.dart` e
  `rive_helper.dart` — documentação de como ativar RevenueCat/Rive no futuro).
  Removendo os comentários e recontando: **0 problemas reais**.
- **122 referências de asset** (`AppAssets.*` + `AppIcons.*`) reconferidas —
  **0 quebradas**. (Tive um erro no meu próprio script nessa checagem — grep
  com 2 arquivos prefixa `nome:` no resultado e eu não tratei isso da primeira
  vez, o que gerou uma lista de 122 "falhas" falsas. Corrigido e revalidado.)

### Novo: `CHECKLIST_VALIDACAO_MANUAL.md`
Login, Firebase, receitas, vídeos, áudios, treinos, notificações e navegação
**não dá pra validar por leitura de código** — só testando o app rodando de
verdade. Preparei uma checklist objetiva pra você marcar assim que tiver o
APK instalado, com um campo de "se algo falhar, anote isto" pra me trazer de
volta caso apareça algo quebrado.

### Situação
Chegamos ao teto do que a auditoria estática consegue fazer sem compilador.
Não há mais nada de "código morto" ou "referência quebrada" restante pra
caçar — as duas grandes varreduras desta e da versão anterior (v51) não
encontraram problema real algum. O próximo `flutter analyze` real é o que
decide se seguimos para o refinamento visual, como você pediu.

---

## Adendo V53 — Água (tela nova) + busca em Receitas

Continuação do refinamento visual (Home e Meu Plano já cobertos na v48-49).

### Nova tela: Água (`lib/features/nutrition/presentation/hydration_screen.dart`)
Não existia como tela própria — a hidratação vivia só embutida em Nutrição.
Reaproveita 100% a lógica real (`waterLogProvider`, `WaterCalculator`,
integração com a missão `copoDeAgua`) — nenhum dado novo. Visual: anel de
progresso com selo de garrafa animada no centro (nível sobe conforme os copos,
construído em Flutter puro, sem asset externo), cartão da Lily reagindo
(comemora ao bater a meta, incentiva enquanto não bate), botão "+ Beber água".
Rota `/hydration`; o tile de Água na Home agora abre essa tela ao tocar.

### Receitas: busca adicionada
O mockup mostrava busca por nome, que não existia. Adicionada, combinando com
o filtro de categoria já existente (11 categorias reais, mais completo que as
4 do mockup). Mensagem de "nada encontrado" ajustada pra refletir se foi a
busca ou a categoria que não achou nada.

### Correção de processo (transparência)
Ao registrar a rota `/hydration` no `app_router.dart`, minha primeira edição
via script ficou malformada — fechei o bloco do GoRoute anterior no lugar
errado. A contagem bruta de chaves bateu por coincidência (mesmo total, posição
errada), o que quase passou despercebido. Peguei ao **ler o texto**, não só
contar, e corrigi na hora. Fica registrado porque é exatamente o tipo de erro
que só um compilador real pega com certeza — reforça por que o próximo
`flutter analyze` seu continua sendo o passo decisivo.

### Verificação
- ✅ Varredura completa nos 185 arquivos (184 + a tela nova): 0 problemas reais.
- ✅ Todos os símbolos usados na tela de Água confirmados um a um antes de
  fechar (`MissionEvent.copoDeAgua`, `LiliMood.comemorando`,
  `MascotePose.hidratacao/celebrando`, `AppColors.info/background`, etc.)
- ✅ Rota `/hydration` registrada uma única vez, sem duplicata.

### Ainda no radar (próximos passos do mockup)
Treinos (adicionar campo de foto real ao modelo, hoje usa emoji — preparado
pra quando você mandar fotos), tela de Progresso com gráfico de peso dedicado,
telas de detalhe (receita aberta / treino aberto) no padrão foto-grande do
mockup. Sigo nessa ordem quando você mandar continuar.

### Decisão de produto em aberto (sua, não minha)
O mockup usa "Receitas" como uma das 5 abas fixas da navegação inferior; o
app hoje usa "Hábitos" nesse lugar. São conceitos diferentes — não troquei
sozinho. Se quiser Receitas na barra fixa, me avisa qual dos dois deve sair.

---

## Adendo V54 — Foto real em Treinos + Medidas em Evolução

### Treinos: preparado para foto real
`Workout` ganhou campo opcional `photoUrl` (retrocompatível — `null` cai no
emoji de sempre). Card da lista atualizado: mostra a foto quando existir, com
fallback automático pro emoji se a URL falhar ao carregar
(`errorWidget` do `CachedNetworkImage`, mesmo padrão usado em Receitas).
Nenhum treino existente quebra; quando você cadastrar fotos reais, aparecem
automaticamente.

### Evolução: nova seção "Medidas"
Não existia NENHUM rastro de medidas corporais no projeto — confirmei antes
de construir. Criado do zero, seguindo exatamente o mesmo padrão local-first
já usado pelo histórico de peso (`weightHistoryProvider`):
- `MeasurementEntry` (cintura/quadril/peito/braço/coxa, todos opcionais).
- `measurementHistoryProvider` — persiste em SharedPreferences, mesma
  estrutura de `WeightHistoryNotifier`.
- Cartão "Medidas" na tela de Evolução, com diálogo de registro (mesmo padrão
  visual do diálogo de peso) e exibição da última medida registrada.

### Verificação
- ✅ Varredura completa nos 186 arquivos: 0 problemas novos (só os 2
  falso-positivos de comentário, já documentados e confirmados antes).
- ✅ Li os dois arquivos principais (evolution_screen.dart e workouts_screen
  card) do início ao fim — não confiei só em contagem, depois do erro de
  processo registrado na v53.
- ✅ `MeasurementEntry`/`measurementHistoryProvider` resolvidos onde usados.

### Status da lista de pendências visuais (da v53)
- ✅ Água (v53)
- ✅ Busca em Receitas (v53)
- ✅ Foto real em Treinos — estrutura pronta (v54)
- ✅ Medidas em Evolução (v54)
- ⏳ Telas de detalhe (receita aberta / treino aberto) no padrão foto-grande
  do mockup — próximo passo.
- ⏳ Decisão de produto em aberto: Receitas vs Hábitos na barra fixa (sua).

---

## Adendo V55 — Telas de detalhe: treino e receita no padrão foto-grande

### Treino aberto (`workout_detail_screen.dart`) — reescrita completa
- **Foto real**: usa `photoUrl` quando existir, com fallback pro emoji+gradiente
  de sempre se a URL falhar ou não existir ainda.
- **Descanso automático**: trouxe o mesmo mecanismo de cronômetro
  (`Timer.periodic`) que já existia e funcionava na área do Personal Trainer
  — não inventei um novo, reaproveitei o padrão comprovado. Ao marcar um
  exercício como feito, inicia uma contagem de 45s com opção de pular.
- **Marcar exercício**: cada exercício agora responde ao toque (check verde,
  texto riscado), com contador "(x/y)" no cabeçalho da seção.
- Toda a lógica de XP/moedas/celebração com a Lily que já existia foi
  **preservada exatamente igual**, só reorganizada dentro da nova estrutura
  (StatefulWidget, necessário pro cronômetro).

### Receita aberta (`pdf_viewer_screen.dart`) — polimento
Essa tela já mostrava os macros reais (nada fabricado antes nem agora) — só
faltava a fotografia de capa em destaque, que o modelo já tinha
(`coverUrl`) mas não era exibida. Adicionei o header de foto (com
placeholder e fallback de ícone) e troquei os macros de texto simples para
pílulas com ícone, no mesmo estilo visual do treino — consistência entre as
duas telas de detalhe.

### Por que não criei uma lista de "ingredientes" na receita
O modelo `PdfRecipe` não tem ingredientes como dado estruturado — o conteúdo
real É o PDF. Fabricar uma lista de ingredientes fake pra bater 100% com o
mockup teria sido inventar dado, o que os relatórios desta sessão vêm evitando
sistematicamente. A receita mostra o que é real (foto, macros, tempo,
dificuldade) e abre o PDF de verdade para o conteúdo completo.

### Verificação
- ✅ Varredura completa nos 186 arquivos: 0 problemas novos.
- ✅ Ambos os arquivos lidos do início ao fim antes de fechar (disciplina
  mantida desde o erro de processo da v53).
- ✅ Único call site de `WorkoutDetailScreen` (`workouts_screen.dart` +
  `my_plan_screen.dart`) confirmado compatível — assinatura do construtor
  não mudou.
- ✅ Todos os 6 usos de `_Macro` no novo formato `(icon, label)`.

### Status final da lista de pendências visuais
- ✅ Home, Meu Plano, Água, Receitas (busca), Treinos (foto), Evolução
  (medidas), detalhe de treino, detalhe de receita.
- ⏳ Única pendência restante do mockup: decisão de produto sobre
  Receitas vs Hábitos na barra de navegação fixa (sua, não minha).

---

## Adendo V56 — Treinos favoritos

Item da Prioridade 5 (v50) que ainda faltava: "exercícios favoritos".

### Novo: `lib/features/workouts/providers/workout_favorites_providers.dart`
Mesmo padrão exato já comprovado em Receitas (`PdfRecipeFavoritesNotifier`) —
Set de IDs persistido em SharedPreferences, sem servidor.

### Integração em `workouts_screen.dart`
- Convertido de `StatefulWidget` para `ConsumerStatefulWidget` (necessário
  pra acessar o provider).
- Coração de favorito em cada card da lista (mesmo ícone/cor do padrão já
  usado em Receitas — `AppColors.secondary` quando ativo).
- Novo chip de filtro "❤️ Favoritos" — mostra só os treinos favoritados,
  com estado vazio próprio ("Você ainda não favoritou nenhum treino").

### Verificação
- ✅ Varredura completa nos 187 arquivos: 0 problemas novos.
- ✅ Arquivo lido do início ao fim; único call site de `_WorkoutCard`
  (dentro do próprio arquivo) atualizado com os 2 novos parâmetros
  obrigatórios.

### Situação
A lista de pendências visuais do mockup + Prioridades 2-9 da v50 está, neste
ponto, coberta na medida do que dá pra fazer sem compilador. Itens que
seguem fora do meu alcance aqui: qualquer coisa que dependa de execução real
(`flutter analyze`, testes, builds) e as duas decisões que são suas —
Receitas vs Hábitos na navegação, e fonte das fotos (mascote ilustrada vs
fotografia real licenciada).
