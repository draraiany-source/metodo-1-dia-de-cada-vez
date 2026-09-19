# Roteiro E2E — Aluno / Personal / Admin Técnico

Projeto Firebase: `metodo1dia-app`  
App: Método 1 Dia de Cada Vez (`com.metodo1dia.app`)  
Cobrança: **desligada** (`PAYMENTS_ENABLED=false`)  
Não use contas reais de alunas. Não commite senhas.

## 1. Provisionar as 3 contas (Firebase Console)

Authentication → Users → Add user (e-mail/senha).  
Anote e-mail e senha **fora do Git**.

| Perfil | Depois do cadastro |
|---|---|
| Aluno | Nada. Cadastro pelo app também serve (sempre nasce aluno). |
| Personal | Em Firestore `users/{uid}`: `isPersonalTrainer: true`. **Não** criar `admins/{uid}`. |
| Admin Técnico | Criar `admins/{uid}` (doc vazio serve). Só isso eleva a admin. Flag `users.isAdmin` sozinha **não** eleva. |

Sem esses UIDs o E2E **não pode ser marcado PASSOU**.

## 2. Aluno

1. Cadastro (checkbox legal) **ou** login.  
2. Home: saudação sem “Olá, !”.  
3. Treino → cronômetro → concluir → histórico.  
4. Hidratação: registrar copo.  
5. Vídeo (um Short) → play → voltar.  
6. Áudio → play/pause.  
7. Desafio: marcar **hoje**; dia futuro bloqueado.  
8. Evolução: uma medida.  
9. Tentar `/admin` (URL) → deve ir para Home.  
10. Logout.

## 3. Personal (outra conta, sem reutilizar sessão)

1. Login → destino `/personal-trainer`.  
2. Painel: aluno, anamnese, conteúdo, vídeos, Quem sou eu, agenda.  
3. Tentar `/admin` (raiz) → deve ir para Central da Personal.  
4. `/admin/videos` pode abrir (CMS).  
5. Apostilas: consultar; **não** publicar (só Admin grava).  
6. Logout.

## 4. Admin Técnico

1. Login → `/admin`.  
2. Usuários / papéis visíveis.  
3. Logout no AppBar.

## 5. Troca de contas

Sair → login Aluno → sair → Personal → sair → Admin.  
Não pode sobrar sessão, guest nem “Olá, !”.

## 6. Resultado

Marque PASSOU só com evidência no aparelho. Sem as 3 contas = **PENDENTE**.
