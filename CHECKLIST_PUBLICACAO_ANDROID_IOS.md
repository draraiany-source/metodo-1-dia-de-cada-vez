# CHECKLIST DE PUBLICAÇÃO — ANDROID & iOS
## Método 1 Dia de Cada Vez

**Data:** 22/09/2026  
**IMPORTANTE:** NÃO publicar até Amanda assinar homologação.  
**Cobrança:** manter `PAYMENTS_ENABLED` **ausente/false** até autorização escrita.

Dart-defines oficiais (exemplo):

```bat
--dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com
--dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html
--dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html
```

---

## Pré-requisitos (ambos)

- [ ] `CHECKLIST_HOMOLOGACAO_FINAL.md` com fluxos críticos PASSOU
- [ ] Amanda aprovou conteúdo e listing
- [ ] Legais no ar conferidos no navegador
- [ ] Functions/IA alinhadas (ou features desligadas na vitrine)
- [ ] Working tree de release commitada/tagueada
- [ ] Sem segredos no Git (`key.properties`, `.jks`, OpenAI)
- [ ] Shorts `lLfcuiW32iI` ausente (repo + Firestore) se era o caso

---

## A. Android — gerar artefato

1. [ ] Confirmar `android/key.properties` aponta para upload keystore (local)
2. [ ] `flutter clean`
3. [ ] `flutter pub get`
4. [ ] Build AAB:

```bat
set GRADLE_USER_HOME=C:\Users\Lenovo\.gradle
flutter build appbundle --release --split-debug-info=build/app/debug-info ^
  --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com ^
  --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html ^
  --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html
```

5. [ ] Arquivo: `build/app/outputs/bundle/release/app-release.aab`
6. [ ] Registrar tamanho e versionCode/versionName
7. [ ] Guardar pasta `build/app/debug-info` (símbolos) fora do git se necessário
8. [ ] **Não** enviar ainda — aguardar OK Amanda

### Play Console (após aprovação)

1. [ ] Conta Owner = Amanda
2. [ ] Criar app / preencher nome, categoria
3. [ ] Descrição curta e completa aprovadas
4. [ ] Ícone 512 + feature graphic
5. [ ] Screenshots phone (e tablet se declarado)
6. [ ] Classificação de conteúdo
7. [ ] Política de privacidade URL
8. [ ] Data Safety preenchido com base no app real
9. [ ] Países/regiões
10. [ ] Conta de teste / track interno ou fechado primeiro (recomendado)
11. [ ] Upload AAB
12. [ ] Revisar permissões declaradas
13. [ ] Só então produção **após** OK Amanda

### Identidade Android

| Campo | Valor esperado |
|---|---|
| applicationId | `com.metodo1dia.app` |
| versionName | conforme `pubspec` (hoje `1.0.0`) |
| versionCode | conforme `pubspec` (hoje `1`) — incrementar a cada upload |
| minSdk | 23 |
| targetSdk | 36 |

---

## B. iOS — gerar artefato (Mac obrigatório)

1. [ ] Mac com Xcode atual
2. [ ] `flutterfire configure` → preencher iOS em `firebase_options.dart` (remover `REPLACE_ME`)
3. [ ] Abrir `ios/Runner.xcworkspace`
4. [ ] Bundle ID `com.metodo1dia.app`
5. [ ] Signing Team = conta Amanda
6. [ ] Capabilities: Push (se usar), Sign in with Apple (se usar), In-App Purchase (se IAP)
7. [ ] Privacy descriptions (câmera, foto, localização, etc.) alinhadas ao uso real
8. [ ] `flutter build ipa --release` com mesmos dart-defines (+ keys RC se sandbox)
9. [ ] Upload Transporter / Xcode → TestFlight
10. [ ] Teste em iPhone real
11. [ ] Só então Submit for Review após OK Amanda

### App Store Connect

1. [ ] Nome, subtítulo, descrição
2. [ ] Categoria, classificação etária
3. [ ] Privacidade URL + App Privacy questionnaire
4. [ ] Screenshots tamanhos exigidos
5. [ ] Notas para revisor + conta demo
6. [ ] Build selecionado
7. [ ] Submissão

---

## C. Assinaturas (se aplicável)

1. [ ] Produtos criados Play + Apple com IDs do `AppConfig`
2. [ ] RevenueCat offering `default` + entitlement `premium`
3. [ ] Sandbox testado
4. [ ] **Produção:** só com `PAYMENTS_ENABLED=true` autorizado por escrito
5. [ ] Sem Pix/Stripe para conteúdo digital in-app

---

## D. Pós-envio

1. [ ] Monitorar Crashlytics 48–72h
2. [ ] Responder rejeições da loja com Amanda
3. [ ] Incrementar versionCode a cada novo AAB/IPA
4. [ ] Manter backup keystore + tags Git

---

## E. O que esta etapa NÃO faz

- [x] Não envia para produção automaticamente
- [x] Não altera contas
- [x] Não apaga banco
- [x] Não liga pagamentos
- [x] Não troca credenciais

---

## Registro do envio (preencher no dia)

| Campo | Valor |
|---|---|
| Data aprovação Amanda | |
| versionName / versionCode | |
| SHA AAB / tamanho | |
| Track Play | interno / fechado / produção |
| Build iOS / TF | |
| Responsável upload | |
