# CORREÇÕES — Bloqueios de publicação (pós-auditoria)
**Data:** 23–24/09/2026  
**Referência:** `AUDITORIA_COMPLETA_HOMOLOGACAO_20260923.md`  
**Produção / cobrança real / publicação loja:** **não** realizados nesta etapa.

---

## 1. Arquivos alterados (navegação + Admin + iOS diagnóstico)

| Arquivo | Correção |
|---|---|
| `lib/core/router/premium_app_bar.dart` | Flag `showStaffSignOut` — Voltar + Sair compacto em filhas |
| `lib/features/admin/presentation/admin_screen.dart` | Removidos stubs (métricas fake, abas Receitas/Desafios stub, ações SnackBar); links reais CMS; Sair mantido na raiz + `PopScope` |
| `lib/features/admin/presentation/admin_users_roles_screen.dart` | `PremiumAppBar` + `showStaffSignOut` |
| `lib/features/subscriptions/presentation/admin_subscriptions_screen.dart` | idem |
| `lib/features/video_streaming/presentation/videos_admin_screen.dart` | idem |
| `lib/features/ebooks/presentation/ebooks_admin_screen.dart` | idem |
| `lib/features/audio_courses/presentation/audio_courses_admin_screen.dart` | idem |
| `lib/features/mascot_lili/presentation/lili_assets_admin_screen.dart` | idem |
| `lib/features/coupons/presentation/coupons_admin_screen.dart` | idem |
| `lib/features/personal_amanda/presentation/amanda_assets_admin_screen.dart` | idem |
| `lib/features/personal_amanda/presentation/amanda_profile_edit_screen.dart` | idem |
| `lib/features/personal_cms/presentation/recipes_cms_screen.dart` | idem |
| `lib/features/personal_cms/presentation/treinos_cms_screen.dart` | idem |
| `lib/features/personal_cms/presentation/personal_cms_hub_screen.dart` | Sair no branch negado |
| `lib/features/weekly_challenge/presentation/weekly_challenge_*.dart` (3) | idem |
| `lib/features/personal_trainer/presentation/exercise_library_screen.dart` | idem |
| `lib/features/personal_trainer/presentation/student_detail_screen.dart` | idem |
| `lib/features/personal_trainer/presentation/evolution_pt_screen.dart` | idem |
| `lib/features/personal_trainer/presentation/workout_builder_screen.dart` | idem |
| `lib/features/personal_trainer/presentation/student_anamnesis_screen.dart` | idem |
| `lib/features/nutrition/presentation/food_database_screen.dart` | Sair só se `isAdmin` |
| `lib/features/accompaniment/presentation/trainer_inbox_screen.dart` | idem |
| `lib/features/accompaniment/presentation/trainer_agenda_screens.dart` | 3 AppBars |
| `lib/firebase_options.dart` | Getter `iosFirebaseReady` (ainda `REPLACE_ME`) |
| `lib/core/config/app_config.dart` | Status “Firebase iOS” no painel |
| `test/premium_app_bar_staff_test.dart` | Widget tests Voltar/Sair |
| `docs/IOS_FIREBASE_SETUP_20260923.md` | Procedimento sem inventar chaves |

Raízes Admin/Personal já tinham `PopScope(canPop: false)` + `StaffSignOutButton` — mantidas.

---

## 2. Correções realizadas (resumo)

### Prioridade 1 — Navegação Admin/Personal
- Filhas staff: **Voltar** via `PremiumAppBar` + **Sair** (`showStaffSignOut`).
- Raízes: **Sair da conta** visível; sem Voltar de papel; Android back não cruza perfil (`PopScope`).
- Logout: `signOutAndGoToLogin` → login (`PopScope` no login impede reabrir protegidas).

### Admin stubs (ALT-01 / ALT-02)
- Removidas métricas hardcoded e CRUD fake.
- Abas reduzidas a **Dashboard + Treinos**.
- Links reais para Receitas/Desafios CMS.

### Cobrança
- **Não** ativado `PAYMENTS_ENABLED`.
- Fluxo documentado: UI + `BILLING_SANDBOX` opcional; produção continua off.
- Status no painel lista billing / sandbox / payments.

### iOS
- Sem inventar credenciais.
- `iosFirebaseReady` + doc de setup; publicação iOS **ainda bloqueada**.

---

## 3. Testes efetivamente executados

| Teste | Plataforma | Resultado |
|---|---|---|
| `premium_app_bar_staff_test.dart` (2) | VM | **PASS** |
| `app_navigation_staff_back_test.dart` (4) | VM | **PASS** |
| `user_role_permissions_test.dart` (11) | VM | **PASS** |
| E2E Admin login → Sair → Voltar | Web Chrome | **NÃO EXECUTADO** — sem contas teste Auth |
| E2E Personal (idem) | Web | **NÃO EXECUTADO** — sem contas |
| E2E Aluna fluxos | Web | **NÃO EXECUTADO** — sem contas |
| E2E 3 perfis | Android | **NÃO EXECUTADO** — **nenhum device/emulador Android conectado** (só Windows/Chrome/Edge) |
| Smoke `flutter run -d chrome` | Web | **INCOMPLETO** — ficou em “Waiting for connection from debug service”; processo interrompido. **Não** conta como E2E de login |

### Devices no momento do teste
- Windows, Chrome, Edge — **sem Android**.

---

## 4. Pendências restantes

| ID | Item | Bloqueia |
|---|---|---|
| P0-E2E | Contas teste 3 perfis + execução checklist web **e** Android | Homologação completa / publish |
| P0-iOS | `REPLACE_ME` + Mac + TestFlight | Publicação iOS |
| P1-RC | Chaves RevenueCat + sandbox autorizado (sem `PAYMENTS_ENABLED`) | Validar cobrança teste |
| P1-AAB | Commit working tree + AAB assinado Amanda | Play |
| P1-Listing | Data Safety / screenshots | Play/App Store |
| P2-Legais | Redirect `/privacidade` → `.html` | Qualidade |

---

## 5. Novo veredito (separado)

| Alvo | Veredito | Evidência |
|---|---|---|
| **Homologação web** | **APTO PARA INICIAR**, com ressalva | Código nav/stubs corrigido; canal homolog pode estar **defasado** até novo deploy; E2E 3 perfis **ainda pendente** de contas |
| **Homologação Android** | **APTO PARA INICIAR EM DEVICE**, com ressalva | Mesmas correções no código; **device não disponível nesta sessão**; APK local antigo pode estar defasado — rebuild recomendado |
| **Publicação iOS** | **BLOQUEADO** | Firebase iOS `REPLACE_ME`; sem plist; sem Mac Archive nesta etapa |
| **Publicação Play (produção)** | **BLOQUEADO** | E2E pendente + listing + AAB assinado + cobrança decisão Amanda |

**Não publicar. Não ativar cobrança real.**

---

## 6. Próximo passo sugerido
1. Amanda envia 3 contas teste (senhas só canal seguro).  
2. Rebuild APK + (opcional) redeploy canal homolog.  
3. Executar `CHECKLIST_E2E_TRES_PERFIS_ENTREGA_20260923.md`.  
4. Só então avaliar liberação de store.
