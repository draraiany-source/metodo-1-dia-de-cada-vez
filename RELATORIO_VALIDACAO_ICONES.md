# Relatório — Validação final da integração visual

**Branch:** `consolidacao-recuperacao`  
**Data:** 2026-09-09

## 1. Inventário ZIP → assets

| Categoria | ZIP | Projeto | Missing |
|-----------|-----|---------|---------|
| navigation | 14 | 14 | 0 |
| health | 17 | 17 | 0 |
| actions | 12 | 12 | 0 |
| mood | 9 | 9 | 0 |
| achievements | 22 | 22 | 0 |
| premium | 2 | 2 | 0 |
| **Total** | **76** | **76** | **0** |

## 2. Uso

- **76** assets integrados no disco e declarados no `pubspec`
- Todos referenciados em `AppIcons` (`allCursor`)
- Uso direto nas telas: navegação/saúde/ações/humor/conquistas seed mapeadas
- Ainda pouco usados visualmente (prontos no catálogo): vários `ach*` extras (60/100 dias, 50/100 treinos, etc.), `moodWink/Surprised/Determined/Calm`, `subscription`, `hydrationGoal`, `stretching`

## 3. Substituições feitas nesta validação

- Check-in: chips sem emoji + AppIcons
- Diário: humor com `moodCheckin`
- Scanner IA: câmera/galeria/retry/add/delete/edit
- Nutrição: título/água/card IA
- Receitas: busca, favoritas, kcal/categoria, refresh
- Conquistas: badges por `AppIcons.forAchievementId`
- Home / Evolução / Medidas / Fotos: emojis e Material trocados onde havia match

## 4. O que permanece genérico (ok)

- Chrome Material: setas AppBar, schedule/dificuldade em chips de receita, cadeado de privacidade
- Emojis de **ligas** (🥉🥈🥇) — sem assets de tier no pacote
- Hábitos seed e alguns snacks secundários

## 5. Conclusão

App apto para instalar **APK de teste** e homologar visualmente.
AAB **não** gerado.
