# Relatório — Módulo de acompanhamento Personal ↔ alunas

Data: 2026-09-17  
Commit de backup (antes desta fatia): `83cbc21`  
`chore: backup do app antes do modulo de acompanhamento Personal-alunas`

Não houve publicação em produção. O canal de homologação existente permanece:
https://metodo1dia-app--homologacao-cw9j2u83.web.app

---

## O que foi reaproveitado

- Papéis `UserRole` + `pt_students` + `PtHubScreen` / dashboard / ficha da aluna
- Anamnese existente (`pt_anamnesis`) — campos novos em `questionnaire` (merge)
- Avaliações, fotos e medidas já em `pt_assessments` / `pt_photos` / evolução
- OpenAI via Cloud Function (mesmo padrão de `amandaChat`)
- Tema `AppCard` / `PremiumAppBar` / `AppPage` / Lily Fit
- Chat `/amanda` (IA da Amanda) **não foi removido**. O 1:1 humano é outra rota.

---

## Funcionalidades implementadas

### Aluna
- Home: atalhos **Fale com Amanda** e **Consultoria**
- Meu Treino: Fale com Amanda, Consultoria, Anamnese completa
- Chat 1:1 (texto, foto, resposta, estrela, excluir própria, horário/status)
- Agenda de consultoria (serviço, calendário, horários, confirmação, minhas consultas, cancelar)
- Anamnese com consentimento LGPD + questionário (saúde, dor 0–10, triagem cardiovascular)
- Assistente do Método (IA **não se passa pela Amanda**)

### Personal
- Inbox de mensagens (busca + filtros)
- Agenda da Personal (confirmar / concluir / cancelar / faltou)
- Disponibilidade (horários por dia da semana)
- Google Calendar: tela de conexão + Cloud Function OAuth real (não simulada)
- Configurações de IA (ligar/desligar cada recurso)
- Score de pendências 🟢🟡🔴 **sem diagnóstico**

---

## Arquivos criados

- `lib/features/accompaniment/domain/anamnesis_attention.dart`
- `lib/features/accompaniment/domain/appointment_overlap.dart`
- `lib/features/accompaniment/domain/accompaniment_models.dart`
- `lib/features/accompaniment/data/accompaniment_repository.dart`
- `lib/features/accompaniment/data/accompaniment_ai_repository.dart`
- `lib/features/accompaniment/providers/accompaniment_providers.dart`
- `lib/features/accompaniment/presentation/fale_com_amanda_screen.dart`
- `lib/features/accompaniment/presentation/chat_thread_screen.dart`
- `lib/features/accompaniment/presentation/trainer_inbox_screen.dart`
- `lib/features/accompaniment/presentation/consultoria_screens.dart`
- `lib/features/accompaniment/presentation/anamnesis_screens.dart`
- `lib/features/accompaniment/presentation/trainer_agenda_screens.dart`
- `lib/features/accompaniment/presentation/assistant_and_ai_screens.dart`
- `test/anamnesis_attention_test.dart`

## Arquivos alterados

- `lib/core/router/app_router.dart` — rotas e guarda de `/personal-trainer/*`
- `lib/core/constants/app_constants.dart` — URLs das functions
- `lib/core/config/app_config.dart` — tópicos de notificação
- `lib/features/home/presentation/home_screen.dart`
- `lib/features/personal_trainer/presentation/student_home_screen.dart`
- `lib/features/personal_trainer/presentation/personal_dashboard_screen.dart`
- `lib/features/personal_trainer/domain/pt_models.dart` — `questionnaire` na anamnese
- `lib/features/profile/presentation/notification_preferences_screen.dart`
- `firebase/firestore.rules`
- `firebase/storage.rules`
- `firebase/firestore.indexes.json`
- `functions/src/index.js` — `accompanimentAi` e `googleCalendar`

---

## Novas collections

| Collection | Uso |
|---|---|
| `pt_conversations` | Threads 1:1 |
| `pt_messages` | Mensagens |
| `pt_appointment_services` | Tipos de consultoria |
| `pt_availability` | Grade da Personal |
| `pt_appointments` | Consultas |
| `pt_trainer_notes` | Notas shared/private |
| `pt_consents` | Termo LGPD |
| `pt_ai_settings` | Flags da IA |
| `pt_ai_logs` | Histórico da IA |
| `pt_calendar_connections` | Status Google (sem token) |
| `pt_calendar_secrets` | Tokens OAuth — **somente Admin SDK** |

Reutilizadas: `pt_students`, `pt_anamnesis`, `pt_assessments`, `pt_photos`, `pt_sessions`.

Não é banco paralelo.

---

## Novas rotas

| Rota | Quem |
|---|---|
| `/fale-com-amanda` | Aluna |
| `/fale-com-amanda/chat/:id` | Aluna |
| `/consultoria` `/agendar` `/confirmar` `/minhas` | Aluna |
| `/minha-anamnese` `/formulario` | Aluna |
| `/assistente-metodo` | Aluna |
| `/personal-trainer/mensagens` | Personal |
| `/personal-trainer/agenda` | Personal |
| `/personal-trainer/disponibilidade` | Personal |
| `/personal-trainer/google-calendar` | Personal |
| `/personal-trainer/ia` | Personal |

---

## Cloud Functions / env

Novas HTTPS functions (deploy **não** feito nesta sessão):

- `accompanimentAi`
- `googleCalendar`

Variáveis (não commitar segredo):

```
OPENAI_API_KEY              (já usada pela Amanda)
GOOGLE_CALENDAR_CLIENT_ID
GOOGLE_CALENDAR_CLIENT_SECRET
GOOGLE_CALENDAR_REDIRECT_URI
```

Exemplo:

```
firebase functions:config:set googlecalendar.client_id="..." googlecalendar.client_secret="..." googlecalendar.redirect_uri="https://us-central1-metodo1dia-app.cloudfunctions.net/googleCalendar"
firebase deploy --only functions:accompanimentAi,functions:googleCalendar,firestore:rules,storage,firestore:indexes
```

OAuth Google: escopos `calendar.events`, `calendar.freebusy`, `calendar.readonly`.  
Eventos criados **não** levam anamnese/dados clínicos.  
Horário ocupado no Google aparece só como indisponível.

---

## Testes

- Unitários: `test/anamnesis_attention_test.dart` (pendência 🟢🟡🔴 + overlap de horário)
- Lint/build desta fatia: pendente de `flutter test` / `flutter analyze` no ambiente local (o shell da sessão é lento)

---

## Pendências (homologação)

1. Deploy das rules, indexes e functions (não publicar live automaticamente)
2. Configurar OAuth Google e testar conectar / busy / sync / desconectar
3. Anexar PDF/áudio nativo (`file_picker` / gravação) — foto já entra no chat
4. Abas extras da ficha (Documentos, Observações private/shared na UI da ficha) — modelo e rules prontos
5. Lembretes FCM 24h / 2h / horário — tópicos criados; agendamento push ainda usa a infra local existente
6. Comparar avaliações / rascunho de treino com botão “aprovar” na UI do builder (IA gera texto; publicação continua manual)
7. Gráficos da jornada “Minha Jornada” unificados com a Evolução já existente
8. Republicar canal `homologacao` depois do deploy das functions

## Riscos

- Indexes compostos precisam ser criados no Firebase antes do inbox/agenda em produção
- `pt_calendar_secrets` depende 100% das rules `allow read, write: if false`
- Sem `GOOGLE_CALENDAR_*` a agenda do app continua funcionando; o Google fica “Não conectado”
- Dois agendamentos simultâneos: o app recusa overlap local; transação server-side ainda pode ser reforçada na function `bookAppointment` numa próxima fatia
