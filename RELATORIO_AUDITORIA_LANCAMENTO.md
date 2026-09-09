# Relatório de auditoria e consolidação — Método 1 Dia de Cada Vez

Data: 2026-09-09  
Escopo: Prioridade 1 (lançamento) + inventário P2/P3  
Princípio: reutilizar módulos existentes; não duplicar.

---

## 1. O que já existia

| Área | Status | Onde |
|------|--------|------|
| Papéis Admin / Personal / Aluno | Existe | `lib/core/auth/user_role.dart`, flags `isAdmin` / `isPersonalTrainer`, redirects em `app_router.dart` |
| Hub PT (Personal vs Aluno) | Existe | `pt_hub_screen.dart` |
| Dashboard Personal (KPIs) | Existe | `personal_dashboard_screen.dart` |
| Cadastro aluno + vínculo e-mail/UID | Existe | `pt_students`, `PtRepository` |
| Biblioteca de exercícios + YouTube/Storage | Existe | `exercise_library_screen.dart`, `pt_exercises` |
| Montagem de treinos (criar/editar/duplicar/arquivar) | Existe | `workout_builder_screen.dart`, `pt_workout_plans` |
| Meu Treino + sessão + cargas | Existe | `student_home_screen.dart`, `workout_session_screen.dart` |
| Avaliações físicas + IMC | Existe | `PhysicalAssessment`, aba Avaliações |
| Evolução com gráficos | Existe | `evolution_pt_screen.dart` |
| Sessões / histórico básico | Existe | `pt_sessions` |
| Quem Sou Eu + edição Firebase | Existe (turno anterior) | `personal_amanda/` |
| Receitas, áudios, corrida, água, IMC, gamificação | Existem módulos | `features/recipes`, `audio_*`, `running`, `hydration`, etc. |
| Admin in-app | Existe | `admin_screen.dart` |
| Cupons / desafios / Health Connect | Estrutura parcial / P3 | cupons admin; health sync stub |

---

## 2. O que foi corrigido / criado nesta rodada (P1)

### Criado
- **Anamnese completa** — `StudentAnamnesis` + `pt_anamnesis` + tela `student_anamnesis_screen.dart` (Personal e Aluno)
- **Feedback pós-treino** — dificuldade, dor, cansaço, observações em `WorkoutSessionLog`
- **Histórico com feedback** — aba Histórico no detalhe do aluno
- **Upload de fotos de evolução** — Storage `pt_photos/{studentId}/` + comparação primeira/atual
- **Campos extras do aluno** — telefone, idade, sexo, peso, altura, nível, observações + editar/arquivar
- **Calendário semanal** — Meu Treino (programado / concluído / descanso)
- **Central da Personal** — título + atalhos (biblioteca, receitas, áudios, perfil, fotos, Quem Sou Eu, config)
- **Intensidade** no exercício do treino (`WorkoutExerciseConfig.intensidade`)
- **Tipo de foto `outras`**
- **Regras Firestore** para `pt_anamnesis`
- **Storage** (turno anterior) — Personal pode gravar `public/amanda_assets`

### Reutilizado (não duplicado)
- Coleções `pt_*` (não migradas para nomes sugeridos `students/` etc. nesta fase)
- Telas Amanda, receitas, áudios, corrida, água, notificações existentes

---

## 3. O que ficou para depois

### Prioridade 1 ainda parcial / validar em device
- Notificações push reais (treino/água/nova ficha) — coleção existe; criação tipicamente backend
- Calendário mensal completo de treinos
- Substituição rápida de exercício com motivo
- Mensagens Personal↔Aluno (além de `amanda_messages` legado)
- Depoimentos / área dedicada de certificações com imagem
- Player/áudio 7 dias — auditoria de playback em aparelho real
- Corrida/GPS — validar permissões em Android real
- Política/termos/exclusão — conferir telas legais antes da loja

### Prioridade 2
- Metas do aluno unificadas; favoritos multi-módulo; mensagens; depoimentos; substituições

### Prioridade 3
- Planos/assinaturas com cobrança; cupons avançados; desafios; gamificação expandida; Apple Health / Health Connect

---

## 4. Telas adicionadas / reforçadas

| Tela | Rota / acesso |
|------|----------------|
| Quem Sou Eu | `/amanda/perfil` |
| Editar meu perfil | `/admin/amanda-profile` |
| Fotos da Amanda | `/admin/amanda-assets` |
| Central da Personal | `/personal-trainer` (staff) |
| Anamnese | push a partir do aluno / detalhe |
| Meu Treino + semana | `/personal-trainer` (aluno) |

---

## 5. Estrutura Firebase (canônica atual)

```
users/{uid}
pt_students/{id}
pt_exercises/{id}
pt_workout_plans/{id}
pt_assessments/{id}
pt_photos/{id}          + Storage pt_photos/{studentId}/
pt_loads/{id}
pt_sessions/{id}        (+ feedback fields)
pt_anamnesis/{studentId}
amanda_assets/{id}      + Storage public/amanda_assets/
amanda_profile/main
recipes/, notifications/, running_sessions/, …
```

**Não renomear** para `students/` / `workoutPlans/` sem migração — quebra produção.

### Deploy obrigatório
```bash
firebase deploy --only firestore:rules,storage
```

---

## 6. Testes realizados

- Análise estática do módulo PT / Amanda (via analyzer; infos de estilo, sem erros de compilação esperados)
- Fluxo lógico coberto no código: Personal cadastra → anamnese → avaliação → treino → aluno conclui com feedback → Personal vê histórico
- **Não executado nesta sessão:** emulador Android E2E completo, GPS real, push FCM, Play Console AAB

---

## 7. Problemas encontrados

1. Storage `/public/**` era só admin — corrigido path `amanda_assets` para Personal  
2. Textos do Quem Sou Eu estavam hardcoded — agora Firestore  
3. Fotos de evolução sem UI de upload — agora com picker  
4. Cadastro de aluno pobre demais para lançamento clínico — campos expandidos  
5. Falta de anamnese e feedback — fechados nesta rodada  

---

## 8. Situação para publicação

**Quase pronto para beta fechado** após:
1. `firebase deploy --only firestore:rules,storage`
2. Conta Personal com `isPersonalTrainer: true` (e Admin em `admins/{uid}` se necessário)
3. Smoke test no aparelho: login roles, treino, vídeo YouTube, áudio 7 dias, corrida GPS, Quem Sou Eu
4. Checklist loja: ícone, splash, nome, privacidade, termos, exclusão de conta

**Não gerar AAB** até o smoke test visual/funcional no device.

---

## 9. Arquivos principais alterados nesta consolidação

- `lib/features/personal_trainer/domain/pt_models.dart`
- `lib/features/personal_trainer/data/pt_repository.dart`
- `lib/features/personal_trainer/providers/pt_providers.dart`
- `lib/features/personal_trainer/presentation/student_*`
- `lib/features/personal_trainer/presentation/workout_session_screen.dart`
- `lib/features/personal_trainer/presentation/personal_dashboard_screen.dart`
- `lib/features/personal_amanda/**` (perfil dinâmico)
- `firebase/firestore.rules`
- `firebase/storage.rules`
