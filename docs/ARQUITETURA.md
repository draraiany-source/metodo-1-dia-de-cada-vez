# Método 1 Dia de Cada Vez (Lili Fit) — Documentação Técnica

## Arquitetura

Flutter + Riverpod (state management) + GoRouter (navegação) + Firebase
(Auth/Firestore/Storage/Functions), seguindo Clean Architecture por
feature:

```
lib/
  core/            # config, router, serviços, tema, widgets compartilhados
  models/          # modelos globais (AppUser)
  features/
    <feature>/
      domain/        # modelos e regras de negócio puras
      data/          # repositórios (Firestore/HTTP), sem estado
      providers/     # Riverpod — ponte entre data e presentation
      presentation/  # telas e widgets
```

Padrão de resiliência usado em todo repositório que fala com Firebase:
`bool get _local => !FirebaseService.isReady;` — se o Firebase não estiver
configurado, cai num modo local/demo em vez de quebrar. Isso permite rodar
o app em desenvolvimento sem credenciais reais.

## Módulos (features/)

| Módulo | O que faz | Backend |
|---|---|---|
| auth | login, cadastro, recuperação de senha, código de indicação | Firebase Auth + Firestore |
| onboarding | fluxo de boas-vindas | local |
| home | tela inicial com atalhos | — |
| profile | perfil, edição de dados | Firestore |
| nutrition | água, IMC, diário alimentar, calorias por foto | Firestore local + Cloud Function `calorieVision` |
| evolution | peso, gráfico, fotos de progresso | local (SharedPreferences) |
| running | corrida com GPS, histórico | Firestore `running_sessions` |
| workouts | biblioteca de treinos (texto) | seed local |
| video_streaming | vídeos por streaming, player, download offline | Firestore `videos` + Cloud Function `getVideoUrl` |
| audio_courses | cursos em áudio, player | Firestore `audio_courses` |
| pdf_recipes | receitas em PDF | Firestore `pdf_recipes` |
| calendar | agenda/calendário de hábitos | local |
| reminders | lembretes com notificação local agendada | local + `flutter_local_notifications` |
| checkin | check-in diário de hábitos | local |
| missions / gamification / rewards / streak | sistema de XP, missões, loja, sequência | Firestore (privilegiado, só Cloud Functions escrevem) |
| dashboard | dashboard premium com gráficos | agrega dados de outros módulos |
| certificates | certificados em PDF | gerado no device (`pdf` + `printing`) |
| referral | sistema de indicação | Firestore + Cloud Function `onUserCreated` |
| coupons | cupons promocionais | Firestore (admin) + Cloud Function `redeemCoupon` |
| reports | relatórios em PDF | agrega dados de outros módulos |
| ai_trainer / amanda | assistente de IA | Cloud Function `amandaChat` (proxy OpenAI) |
| health_sync | integração com Apple Health/Google Fit | pacote `health` |
| community | comunidade/feed | Firestore |
| premium | assinatura | RevenueCat (preparado) |
| admin | painel administrativo | Firestore (parte mock, parte real — ver relatório RC1) |

## Dependências principais

- **Estado**: `flutter_riverpod`
- **Navegação**: `go_router`
- **Firebase**: `firebase_core`, `firebase_auth`, `cloud_firestore`,
  `firebase_storage`\*, `firebase_analytics`, `firebase_crashlytics`,
  `firebase_messaging`, `firebase_remote_config`
- **Vídeo**: `video_player`, `chewie`
- **Áudio**: `just_audio`
- **PDF**: `pdfx` (visualizar), `pdf` + `printing` (gerar/compartilhar)
- **Gráficos**: `fl_chart`
- **Calendário**: `table_calendar`
- **Notificações locais**: `flutter_local_notifications` + `timezone`
- **Imagens**: `cached_network_image`, `image_picker`
- **Outros**: `http`, `shared_preferences`, `path_provider`, `share_plus`,
  `geolocator`\*, `geocoding`\*, `google_sign_in`\*

\* = dependência presente mas ainda não conectada a nenhuma tela (preparada
para integração futura — ver relatório de auditoria).

## Configuração do Firebase

1. Criar projeto no Firebase Console.
2. Rodar `flutterfire configure` na raiz do projeto (gera
   `lib/firebase_options.dart` de verdade, hoje é placeholder).
3. Ativar: Authentication (Email/Senha), Firestore, Storage, Analytics,
   Crashlytics, Cloud Messaging, Remote Config.
4. Deploy das regras: `firebase deploy --only firestore:rules,storage:rules`
   (arquivos em `firebase/firestore.rules` e `firebase/storage.rules`).
5. Deploy das Cloud Functions: `cd functions && npm install && firebase
   deploy --only functions` (arquivo `functions/src/index.js`). Configurar
   a chave da OpenAI: `firebase functions:config:set openai.key="sk-..."`
   (usada por `amandaChat` e `calorieVision`).
6. Depois do deploy, atualizar as URLs das functions no app via
   `--dart-define` (ver `lib/core/constants/app_constants.dart` — todas
   as constantes `*FunctionUrl` têm o padrão
   `https://us-central1-SEU-PROJETO.cloudfunctions.net/...`).

### Coleções do Firestore (visão geral)
`users`, `running_sessions`, `audio_courses` (+ `chapters`), `pdf_recipes`,
`videos` (+ `private/stream` — nunca lido pelo cliente), `referral_codes`,
`coupons`, `coupon_redemptions`, `workouts`, `recipes`, `challenges`,
`admins`.

## Processo de build

**Pré-requisito ainda pendente**: rodar `flutter create .` na raiz do
projeto pra gerar `android/`, `ios/`, `web/` (não incluídos ainda — ver
checklist abaixo).

```bash
flutter pub get

# Ícone e splash (depois de exportar os PNGs — ver checklist)
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create

# Debug
flutter run

# Produção
flutter build appbundle --release   # Android (Play Store)
flutter build apk --release         # Android (teste direto)
flutter build ios --release         # iOS (precisa de Mac + Xcode)
flutter build web --release         # Web
```

## Checklist de publicação

- [ ] Rodar `flutter create .` pra gerar as pastas nativas
- [ ] `flutterfire configure` com o projeto Firebase real
- [ ] Exportar `assets/app_icon/app_icon.svg` como PNG 1024x1024 (e o
      adaptive foreground) — os SVGs já existem, falta rasterizar
- [ ] Rodar `flutter pub run flutter_launcher_icons` e
      `flutter pub run flutter_native_splash:create`
- [ ] Adicionar permissões de câmera/galeria no `Info.plist`/
      `AndroidManifest.xml` (texto exato em
      `NOVAS_FUNCIONALIDADES_NUTRICAO.md`)
- [ ] Deploy das Firestore/Storage rules
- [ ] Deploy das Cloud Functions + configurar chave da OpenAI
- [ ] Configurar RevenueCat (assinaturas)
- [ ] `flutter analyze` sem erros (não verificado neste ambiente — ver
      relatório)
- [ ] `flutter test` passando
- [ ] Testar em dispositivo Android físico
- [ ] Testar em dispositivo iOS físico
- [ ] Preencher ficha da loja (Google Play Console / App Store Connect):
      capturas de tela, descrição, política de privacidade
- [ ] Assinar o build Android (keystore) e configurar o certificado iOS

## Manutenção

- **Cadastrar conteúdo** (vídeos, áudios, receitas PDF, cupons): pelo
  painel administrativo do próprio app (Perfil → Admin, requer
  `isAdmin: true` no documento do usuário no Firestore) ou direto pelo
  console do Firebase.
- **Segurança**: nunca adicionar um campo nas regras sem checar se ele
  deveria estar em `noPrivilegedFields()` (`firebase/firestore.rules`) —
  esse foi o tipo de brecha encontrada e corrigida durante o
  desenvolvimento (ver relatórios de auditoria).
- **Novas Cloud Functions**: seguir o padrão de `functions/src/index.js`
  — CORS liberado, verificação de token via `admin.auth().verifyIdToken`
  quando precisar saber quem está chamando, nunca confiar em dado vindo
  do cliente pra créditos/recompensas.
