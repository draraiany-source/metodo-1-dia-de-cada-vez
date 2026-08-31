# CHECKLIST DE VALIDAÇÃO — rodar no celular, com o APK instalado

Isso eu não posso confirmar por leitura de código — só testando o app de
verdade, na sua mão. Use esta lista assim que tiver o `app-debug.apk`
instalado (via GitHub Actions ou `flutter run` no Android Studio).

## 1. Login / Cadastro
- [ ] Abre a tela de login sem crash
- [ ] Criar conta nova funciona (ou mostra erro claro se Firebase não configurado)
- [ ] Login com conta existente funciona
- [ ] "Esqueci a senha" envia e-mail (ou mostra mensagem clara)
- [ ] Logout volta pra tela de login

## 2. Firebase (modo real OU modo demonstração)
- [ ] Se `google-services.json` NÃO estiver configurado: o app abre mesmo
      assim, em modo local, sem crash — é o comportamento esperado
- [ ] Se configurado: dados salvam e persistem entre sessões (feche e abra o
      app de novo, veja se o progresso continua lá)

## 3. Receitas
- [ ] Lista de receitas carrega (ou mostra estado vazio, se não houver conteúdo cadastrado)
- [ ] Abrir uma receita mostra ingredientes/modo de preparo
- [ ] Favoritar funciona

## 4. Vídeos / Áudios
- [ ] Lista carrega
- [ ] Player de vídeo abre e reproduz (ou mostra erro claro se a URL não estiver configurada)
- [ ] Player de áudio abre e reproduz
- [ ] Conteúdo Premium bloqueado mostra o cadeado corretamente pra quem não é Premium

## 5. Treinos
- [ ] Lista de treinos carrega
- [ ] Abrir um treino mostra os exercícios
- [ ] Marcar como concluído funciona e reflete na Home/missões

## 6. Notificações
- [ ] O app pede permissão de notificação (Android 13+)
- [ ] Criar um lembrete e ele dispara no horário certo
- [ ] Notificação push chega (só funciona com Firebase configurado)

## 7. Navegação
- [ ] As 5 abas da barra inferior trocam de tela sem travar
- [ ] Botão "voltar" do Android funciona em todas as telas
- [ ] Nenhuma tela abre em branco/crash ao navegar

## Se algo falhar
Anote: **em qual tela**, **o que você tocou**, e **o que apareceu** (mensagem
de erro, tela branca, app fechou sozinho). Me manda essa descrição — é o
equivalente a um "stack trace manual" e me dá o suficiente pra corrigir.
