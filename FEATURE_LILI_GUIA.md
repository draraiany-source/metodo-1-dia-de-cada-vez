# 💜 A Lili como guia do aplicativo

Nenhum módulo novo. Um `Provider` derivado + 3 widgets em `core/`.

## O cérebro: `liliGuideProvider`
Observa o estado **real** dos módulos (`gamification`, `missions`, `rewards`,
`health_sync`) e decide **expressão + humor + fala + ação**, por prioridade:

| # | Situação | Pose · Humor | Fala | CTA |
|---|---|---|---|---|
| 1 | **Sequência perdida** | `triste` · `calma` | "Você tinha 12 dias. A sequência parou — e tudo bem. 💜 Recomeçar também é constância." | Recomeçar hoje |
| 2 | Recompensa esperando | `celebrando` · `comemorando` | "Você tem 2 missões concluídas esperando resgate! 🎁" | Resgatar |
| 3 | Em chamas (streak ≥ 7) | `forte` · `correndo` | "9 dias seguidos! Você está pegando fogo. 🔥" | Ver sequência |
| 4 | Meta de passos batida | `joinha` · `comemorando` | "9412 passos hoje! Seu corpo agradece. 👟" | — |
| 5 | Pode comprar | `rainha` · `respirando` | "320 moedas! Dá uma olhada na Loja. 🪙" | Abrir Loja |
| 6 | Começando | `apontando` · `viva` | "Não precisa ser perfeita. Só precisa começar. 💜" | Fazer check-in |
| 7 | Neutro | `coracao` · `respirando` | frase motivacional do dia | Conversar |

Frases variam por dia (estáveis dentro do mesmo dia — sem "loteria" a cada rebuild).

## Reação à sequência perdida (era uma lacuna real)
O streak **zerava em silêncio**. Agora `GamificationState` expõe
`streakJustBroken` + `previousStreak`, detectados no boot. A Lili **acolhe**:
nunca culpa, e o sinal é limpo com `acknowledgeStreakBreak()` quando a usuária
age — ela não repete a má notícia.

## Falas sincronizadas: `LiliSpeechBubble`
- Texto revelado ~28 caracteres/segundo, com cursor `▌` enquanto "fala".
- **Tocar revela tudo** (respeita quem tem pressa).
- Respeita `MediaQuery.disableAnimations` (acessibilidade do sistema).
- Leitores de tela recebem a **frase inteira**, não a digitação (`Semantics`).
- Balão com "bico" apontando para a mascote (`CustomPainter`).

## Onde a Lili aparece como guia
| Tela | Papel |
|---|---|
| **Home** | Substituiu o card estático "Amanda diz" — agora é contextual |
| **Missões** | Substituiu o header fixo (removido como código morto) |
| **Loja** | Comenta o saldo acima do card de moedas |
| **IA Personal Trainer** | Já chega falando do contexto atual |

## Integração
Ela lê Missões, Loja, Gamificação e Health Sync — as mesmas fontes únicas de
verdade consolidadas no RC1. Zero duplicação de estado.

## Testes
`test/lili_guide_test.dart` — 8 testes travando a **ordem de prioridade**
(perda de sequência vence tudo, inclusive moedas), o acolhimento da fala,
a não-quebra do streak feito ontem, e a limpeza do sinal.

## Rive
Continua impossível gerar `.riv` por código. As expressões usam as 15 poses PNG
com `AnimatedLiliMascot` (respirar, piscar, comemorar, correr, calma) — funcionam
hoje. Quando exportar os `.riv`, o `RiveHelper` assume sem mudar nenhuma tela.
