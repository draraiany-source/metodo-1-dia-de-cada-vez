# 🤖 Módulo: IA Personal Trainer

Módulo novo (`lib/features/ai_trainer/`). Nenhuma funcionalidade existente foi
alterada — o módulo Amanda antigo (`/amanda`) continua intacto e acessível.

## Telas
- **`/ai-trainer`** — chat completo com a Amanda IA (histórico, ações rápidas,
  indicador "está pensando...", avatar contextual da mascote).
- **`/ai-trainer/profile`** — perfil físico que alimenta a personalização.

## O que a IA faz (de verdade, mesmo sem chave de API)

O `TrainerEngine` é um motor de prescrição com regras reais — não frases soltas.

| Capacidade | Como funciona |
|---|---|
| **Monta treinos personalizados** | Divisão por dias disponíveis (full body → ABC), volume por nível (2/3/4 séries), reps e descanso por objetivo |
| **Adapta por idade, peso, sexo, objetivo, nível** | `TrainerProfile` + fórmulas (IMC, TMB Mifflin-St Jeor) |
| **Considera limitações físicas** | Tabela de substituição: joelho, lombar, ombro, punho, gestante, hipertensão. Ex.: *Agachamento → Elevação de quadril* |
| **Sugestões de alimentação** | Calcula kcal alvo (TMB × 1.375 ± objetivo) e proteína (1.6 g/kg) |
| **Mensagens motivacionais** | Contextual — usa o streak real do usuário |
| **Acompanha evolução** | Lê nível, streak e histórico de peso |
| **Detecta platô** | Variação < 0,5 kg em 3 semanas → alerta + 4 ajustes concretos |
| **Recomenda descanso** | ≥6 treinos/semana ou streak ≥14 → sugere recuperação ativa |
| **Dúvidas sobre exercícios** | Princípios de técnica, respiração e amplitude adaptados ao nível |
| **Dúvidas sobre alimentação** | Responde sem demonizar alimentos, com regra do prato |
| **Quantidade de água** | 35 ml/kg + ajuste por nível → litros e copos |
| **Metas semanais** | Geradas a partir do perfil |

## Integrações com módulos existentes
`trainerContextProvider` lê em tempo real:
- **Streak** → `currentUserProvider`
- **Missões** → `claimableMissionsProvider` + progresso de treinos da semana
- **Conquistas/Nível/XP** → `gamificationProvider`
- **Loja de Recompensas** → `rewardsProvider` (saldo de moedas)

A IA usa isso nas respostas. Ex.: *"Você tem 2 missões prontas para resgatar!"*
ou *"Você já tem 8 dias de sequência — isso é prova de que você consegue."*

## OpenAI (quando houver chave)
Arquitetura segura: o app **nunca** guarda a chave.
1. `firebase functions:config:set openai.key="SUA_CHAVE"`
2. Ajuste `AppConstants.amandaFunctionUrl` (troque `SEU-PROJETO`)
3. `firebase deploy --only functions`

A Cloud Function `amandaChat` foi **estendida** (retrocompatível) para receber
`profile` e `context` e injetá-los no prompt, respeitando limitações físicas e
detectando platô.

**Fallback automático**: sem chave, ou se a rede falhar, cai no motor local —
o app nunca quebra. O cabeçalho do chat mostra "IA online" ou "Modo inteligente local".

## Persistência
- Perfil físico e histórico de conversa em SharedPreferences (últimas 200 msgs).
- `syncToCloud()` é o ponto de extensão para o Firestore.

## Navegação
- Atalho **🤖 IA Personal** no grid da Home.
- O botão "Conversar" do card da Amanda na Home agora abre a nova IA.
