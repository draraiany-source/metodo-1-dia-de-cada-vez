# Configuração Firebase iOS — bloqueio de publicação
**Data:** 23/09/2026  
**Estado:** `lib/firebase_options.dart` → `ios.apiKey` / `ios.appId` = **`REPLACE_ME`**

## Por que está bloqueado
Não existe `GoogleService-Info.plist` no repositório. **Não inventar** apiKey/appId (Firebase rejeita IDs de outra plataforma).

## Procedimento (Amanda + Mac)
1. Firebase Console → projeto `metodo1dia-app` → Add app **iOS**
2. Bundle ID: `com.metodo1dia.app`
3. Baixar `GoogleService-Info.plist` **ou** no Mac:
   ```bash
   flutterfire configure --project=metodo1dia-app
   ```
4. Confirmar `DefaultFirebaseOptions.iosFirebaseReady == true`
5. Archive / TestFlight

## Diagnóstico no app
Painel Técnico → “Configuração de produção” → item **Firebase iOS (não REPLACE_ME)** deve ficar OK após o configure.

## Cobrança
`PAYMENTS_ENABLED` permanece **false**. Sandbox: `--dart-define=BILLING_SANDBOX=true` + chaves RevenueCat — **não** é produção.
