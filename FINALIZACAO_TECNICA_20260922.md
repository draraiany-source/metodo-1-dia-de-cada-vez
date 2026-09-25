# FINALIZAÇÃO TÉCNICA — 22/09/2026
## Evidências da execução (sem publicar)

### Comandos executados

```bat
set GRADLE_USER_HOME=C:\Users\Lenovo\.gradle
flutter build appbundle --release --split-debug-info=build/app/debug-info ^
  --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com ^
  --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html ^
  --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html

flutter test test/user_role_permissions_test.dart test/etapa8_seguranca_test.dart

curl/Invoke-WebRequest GET privacidade.html + termos.html
POST sem token → amandaChat / calorieVision / accompanimentAi
firebase functions:list --project metodo1dia-app
```

### AAB

| Campo | Valor |
|---|---|
| Caminho | `C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\build\app\outputs\bundle\release\app-release.aab` |
| Tamanho | **148,43 MB** (155 639 603 bytes) |
| Minify / shrink | `isMinifyEnabled=true` / `isShrinkResources=true` (já ativos) |
| R8 | `BUNDLE-METADATA/.../proguard.map` + `r8.json` presentes no AAB |
| MP3 no bundle | **0** |
| Produção alterada? | **Não** |

### Firebase (somente leitura)

| Superfície | Evidência |
|---|---|
| Hosting privacidade | HTTP 200 + e-mail suporte |
| Hosting termos | HTTP 200 + e-mail suporte |
| Functions | Deployadas (amandaChat, calorieVision, accompanimentAi, …) |
| Functions sem auth | HTTP **401** (auth exigida) |
| Firestore rules | Catch-all `allow read, write: if false` |
| Storage rules | Catch-all deny no arquivo; `/public` leitura aberta controlada |
| Auth | Estrutura no app; E2E contas = Amanda |
| iOS REPLACE_ME | **Mantido** — sem `GoogleService-Info.plist` / sem appId iOS real no repo (não inventado) |

### RBAC

- Testes: `user_role_permissions_test` + `etapa8_seguranca_test` → **All tests passed** (15)
- Router: Aluna → home; Personal → `/personal-trainer`; Admin → `/admin`; aluno bloqueado em `/admin*`

### Docs gerados nesta fase

- `ROTEIRO_E2E_TRES_PERFIS_EXECUCAO.md`
- `LISTA_AMANDA_MANUAL_APP.md`
- `LISTA_DEPENDENCIAS_PLAY_APPLE_MAC.md`
- Comentário atualizado em `lib/firebase_options.dart`

### Status

**APTO PARA HOMOLOGAÇÃO** (Android / AAB + APK)

Ainda **não** apto para publicar nas lojas: E2E 3 perfis no aparelho, listing Play/Apple, iOS credentials reais, autorização de cobrança.
