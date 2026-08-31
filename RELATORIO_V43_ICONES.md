# Relatório V43 — Integração dos ícones oficiais

> Ambiente sem Flutter SDK/rede: `flutter analyze`/build seguem para sua máquina
> ou o CI. Validação aqui = análise estática + inspeção real das imagens (PIL).
> Não declaro "compilado".

## 1. RELATÓRIO DE TRANSPARÊNCIA (importante — leia)
Os 42 ícones vieram **em RGB, com fundo BRANCO sólido — SEM transparência**
(verificado imagem a imagem). Isso contraria o requisito "transparência real /
sem fundo branco" e quebraria o visual sobre cards lilás/escuros.

**O que fiz:** removi **apenas o fundo branco externo** por flood-fill a partir
das bordas, **preservando o desenho e o branco interno** (ex.: a casinha do
`home`, símbolos brancos dentro dos tiles). Não redesenhei nada, não mudei cores.
Resultado padronizado em **1024×1024 RGBA**.
- 41/42 ficaram com transparência limpa (34–79% de área transparente).
- `icon_edit` é um tile rosa que preenche o quadro (quase sem fundo) — mantido
  como está (0% a remover), sem prejuízo.
- **QA visual:** gerei folhas de contato sobre fundo **preto** e **lilás** —
  sem halos brancos, contraste bom. (`icons_on_dark.png`, `icons_on_lilac.png`)
- **Originais preservados** (fundo branco) como backup fora do entregável, caso
  queira revisar/reverter.

> Se preferir os ícones EXATAMENTE como enviados (com fundo branco), é só avisar
> que eu troco pelos originais — mas aí eles mostrarão quadrado branco sobre
> fundos coloridos.

## 2. Ícones integrados (42)
Copiados para `assets/icons/` (transparentes, 1024²), convivendo com os 25 SVGs
antigos (não apagados ainda — ver §5). `pubspec.yaml` já declarava
`assets/icons/` (nível de pasta), então os PNGs novos já entram no bundle.

Lista: audio, bmi_measure, calendar, calories, camera_food, checklist,
community, courses, edit, favorite, goal, gps_running, health_heart, home,
hydration, login, logout, medal_ranking, meditation, messages, notifications,
nutrition, premium, privacy, profile, progress, recipes, running, scanner,
search, settings, share, shopping_list, sleep, statistics, stopwatch, streak,
support, trophy, video, weight, workout_dumbbell.

## 3. Catálogo + componente (itens 4 e 5)
- **`lib/core/assets/app_icons.dart`** — `AppIcons` com os 42 caminhos + apelidos
  semânticos para os nomes do briefing (camera→cameraFood, timer→stopwatch,
  measurement→bmiMeasure, medal/ranking→medalRanking, food→nutrition,
  workout→workoutDumbbell, course→courses). Todos os caminhos validados: existem.
- **`lib/core/widgets/app_icon_image.dart`** — `AppIconImage` com `assetPath`,
  `size/width/height`, `fit`, `semanticLabel`, `borderRadius`, `fallbackIcon`,
  `onTap`, `filterQuality`, **`errorBuilder`** (nunca deixa buraco) e
  **`cacheWidth`** por devicePixelRatio (não carrega 1024² para exibir 24px).
  Sem tint sobre o PNG. `Semantics` para acessibilidade; área de toque com
  padding quando `onTap`.

## 4. Ícones faltantes / apelidados (sem arquivo dedicado)
- **ebook** → apontado para `courses` (não veio `icon_ebook`).
- **location** → apontado para `gps_running` (não veio ícone de localização puro).
  Se quiser ícones dedicados, me envie que eu integro.

## 5. Referências antigas restantes (item 10)
- **SVGs antigos** (`assets/icons/ic_*.svg`, 25): só **1** é usado numa tela real
  (`AppAssets.icTreinos`, na tela de *showcase*). Os outros 24 constantes estão
  **definidos mas sem uso**. **Não apaguei** nenhum (conforme sua regra).
- **Material `Icons.*`**: 213 usos (103 distintos). **Não troquei em massa** —
  você pediu substituição *gradual* e para **preservar** ícones de navegação
  (voltar, fechar, menu...). A migração de cards/menus/módulos é incremental
  (ver §7), feita com o compilador disponível para validar cada tela.

## 6. Adoção de referência feita
Adicionei uma **galeria dos 42 ícones** na tela de showcase, renderizada pelo
`AppIconImage` — prova que o componente carrega todos corretamente e serve de
catálogo visual no app. (arquivo: `asset_showcase_screen.dart`)

## 7. Guia de migração gradual (para as ~33 telas do briefing)
Trocar, onde há um Material icon grande de módulo/card/atalho:
```dart
// antes:  Icon(Icons.fitness_center, size: 32)
// depois: AppIconImage(AppIcons.workout, size: 32, semanticLabel: 'Treinos')
```
Manter `Icon(Icons.*)` para navegação técnica (voltar, fechar, seta, menu).

## 8. Verificação
- ✅ Todos os caminhos de `AppIcons` resolvem para arquivo real.
- ✅ `app_icons.dart` e `app_icon_image.dart` balanceados; imports usados.
- ✅ `pubspec` cobre `assets/icons/` (sem duplicar entrada).
- ✅ Duplicatas de conteúdo: **nenhuma** (42 hashes distintos).
- ✅ Fallback confirmado (`errorBuilder` → ícone Material).
- ⏳ `flutter analyze`/build: na sua máquina/CI.

## 9. Arquivos desta versão
Novos: `lib/core/assets/app_icons.dart`, `lib/core/widgets/app_icon_image.dart`,
`assets/icons/icon_*.png` (42). Editado: `asset_showcase_screen.dart`.

---

## Adendo V44 — Migração gradual (primeiro lote real)

Continuei a substituição dos ícones nas telas, do jeito seguro (telas lidas por
inteiro, componentes retrocompatíveis, sem tocar em ícones de navegação):

- **Perfil** (`profile_screen.dart`): `_menuItem` ganhou parâmetro opcional
  `iconAsset`. 6 itens de menu agora usam ícone PNG oficial — Editar (edit),
  Premium (premium), Conquistas (trophy), Notificações (notifications), Chat da
  Amanda (messages), Sincronização de Saúde (healthHeart). Itens sem ícone
  dedicado (Som/vibração, IA, Admin) mantêm Material. `chevron_right` de
  navegação preservado.
- **Home** (`home_screen.dart`): `_QuickAction` ganhou `iconAsset` (emoji vira
  fallback). **16 atalhos** do grid principal agora usam ícone PNG: Treinos,
  Corrida GPS, Nutrição, Hábitos, Comunidade, Premium, Metas, Sequência, Saúde,
  Calendário, Cursos em áudio, Receitas PDF, Relatórios, Vídeos, Personal
  Trainer, Banco de alimentos. Os demais atalhos mantêm emoji (sem ícone
  correspondente).

**Padrão retrocompatível:** em ambos, o parâmetro novo é opcional — nada quebra
onde não foi passado, e a migração dos atalhos/itens restantes é só adicionar
`iconAsset:` conforme forem surgindo ícones.

**Verificação:** todas as referências `AppIcons.*` resolvem; as 3 telas
(perfil, home, showcase) balanceadas; imports sem duplicação; `AppColors`
preservado no perfil (bug de import corrigido no ato).

Telas migradas neste lote: 2 reais (perfil, home) + showcase (galeria).
Próximos lotes sugeridos: nutrição, treinos, gamificação, comunidade.

---

## Adendo V45 — Navegação inferior + análise honesta do lote

### Barra de navegação inferior (5 abas) ✅
`main_shell.dart` agora usa os ícones PNG oficiais: Home, Treinos (workout),
Hábitos (checklist), Evolução (progress), Perfil (profile). Em **tamanho
equilibrado (26px)**, com estado ativo/inativo pelo mecanismo nativo
`icon`/`activeIcon` (inativo esmaecido a 45%), já que PNG colorido não muda de
cor como Material. Cada aba mantém um `fallbackIcon` Material.
> Se achar os ícones 3D "cheios" demais na barra, reverter para Material (ou
> usar versões flat) é trivial — é só sua preferência; deixei o fallback pronto.

### Lote nutrição / treinos / gamificação / comunidade — por que NÃO troquei
Ao ler essas telas, elas usam sobretudo **ícones pequenos e técnicos**:
salvar, buscar, informação, curtir (favorite/favorite_border), comentar,
editar (FAB), voltar, chevron. Isso é justamente a categoria que o seu briefing
mandou **preservar em Material** ("não substituir automaticamente ícones
pequenos de navegação técnica"; "não usar 3D muito grande"; usar os 3D em
"cards, atalhos, menus, módulos, banners"). Trocar esses por PNG 3D pioraria a
usabilidade e o visual. Então, por decisão técnica coerente com suas regras,
**mantive Material** nessas telas.

### Onde os ícones 3D REALMENTE encaixam (já feito)
- Grid de atalhos da Home (16 itens) ✅
- Menu do Perfil (6 itens) ✅
- Barra de navegação inferior (5 abas) ✅
- Galeria no showcase ✅
Essas são as superfícies de "módulo/atalho/card" — o resto do app usa ícones de
ação pequenos, que não são candidatos.

### Verificação
- ✅ `main_shell.dart` balanceado; 5 refs `AppIcons` resolvem; fallback Material.
- ✅ Nenhuma tela quebrada; mudança isolada na casca de navegação.
