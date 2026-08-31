/// Constantes globais do app.
///
/// Os nomes das coleções seguem a MODELAGEM_FIRESTORE.md e as regras de
/// segurança (`firestore.rules`) fornecidas no KIT MASTER, para que a
/// autenticação e as permissões funcionem corretamente.
class AppConstants {
  AppConstants._();

  static const String appName = 'Método 1 Dia de Cada Vez';
  static const String appTagline = 'Um dia de cada vez 💜';

  // ---- Chaves SharedPreferences ----
  static const String kOnboardingDone = 'onboarding_done';
  static const String kThemeMode = 'theme_mode';

  /// Persiste se a pessoa optou por "Entrar como visitante" — precisa ficar
  /// salvo em disco (e não só em memória) porque no Flutter Web o estado do
  /// Riverpod é perdido a cada F5. Sem isso, atualizar a página dentro do
  /// app derrubava a visitante de volta para a tela de login/cadastro.
  static const String kGuestMode = 'guest_mode_active';

  /// Modo de desenvolvimento/demonstração: quando `true`, o botão "Entrar
  /// como visitante" fica disponível já na primeira tela, permitindo abrir
  /// a Home sem precisar criar conta. Deixe `false` caso queira exigir
  /// cadastro/login obrigatório em produção.
  static const bool enableGuestMode = true;

  /// Auditoria/teste: quando `true`, TODO o conteúdo Premium fica liberado
  /// no app inteiro (vídeos, e-books, cursos, IA, etc.), sem precisar
  /// assinar. Único lugar que precisa mudar — [PremiumNotifier] lê esta
  /// flag antes de consultar o serviço real. Deixe `false` antes de
  /// publicar a versão final para as usuárias.
  static const bool debugUnlockAllPremiumContent = true;

  // ---- Coleções Firestore (alinhadas ao KIT MASTER) ----
  static const String cUsers = 'users';
  static const String cAdmins = 'admins';
  static const String cWorkouts = 'workouts';
  static const String cWorkoutHistory = 'workout_history';
  static const String cRunningSessions = 'running_sessions';
  static const String cRecipes = 'recipes';
  static const String cHabits = 'habits';
  static const String cProgress = 'progress';
  static const String cBadges = 'badges';
  static const String cChallenges = 'challenges';
  static const String cCommunityPosts = 'community_posts';
  static const String cComments = 'comments';
  static const String cSubscriptions = 'subscriptions';
  static const String cNotifications = 'notifications';
  static const String cAmandaMessages = 'amanda_messages';

  // ---- Gamificação (regras de negócio) ----
  static const int xpPerCheckin = 50;
  static const int xpPerWorkout = 50;
  static const int xpPerRun = 70;
  static const int xpPerHabit = 10;
  static const int xpPerLevel = 1000;

  // Moedas da Loja de Recompensas (ganhas ao concluir ações).
  static const int coinsPerWorkout = 20;
  static const int coinsPerCheckin = 15;
  static const int coinsPerRun = 25;
  static const int coinsPerGoal = 50;
  static const int coinsPerChallenge = 40;

  // ---- Amanda IA ----
  /// Endpoint da Cloud Function que faz proxy para a OpenAI.
  /// A chave da OpenAI NUNCA deve ficar no app cliente.
  static const String amandaFunctionUrl =
      'https://us-central1-SEU-PROJETO.cloudfunctions.net/amandaChat';

  // ---- Calculadora de calorias por foto ----
  /// Endpoint da Cloud Function que faz proxy para a OpenAI Vision.
  /// Mesma lógica da Amanda: a chave da OpenAI nunca fica no app.
  static const String calorieVisionFunctionUrl =
      'https://us-central1-SEU-PROJETO.cloudfunctions.net/calorieVision';

  // ---- Resgate de cupons ----
  /// Endpoint da Cloud Function que valida e credita cupons com segurança
  /// (exige token de autenticação — ver `functions/src/index.js`).
  static const String redeemCouponFunctionUrl =
      'https://us-central1-SEU-PROJETO.cloudfunctions.net/redeemCoupon';

  // ---- Streaming de vídeo ----
  /// Endpoint da Cloud Function que resolve a URL real de streaming,
  /// validando acesso Premium no servidor (a URL nunca fica exposta no
  /// Firestore público). Ver `docs/ARQUITETURA_STREAMING.md`.
  static const String getVideoUrlFunctionUrl =
      'https://us-central1-SEU-PROJETO.cloudfunctions.net/getVideoUrl';

  // ---- Biblioteca (e-books, cursos) ----
  /// Endpoint genérico que resolve arquivos protegidos por Premium —
  /// reutilizado por e-books e cursos (evita uma function por tipo).
  static const String getContentUrlFunctionUrl =
      'https://us-central1-SEU-PROJETO.cloudfunctions.net/getContentUrl';

  /// Frase de segurança da Amanda (nunca substitui profissionais).
  static const String amandaDisclaimer =
      'A Amanda é sua motivadora virtual e não substitui médico, '
      'nutricionista ou psicólogo. Procure um profissional quando precisar. 💜';

  // ---- Premium ----
  static const String premiumMonthlyId = 'metodo1dia_monthly';
  static const String premiumYearlyId = 'metodo1dia_yearly';
  static const double premiumMonthlyPrice = 29.90;
  static const double premiumYearlyPrice = 197.00;
}
