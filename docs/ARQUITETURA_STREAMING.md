# Arquitetura de Streaming — Vídeos e Áudios

## Princípio central
**Nenhum arquivo de vídeo ou áudio fica dentro do app.** O Firestore
guarda só metadados leves (nome, categoria, capa, professor, duração,
Premium sim/não, ordem). O arquivo em si vive num provedor de streaming
externo (Bunny.net, Cloudflare R2, S3+CloudFront — veja abaixo) e o app só
guarda/consome uma **URL**.

Isso significa: **o tamanho do APK/AAB/IPA não cresce** conforme você
adiciona conteúdo, e você pode publicar centenas de vídeos novos sem
precisar atualizar o app nas lojas.

## Por que a URL do vídeo não fica no documento público

Se `videoUrl` estivesse no mesmo documento que `name`/`thumbnailUrl`/etc.
(que qualquer usuária logada pode ler), o botão "Premium" na tela seria
só estética — qualquer pessoa com um pouco de curiosidade conseguiria
abrir o Firestore no DevTools e pegar a URL de um vídeo pago.

Por isso a estrutura é:

```
videos/{videoId}                        <- metadados públicos (todo mundo logado lê)
  name, category, subcategory, description, teacher,
  thumbnailUrl, durationSeconds, level, isPremium, order, active

videos/{videoId}/private/stream          <- URL real (ninguém lê direto)
  videoUrl: "https://seu-provedor.../video.m3u8"
```

A regra do Firestore bloqueia leitura de `private/*` pra qualquer cliente
(`allow read: if false`). A única forma de obter a URL é chamando a Cloud
Function `getVideoUrl`, que:
1. Verifica o token de autenticação (sabe quem está pedindo).
2. Se o vídeo é Premium, confere `isPremium` no perfil da usuária — no
   servidor, não confiando em nada que o app mandou.
3. Só então devolve a URL.

O mesmo raciocínio vale pra áudio — **e agora recebeu a mesma proteção**:
a URL de cada capítulo saiu do documento público e foi pra
`audio_courses/{id}/private/chapters` (mapa chapterId→url), resolvida só
pela Cloud Function `getContentUrl`. Cursos em áudio Premium agora têm
proteção de servidor de verdade, igual vídeos/e-books/cursos.

**Gap que ainda resta, e por quê não fechei agora**: receitas em PDF
(`pdf_recipes`) continuam com a URL no documento público — proteção só de
UI. Diferente de áudio, receitas nunca tiveram um painel admin pra
cadastrar conteúdo (uma lacuna à parte, pré-existente); migrar a proteção
sem ter como testar/cadastrar via admin não fazia sentido nesta rodada, e
criar esse admin seria funcionalidade nova — fora do escopo que foi
pedido ("não adicionar novas funcionalidades"). Fica registrado como
pendência clara pra próxima vez que isso for prioridade.

## Player

- **Vídeo**: `video_player` + `chewie` — play/pause/seek/tela cheia/
  velocidade (0.5x-2x)/próximo automático ao terminar/lista "a seguir"/
  continuar de onde parou (posição salva localmente por vídeo).
- **Áudio**: `just_audio` — mesma ideia, tocando em segundo plano.

### O que ficou de fora (documentado, não escondido)
- **Picture-in-Picture**: exigiria o pacote `floating` (Android) +
  configuração nativa específica por plataforma — não implementado.
- **Chromecast/AirPlay**: exigiriam SDKs de cast dedicados — não
  implementado, mas a arquitetura (URL simples de streaming) é
  compatível com isso no futuro.
- **Qualidade adaptativa (HLS multi-bitrate)**: `video_player` reproduz
  HLS se a URL for um `.m3u8` bem formado — funciona, mas eu não construí
  um seletor de qualidade manual na UI.

## Download offline (MVP)

Implementado: baixar o vídeo pro armazenamento privado do app (não
acessível por outros apps), tocar offline, ver espaço usado, remover
download.

**Limitação honesta**: não há criptografia/DRM real — é um arquivo comum
salvo localmente. Para proteção de nível profissional (o tipo que
bloqueia extração mesmo em device comprometido), seria necessário usar o
SDK de DRM do próprio provedor (Bunny.net oferece isso, por exemplo) — não
é algo genérico que dá pra implementar só em Dart. Documentando como
pendência real, não maquiando como resolvido.

## Cache

- **Metadados**: Riverpod já mantém em memória durante a sessão.
- **Thumbnails**: `cached_network_image` (cache automático em disco).
- **Vídeo/áudio em si**: o cache de streaming (buffer) é feito pelo
  próprio `video_player`/`just_audio`; não há um cache "prévio" de
  segmentos além do download offline explícito.

## Provedor de streaming — arquitetura desacoplada

O app **não tem nenhuma dependência de SDK de provedor específico**. Ele
só reproduz uma URL HTTP(S) — funciona igual com Bunny.net, Cloudflare R2,
S3+CloudFront ou qualquer CDN. Trocar de provedor no futuro = trocar a URL
cadastrada no Firestore, zero mudança de código no app.

Ordem de recomendação (do prompt original):
1. **Bunny.net** — melhor custo-benefício pra streaming de vídeo/áudio,
   suporta tokens de autenticação assinados (útil pra reforçar a proteção
   Premium além do que a Cloud Function já faz).
2. **Cloudflare R2** — bom como armazenamento puro (sem custo de egress),
   combine com um player HLS se quiser transcodificação.
3. **Amazon S3 + CloudFront** — estrutura mais "enterprise", mais cara,
   mais configuração.

## Painel administrativo

`VideosAdminScreen` (Perfil -> Admin -> Vídeos) já escreve nas duas
coleções corretamente (público + privado) — cadastrar um vídeo novo não
exige nenhuma alteração de código nem publicação de nova versão do app.
