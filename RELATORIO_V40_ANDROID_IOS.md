# Relatório V40 — Preparação para Android e iOS

> **Ambiente (declaração honesta).** Este ambiente não tem Flutter SDK, Android
> SDK, Xcode nem internet. Portanto **NÃO** executei `flutter create`,
> `analyze`, `test` nem build algum, e **NÃO** gerei pastas `android/`/`ios/`,
> APK, AAB ou IPA. Nada disso é simulado. O que segue é o trabalho de
> preparação que É possível e verificável sem SDK — e que faz a build real (na
> sua máquina ou no CI) exigir menos ajustes.

## (B) Auditoria de permissões — o que o código REALMENTE usa

| Recurso | Usado? | Evidência no código |
|---|---|---|
| Internet / rede | ✅ | Firebase, `http` (11 arquivos) |
| Localização (GPS) | ✅ **só em uso** | `Geolocator.getPositionStream` na tela de corrida; sem background |
| Câmera | ✅ | `ImageSource.camera` (scanner de calorias, upload admin) |
| Galeria/fotos | ✅ | `ImageSource.gallery` (perfil/progresso) |
| Notificações | ✅ | `firebase_messaging` + `flutter_local_notifications` (lembretes agendados) |
| Microfone | ❌ | Não há gravação; `just_audio` é só reprodução; "record" = `Crashlytics.recordError` |
| Saúde/wearables | ❌ (ainda) | Pacote `health` não está no pubspec; feature é stub |
| Rastreamento/IDFA | ❌ | Sem ATT/IDFA |

**Consequência prática:** as configs a seguir pedem exatamente esse conjunto —
nem a mais (que reprova na loja) nem a menos (que quebra funcionalidade).

## (A) Configuração nativa entregue — pasta `release_config/`

- **`AndroidManifest_permissions.xml`** — permissões exatas: internet, GPS em
  uso, câmera, galeria (READ_MEDIA_IMAGES + READ_EXTERNAL_STORAGE≤API32),
  notificações (POST_NOTIFICATIONS + alarmes exatos + boot para reagendar
  lembretes). Background location fica **comentado** como opcional.
- **`Info_plist_keys.xml`** — descrições de câmera, fotos, localização em uso;
  `UIBackgroundModes: remote-notification`; `ITSAppUsesNonExemptEncryption=false`.
  Microfone/HealthKit/ATT deliberadamente fora, com justificativa.
- **`build_gradle_release_snippet.gradle`** — **reescrito à prova de CI**: sem
  keystore cai na assinatura debug (build release instalável); com
  `key.properties` assina produção. `applicationId` sugerido `com.metodo1dia.app`.

## (C) Publicação — `release_config/PRIVACIDADE_E_DATA_SAFETY.md`

Rascunho de política de privacidade (LGPD), mapa do formulário **Data Safety**
da Play Console e das **Privacy Nutrition Labels** da App Store, todos baseados
nos dados que o código realmente coleta (e-mail, dados de fitness, localização
em uso, fotos, uso, falhas, texto para a IA). Inclui checklist de loja.

## Correção de over-permission (importante)

As configs anteriores pediam `ACCESS_BACKGROUND_LOCATION`, foreground-service e
`NSLocationAlwaysAndWhenInUse` + `UIBackgroundModes:location` — que o código
**não usa**. Isso dispararia revisão pesada (Play) e prompts desnecessários.
**Removidos** do conjunto ativo e marcados como opcionais.

## O que continua dependendo de você / credenciais

1. Rodar `flutter create .` + build (SDK) — na sua máquina ou pelo CI.
2. `google-services.json` / `GoogleService-Info.plist` (console Firebase).
3. Keystore de upload (Android) e conta Apple Developer + certificado (IPA).
4. Confirmar o domínio do `applicationId`/Bundle ID.
5. Hospedar a política de privacidade em URL pública.

## Arquivos desta versão

Atualizados: `release_config/AndroidManifest_permissions.xml`,
`release_config/Info_plist_keys.xml`,
`release_config/build_gradle_release_snippet.gradle`.
Novos: `release_config/PRIVACIDADE_E_DATA_SAFETY.md`,
`README_BUILD_ANDROID_IOS.md`, este relatório.
