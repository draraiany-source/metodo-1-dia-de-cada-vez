# Relatório — Seção 15 (obrigatório) após execução

**App:** Método 1 Dia de Cada Vez  
**Data:** 19/09/2026  
**Backup:** tag `backup-sec15-obrigatorio-20260919` (`23b1c0a`)  
**Produção de loja:** não publicada. Cobrança: **não ativada**. Secrets: **não expostos**.

---

## O que foi feito (prioridade pedida)

| # | Tarefa | Resultado |
|---|---|---|
| 1 | Atualizar e publicar Hosting legal | **PASSOU** |
| 2 | Deploy `amandaChat`, `calorieVision`, `accompanimentAi` com auth; POST sem token = 401 | **PASSOU** |
| 3 | OpenAI só no servidor (código + cliente sem chave) | **PASSOU** (presença da chave no servidor = **PENDENTE**) |
| 4 | Contas + roteiro E2E 3 perfis | Roteiro **PASSOU**; contas reais **PENDENTE** |
| 5 | QA das tarefas desta etapa | Hosting + 401 + testes legais **PASSOU**. E2E aparelho **PENDENTE** |
| 6 | Preparar Android AAB com `PAYMENTS_ENABLED=false` | **PASSOU** (pronto para *gerar* AAB; não enviar à Play) |

### Evidências

**Hosting** (`firebase deploy --only hosting --project metodo1dia-app`):

- `https://metodo1dia-app.web.app/privacidade.html` — 200, 1 `<html`, 1 `</html>`, suporte oficial, **sem** e-mail pessoal  
- `https://metodo1dia-app.web.app/termos.html` — 200, começa com `<!DOCTYPE html>`, **sem** e-mail pessoal  

**Functions** (us-central1, Node 22):

- `amandaChat` atualizada  
- `calorieVision` atualizada  
- `accompanimentAi` **criada** (antes 404)  
- POST sem token → **HTTP 401** nas três  
- POST com Bearer inválido → **HTTP 401** nas três  

**OpenAI:** nenhum `OPENAI_API_KEY` / `sk-` em `lib/`. A Function lê só `functions.config().openai.key` ou `process.env.OPENAI_API_KEY`. Não consultei o config remoto para não imprimir secret. Sem login autenticado, não dá para provar se a chave **já está** no servidor (503 vs resposta real).

**E2E:** roteiro em `release_config/ROTEIRO_E2E_TRES_PERFIS.md`. Sem e-mail/senha/UID desta sessão — contas **não provisionadas**.

**Android AAB (preparação):**

- `PAYMENTS_ENABLED` default `false`  
- `assets/app_icon/app_icon.png` 1024 existe  
- `android/key.properties` existe **local** (gitignored)  
- URLs legais no ar válidas  

```bat
flutter build appbundle --release --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html
```

Não usar `PAYMENTS_ENABLED=true`. Não enviar à Play neste passo.

`test/etapa7_legal_test.dart`: 3 passaram.

---

## Android está pronto para gerar AAB?

**SIM — gerar AAB técnico local.**  
**NÃO — enviar à Google Play** (faltam E2E dos 3 perfis, Data Safety, listing, confirmação da chave OpenAI se a IA for vitrine).

---

## Tabela da página 9 (atualizada)

Critério: PASSOU só com evidência desta rodada ou já comprovada no código/teste.

| ITEM | STATUS | SEVERIDADE | BLOQUEIA PUBLICAÇÃO? | AÇÃO NECESSÁRIA |
|---|---|---|---|---|
| Aluno E2E | PENDENTE | BLOQUEADOR | Sim | Executar roteiro com conta Aluno |
| Personal E2E | PENDENTE | BLOQUEADOR | Sim | Idem Personal |
| Admin E2E | PENDENTE | BLOQUEADOR | Sim | Idem + `admins/{uid}` |
| RBAC código/rules | PASSOU | — | Não | Manter |
| Logout / troca | PENDENTE | BLOQUEADOR | Sim | 3 trocas no aparelho |
| Treinos | PENDENTE | IMPORTANTE | Sim p/ loja | QA aparelho |
| Cronômetro | PENDENTE | IMPORTANTE | Sim p/ loja | QA aparelho |
| Hidratação | PENDENTE | IMPORTANTE | Sim p/ loja | QA aparelho |
| Receitas | PENDENTE | IMPORTANTE | Sim p/ loja | QA aparelho |
| Desafio | PENDENTE | IMPORTANTE | Sim p/ loja | QA aparelho |
| Evolução | PENDENTE | IMPORTANTE | Sim p/ loja | QA aparelho |
| Vídeos | PENDENTE | IMPORTANTE | Sim p/ loja | Play no aparelho |
| Áudios | PENDENTE | IMPORTANTE | Sim p/ loja | Play no aparelho |
| Fotos Storage | PENDENTE | IMPORTANTE | Não isolado | Upload |
| Quem Sou Eu | PENDENTE | IMPORTANTE | Não isolado | Salvar CMS |
| Anamnese | PENDENTE | BLOQUEADOR* | Se for vitrine | Fluxo com conta |
| Agenda | PENDENTE | IMPORTANTE | Não isolado | Horário |
| Mensagens | PENDENTE | IMPORTANTE | Não isolado | Chat |
| IA aluno | PENDENTE | BLOQUEADOR | Se for vitrine | Auth 401 OK; falta OpenAI+E2E |
| Foto/calorias | PENDENTE | BLOQUEADOR | Se for vitrine | Auth 401 OK; falta OpenAI+foto |
| Painel Personal | PENDENTE | BLOQUEADOR | Sim | Login Personal |
| Painel Admin | PENDENTE | BLOQUEADOR | Sim | Login Admin |
| Firebase Auth | PASSOU código | — | Não | E2E senha |
| Firestore Rules | PASSOU | — | Não | Não abrir |
| Storage Rules | PASSOU | — | Não | — |
| Functions nuvem | PASSOU | — | Não (auth) | 401 confirmado nas 3 |
| App Check | PENDENTE | IMPORTANTE | Não imediato | Monitor → enforce |
| Secrets no git | PASSOU | — | Não | Manter |
| RevenueCat sandbox | FALHOU | IMPORTANTE | Não se IAP off | Testers (fora desta etapa) |
| Privacidade local | PASSOU | — | Não | Teste etapa 7 |
| Privacidade/Termos no ar | PASSOU | — | Não | Hosting 19/09/2026 |
| Exclusão conta | PASSOU código | IMPORTANTE | Não | Teste descartável |
| Data Safety / App Privacy | PENDENTE | BLOQUEADOR | Sim p/ loja | Jurídico + Console |
| Android / Play | PENDENTE | BLOQUEADOR | Sim p/ *loja* | AAB pode ser gerado; listing falta |
| iOS / TestFlight | FALHOU | BLOQUEADOR | Sim | Fora desta etapa (Mac) |
| Guest/debug | PASSOU (off) | — | Não | Manter off |

\*Anamnese continua bloqueador só se o acompanhamento for vitrine.

---

## Seção 15.1 — o que ainda falta (obrigatório original)

1. Hosting legal — **concluído**  
2. Functions + 401 — **concluído**  
3. OpenAI no servidor — código OK; **confirmar chave no Firebase** (sem commitar)  
4. 3 contas + E2E — **roteiro pronto; falta executar**  
5. iOS Firebase/IPA — **não feito** (Windows; fora da prioridade 1–6 desta ordem)  
6. Screenshots / Data Safety — **não feito** (fora da ordem 1–6, ainda bloqueia *loja*)  
7. Conta revisor lojas — **não feito**  
8. `PAYMENTS_ENABLED=false` — **mantido**  
9. Commit/push do release — **não feito** (working tree sujo; tag de backup sim)

Arquivos novos desta etapa: `release_config/ROTEIRO_E2E_TRES_PERFIS.md`, este relatório.
