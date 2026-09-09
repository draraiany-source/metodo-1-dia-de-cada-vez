# Relatório — papéis e segurança (3 níveis)

Data: 2026-09-09  
App: Método 1 Dia de Cada Vez

## Estrutura de roles (reutilizada + alinhada)

| Produto | Código (`UserRole`) | Persistência |
|---------|---------------------|--------------|
| Admin Técnico | `admin` → `technical_admin` | Coleção **`admins/{uid}`** (fonte de verdade) + `users.isAdmin` / `users.role` |
| Personal / Admin profissional | `personal` → `trainer` | `users.isPersonalTrainer == true` + `users.role` |
| Aluno | `aluno` → `student` | Sem flags privilegiadas |

**Não** há e-mail fixo no código. Bootstrap do primeiro Admin Técnico: criar doc `admins/{SEU_UID}` no Console Firebase.

## Arquivos modificados / criados

- `lib/core/auth/user_role.dart` — aliases, permissões, whitelist `/admin/*` da Personal
- `lib/features/auth/data/auth_repository.dart` — `isAdmin` só se existir `admins/{uid}`
- `lib/models/app_user.dart` — `copyWith` com `isPersonalTrainer`
- `lib/features/admin/data/roles_admin_repository.dart` — listar usuários + alterar papéis
- `lib/features/admin/presentation/admin_users_roles_screen.dart` — UI Usuários e papéis
- `lib/features/admin/presentation/admin_screen.dart` — Painel Técnico + atalhos
- `lib/core/router/app_router.dart` — redirects e whitelist Personal
- `lib/features/splash/presentation/splash_screen.dart` — Admin → Painel Técnico
- `lib/features/profile/presentation/profile_screen.dart` — labels / Central
- `firebase/firestore.rules`
- `firebase/storage.rules`
- `test/user_role_permissions_test.dart`
- este relatório

## Firestore (resumo)

- `isAdmin()` = membership em `admins/{uid}`
- `isPersonalTrainer()` = flag em `users`
- `admins/{uid}`: Admin Técnico cria/atualiza; **não pode excluir a si mesmo**
- `pt_*`: aluno só próprios dados; Personal só seus alunos; Admin vê tudo
- `recipes` / metadados de áudio: Admin ou Personal; **`/private/**` só Admin Técnico**
- `notifications`: Admin ou Personal (create com `userId`)
- Campos privilegiados (`isAdmin`, `isPersonalTrainer`, xp…) protegidos por `noPrivilegedFields` (exceto update por Admin)

## Storage (resumo)

- **`pt_photos/{studentId}`**: leitura/escrita só Admin, trainer dono ou aluno vinculado (corrigido: antes qualquer logado lia)
- `public/amanda_assets`: leitura pública; escrita Admin/Personal
- `public/**` geral: escrita só Admin Técnico
- `pt_videos`: escrita Admin/Personal
- `users/{userId}`: dono ou Admin

## Telas protegidas

| Papel | Entrada |
|-------|---------|
| Admin Técnico | `/admin` Painel Técnico, `/admin/users`, Central, conteúdos |
| Personal | `/personal-trainer` + whitelist `/admin/amanda-*`, ebooks, áudios, vídeos |
| Aluno | Home / Meu Treino; bloqueio de `/admin` e painel técnico |

## Testes

### Automatizados
- `test/user_role_permissions_test.dart` — resolução de papéis, permissões UX, whitelist

### Manuais (Firebase + app) — checklist

1. **Bootstrap:** Console → `admins/{uidAdmin}`  
2. Login Admin Técnico → Painel Técnico → Usuários e papéis  
3. Promover conta Amanda a Personal (`trainer`)  
4. Login Personal → Central OK; `/admin` (raiz) e `/admin/users` → redireciona para Central  
5. Login Aluno A → Meu Treino próprio; tentativa de ler `pt_students` de Aluno B → **denied**  
6. Aluno → `/admin` → Home  
7. Storage: Aluno B não lê `pt_photos/{studentA}/…`

### Usuários de teste
Definidos pela operação real (UIDs no projeto Firebase `metodo1dia-app`). Não versionar senhas.

## Falhas encontradas e correções

| Problema | Correção |
|----------|----------|
| UI confiava em `users.isAdmin` sem `admins/{uid}` | Auth valida membership canônica |
| Personal bloqueada em `/admin/amanda-*` | Whitelist profissional |
| Storage `pt_photos` legível por qualquer signed-in | Acesso só vinculados |
| Admin Técnico e Personal iam ambos à Central no login | Admin → Painel Técnico |
| `admins` write: false impedia gestão de papéis no app | Create/update por Admin; delete ≠ self |

## Deploy obrigatório

```bash
firebase deploy --only firestore:rules,storage
```

## Situação

Estrutura de 3 níveis alinhada ao sistema já existente, com rules reforçadas e Painel Técnico de papéis. Pronto para validação com contas reais após o deploy das rules.
