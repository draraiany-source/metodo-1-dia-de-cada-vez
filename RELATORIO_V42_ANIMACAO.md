# Relatório V42 — Mascote animada (micro-animação, nível 1)

> Ambiente sem SDK: validação por análise estática. As micro-animações são
> Flutter puro (sem dependência nova, sem Lottie/Rive), então rodam assim que
> o app compilar.

## Descoberta importante
O app **já tinha** um sistema de mascote animada — `AnimatedLiliMascot`
(`lib/core/widgets/lili_animated.dart`) com 6 moods: respirando, viva,
comemorando, correndo, calma, estática. Ele já era usado em **26 telas** e
renderiza `LiliMascot` por baixo — ou seja, **já anima a nova Lili** automaticamente.

Por isso NÃO criei um widget novo (seria duplicação, que você pediu para evitar).
Em vez disso, melhorei e ampliei o que já existe.

## O que foi feito
1. **Acessibilidade (melhoria real):** o `AnimatedLiliMascot` não respeitava o
   "reduzir movimento" do sistema. Agora, com `MediaQuery.disableAnimations`
   ativo, ele para o loop e mostra a Lili estática (poupa bateria; requisito de
   loja para acessibilidade). Beneficia as 30 telas de uma vez.
2. **Ampliação da cobertura (26 → 30 telas):** troquei a mascote ESTÁTICA por
   animada onde fazia sentido (heróis de tela, não avatares de card):
   - `app_states.dart` → **estados vazios (respirando) e de erro (calma)**.
     Como é o componente padrão de vazio/erro, a Lili passa a "respirar" nesses
     estados em TODAS as telas que os usam.
   - `rewards_history`, `missions_history` → herói de vazio respirando.
   - `daily_chest` → mascote "viva" (respira + pisca).
3. Mantido estático de propósito onde animar distrairia (avatares pequenos de
   card, tela de showcase/admin).

## Verificação
- ✅ Balanceamento OK nos 5 arquivos tocados.
- ✅ Sem import órfão (removido `LiliMascot` não usado em daily_chest; ajustado
   o `show`).
- ✅ Todos os arquivos que usam `AnimatedLiliMascot` importam `lili_animated`.
- ✅ Demonstração: `lili_breathing_demo.gif` (gerado da arte real, replicando o
   mood "respirando" do código).

## Níveis de animação — onde estamos e o que vem depois
- **Nível 1 (feito):** micro-animação sobre os PNGs — respiração, float, balanço,
   pulinho, entrada. Custo zero de arte. É o que dá "vida" premium sem peso.
- **Nível 2 (Lottie):** a Lili acenando/piscando/comemorando fluida. O app já
   tem suporte (`Lottie.network` no `LiliMascot`); falta um `.json` feito por
   animador. Quando tiver, o `LiliMascot` resolve o asset animado e tudo se
   aproveita — inclusive os moods atuais como fallback.
- **Nível 3 (Rive):** animação interativa por estados. Ganchos já preparados;
   falta adicionar o pacote `rive` + os `.riv`.
- **Nível 4 ("falando"):** vídeo/lip-sync — recomendado só pontualmente (ex.:
   boas-vindas), via `video_player`, com material gerado à parte.

## Arquivos desta versão
Editados: `lib/core/widgets/lili_animated.dart` (acessibilidade),
`lib/core/widgets/app_states.dart`, `lib/features/rewards/presentation/rewards_history_screen.dart`,
`lib/features/rewards/presentation/daily_chest_screen.dart`,
`lib/features/missions/presentation/missions_history_screen.dart`.
