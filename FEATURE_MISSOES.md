# 🎯 Módulo: Missões Diárias, Semanais e Mensais

Módulo novo. Nenhuma funcionalidade existente foi alterada — apenas adições.

## Telas
- **`/missions`** — Missões, com abas ☀️ Diárias · 📅 Semanais · 🗓️ Mensais
- **`/missions/history`** — Histórico de missões concluídas + totais (missões, XP, moedas)

## Renovação automática
Comparando "chaves de período" salvas localmente:
- **Diárias** zeram a cada novo dia
- **Semanais** zeram a cada nova semana (segunda-feira)
- **Mensais** zeram a cada novo mês

## Recompensas
Ao resgatar uma missão concluída:
- **XP** creditado no `gamificationProvider` (sistema existente)
- **Moedas** creditadas no `rewardsProvider` → usáveis na **Loja de Recompensas**
- **Animação de conclusão**: Lottie de confete + mascote comemorando

## Barra de progresso animada
`TweenAnimationBuilder` + `LinearProgressIndicator` (700ms, easeOutCubic).
Cor muda conforme o estado: em progresso (roxo) → pronta (rosa) → resgatada (verde).

## Integrações (sistema de eventos)
As telas existentes só disparam um evento; o módulo cuida do resto.

| Evento | Onde é reportado | Missões afetadas |
|---|---|---|
| `treinoConcluido` | `workout_detail_screen` | Diária, Semanal, Mensal |
| `checkinFeito` | `habits_screen` | Diária |
| `streakDia` | `habits_screen` | Semanal, Mensal |
| `copoDeAgua` | `nutrition_screen` (progresso absoluto) | Diária |
| `refeicaoRegistrada` | `nutrition_screen` (botão "Registrar refeição") | Diária |
| `pesoRegistrado` | `evolution_screen` (FAB "Registrar peso") | Semanal |
| `corridaConcluida` | `running_screen` | Semanal |
| `desafioConcluido` | *API pronta* — ligar quando existir ação de concluir desafio | Mensal |

## Arquitetura
- `lib/features/missions/providers/missions_providers.dart`
  - `MissionPeriod`, `MissionEvent`, `MissionDef`, `MissionProgress`, `MissionRecord`
  - `MissionsCatalog` (11 missões), `MissionsState`, `MissionsNotifier`
  - API: `report(event)`, `setProgress(event, valor)`, `claim(def)`, `claimableCount`
  - `missionsProvider`, `claimableMissionsProvider`
- `lib/features/missions/presentation/missions_screen.dart`
- `lib/features/missions/presentation/missions_history_screen.dart`

## Persistência e Firebase
- **Local**: SharedPreferences (progresso, histórico, chaves de período).
- **Firebase**: `MissionsNotifier.syncToCloud()` é o ponto de extensão —
  hoje no-op; sincronize em `users/{uid}/missions` quando o Firestore estiver ativo.

## Navegação
- Atalho **🎯 Missões** no grid da Home.
- **Banner de resgate** na Home, exibido só quando há missão concluída pendente.

## Observação honesta
Duas telas (`nutrition_screen`, `running_screen`) eram `StatefulWidget` puro e
foram convertidas para `ConsumerStatefulWidget` — mudança apenas da classe base,
necessária para acessar o provider. Nenhuma lógica existente foi tocada.
