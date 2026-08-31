# Correções do `flutter analyze` — rodada 1

Baseado no relatório REAL do analyzer que você enviou. Todas as correções foram
aplicadas no código-fonte deste ZIP.

## ✅ ERROS DE COMPILAÇÃO (7) — corrigidos

| # | Arquivo | Correção aplicada |
|---|---|---|
| 1 | `core/services/local_reminders_service.dart` | `DarwinFlutterLocalNotificationsPlugin` → **`IOSFlutterLocalNotificationsPlugin`** (permissões iOS preservadas: alert/badge/sound) |
| 2 | `core/services/local_reminders_service.dart` | Adicionado **`uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime`** no `zonedSchedule`; mantidos `androidScheduleMode` e `matchDateTimeComponents` |
| 3 | `core/theme/app_theme.dart` | `cardTheme: CardTheme(` → **`CardThemeData(`** (cor, elevação e borda preservadas — identidade visual intacta) |
| 4 | `features/nutrition/presentation/calorie_scanner_screen.dart` | Adicionado `import '../domain/nutrition_models.dart';` (enum `FoodEntrySource` reaproveitado — **nenhum enum duplicado criado**) |
| 5 | `features/video_streaming/presentation/video_player_screen.dart` | `await _chewieController?.dispose();` → **`_chewieController?.dispose();`** (dispose do Chewie é `void`); `await _videoController?.dispose()` mantido |
| 6 | `test/widget_test.dart` | **AÇÃO SUA:** esse arquivo foi criado pelo `flutter create` na sua máquina e **não existe neste ZIP**. Apague-o: `del test\widget_test.dart` (Windows). Os 4 testes próprios do projeto seguem intactos |
| 7 | (contabilizado nos itens acima) | — |

## ✅ WARNINGS — imports não utilizados removidos (4)
- `core/router/app_router.dart` → `auth_providers.dart`
- `features/amanda/presentation/amanda_screen.dart` → `app_constants.dart`
- `features/coupons/data/coupons_repository.dart` → `app_config.dart`
- `features/personal_trainer/presentation/personal_dashboard_screen.dart` → `app_theme.dart`

> Verifiquei um a um que o símbolo não era usado antes de remover. Em
> `coupons_repository` o import de **`app_constants` foi mantido** (é usado por
> `redeemCouponFunctionUrl`) — só o `app_config` saiu.

## ✅ SEGURANÇA ASSÍNCRONA (`use_build_context_synchronously`)
- `login_screen.dart`: `_login()` agora faz `if (!mounted) return;` +
  `context.mounted` antes do `context.go`; snackbar de erro protegida por
  `mounted && context.mounted`; "Esqueci a senha" com `if (!context.mounted) return;`.
- `running_screen.dart`: no salvar corrida, trocado por `if (!context.mounted) return;`
  **antes** de `Navigator.pop` e de `_reset()`. ⚠️ Isso corrigiu um bug real: o
  `_reset()` (que chama `setState`) rodava **fora** da proteção e podia crashar
  se a tela fosse fechada durante o `await`.

## ✅ LINTS
- `core/utils/date_format.dart`: `_2` → **`_pad2`** (lowerCamelCase), com os
  usos atualizados.
- `models/domain_models.dart`: adicionado **`library;`** após o comentário de
  topo (dangling library doc comment).

> Sobre `const`/`final→const`/`child` por último: são infos não bloqueantes e
> variam conforme a linha exata que o seu analyzer apontou. Se sobrarem depois
> desta rodada, me mande a lista e eu aplico uma a uma — prefiro corrigir com o
> apontamento exato do que adivinhar linha e arriscar erro novo.

---

# STATUS REAL — sem exagero

| # | Item | Status |
|---|---|---|
| 1 | **Compila** | ⏳ **A VERIFICAR** — rode `flutter analyze` de novo. Corrigi os 7 erros reportados; podem surgir outros que só aparecem depois destes |
| 2 | **Testes passam** | ⏳ não executado aqui (sem SDK) |
| 3 | **APK gerado** | ⏳ não gerado aqui (sem SDK/Android SDK) |
| 4 | **Firebase configurado** | ❌ pendente (`REPLACE_ME` em `firebase_options.dart`) — app roda em modo demonstração |
| 5 | **Pagamentos configurados** | ❌ pendente (`LocalPremiumService` é mock; falta RevenueCat + lojas) |
| 6 | **Pronto para publicação** | ❌ **NÃO** — depende de 1–5 + assinatura + fichas das lojas |

## Próximo passo (na sua máquina)
```
del test\widget_test.dart
flutter clean
flutter pub get
dart format lib test
flutter analyze
```
➡️ Cole aqui o resultado. Se sobrar erro, corrijo na rodada 2. Quando aparecer
**"No issues found!"**, seguimos para `flutter test` → `flutter build apk --debug`.

## Sobre `flutter create .` ter sobrescrito configurações
Verifique (o `create` pode ter gerado arquivos nativos padrão):
- `android/app/src/main/AndroidManifest.xml` → aplicar as permissões de
  `release_config/AndroidManifest_permissions.xml`
- `ios/Runner/Info.plist` → aplicar `release_config/Info_plist_keys.xml`
- `android/app/build.gradle` → aplicar `release_config/build_gradle_release_snippet.gradle`
  (applicationId/namespace `com.metodo1dia.app` + assinatura)
- Colocar `google-services.json` em `android/app/` e `GoogleService-Info.plist`
  em `ios/Runner/` quando configurar o Firebase.
