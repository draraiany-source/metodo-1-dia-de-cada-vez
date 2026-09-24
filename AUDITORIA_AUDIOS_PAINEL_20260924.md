# Áudios — o que funciona e o que foi corrigido (24/09/2026)

## Escopo
Painel da Amanda (Personal / Admin) para **adicionar, substituir, ordenar e remover** áudios com arquivo no **Firebase Storage** e metadados no **Firestore**. Sem conteúdo fictício publicado para alunas.

## O que já existia
| Parte | Status anterior |
|---|---|
| Tela `AudioCoursesAdminScreen` (Central → Áudios) | Criar curso + adicionar capítulo só por **URL colada**; excluir curso inteiro |
| Firestore `audio_courses` + `private/chapters` | Escrita liberada para Admin **e** Personal |
| Storage upload de MP3 no app | **Não existia** |
| Rules Storage `audio_programs/**` | Só **Admin** podia gravar |
| Programa 7 Dias | YouTube hardcoded + **demo** quando lista vazia (parecia publicado) |
| Meditações | CMS de **vídeos YouTube** (não MP3) — intacto |

## O que foi corrigido / adicionado
1. **Upload de arquivo** no painel (`file_picker` → Storage `audio_courses/{courseId}/{chapterId}.ext`).
2. **Substituir** arquivo da faixa (mesmo chapterId; remove path antigo).
3. **Ordenar** faixas (setas sobe/desce → `reorderChapters`).
4. **Remover** faixa individual (Firestore + Storage).
5. **Rascunho / teste**: campo `active` — desligado = **não aparece para alunas**.
6. **RBAC na UI**: só Personal ou Admin com `canManageContent`; aluna vê bloqueio.
7. **Storage rules**: path `audio_courses/...` + Personal autorizado em áudios; rules **deployadas**.
8. **Demo Programa 7**: em release, lista vazia/timeout **não** injeta catálogo fictício (`kDebugMode` only).

## Teste com arquivo
| Cenário | Resultado |
|---|---|
| Upload Storage + doc Firestore `active:false` + HTTP GET do áudio | **PASSOU** (`PLAYBACK_HTTP 200`, 16840 bytes) |
| Cleanup imediato (curso/faixa/arquivo removidos) | **PASSOU** |
| Publicado para alunas? | **Não** (`active:false` + removido) |
| UI painel web logada (Amanda) | **NÃO TESTADO** — sem conta autorizada nesta sessão |
| Reprodução no player Flutter web/Android | **NÃO TESTADO** na UI — URL HTTP do Storage validada |

Arquivo de teste local (não é conteúdo do app): `tools/_test_audio_homolog_NOT_PUBLISH.mp3`  
Script: `tools/_homolog_audio_upload_test.js`

## Como a Amanda usa
1. Entrar como Personal/Admin → Central → **Áudios**.
2. **Novo curso** (pode desligar “Visível para alunas” para rascunho).
3. Abrir o curso → **adicionar áudio** (escolhe MP3/M4A/WAV…).
4. Setas para ordenar · ícone trocar para substituir · lixeira para remover faixa.
5. Olho para publicar/ocultar o curso das alunas.

## Limitações restantes
- **Programa 7 Dias** ainda não tem CMS de MP3 no app (YouTube / seed externo).
- E2E visual com login Amanda no web/Android pendente de contas de teste.
- Cobrança continua desligada; lojas não publicadas neste trabalho.
