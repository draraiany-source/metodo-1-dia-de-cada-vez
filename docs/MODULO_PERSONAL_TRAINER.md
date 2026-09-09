# Módulo Personal Trainer + Aluno (atualizado)

## O que já existia
Telas e CRUD em `lib/features/personal_trainer/`:
- Painel do Personal, detalhe do aluno, builder de treino, biblioteca,
  sessão, evolução, hub por papel (`isPersonalTrainer`).

Coleções Firestore: `pt_students`, `pt_exercises`, `pt_workout_plans`,
`pt_assessments`, `pt_photos`, `pt_loads`, `pt_sessions`.

## O que foi completado
1. Vínculo aluno ↔ Auth por e-mail (auto ao abrir Meu Treino) + UID manual.
2. Regras: aluno lê planos via `pt_students` (não Auth UID == studentId).
3. YouTube: prévia na biblioteca + assistir na sessão (`YoutubeLaunch`).
4. Biblioteca: editar exercício, equipamento, nível, séries/reps padrão.
5. Builder: nomes prontos (A/B/C/Superior…), duração, reordenar exercícios.
6. KPIs reais do painel (sessões de hoje, sem treinar 5d+, % com histórico).
7. Atalho Home **Meu Treino** → `/personal-trainer`.
8. Storage `pt_videos/` e `pt_photos/` + índices compostos.
9. `isPersonalTrainer` protegido em `noPrivilegedFields`.

## Fluxo
Personal cadastra aluno (e-mail da conta) → cria exercício com YouTube →
monta treino → aluno abre Meu Treino (vínculo automático) → assiste vídeo →
conclui séries/treino → Personal vê KPIs/sessões.

## Deploy Firebase (quando for publicar regras)
```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```
