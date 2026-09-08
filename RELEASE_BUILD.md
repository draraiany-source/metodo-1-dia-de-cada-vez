# Release build (Android AAB)

Comandos exatos para gerar o App Bundle de produção. **Não cole chaves reais neste arquivo.**

## Pré-requisitos

1. `android/app/google-services.json` presente localmente (gitignored).
2. `android/key.properties` + keystore de upload (gitignored).
3. Produtos / entitlement `premium` configurados no RevenueCat + Play Console.
4. Firebase App Check (Play Integrity) e Crashlytics ativos no projeto Firebase.

## Análise

```bash
flutter pub get
flutter analyze --no-fatal-infos
```

## AAB de release (placeholders)

Substitua os valores `...` pelos reais **só no terminal** (não commitá-los):

```bash
flutter build appbundle --release \
  --dart-define=REVENUECAT_ANDROID_KEY=goog_REPLACE_ME \
  --dart-define=REVENUECAT_IOS_KEY=appl_REPLACE_ME \
  --dart-define=AMANDA_FUNCTION_URL=https://us-central1-SEU-PROJETO.cloudfunctions.net/amandaChat \
  --dart-define=CALORIE_VISION_FUNCTION_URL=https://us-central1-SEU-PROJETO.cloudfunctions.net/calorieVision \
  --dart-define=MAPS_API_KEY=AIza_REPLACE_ME
```

Saída típica:

`build/app/outputs/bundle/release/app-release.aab`

## APK de smoke-test (opcional)

```bash
flutter build apk --release \
  --dart-define=REVENUECAT_ANDROID_KEY=goog_REPLACE_ME \
  --dart-define=AMANDA_FUNCTION_URL=https://us-central1-SEU-PROJETO.cloudfunctions.net/amandaChat \
  --dart-define=CALORIE_VISION_FUNCTION_URL=https://us-central1-SEU-PROJETO.cloudfunctions.net/calorieVision \
  --dart-define=MAPS_API_KEY=AIza_REPLACE_ME
```

## iOS (ação manual — pasta `ios/` ausente)

Não rode `flutter create . --platforms=ios` sem backup: pode regenerar arquivos nativos.

Em um Mac, com cópia segura do projeto:

```bash
flutter create . --platforms=ios --org com.metodo1dia
# Depois: flutterfire configure (gera GoogleService-Info.plist)
# NÃO invente credentials iOS fake.
flutter build ipa --release \
  --dart-define=REVENUECAT_IOS_KEY=appl_REPLACE_ME \
  --dart-define=AMANDA_FUNCTION_URL=https://us-central1-SEU-PROJETO.cloudfunctions.net/amandaChat
```

## Checklist rápido Play Store

- [ ] `version` em `pubspec.yaml` incrementado
- [ ] Keystore de **upload** (não debug)
- [ ] `google-services.json` do app `com.metodo1dia.app`
- [ ] dart-defines de billing / functions / maps preenchidos no build
- [ ] Política de privacidade + Data safety no Play Console
- [ ] Conta de teste de licença / assinaturas internas
