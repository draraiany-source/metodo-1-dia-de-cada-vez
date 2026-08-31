# CI — Build na nuvem (Método 1 Dia de Cada Vez)

Este repositório é compilado por **GitHub Actions** porque o ambiente onde o
código foi desenvolvido não tem Flutter SDK. O workflow roda num runner com
Flutter de verdade e devolve os builds como artefatos.

## Passo a passo

1. **Crie um repositório no GitHub** e suba o projeto inteiro, incluindo esta
   pasta `.github/`.
   ```bash
   cd metodo_1_dia
   git init && git add . && git commit -m "V38 + CI"
   git branch -M main
   git remote add origin https://github.com/SEU_USUARIO/metodo_1_dia.git
   git push -u origin main
   ```
2. No GitHub, abra a aba **Actions** → workflow **build** → **Run workflow**
   (ou o push já dispara automaticamente).
3. Aguarde. Ao terminar, role até **Artifacts** e baixe:
   - `analyze-log` → **`analyze.txt`** (a lista de erros/avisos)
   - `test-log` → resultado dos testes
   - `android-apk` → APK debug e release
   - `android-aab` → AAB para a Play Store
   - `web-release` → site pronto
   - `ios-app-unsigned` → `.app` do iOS (sem assinatura)

## O que esperar da PRIMEIRA execução

Como o código nunca passou por um compilador, é **muito provável** que o
`flutter analyze` e os builds acusem erros na primeira vez. **Isso é o
objetivo.** Baixe o `analyze.txt` e me envie o conteúdo — eu corrijo os erros
reais em lote e você roda o workflow de novo. Repetimos até `No issues found` e
os APK/AAB saírem verdes.

## Observações importantes (sem invenção)

- **APK/AAB release** saem **assinados com a chave de debug** (padrão do Flutter
  quando não há keystore). Servem para teste em dispositivo, **não** para
  publicar. Para a loja, configure um keystore próprio em
  `android/app/build.gradle` (`signingConfigs`) e adicione os segredos no GitHub.
- **IPA assinado** NÃO é gerado: exige certificado + provisioning profile da sua
  conta Apple Developer. O job iOS aqui só prova que o app **compila** no iOS.
- Os ícones são gerados a partir dos SVGs convertidos para PNG no próprio CI.
  Para qualidade final, exporte um `app_icon.png` 1024×1024 real e comite em
  `assets/app_icon/`.

## Versão do Flutter

Fixada em `3.27.1` (stable), que satisfaz o `sdk: ">=3.3.0 <4.0.0"` do pubspec.
Se quiser outra, altere `flutter-version` em `.github/workflows/build.yml`.
