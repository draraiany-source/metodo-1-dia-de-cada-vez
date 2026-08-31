# Módulos 19, 20 e Check-in diário

## ✅ Implementado e funcional

### Módulo 19 — Calendário (`features/calendar`)
- Visualização mensal/semanal (`table_calendar`), eventos marcados por dia.
- Categorias: treino, corrida, alimentação, hidratação, pesagem, medições,
  desafio, curso, vídeo, receita, consulta, medicamento/suplemento, meta, outro.
- Criar evento com título, categoria, horário opcional e repetição
  (nenhuma/diária/semanal/mensal).
- Marcar concluído por dia (mesmo em eventos recorrentes — cada ocorrência
  tem sua própria conclusão).
- Excluir evento (swipe) — desabilitado em recorrentes pra evitar apagar a
  série sem querer; dá pra evoluir depois com opção "excluir só esta
  ocorrência" vs. "excluir a série".
- Estatística simples de % concluído nos últimos 30 dias.
- Persistência local (`SharedPreferences`).

### Módulo 20 — Lembretes (`features/reminders`)
- As 15 categorias pedidas no prompt.
- Horário configurável por lembrete, várias por categoria (ex.: 2 remédios
  diferentes), ativar/desativar sem apagar, observação customizada.
- Notificações **locais agendadas de verdade** via `flutter_local_notifications`
  + `timezone` (novo `LocalRemindersService`), repetindo todo dia no horário
  configurado — funciona mesmo sem internet.
- Estrutura pronta para push via FCM (`NotificationsService` já existente) —
  não mexi nela, os dois sistemas coexistem.

### Check-in diário (`features/checkin`)
- Sono, humor, energia, água, peso (opcional), treinou/correu/alimentação/meta,
  observações.
- Pontuação 0-100 calculada na hora.
- Alimenta a missão `MissionEvent.checkinFeito` já existente (gamificação).
- Histórico completo persistido — pronto pra ser plugado no Calendário/Evolução
  depois, se quiser.

### Home
Adicionei 3 atalhos novos (Calendário, Lembretes, Check-in) ao grid existente
— só acrescentei itens, não toquei nos que já estavam lá.

## ⏳ O que fica pra depois (fora do escopo desta rodada)

- **Cursos em áudio** e **Receitas em PDF**: exigem uma biblioteca de
  conteúdo real (arquivos de áudio/PDF hospedados, provavelmente Firebase
  Storage + um player). Preciso saber de onde viria esse conteúdo antes de
  desenhar a arquitetura, pra não construir em cima de suposição errada.
- **Google Calendar / Apple Calendar**: mencionado no prompt como integração
  futura — não implementei, é um projeto à parte (OAuth, sync bidirecional).
- Quando você rodar `flutter create .`, o Android precisa do ícone padrão de
  notificação (`@mipmap/ic_launcher`, já vem por padrão) — nenhuma ação extra
  necessária além do que já está documentado para o scanner de calorias.

## Dependências novas no `pubspec.yaml`
- `table_calendar: ^3.1.2` (UI do calendário)
- `timezone: ^0.9.4` (agendamento de notificações locais)
- `just_audio: ^0.9.40` (player dos cursos em áudio)
- `pdfx: ^2.6.0` (visualizador de PDF nativo, sem chave de licença)

Nenhuma exige chave de API — funcionam offline.

---

## Cursos em áudio (`features/audio_courses`) e Receitas em PDF (`features/pdf_recipes`)

Como você vai fornecer o conteúdo, montei os dois módulos pra consumir do
**Firestore** — é a peça que faltava pra eles funcionarem de verdade, sem
inventar dado nenhum. Enquanto as coleções estiverem vazias, a tela mostra
um estado vazio explicando isso (não é erro, nem placeholder fake).

### Como cadastrar o conteúdo
Direto no console do Firestore (ou por um script/admin que a gente monta
depois), crie:

```
audio_courses/{courseId}
  title: string
  teacher: string
  category: string  (um de: mentalidade, habitos, alimentacao, emagrecimento,
                      sono, ansiedade, motivacao, autoestima, organizacao, meditacao)
  coverUrl: string   (link público da capa, ex.: Firebase Storage)

audio_courses/{courseId}/chapters/{chapterId}
  title: string
  audioUrl: string   (link público do áudio, ex.: Firebase Storage)
  durationSeconds: number
  order: number      (ordem de exibição, 0, 1, 2...)

pdf_recipes/{recipeId}
  title: string
  category: string   (um de: cafeDaManha, almoco, jantar, lanches, sobremesasFit,
                      lowCarb, hipertrofia, emagrecimento, vegetarianas, veganas, airFryer)
  coverUrl: string
  pdfUrl: string      (link público do PDF)
  minutes: number
  difficulty: string  (facil | medio | dificil)
  kcal, protein, carbs, fat: number
```

Os links (`coverUrl`, `audioUrl`, `pdfUrl`) podem apontar pra qualquer lugar
público — Firebase Storage, um CDN seu, etc. Não precisam ser do Storage
necessariamente.

### O que já funciona
- **Áudio**: player com velocidade 0.5x–2x, favoritos, "continuar de onde
  parou" (por curso), avanço automático pro próximo capítulo, tocando em
  segundo plano enquanto navega no app.
- **PDF**: grade por categoria, favoritos, visualizador nativo com zoom,
  macros da receita no topo, botão "abrir externamente" como plano B se o
  PDF não carregar.

### Limitação conhecida
No player de áudio, a retomada de "onde parou" depende do histórico local
já ter carregado quando a tela abre — em telas muito rápidas isso pode, raramente,
começar do zero em vez de retomar. Não afeta o resto do app; se incomodar,
dá pra endurecer isso depois com um provider de loading dedicado.
