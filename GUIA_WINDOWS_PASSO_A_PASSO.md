# GUIA WINDOWS — Instalar, testar e caminhar para publicar
## Método 1 Dia de Cada Vez

Este guia assume que é sua primeira vez. Vá com calma; a instalação é uma vez só.
Ao final você consegue: rodar o app no celular/emulador e gerar o APK.

═══════════════════════════════════════════════
ETAPA 1 — INSTALAR (uma vez, ~1h com downloads)
═══════════════════════════════════════════════

## 1.1 Android Studio (traz o Android SDK junto)
- Baixe: https://developer.android.com/studio
- Instale com as opções padrão (Next → Next → Finish).
- Abra uma vez e deixe ele baixar os componentes que pedir.

## 1.2 Flutter SDK
- Baixe o .zip: https://docs.flutter.dev/get-started/install/windows
- Descompacte em **`C:\src\flutter`**
  ⚠️ NÃO use pastas com espaço ou acento (ex.: evite "Área de Trabalho",
  "Program Files"). `C:\src\flutter` é o ideal.

## 1.3 Colocar o Flutter no PATH (pra o Windows "enxergar" o comando)
1. Tecla Windows → digite "variáveis de ambiente" → abra
   "Editar as variáveis de ambiente do sistema".
2. Botão "Variáveis de Ambiente" → em "Variáveis do usuário", selecione **Path**
   → Editar → Novo → cole: `C:\src\flutter\bin` → OK em tudo.
3. Feche e reabra qualquer terminal para valer.

## 1.4 Conferir a instalação
- Abra o **PowerShell** (tecla Windows → digite "powershell").
- Rode:
  ```
  flutter doctor
  ```
- Ele mostra uma lista com ✓ e ✗. O comum é faltar aceitar as licenças do
  Android. Se pedir, rode:
  ```
  flutter doctor --android-licenses
  ```
  e aperte `y` em tudo. Rode `flutter doctor` de novo até o Android ficar ✓.
  (O item do Visual Studio / Xcode pode ficar ✗ — não precisa para Android.)

═══════════════════════════════════════════════
ETAPA 2 — ABRIR O PROJETO E GERAR AS PLATAFORMAS
═══════════════════════════════════════════════

## 2.1 Descompactar
- Descompacte o ZIP do projeto (vai virar a pasta `metodo_1_dia`).
- Coloque em um caminho simples, ex.: `C:\src\metodo_1_dia`.

## 2.2 Abrir o terminal na pasta
- No PowerShell:
  ```
  cd C:\src\metodo_1_dia
  ```

## 2.3 Gerar android/ios/web e baixar pacotes
  ```
  flutter create . --platforms=android,ios,web
  flutter pub get
  ```
  (O `create` NÃO apaga seu código — só adiciona as pastas nativas.)

## 2.4 A checagem que importa
  ```
  flutter analyze
  ```
  ➡️ **Isto vai listar erros na primeira vez. É esperado** (o código nunca foi
  compilado). **COPIE tudo o que aparecer e me mande.** Eu corrijo e te devolvo.
  Repetimos até aparecer **"No issues found!"**.

═══════════════════════════════════════════════
ETAPA 3 — TESTAR O APP
═══════════════════════════════════════════════

## Opção A — Celular Android por cabo (recomendado, mais real)
1. No celular: Configurações → Sobre o telefone → toque 7× em "Número da versão"
   para liberar o "Modo desenvolvedor".
2. Em Opções do desenvolvedor → ative **Depuração USB**.
3. Ligue o celular no PC por USB e aceite o aviso "Permitir depuração".
4. No PowerShell, confirme que apareceu:
   ```
   flutter devices
   ```
5. Rode:
   ```
   flutter run
   ```
   O app instala e abre no seu celular.

## Opção B — Emulador (celular virtual no PC)
1. Android Studio → ícone "Device Manager" (celular) → Create Device.
2. Escolha um modelo (ex.: Pixel 7) → uma imagem de sistema (Android 14) →
   baixe → Finish.
3. Dê play no emulador e rode `flutter run`.

═══════════════════════════════════════════════
ETAPA 4 — GERAR O APK (para instalar/compartilhar)
═══════════════════════════════════════════════
  ```
  flutter build apk --release
  ```
- O arquivo fica em:
  `build\app\outputs\flutter-apk\app-release.apk`
- Esse APK instala em qualquer Android para teste.
  (Para PUBLICAR na Play Store depois, o formato é o AAB:
   `flutter build appbundle --release` — mas isso é etapa lá na frente,
   com sua chave de assinatura.)

═══════════════════════════════════════════════
QUANDO ME CHAMAR
═══════════════════════════════════════════════
- Assim que o `flutter analyze` (Etapa 2.4) mostrar erros → cole aqui.
- Se `flutter run` falhar com alguma mensagem → cole a mensagem.
- Se travar em qualquer etapa da instalação → me diz em qual número parou.

Eu corrijo os erros de código direto e te oriento em cada tranco. O objetivo é
chegar em "No issues found" + APK instalado no seu celular. A partir daí,
seguimos para Firebase, assinatura e publicação — um passo de cada vez.

═══════════════════════════════════════════════
LEMBRETES HONESTOS
═══════════════════════════════════════════════
- Firebase (login/nuvem): o app abre em "modo demonstração" sem ele. Para ligar
  de verdade, depois você roda `flutterfire configure` (eu te guio).
- Pagamentos: hoje é simulado. Monetização real exige RevenueCat + contas de loja.
- iOS/iPhone: só compila em Mac com Xcode. No Windows, foque no Android.
