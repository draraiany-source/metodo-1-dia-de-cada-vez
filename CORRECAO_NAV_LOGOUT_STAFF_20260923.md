# Correção — Navegação e Logout (Personal + Admin)
**Data:** 23/09/2026  
**Deploy/produção:** não realizado

## Causa raiz

1. `AppNavigation.back` fallback ia sempre para `Routes.home` (Aluna).
2. `PremiumAppBar` na raiz da Personal mostrava “home” e disparava esse fallback.
3. Raízes Admin/Personal sem `PopScope` — gesto Voltar do Android podia sair da área do perfil.
4. “Sair” existia em ícones, mas faltava reforço textual + CMS com AppBar sem Voltar explícito.

## Correções

| Arquivo | Mudança |
|---|---|
| `lib/core/router/app_navigation.dart` | `hubForPath` / `isRoleRootPath`; Voltar não cruza perfis |
| `lib/core/router/premium_app_bar.dart` | `isRoleRoot` oculta Voltar na raiz |
| `lib/core/auth/staff_sign_out_button.dart` | Botão visível “Sair da conta” |
| `lib/core/auth/session_sign_out.dart` | Invalida `currentUserProvider`; docs PopScope login |
| `lib/features/admin/presentation/admin_screen.dart` | `PopScope` + Sair visível |
| `lib/features/personal_trainer/presentation/personal_dashboard_screen.dart` | `PopScope` + Sair + sem Voltar na raiz |
| `lib/features/personal_cms/presentation/personal_cms_hub_screen.dart` | `PremiumAppBar` + Sair |
| `lib/features/personal_cms/presentation/treinos_cms_screen.dart` | `PremiumAppBar` (Voltar) |
| `lib/features/personal_cms/presentation/recipes_cms_screen.dart` | `PremiumAppBar` (Voltar) |
| `test/app_navigation_staff_back_test.dart` | Testes de hub/raiz |
| `PENDENCIAS_PROGRAMADOR.md` | **P0-00 BLOQUEADORA** até E2E |

## Compile fix (sessão 23/09)

- Restaurado import de `session_sign_out.dart` em `personal_dashboard_screen.dart` (uso de `signOutAndGoToLogin` em `_PersonalBody`).
- Parênteses/`PopScope` do layout wide da Personal alinhados.
- `StaffSignOutButton` fora de lista `const` no `AdminScreen` (acesso restrito).
- Removido import Riverpod não usado em `premium_app_bar.dart`.

## Testes

### Automatizados

| Teste | Resultado |
|---|---|
| `flutter test test/app_navigation_staff_back_test.dart` | **PASSOU** (4 testes) |
| `flutter test test/user_role_permissions_test.dart` | **PASSOU** (11 testes) |
| Conjunto (15 total) | **All tests passed!** EXIT=0 — 23/09/2026 |

### E2E Manual — Personal

| Caso | Web | Android |
|---|---|---|
| “Sair da conta” visível na Central | PENDENTE | PENDENTE |
| Telas internas têm Voltar → Central | PENDENTE | PENDENTE |
| Voltar Android na raiz não abre Aluna/Admin | PENDENTE | PENDENTE |
| Sair → login; Voltar não reabre Personal | PENDENTE | PENDENTE |

### E2E Manual — Admin

| Caso | Web | Android |
|---|---|---|
| “Sair da conta” visível no Painel | PENDENTE | PENDENTE |
| Telas internas (usuários, assinaturas…) Voltar → Admin | PENDENTE | PENDENTE |
| Voltar Android na raiz não abre Aluna/Personal | PENDENTE | PENDENTE |
| Sair → login; Voltar não reabre Admin | PENDENTE | PENDENTE |

**Motivo dos PENDENTE E2E:** requer contas reais Personal/Admin no Auth e device/emulador; não marcar como aprovado sem execução.

## Homologação

- Web (canal existente, sem novo deploy nesta tarefa): https://metodo1dia-app--homologacao-cw9j2u83.web.app  
  **HTTP HEAD:** `200` (checado 23/09/2026; canal **não** atualizado com esta correção).
  **Nota:** o canal web só reflete esta correção após `flutter build web` + deploy Hosting do canal `homologacao` (não feito aqui).
- APK release (23/09/2026):
  - Caminho: `build\app\outputs\flutter-apk\app-release.apk`
  - Tamanho: **155.8 MB**
  - Comando: `flutter build apk --release` + dart-defines SUPPORT_EMAIL / PRIVACY_POLICY_URL / TERMS_URL
  - `GRADLE_USER_HOME=C:\Users\Lenovo\.gradle` — assembleRelease ~5002 s — EXIT=0

## Status publicação

**BLOQUEADO** até E2E Personal + Admin (web e Android) PASSOU. Código corrigido ≠ liberado para loja.
