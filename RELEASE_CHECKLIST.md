# 🚀 Checklist de Release — Método 1 Dia de Cada Vez

Passos na ordem exata para gerar APK/AAB/IPA e publicar. Tudo isto roda na
**sua máquina** (com Flutter SDK instalado) — não é possível executar no ambiente
onde o código foi montado.

---

## 0. Pré-requisitos (uma vez)
```bash
flutter --version          # precisa Flutter 3.19+ / Dart 3.3+
flutter doctor             # resolva o que aparecer em vermelho
```

## 1. Gerar as pastas nativas (OBRIGATÓRIO — elas não existem no zip)
```bash
cd metodo_1_dia
flutter create --org com.suaempresa .   # cria android/ ios/ web/ sem apagar lib/
flutter pub get
```

## 2. Rodar a análise e testes
```bash
flutter analyze          # corrija o que aparecer (me mande a saída se travar)
flutter test             # roda o smoke test em test/
```

## 3. Firebase (backend real)
```bash
dart pub global activate flutterfire_cli
flutterfire configure    # gera firebase_options.dart real + google-services.json + GoogleService-Info.plist
firebase deploy --only firestore:rules,firestore:indexes,storage,functions
firebase functions:config:set openai.key="SUA_CHAVE_OPENAI"   # Amanda IA
```
Depois, troque `SEU-PROJETO` em `lib/core/constants/app_constants.dart`
(`amandaFunctionUrl`).

## 4. Permissões nativas
- Android: cole `release_config/AndroidManifest_permissions.xml` em
  `android/app/src/main/AndroidManifest.xml`.
- iOS: cole `release_config/Info_plist_keys.xml` em `ios/Runner/Info.plist`.
- Maps: adicione a chave do Google Maps nos dois (ver comentários dos arquivos).

## 5. Ícone e Splash nativos
```bash
# converta assets/app_icon/app_icon.svg -> app_icon.png (1024) no Figma/Inkscape
flutter pub add dev:flutter_launcher_icons dev:flutter_native_splash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```
(config do launcher_icons já documentada em `DESIGN_PACK_README.md`)

## 6. Premium / compras (RevenueCat)
- Crie os produtos e o entitlement `premium` no RevenueCat + Play/App Store.
- `flutter pub add purchases_flutter`
- Em `lib/core/services/premium_service.dart`, troque o `premiumServiceProvider`
  para `RevenueCatPremiumService` (stub já pronto no arquivo).

## 7. Assinatura
- Android: crie keystore `.jks` + `android/key.properties` e aplique o snippet
  de `release_config/build_gradle_release_snippet.gradle`.
- iOS: certificados/perfis no Apple Developer + Xcode.

## 8. Build final
```bash
flutter build apk --release          # APK para teste
flutter build appbundle --release    # AAB para a Play Store
flutter build ipa --release          # IPA para a App Store (precisa de macOS + Xcode)
flutter build web --release          # opcional
```

## 9. Envio
- **Google Play**: suba o `.aab` no Play Console, preencha ficha, classificação,
  política de privacidade, e envie para revisão.
- **App Store**: via Xcode/Transporter, suba o `.ipa` ao App Store Connect.

---

### Versionamento
Está em `pubspec.yaml`: `version: 1.0.0+1` (nome+build). Incremente o `+build`
a cada envio.
