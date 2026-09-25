# Checklist App Store — Método 1 Dia de Cada Vez

Bundle ID: `com.metodo1dia.app`  
Versão: `1.0.0` (build `1`)  
Display name: Método 1 Dia

## [OK no código]

- Bundle previsto igual ao Android
- Privacy Manifest (`ios/Runner/PrivacyInfo.xcprivacy`) — UserDefaults / file timestamp / disk space; **NSPrivacyTracking = false**
- Textos de permissão no Info.plist (câmera, fotos, localização when-in-use, microfone se o plugin exigir)
- Sem tracking ATT (não usamos IDFA)
- Exclusão de conta no app
- Documentos legais no app (`/privacidade`, `/termos`)

## [CORRIGIDO]

- Pasta `ios/` estava **ausente**; recriada com `flutter create --platforms=ios`
- Privacy Manifest adicionado

## [PENDENTE — só em macOS]

- `pod install`
- `flutter build ipa --release`
- Assinatura Automatic/Manual no Xcode
- Push (APNs) + `GoogleService-Info.plist` no target
- Ícones 1024 sem alpha (`remove_alpha_ios: true` no pubspec)
- Archive / TestFlight

## [DEPENDE DA PROPRIETÁRIA]

- Conta Apple Developer (paga)
- Apple Team ID
- Certificados + perfil de distribuição
- URL de suporte **e** URL de privacidade (https) — **obrigatórias**
- Conta de demonstração para revisão (aluna de teste)
- Screenshots iPhone 6.7" e 6.1" (e iPad se o app for universal)
- Age rating, keywords, descrição
- Export compliance (criptografia padrão HTTPS → geralmente isento)
- Confirmar se usa HealthKit: o código tem tela `health_sync`; se não usar HealthKit nativo, não ligar a capability
