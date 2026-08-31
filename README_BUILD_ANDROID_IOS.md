# Método 1 Dia de Cada Vez — Guia de Build (Android & iOS)

Este guia mostra como transformar o código em apps instaláveis. **As pastas
`android/` e `ios/` não vêm no ZIP** — elas são geradas pelo Flutter na sua
máquina (ou no CI). Isso é normal: o código, os assets e a lógica estão todos
em `lib/`, `assets/`, `firebase/` e `pubspec.yaml`, preservados.

## Pré-requisitos
- Flutter SDK 3.27+ (satisfaz `sdk: ">=3.3.0 <4.0.0"`)
- Android Studio + Android SDK (para Android)
- macOS + Xcode 15+ (para iOS — obrigatório, Apple exige macOS)

## Passo 0 — Gerar as pastas nativas (uma vez)
```bash
cd metodo_1_dia
flutter create .            # cria android/, ios/, web/ sem tocar em lib/, assets/, test/
flutter pub get
```
Depois, **aplique as configurações** de `release_config/`:
- Permissões Android → cole em `android/app/src/main/AndroidManifest.xml`
  (arquivo `AndroidManifest_permissions.xml`).
- Assinatura/pacote Android → aplique `build_gradle_release_snippet.gradle` em
  `android/app/build.gradle`.
- Chaves iOS → cole `Info_plist_keys.xml` em `ios/Runner/Info.plist`.
- Coloque `google-services.json` em `android/app/` e `GoogleService-Info.plist`
  em `ios/Runner/` (baixados do console do Firebase).

## Testar no Android
```bash
flutter devices                 # confirme um emulador ou aparelho conectado
flutter run                     # roda em debug no aparelho
```

## Gerar APK
```bash
flutter build apk --debug       # build/app/outputs/flutter-apk/app-debug.apk
flutter build apk --release     # build/app/outputs/flutter-apk/app-release.apk
```
Instalar no aparelho: `adb install build/app/outputs/flutter-apk/app-release.apk`

## Gerar AAB (Play Store)
```bash
flutter build appbundle --release
# build/app/outputs/bundle/release/app-release.aab
```

## Abrir no Xcode / rodar no iPhone
```bash
cd ios && pod install && cd ..
open ios/Runner.xcworkspace     # SEMPRE o .xcworkspace, nunca o .xcodeproj
```
No Xcode: selecione o time de desenvolvimento (Signing & Capabilities), escolha
seu iPhone e clique em Run. Para compilar sem assinatura pelo terminal:
```bash
flutter build ios --release --no-codesign
```

## Gerar IPA assinado (futuro — exige conta Apple Developer)
```bash
flutter build ipa --release     # precisa de certificado + provisioning profile
# build/ios/ipa/*.ipa  -> enviar via Transporter ou Xcode Organizer
```
Sem a conta Apple Developer paga, só é possível o `--no-codesign` (compila, não
publica).

## Assinatura de produção Android (keystore)
```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Crie `android/key.properties` (modelo no snippet do gradle) — não comite. Com
ele presente, `flutter build appbundle --release` já assina para produção.

## Build na nuvem (sem instalar nada)
Já existe `.github/workflows/build.yml`. Suba o projeto ao GitHub e rode o
workflow em **Actions → build**; baixe APK, AAB, Web e os logs `analyze.txt` /
`test.txt` como artefatos. Veja `.github/workflows/README.md`.

## Package name / Bundle ID
Sugestão de identificador definitivo: **`com.metodo1dia.app`** (usado nos
snippets). Confirme que o domínio é seu antes de publicar; se mudar, ajuste em
`android/app/build.gradle` e no target iOS do Xcode.
```
```
```
