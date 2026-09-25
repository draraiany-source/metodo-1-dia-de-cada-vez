# Publicação Android e iOS — Método 1 Dia de Cada Vez

## Resumo

App fitness feminino premium (aluno, Personal, admin). Flutter + Firebase + RevenueCat.

**Não é produção nas lojas ainda.** Homologação web: `https://metodo1dia-app--homologacao-cw9j2u83.web.app`

## Stack (validado no repositório)

| Item | Valor |
|---|---|
| Framework | Flutter (`>=3.19.0`), Dart SDK `>=3.3.0 <4.0.0` |
| Estado / rotas | Riverpod 2.x, go_router 14 |
| Backend | Firebase project `metodo1dia-app` (Auth, Firestore, Storage, Functions, FCM, Analytics, Crashlytics, App Check) |
| Pagamentos | RevenueCat (`purchases_flutter`) — chaves via `--dart-define` |
| IA | Cloud Functions (`amandaChat`, `calorieVision`, `accompanimentAi`) — OpenAI **não** no app |
| GPS | geolocator (corrida, primeiro plano) |
| Áudio | just_audio |
| PDF | pdfx / pdf / printing |
| Android applicationId | `com.metodo1dia.app` |
| Android minSdk | 23 |
| Android compile/target | `maxOf(36, flutter.compile/targetSdkVersion)` — Play 2026 API 36+ (AGP 9.0.1, Gradle 9.1, Kotlin 2.3.20, Java 17) |
| iOS bundle id | `com.metodo1dia.app` (pasta `ios/` recriada nesta auditoria — **build iOS só em macOS**) |
| Versão app | `1.0.0+1` (`pubspec.yaml`) |

Não há Node no app cliente. Cloud Functions usam Node 22 (`firebase.json`).

Não há ambiente Firebase de staging separado: o canal Hosting `homologacao` usa o **mesmo** backend de produção.

## Comandos

```bash
flutter pub get
flutter analyze
flutter test
```

### Android (AAB para Play)

Requer `android/key.properties` **local** (já no `.gitignore`) apontando para o keystore de upload.

```bash
flutter build appbundle --release ^
  --dart-define=SUPPORT_EMAIL=COLOQUE_O_EMAIL ^
  --dart-define=PRIVACY_POLICY_URL=https://COLOQUE_A_URL/privacidade ^
  --dart-define=TERMS_URL=https://COLOQUE_A_URL/termos ^
  --dart-define=REVENUECAT_ANDROID_KEY=goog_xxx
```

AAB esperado: `build/app/outputs/bundle/release/app-release.aab`

Nesta auditoria o `flutter build appbundle --release` **não chegou a concluir** (bloqueio da ferramenta de automação). Rode o comando acima na sua máquina. Sem `key.properties` o Gradle assina com debug — **a Play rejeita**.

### iOS (somente macOS)

```bash
cd ios
pod install
cd ..
flutter build ipa --release \
  --dart-define=SUPPORT_EMAIL=COLOQUE_O_EMAIL \
  --dart-define=PRIVACY_POLICY_URL=https://COLOQUE_A_URL/privacidade \
  --dart-define=TERMS_URL=https://COLOQUE_A_URL/termos \
  --dart-define=REVENUECAT_IOS_KEY=appl_xxx
```

## Variáveis de ambiente (loja)

Ver `.env.example`. Nenhuma chave secreta deve ir para o Git.

| Define | Obrigatório para loja |
|---|---|
| SUPPORT_EMAIL | Sim (Apple Support URL / e-mail) |
| PRIVACY_POLICY_URL | Sim (https público) |
| TERMS_URL | Recomendado |
| REVENUECAT_ANDROID_KEY / IOS_KEY | Sim se houver IAP |
| MAPS_API_KEY | Só se Maps nativo for ligado |

## Problemas conhecidos

- PNG 1024 do ícone (`assets/app_icon/app_icon.png`) **não está no repo**. Ícones Android atuais vêm do mipmap; falta rasterizar o SVG e rodar `flutter_launcher_icons`.
- Product IDs: `AppConfig` usa `metodo1dia_premium_mensal/anual`; `AppConstants` ainda cita `metodo1dia_monthly/yearly`. Alinhar na Play Console / App Store Connect / RevenueCat.
- Pasta `ios/` estava ausente; foi recriada. Certificados e Apple Team ID dependem da proprietária.
- `google-services.json` e `GoogleService-Info.plist` são locais (gitignore).
- PNGs do pacote Personal-IA são pesados (~1,5 MB cada).

## Status

- Android: **quase pronto** (keystore local existe; falta URL de privacidade, ícone 1024, AAB assinado validado na Play).
- iOS: **bloqueado** até macOS + conta Apple + Privacy URL + ícones.
