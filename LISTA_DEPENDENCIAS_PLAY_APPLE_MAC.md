# O QUE DEPENDE DE GOOGLE PLAY / APPLE / MAC
## Método 1 Dia de Cada Vez — 22/09/2026

### Google Play Console (conta da Amanda = Owner)

- Criar/configurar o app na Play
- Upload do AAB (após aprovação de homologação)
- Screenshots, feature graphic, descrição
- Questionário Data Safety
- Classificação de conteúdo
- Conta de revisor / faixa interna ou fechada
- Aceitar Play App Signing
- Produtos IAP (se for vender) alinhados ao RevenueCat

### Apple Developer + App Store Connect (conta da Amanda = Owner)

- Membership Apple Developer
- Registrar Bundle ID `com.metodo1dia.app`
- Certificados, profiles, capabilities (Push, IAP se houver)
- App Privacy questionnaire
- Screenshots e metadados
- Conta de revisor
- Submissão após TestFlight

### Computador Mac (obrigatório para iOS)

- Xcode atualizado
- `flutterfire configure` / colar `GoogleService-Info.plist` real (hoje `REPLACE_ME` no iOS)
- `flutter build ipa` / Archive
- Upload TestFlight
- Teste em iPhone físico

### O que NÃO depende disso (já feito no Windows)

- Código Flutter Android
- APK/AAB release local
- Minify + shrinkResources
- Seed de vídeos/meditações
- Rules Firestore/Storage no repositório
- Relatórios de homologação
