# Relatório — Login, logout e troca de perfis

Backup anterior às alterações: commit `627a3eb`  
(`chore: backup antes de corrigir login, logout e troca de perfis`)

Regras do Firestore: **não alteradas**.  
Guest / debug / bypass: **permanecem desligados**.

---

## Arquivos alterados

| Arquivo | Tipo |
|---|---|
| `lib/core/auth/session_sign_out.dart` | novo |
| `lib/core/auth/user_role.dart` | alterado |
| `lib/core/router/app_router.dart` | alterado |
| `lib/features/auth/presentation/login_screen.dart` | alterado |
| `lib/features/auth/presentation/register_screen.dart` | alterado |
| `lib/features/splash/presentation/splash_screen.dart` | alterado |
| `lib/features/profile/presentation/profile_screen.dart` | alterado |
| `lib/features/profile/presentation/settings_screen.dart` | alterado |
| `lib/features/personal_trainer/presentation/personal_dashboard_screen.dart` | alterado |
| `lib/features/personal_trainer/presentation/pt_hub_screen.dart` | alterado |
| `lib/features/personal_cms/presentation/personal_cms_hub_screen.dart` | alterado |
| `lib/features/admin/presentation/admin_screen.dart` | alterado |
| `test/user_role_permissions_test.dart` | alterado |

`lib/features/auth/data/auth_repository.dart` já validava `admins/{uid}` e **não precisou mudar**.

---

## Problemas encontrados e correção

### 1. Logout incompleto e sessão presa
**Problema:** cada tela fazia `signOut` de um jeito; o GoRouter só escutava o stream do Auth e não a sessão local / visitante. Trocar de conta exigia limpar o navegador.  
**Correção:** `signOutAndGoToLogin` único: `FirebaseAuth.signOut()`, limpa `localSession`, sai do guest, invalida `authStateProvider`, `context.go(/login)`. O router agora dá `ping()` quando sessão local ou guest muda.

### 2. Botão voltar voltava para tela autenticada
**Problema:** após logout, o histórico do celular/navegador ainda apontava para Home / Central / Admin.  
**Correção:** `context.go` (não empilha), `PopScope(canPop: false)` no login, e o `redirect` manda qualquer rota autenticada para `/login` se não houver sessão.

### 3. Roteamento pós-login por flag isolada
**Problema:** login/register/splash usavam `isAdmin` / `isPersonalTrainer` soltos; login caía em `/home` e o redirect depois “empurrava” staff.  
**Correção:** `homePathForRole` / `homePathForUser` passam por `resolveUserRole`: aluno → `/home`, personal → `/personal-trainer`, admin → `/admin` (admin vence). Hub da Personal e atalhos do Perfil também usam o papel resolvido.

### 4. Admin Técnico só pela flag `users.isAdmin`
**Problema (já tratado no repositório):** flag órfã no doc `users` podia elevar o cliente.  
**Correção mantida:** `_loadProfile` só eleva se `admins/{uid}` existir; se a flag existir sem o doc, o app rebaixa. Sem leitura em `admins` = não é técnico.

### 5. “Amanda Lopes” como se fosse a Personal logada
**Problema:** o cabeçalho da Central tratava a marca institucional como o nome da conta.  
**Correção:** saudação e rail usam `trainer.name` da sessão; a linha institucional ficou explícita: “Marca institucional: Método 1 Dia · Amanda Lopes”. Conteúdos da dona do método (home, vídeos, Quem Sou Eu) continuam institucionais.

### 6. Logout invisível na Personal / Admin
**Problema:** Personal e Admin não tinham “Sair da conta” evidente.  
**Correção:**
- Aluno: Perfil + Configurações  
- Personal: AppBar, rail, chip “Sair”, botão “Sair da conta” no header, CMS  
- Admin: AppBar do painel e da tela de acesso bloqueado  

---

## Segurança (sem enfraquecer RBAC)

- `firestore.rules` não foi editado (catch-all deny permanece).
- Sem guest, debug, bypass ou autenticação temporária (`enableGuestMode = false`, `debugUnlockAllPremiumContent = false`).
- Aluno não altera `role` / `isAdmin` / `isPersonalTrainer` pelo cliente (já bloqueado nas rules + cadastro público sempre `student`).
- Personal não vira Admin pelo cliente (só `admins/{uid}` + Cloud Function de admin).
- Router: aluno em `/admin` → `/home`; Personal em `/admin` (exceto whitelist profissional) → `/personal-trainer`.

---

## Resultados dos testes

### Automatizados

| Teste | Resultado |
|---|---|
| `resolveUserRole` (admin > personal > aluno) | PASSOU |
| `firestoreValue` (`student` / `trainer` / `technical_admin`) | PASSOU |
| `RolePermissions` — só Admin abre painel técnico | PASSOU |
| `RolePermissions` — aluno não abre Central | PASSOU |
| Personal não acessa `/admin` nem `/admin/users` / `/admin/coupons` | PASSOU |
| `homePathForRole` aluno `/home` | PASSOU |
| `homePathForRole` personal `/personal-trainer` | PASSOU |
| `homePathForRole` admin `/admin` (vence personal) | PASSOU |
| `test/user_role_permissions_test.dart` (11 testes) | **All tests passed** |

Suite completa `flutter test` continua com falhas antigas **não relacionadas** (nutrição, catálogo 117 vs 116, placeholder visual). Não foram tocadas.

### Manuais (código / rota — sem contas de teste provisionadas)

| Perfil | Caso | Resultado |
|---|---|---|
| Aluno | login → `/home` | OK no código (`homePathForUser`) |
| Aluno | home, treinos, hidratação, alimentação/IA, vídeos, áudios, perfil | rotas de aluno inalteradas |
| Aluno | não acessa Central | hub usa `canOpenPersonalCentral`; atalhos só para personal/admin |
| Aluno | não acessa `/admin` | redirect → `/home` |
| Aluno | logout | botão no Perfil e Configurações → login |
| Personal | login → Central | OK no código (`/personal-trainer` + dashboard) |
| Personal | alunos, anamnese, agenda, conteúdo whitelist | rotas existentes; `/admin` raiz bloqueado |
| Personal | não acessa usuários/cupons admin | `isPersonalAllowedAdminPath` falso |
| Personal | logout | AppBar, rail, chip, header, CMS |
| Admin | login → `/admin` | OK no código + exige `admins/{uid}` |
| Admin | usuários, conteúdos, configurações | atalhos do painel inalterados |
| Admin | logout | AppBar do painel e da tela bloqueada |

Login/logout/troca **no dispositivo ou no navegador** com as 3 contas reais: **PENDENTE** (UIDs das contas de teste nunca foram criados neste ambiente; sem senhas e sem Admin SDK no repo).

---

## Pendências

1. Executar o checklist nas 3 contas reais (Aluno / Personal / Admin Técnico com doc em `admins/{uid}`) para confirmar troca sem limpar o navegador.
2. Bootstrap do primeiro Admin Técnico continua só pelo Console / Admin SDK — o app não promove ninguém.
3. `/personal-trainer` para aluno abre a área de acompanhamento do aluno (`StudentHomeScreen`), não a Central. A Central só aparece se `resolveUserRole` for personal ou admin.
4. “Amanda Lopes” institucional permanece em home, vídeos, áudios e Quem Sou Eu — conteúdo da dona do método, não da conta logada.
