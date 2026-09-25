# Checklist Google Play — Método 1 Dia de Cada Vez

App ID: `com.metodo1dia.app`  
Versão: `1.0.0` (versionCode `1`)

## [OK]

- applicationId `com.metodo1dia.app`
- minSdk 23, compileSdk/targetSdk ≥ 36, Java 17, AGP 9, Gradle 9.1
- ProGuard/R8 ligado no release
- `android/key.properties` e `*.jks` no `.gitignore`
- `google-services.json` no `.gitignore`
- Guest mode e `debugUnlockAllPremiumContent` = `false`
- Exclusão de conta na tela Configurações
- Logout real (Firebase Auth)
- Rotas `/admin` e painel Personal protegidas
- FCM + canal de notificação; sem `EXACT_ALARM`
- Crashlytics só fora de debug
- `windowSoftInputMode=adjustResize`
- Showcase de assets só em `kDebugMode`
- Analytics **sem** Advertising ID (`google_analytics_adid_collection_enabled=false`; permissão `AD_ID` removida)

## [CORRIGIDO]

- Telas internas `/privacidade` e `/termos` (públicas, para revisão)
- Cadastro exige aceite de Termos/Privacidade + e-mail válido
- Versão do app lida de `PackageInfo` (não mais texto fixo)
- Intent `mailto` no Manifest
- WAKE_LOCK mantido para cronômetro
- `.env.example` sem secrets

## [PENDENTE]

- AAB de release gerado nesta máquina (ver relatório)
- Ícone 1024 PNG + adaptive icon gerados (`flutter_launcher_icons`)
- Screenshots Play (telefone + 7")
- Descrição curta/longa da loja
- Classificação indicativa (IARC)
- Conteúdo de política **hospedado em https público**
- Conferir IDs de produto RevenueCat vs Play Billing
- Teste interno na Play Console

## [DEPENDE DA PROPRIETÁRIA]

- Conta Google Play Console
- URL https da Política de Privacidade
- E-mail de suporte
- Keystore de **upload** (já existe localmente? confirmar backup fora do Git — **não enviar senha**)
- Dados legais (nome/CNPJ ou pessoa física)
- Declaração Data Safety na Play (usar tabela do relatório)
- Screenshots e feature graphic 1024×500
- Responder se o app tem conteúdo gerado por usuário (chat) — sim, mensagens aluna/Personal
