# Sistema Dinâmico — Lili (mascote) e Amanda (personal trainer)

## Por que dois módulos separados
Antes desta rodada, a Amanda (personal trainer, chat de IA) **usava a arte
da Lili emprestada** em 5 lugares diferentes (cabeçalho e bolhas de chat em
`features/amanda` e `features/ai_trainer`). Isso significava que Amanda
nunca teve identidade visual própria — qualquer imagem seria, na prática,
a Lili. Corrigido nesta rodada: Amanda agora tem seu próprio sistema de
fotos, totalmente independente.

## Módulo Lili (`features/mascot_lili`)
**A mudança mais importante**: o widget `LiliMascot` (usado em ~20 lugares
no app) virou "ciente" de assets dinâmicos. Ele:
1. Recebe uma `pose` estática (como sempre) ou uma `category` explícita.
2. Se não vier `category`, deriva automaticamente da `pose` via
   `liliCategoryForPose` (ex.: `MascotePose.halteres` -> `treinando`).
3. Busca no Firestore (`lili_assets`) se existe um asset ativo pra essa
   categoria.
4. Se existir: renderiza a imagem (`CachedNetworkImage`) ou animação
   Lottie (`Lottie.network`) cadastrada.
5. Se não existir, ou o Firebase não estiver configurado, ou a URL falhar
   ao carregar: cai automaticamente pra pose estática local (PNG), exatamente
   como funcionava antes.

**Resultado prático**: quando você cadastra uma imagem pra categoria
"Treinando" no painel admin, TODAS as telas que mostram a Lili treinando
(halteres, força) passam a usar essa imagem nova — sem eu precisar editar
uma linha sequer nessas telas. É exatamente o "sem precisar publicar nova
versão" que foi pedido.

### Rive — status real
`rive` **não é uma dependência do projeto ainda**. O enum `LiliAssetType`
já tem o valor `rive` preparado, e o código já trata esse caso (cai pro
estático), mas a renderização de verdade só funciona quando o pacote
`rive` for adicionado ao `pubspec.yaml` — não fiz isso agora pra não trazer
uma dependência pesada sem um asset `.riv` real pra testar.

## Módulo Amanda (`features/personal_amanda`)
Sistema paralelo e independente: `AmandaImage` widget, categorias de foto
(principal, profissional, categoria, banner, desafio, motivacional,
premium), Firestore `amanda_assets`, e um placeholder próprio (ícone
genérico com gradiente da marca) — **nunca** usa arte da Lili como
fallback.

### O que já foi corrigido nesta rodada
- Cabeçalho do chat da Amanda (`amanda_screen.dart`) — antes usava
  `LiliMascot(pose: apontando)`, agora usa `AmandaImage`.
- Bolhas de mensagem da Amanda no mesmo chat — idem (e removi a função
  `_poseForBotMessage`, que ficou órfã).
- Cabeçalho do chat "Amanda IA" (`ai_trainer_screen.dart`) — idem.
- Tela de apresentação "Sou a Amanda, sua personal" — a imagem grande
  agora é `AmandaImage`; a `LiliGuide` logo abaixo continua sendo a Lili
  de propósito (ela está genuinamente dando uma dica contextual ali, não
  fingindo ser a Amanda).
- Bolha de mensagem no chat do AI trainer — idem.

### Nova tela: Perfil da Personal
`AmandaProfileScreen` — foto grande + bio. Acessível tocando no cabeçalho
de qualquer um dos dois chats da Amanda.

## Onde a Amanda AINDA não foi conectada
O pedido lista vídeos de treino, capas de curso em áudio, dicas de
exercício/alimentação, programas, desafios, onboarding e home como lugares
onde a Amanda "aparecerá". Não editei essas telas nesta rodada — construí
a infraestrutura (`AmandaImage` + categorias certas pra cada contexto) mas
não fui inserindo o widget em uma dúzia de telas já estáveis sem
combinar prioridade primeiro. Se quiser, me diga quais 2-3 telas importam
mais agora e eu conecto.

## Painel administrativo
Dois novos itens em Perfil -> Admin: **"Assets da Lili"** e **"Fotos da
Amanda"**. Fluxo: escolher categoria -> enviar imagem do dispositivo
(`image_picker` -> Firebase Storage, path `public/lili_assets/...` ou
`public/amanda_assets/...`, já coberto pelas regras de Storage existentes)
**ou** colar uma URL direto -> ativar/desativar -> excluir. Mudança aparece
pra todo mundo assim que salva (sem precisar reabrir o app — o provider é
invalidado e recarrega).

## Cache
Imagens: `cached_network_image` (mesmo padrão do resto do app — cache em
disco automático). Lottie: o pacote `lottie` já faz seu próprio cache de
rede. Metadados (lista de assets ativos): ficam em memória durante a
sessão via Riverpod; o admin força recarregar via `ref.invalidate` depois
de qualquer alteração.

## Placeholder / nunca quebra layout
- Lili sem asset dinâmico pra uma categoria -> pose estática local (como
  sempre foi).
- Amanda sem nenhuma foto cadastrada -> ícone genérico com gradiente da
  marca, no tamanho exato pedido (`size` do widget) — o espaço reservado
  nunca colapsa.
