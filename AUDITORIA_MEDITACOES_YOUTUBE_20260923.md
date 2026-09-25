# Auditoria Meditações — título × YouTube × ordem
**Data:** 23/09/2026  
**Escopo:** somente Meditações (`/meditations` + seed). Sem treinos. Sem deploy Firestore.

## Fontes

| Fonte | Resultado |
|---|---|
| Seed `assets/content/videos_biblioteca.json` | 7 itens `category=meditacao` |
| Firestore `videos` (`metodo1dia-app`) | **0** docs `meditacao`; só 3 Shorts `metodo1Dia` |
| Runtime | Meditações vêm **100% do seed** (`_mesclarSeedAusente`) |
| Sequência canônica | Programa 7 Dias / Áudio 1…7 (`tools/audio_seed/seed_data.json` + `kPrograma7YoutubeIds`) |

## ANTES (seed anterior × oEmbed YouTube)

| Pos. | Nome no app (antes) | Título no YouTube (oEmbed) | Link | Correção |
|---:|---|---|---|---|
| 1 (order 100) | Áudio 1 como vencer a procrastinação. | Áudio 1 como vencer a procrastinação. | https://www.youtube.com/shorts/UH5zs7CtPvs | Associação OK; título cru do YT |
| 2 (order 101) | Áudio 2 como criar disciplina. | Áudio 2 como criar disciplina. | https://www.youtube.com/shorts/lLpZMeMNbcU | Associação OK |
| 3 (order 102) | Áudio 3 como.vencer a preguiça. | Áudio 3 como.vencer a preguiça. | https://www.youtube.com/shorts/nZempKMRbe0 | Associação OK (typo do canal) |
| 4 (order 103) | Áudio 4 como manter a constância. | Áudio 4 como manter a constância. | https://www.youtube.com/shorts/36WIOOoo-3I | Associação OK |
| 5 (order 104) | Áudio 5 como voltar depois de errar | Áudio 5 como voltar depois de errar | https://www.youtube.com/shorts/JXnM5Kw5rtQ | Associação OK |
| 6 (order 105) | Áudio 6 Como criar hábitos saudável | Áudio 6 Como criar hábitos saudável | https://www.youtube.com/shorts/gTS3NisvXBg | Associação OK |
| 7 (order 106) | Áudio 7 como acreditar em você. | Áudio 7 como acreditar em você. | https://www.youtube.com/shorts/p1fnlTzTLyE | Associação OK |

**Conclusão antigos:** nenhum videoId estava trocado em relação ao título do YouTube.  
A confusão provável vinha de (a) nomes “Áudio N…” vs títulos limpos do Programa 7 Dias, (b) subtítulo do hub “Sono, respiração e ansiedade” (conteúdo errado), (c) `order` 100–106 em vez de 1–7.

## DEPOIS (ajuste de rótulo + ordem; mesmos IDs)

| Pos. | Nome no app (depois) | Título no YouTube | videoId | Correção feita |
|---:|---|---|---|---|
| 1 | 1. Como Vencer a Procrastinação | Áudio 1 como vencer a procrastinação. | UH5zs7CtPvs | Nome alinhado ao Programa 7; order=1 |
| 2 | 2. Como Criar Disciplina | Áudio 2 como criar disciplina. | lLpZMeMNbcU | Nome + order=2 |
| 3 | 3. Como Vencer a Preguiça | Áudio 3 como.vencer a preguiça. | nZempKMRbe0 | Nome + order=3 |
| 4 | 4. Como Manter a Constância | Áudio 4 como manter a constância. | 36WIOOoo-3I | Nome + order=4 |
| 5 | 5. Como Voltar Depois de Errar | Áudio 5 como voltar depois de errar | JXnM5Kw5rtQ | Nome + order=5 |
| 6 | 6. Como Criar Hábitos Saudáveis | Áudio 6 Como criar hábitos saudável | gTS3NisvXBg | Nome + order=6 |
| 7 | 7. Como Acreditar em Você | Áudio 7 como acreditar em você. | p1fnlTzTLyE | Nome + order=7 |

**Links não alterados.** Mesmos 7 Shorts.

## Arquivos alterados

- `assets/content/videos_biblioteca.json` — nomes + order 1–7
- `lib/features/audio_courses/presentation/meditations_screen.dart` — texto introdutório
- `lib/features/audio_programs/presentation/screens/audios_meditations_hub_screen.dart` — subtítulo do atalho
- `test/meditations_association_order_test.dart` — novo
- `tools/_meditations_firestore_dump.json` / `tools/_videos_firestore_all_dump.json` — evidência leitura

## Testes

| Teste | Status |
|---|---|
| oEmbed YouTube (7 IDs) | Verificado (títulos acima) |
| `flutter test test/meditations_association_order_test.dart` | **PASS** (1/1) — 23/09/2026 |
| `flutter test test/meditations_youtube_test.dart` | **PASS** (3/3) — 23/09/2026 |
| Comando conjunto (`association_order` + `youtube`) | **PASS** — `All tests passed!` (+4), exit 0 |
| Abrir cada item na UI web | **PENDENTE** (requer `flutter run` + login) |
| Abrir cada item no Android | **PENDENTE** (sem emulador/device nesta sessão) |

## Status final

**Associações nome↔vídeo:** sem troca de Shorts necessária (já corretas).  
**Rótulos + ordem de exibição:** corrigidos para sequência 1–7 do cadastro do programa.  
**UI E2E web/Android:** **não marcado como concluído** — pendente tocar os 7 itens no aparelho/navegador.

**Não é “CONCLUÍDO E2E”** até validação manual de abertura. Código/seed: **APTO para homologar** a lista.
