# Módulo de Nutrição — Completo

## Antes de tudo: o que eu NÃO dupliquei
Existia um motor de cálculo (`TrainerProfile` em
`ai_trainer/domain/trainer_engine.dart`) com idade/peso/altura/sexo/
objetivo/IMC/TMB(Mifflin)/água. Em vez de criar um "NutritionProfile"
paralelo, **estendi essa mesma classe** — é por isso que a calculadora de
IMC/água que já existia na tela de Nutrição continua funcionando
exatamente igual, e agora o mesmo perfil alimenta tudo (treino + nutrição).

## Cálculos automáticos (novos, na tela "Meu perfil físico")
IMC, TMB por Mifflin-St Jeor E Harris-Benedict (escolha qual usar), TDEE,
déficit/superávit calórico por objetivo, meta calórica diária, metas de
proteína/carboidrato/gordura/fibra, peso ideal estimado, água (já
existia). Tudo em `TrainerProfile` — getters computados, nada hardcoded.

## Perfil nutricional (campos novos, aditivos)
Peso inicial, peso desejado, % de gordura, massa muscular, nível de
atividade física (5 níveis, usado no TDEE), tipo de dieta (8 opções),
restrições alimentares/alergias/preferências (tags livres). Sexo, idade,
altura, peso atual e objetivo já existiam.

## Diário alimentar completo
Agora agrupado por refeição — café da manhã, lanche da manhã, almoço,
lanche da tarde, jantar, ceia, lanches extras — auto-detectado pelo
horário do registro. A tela de Nutrição mostra consumido/meta com barra de
progresso (calorias) e macros restantes, puxando direto do perfil.

## Banco de alimentos (novo módulo)
~30 alimentos comuns da dieta brasileira com calorias/proteína/carbo/
gordura/fibra/medida caseira, busca por nome, filtro por 14 categorias,
admin pode cadastrar mais. Honestidade sobre escala: não são "milhares" —
é uma base real e funcional, não uma base licenciada tipo TACO/USDA (isso
é conteúdo, não código). Já conectado ao registro manual do diário —
buscar um alimento preenche calorias e macros automaticamente.

## Lista de compras (novo módulo)
Adicionar itens por categoria, marcar como comprado, limpar comprados.
Manual (não gerada automaticamente a partir de um plano alimentar — isso
exigiria receitas com ingredientes estruturados, que as receitas em PDF
não têm hoje).

## O que NÃO construí nesta rodada — e por quê

| Item pedido | Status |
|---|---|
| IA de foto de refeição | Já existe (Cloud Function calorieVision, com macros) |
| IA responde dúvidas nutricionais | Já existe via Amanda/AI Trainer — não criei uma segunda IA |
| Scanner de código de barras / OCR de rótulo | Não construído — exige pacotes novos (mobile_scanner, ML Kit), escopo à parte |
| Plano alimentar (nutricionista monta pra aluno) | Não construído — seria uma cópia estrutural do criador de treinos do Personal Trainer |
| Cardápios automáticos (7/15/30/90 dias) | Não construído — geração algorítmica é um projeto à parte |
| Desafios 21/30/75/100 dias | O sistema de desafios/missões já existe; não criei templates específicos de nutrição |
| Sync wearables além do existente | Apple Health/Google Fit já existem; Garmin/Fitbit/Polar/Strava exigem conta própria em cada empresa |
| Relatórios em PDF de nutrição | O módulo de Relatórios genérico já existe e já inclui alimentação |

## Onde encontrar
Home -> "Banco de alimentos" e "Lista de compras". Perfil físico:
Perfil -> IA Personal -> "Meu perfil físico" (mesma tela de sempre, agora
com a seção "Perfil nutricional"). Admin -> "Banco de alimentos".
