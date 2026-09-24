# iOS Firebase — o que falta (REPLACE_ME)
**Não inventar credenciais.**

## Onde está
`lib/firebase_options.dart` → `DefaultFirebaseOptions.ios`:
- `apiKey: 'REPLACE_ME'`
- `appId: 'REPLACE_ME'`

Já preenchidos (não são o bloqueio): `messagingSenderId`, `projectId`, `storageBucket`, `iosBundleId` (`com.metodo1dia.app`).

## Dado oficial faltando
1. **App iOS registrado** no Firebase Console do projeto `metodo1dia-app` (bundle `com.metodo1dia.app`).
2. Arquivo **`GoogleService-Info.plist`** gerado pelo Console **ou** saída de `flutterfire configure` com `apiKey` + `GOOGLE_APP_ID` reais da plataforma iOS.

## Onde configurar
1. Firebase Console → Project settings → Your apps → Add app → iOS.
2. Baixar `GoogleService-Info.plist` → colocar em `ios/Runner/`.
3. No Mac: `flutterfire configure --project=metodo1dia-app` (atualiza `lib/firebase_options.dart`).
4. Confirmar `DefaultFirebaseOptions.iosFirebaseReady == true`.

**Não** copiar `apiKey`/`appId` do Android — Firebase rejeita.
