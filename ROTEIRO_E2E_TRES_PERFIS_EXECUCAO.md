# ROTEIRO E2E — TRÊS PERFIS (execução homologação)
## Método 1 Dia de Cada Vez

**Data:** 22/09/2026  
**APK sugerido:** `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`  
**AAB loja:** `build/app/outputs/bundle/release/app-release.aab` (após build desta fase)  
**Cobrança:** `PAYMENTS_ENABLED=false`  
**Regra:** marcar PASSOU só com evidência. Sem as 3 contas = tudo PENDENTE.

---

## 0. Provisionar contas (Firebase Console — sem publicar app)

| Perfil | Como criar | Resultado esperado |
|---|---|---|
| **Aluna** | Cadastro no app OU Auth → Add user | Doc `users/{uid}` com `role` aluno; **sem** `isPersonalTrainer`; **sem** `admins/{uid}` |
| **Personal** | Auth user + Firestore `users/{uid}.isPersonalTrainer = true` | Login cai em `/personal-trainer`; **não** criar `admins/{uid}` |
| **Administradora** | Auth user + doc `admins/{uid}` (vazio ok) | Login cai em `/admin`; flag `users.isAdmin` sozinha **não** basta |

Anote e-mail/senha **fora do Git**.

---

## 1. ALUNA — passo a passo

| ID | Etapa | Procedimento | Resultado esperado | Resultado | Status |
|---|---|---|---|---|---|
| A01 | Instalar | Instalar APK arm64 | Abre splash | | [ ] |
| A02 | Cadastro/Login | Entrar como aluna | Home do aluno (`/`) | | [ ] |
| A03 | Saudação | Olhar header | Nome ok; sem “Olá, !” | | [ ] |
| A04 | Bloqueio admin | Digitar rota `/admin` (deep link se possível) | Redireciona para Home | | [ ] |
| A05 | Bloqueio painel PT gestão | Tentar sub-rota PT de gestão | Volta Home / login | | [ ] |
| A06 | Treino | Abrir catálogo → 1 exercício | Imagem/Lily OK | | [ ] |
| A07 | Timer | Iniciar/pausar | Sem freeze | | [ ] |
| A08 | Hidratação | Registrar água | Histórico atualiza | | [ ] |
| A09 | Vídeos | Abrir biblioteca → 1 Short → voltar | Play + voltar à lista | | [ ] |
| A10 | Meditações | Abrir 2 dos 7 Shorts | Conteúdo correto; voltar OK | | [ ] |
| A11 | Programa 7 Dias | Abrir 1 dia | YouTube (não MP3) | | [ ] |
| A12 | PDF/apostila | Se houver | Abre; zoom; voltar | | [ ] |
| A13 | Perfil | Abrir perfil/config | Sem crash | | [ ] |
| A14 | Logout | Sair | Tela login | | [ ] |
| A15 | Relogin | Entrar de novo | Home aluno | | [ ] |

## 2. PERSONAL — passo a passo

| ID | Etapa | Procedimento | Resultado esperado | Resultado | Status |
|---|---|---|---|---|---|
| P01 | Login limpo | Logout prévio → login Personal | Destino `/personal-trainer` | | [ ] |
| P02 | Painel | Abrir ferramentas | CMS/alunos/anamnese visíveis | | [ ] |
| P03 | Vídeos CMS | Listar/editar 1 vídeo (só URL se for o Shorts) | Salva; app aluno reflete | | [ ] |
| P04 | `/admin` raiz | Abrir admin raiz | Redireciona Central Personal (não painel técnico) | | [ ] |
| P05 | `/admin/videos` | Abrir | Permitido (whitelist) | | [ ] |
| P06 | `/admin/users` | Tentar | **Bloqueado** → home/personal | | [ ] |
| P07 | Logout | Sair | Login | | [ ] |

## 3. ADMINISTRADORA — passo a passo

| ID | Etapa | Procedimento | Resultado esperado | Resultado | Status |
|---|---|---|---|---|---|
| D01 | Login | Conta com `admins/{uid}` | Destino `/admin` | | [ ] |
| D02 | Usuários/papéis | Abrir gestão | Lista/ações admin | | [ ] |
| D03 | Conteúdo | Acessar ferramentas admin | OK | | [ ] |
| D04 | Logout | Sair no AppBar | Login | | [ ] |

## 4. TROCA DE PERFIS

| ID | Etapa | Procedimento | Resultado esperado | Resultado | Status |
|---|---|---|---|---|---|
| T01 | Sequência | Aluna → logout → Personal → logout → Admin → logout → Aluna | Sem sessão residual; home correta cada vez | | [ ] |
| T02 | Guest | Conferir | Guest **desligado** (`enableGuestMode=false`) | | [ ] |

## 5. REDE / VOLTAR

| ID | Etapa | Procedimento | Resultado esperado | Status |
|---|---|---|---|---|
| R01 | Sem internet | Abrir vídeo/PDF | Erro claro; sem crash | [ ] |
| R02 | Voltar Android | Após vídeo/PDF/treino | Volta; não prende | [ ] |

## 6. Critério de aceite E2E

- [ ] A01–A15 PASSOU com evidência  
- [ ] P01–P07 PASSOU  
- [ ] D01–D04 PASSOU  
- [ ] T01 PASSOU  

**Assinatura Amanda:** _____________ Data: ___/___/______  
**Assinatura técnica:** _____________ Data: ___/___/______
