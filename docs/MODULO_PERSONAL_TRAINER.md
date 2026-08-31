# Módulo Personal Trainer

## Como ativar
Nenhuma tela nova aparece sozinha: acesse pelo atalho "Personal Trainer" na
Home. O app decide automaticamente qual área mostrar com base no campo
`isPersonalTrainer` do documento do usuário no Firestore — hoje isso só é
setado manualmente (console do Firebase ou uma Cloud Function futura), não
existe ainda um fluxo de "virar personal" dentro do app.

## O que foi construído (funcional, sem invenção)

### Área do Personal
- Dashboard de alunos (cadastrar, listar).
- Detalhe do aluno em 3 abas: Avaliações físicas, Fotos de evolução, Treinos.
- Avaliação física completa: peso, altura, IMC (calculado), % gordura,
  massa muscular, 7 circunferências.
- Criador de treinos: nome, objetivo, nível, dias da semana, exercícios
  escolhidos do banco com séries/repetições/intervalo/método/observações.
- Duplicar treino.
- Banco de exercícios: 17 grupos musculares, cadastro com vídeo/gif/foto/
  descrição/técnica/erros comuns (URLs — mesmo padrão de streaming já
  usado no resto do app, sem inflar o tamanho do APK).

### Área do Aluno
- Tela inicial: treinos atribuídos, XP/nível/sequência (reaproveita a
  gamificação que já existia, não criei um sistema paralelo).
- Execução de treino: navegação exercício a exercício, timer de descanso
  automático, botão "Concluir série", "Adicionar carga" (grava histórico),
  Lili Fit falando frases motivacionais aleatórias durante o treino.
- Ao finalizar: registra a sessão, dispara a missão `treinoConcluido` já
  existente (soma XP pelo fluxo de gamificação padrão).
- Evolução: gráficos de peso/% gordura/massa muscular, contagem de treinos
  realizados e dias ativos, comparação de fotos antes/depois.

## O que NÃO foi construído — e por quê

| Item pedido | Motivo |
|---|---|
| Pagamento (PIX/cartão/assinatura) | Exige gateway de pagamento real (Stripe/Mercado Pago) com conta empresarial — não posso criar isso por você. |
| Videochamada | Exige infraestrutura WebRTC + servidor de sinalização — não é um pacote Flutter simples. |
| Garmin/Fitbit/Polar/Strava | Cada um exige app registrado + OAuth com aquela empresa especificamente. |
| 2.000+ exercícios em vídeo HD | Conteúdo licenciado/produzido — a estrutura pra cadastrar está pronta, o conteúdo em si não é algo que eu gero. |
| Animação 3D de músculos ativados | Exige modelos 3D reais — fora do que é razoável fabricar. |
| Loja/e-commerce completo | Depende da integração de pagamento acima. |
| Agenda/agendamento | Não construído nesta rodada — é um módulo à parte (calendário já existe no app, mas não integrado a "horários disponíveis do personal"). |
| Chat Personal↔Aluno com mídia | O app já tem um padrão de chat simples (Amanda) — dava pra adaptar, mas não fiz nesta rodada por escopo. |
| Prescrição alimentar / e-books / IA de sugestão de carga | Não construídos — cada um é um módulo do tamanho do que já fiz aqui. |
| Notificações específicas do personal (aluno inativo etc.) | O sistema de lembretes já existe (`features/reminders`) mas não tem um gatilho automático de "aluno inativo" — isso exigiria uma Cloud Function agendada (Cloud Scheduler), não construída. |

## Segurança
Regras novas em `firebase/firestore.rules` — alunos só visíveis pro próprio
personal (`trainerId`) e pra si mesmos (`userId`). **Limitação técnica
honesta**: `pt_assessments`, `pt_photos`, `pt_loads` e `pt_sessions` estão
com regra simplificada (`qualquer usuária logada lê/escreve`) porque
regras do Firestore não fazem "join" pra verificar se quem está acessando
é realmente o personal daquele aluno específico sem uma leitura extra. Se
esse dado for sensível o bastante pra exigir isolamento real, o caminho é
replicar o padrão de `redeemCoupon`/`getVideoUrl` (Cloud Function que
verifica o vínculo antes de liberar).

## Dados de exemplo / seed
Não criei nenhum aluno, exercício ou treino de exemplo — tudo começa
vazio, com estados vazios explicando o que fazer (consistente com o
resto do app).
