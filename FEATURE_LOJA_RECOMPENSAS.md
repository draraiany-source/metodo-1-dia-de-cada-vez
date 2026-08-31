# 🪙 Feature: Loja de Recompensas

Feature nova adicionada sem alterar o que já existia.

## O que faz
- **Moedas** ganhas ao concluir ações reais:
  - Treino: +20 · Check-in de hábitos: +15 · Meta concluída: +50
  - (constantes prontas também para corrida +25 e desafio +40)
- **Loja** (`/rewards`) com 6 categorias em abas: Avatares, Temas, Badges
  especiais, Frases motivacionais, Desafios extras, Itens premium.
- **Saldo** do usuário visível no topo da Loja e no cabeçalho da Home (chip 🪙).
- **Resgate**: debita moedas, marca item como "Resgatado", anima a mascote.
- **Histórico** (`/rewards/history`) de tudo que foi resgatado.
- **Persistência local** (SharedPreferences) — saldo, itens e histórico
  sobrevivem a reinícios.

## Arquitetura
- `lib/features/rewards/providers/rewards_providers.dart`
  - `RewardCategory`, `RewardItem`, `RedeemRecord`, `RewardsCatalog`
  - `RewardsState` + `RewardsNotifier` (`earn`, `redeem`, `owns`, `reset`)
  - `rewardsProvider` (StateNotifierProvider)
- `lib/features/rewards/presentation/rewards_store_screen.dart` — loja com abas
- `lib/features/rewards/presentation/rewards_history_screen.dart` — histórico
- Rotas: `Routes.rewards` e `Routes.rewardsHistory`
- Atalho na Home (grid) + chip de saldo no cabeçalho

## Firebase (fallback local mantido)
O `RewardsNotifier.syncToCloud()` é o ponto de extensão: quando o Firestore
estiver ativo, sincronize `coins`, `owned` e `history` em `users/{uid}`.
Hoje é no-op — o app funciona 100% em modo local.

## Não foi alterado
Nenhuma lógica existente foi modificada — só adições:
- `+ earn(...)` ao lado dos `addXp(...)` já existentes (treino, hábitos)
- `+` recompensa ao concluir meta
- `+` imports e navegação
