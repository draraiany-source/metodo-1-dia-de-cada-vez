# Método 1 Dia de Cada Vez 💜

Aplicativo fitness feminino premium construído em **Flutter + Firebase**, seguindo
o KIT MASTER. Arquitetura **feature-first**, tema dark premium com a identidade
oficial (lilás #9B5DE5, roxo #5A189A, rosa #F15BB5, verde #00C896), navegação
completa com **GoRouter** e estado com **Riverpod**.

> "Um dia de cada vez até a sua melhor versão."

---

## ✨ O que já está implementado

Todas as 15 telas obrigatórias, navegáveis e funcionais:

| Módulo | Estado |
|---|---|
| Splash animada | ✅ Completo |
| Onboarding (4 telas) | ✅ Completo |
| Login / Cadastro | ✅ Completo (Firebase Auth + modo local) |
| Home (frase da Amanda, nível, atalhos, stats) | ✅ Completo |
| Amanda IA (chat) | ✅ Chat funcional + integração OpenAI via Cloud Function |
| Treinos (lista, busca, filtros, detalhe) | ✅ Completo |
| Corrida GPS | ✅ Rastreio real via `geolocator` (mapa aguarda chave) |
| Nutrição (água + receitas) | ✅ Completo |
| Hábitos / Check-in (humor + hábitos) | ✅ Completo |
| Evolução (gráfico de peso, IMC, fotos) | ✅ Completo (`fl_chart`) |
| Gamificação (XP, medalhas, desafios, ranking) | ✅ Completo |
| Comunidade (feed, curtir, publicar) | ✅ Completo |
| Perfil (dados corporais, menu, logout) | ✅ Completo |
| Premium (planos, benefícios) | ✅ UI completa (pagamento a integrar) |
| Painel Admin (dashboard + CRUD) | ✅ Estrutura completa |

**Backend incluído** (do KIT MASTER): `firebase/firestore.rules`,
`firebase/storage.rules`, `firebase/firestore.indexes.json`, seeds e
Cloud Functions (`functions/src/index.js`) — incluindo `onWorkoutCompleted`,
`onRunningSessionCreated` e a nova `amandaChat` (proxy OpenAI).

### 🎯 Modo local inteligente
O app **compila e roda mesmo sem o Firebase configurado**. Enquanto as chaves
forem placeholders, ele usa a usuária demo (`ana@exemplo.com` / `123456`) e dados
mockados dos seeds. Assim você vê tudo funcionando antes de plugar o backend.

---

## 🔧 O que depende de configuração externa (chaves)

Estes itens estão **prontos no código**, só precisam das suas credenciais:

1. **Firebase** — rode `flutterfire configure` (gera `firebase_options.dart` real).
2. **Google Maps** (mapa da corrida) — adicione a chave e descomente
   `google_maps_flutter` no `pubspec.yaml`. O rastreio de GPS já funciona sem o mapa.
3. **OpenAI** (Amanda IA avançada) — configure a chave **na Cloud Function**
   (`firebase functions:config:set openai.key="sk-..."`) e ajuste
   `amandaFunctionUrl` em `lib/core/constants/app_constants.dart`.
   Sem isso, a Amanda responde no modo local (frases + palavras-chave).
4. **Pagamentos Premium** — descomente `purchases_flutter` (RevenueCat) e integre.
5. **Notificações Push (FCM)** — `firebase_messaging` já está no projeto; configure
   os certificados APNs/FCM nas lojas.

---

## 🚀 Como rodar

Pré-requisitos: Flutter 3.19+ instalado (`flutter doctor`).

```bash
# 1. Gerar as pastas nativas (android/ios/web) dentro do projeto
flutter create .

# 2. Instalar dependências
flutter pub get

# 3. (Opcional agora, necessário p/ produção) configurar Firebase
dart pub global activate flutterfire_cli
flutterfire configure

# 4. Aplicar permissões nativas — ver PLATFORM_SETUP.md
#    (localização para GPS, câmera para fotos, etc.)

# 5. Rodar
flutter run
```

> Sem o passo 3, o app roda em **modo local** (demo) normalmente.

### Deploy do backend Firebase
```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
firebase deploy --only functions
```

---

## 🗂 Estrutura do projeto

```
lib/
├── main.dart                  # entrypoint (init Firebase + portrait lock)
├── app.dart                   # MaterialApp.router (tema dark)
├── firebase_options.dart      # PLACEHOLDER — flutterfire configure sobrescreve
├── core/
│   ├── theme/                 # cores oficiais + tema (Poppins/Inter)
│   ├── router/                # GoRouter + shell com bottom nav
│   ├── constants/             # constantes + seeds (conteúdo do KIT)
│   ├── services/              # FirebaseService (degradação graciosa)
│   └── widgets/               # widgets compartilhados
├── models/                    # AppUser, Workout, Habit, Challenge, etc.
└── features/                  # feature-first (presentation/data/providers)
    ├── splash/ onboarding/ auth/ home/ amanda/ workouts/ running/
    ├── nutrition/ habits/ evolution/ gamification/ community/
    └── profile/ premium/ admin/

firebase/     # regras, índices, seeds (do KIT MASTER)
functions/    # Cloud Functions (XP automático + Amanda IA)
assets/content/  # JSON de treinos, receitas, desafios, frases da Amanda
```

Coleções Firestore (em `app_constants.dart`) seguem exatamente as regras de
segurança do KIT: `users`, `workouts`, `workout_history`, `running_sessions`,
`recipes`, `habits`, `progress`, `badges`, `challenges`, `community_posts`,
`comments`, `subscriptions`, `notifications`, `amanda_messages`. Admins são
identificados pela coleção `admins/{uid}`.

---

## 🧩 Próximos passos sugeridos (roadmap V1+)

- Persistir check-ins, treinos e corridas no Firestore (repositories já preparados).
- Ativar o mapa da corrida com traçado do percurso (Google Maps + polyline).
- Ligar a Amanda à OpenAI de verdade (deploy da function + chave).
- Integrar pagamento real (RevenueCat) e sincronizar `isPremium`.
- Notificações inteligentes agendadas (água, treino, recuperação de inativas).
- Upload de fotos de progresso (Storage já com regras prontas).

---

## ⚠️ Observações honestas

Este é um **MVP sólido e compilável**: toda a fundação, navegação, tema e telas
estão prontas, com dados mockados onde ainda não há backend real conectado.
Levar cada módulo (corrida com mapa, IA, pagamentos, comunidade em tempo real,
admin com escrita no Firestore) a nível de produção final é um trabalho adicional
de integração — mas a estrutura para isso já está toda no lugar, seguindo o
KIT MASTER e as regras de segurança fornecidas.
