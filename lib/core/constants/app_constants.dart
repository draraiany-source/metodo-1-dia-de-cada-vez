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
  /// a Home sem precisar criar conta. `false` em builds de produção —
  /// exige cadastro/login real.
  static const bool enableGuestMode = false;

  /// Auditoria/teste: quando `true`, TODO o conteúdo Premium fica liberado
  /// no app inteiro (vídeos, e-books, cursos, IA, etc.), sem precisar
  /// assinar. OBRIGATÓRIO `false` em release — caso contrário o paywall
  /// não funciona e todo conteúdo pago fica grátis.
  static const bool debugUnlockAllPremiumContent = false;

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
  static const String cWeeklyChallenges = 'weekly_challenges';
  static const String cWeeklyChallengeProgress = 'weekly_challenge_progress';
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
  static const int xpPerWeeklyChallenge = 120;
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
      'https://us-central1-metodo1dia-app.cloudfunctions.net/amandaChat';

  // ---- Calculadora de calorias por foto ----
  /// Endpoint da Cloud Function que faz proxy para a OpenAI Vision.
  /// Mesma lógica da Amanda: a chave da OpenAI nunca fica no app.
  static const String calorieVisionFunctionUrl =
      'https://us-central1-metodo1dia-app.cloudfunctions.net/calorieVision';

  // ---- Resgate de cupons ----
  /// Endpoint da Cloud Function que valida e credita cupons com segurança
  /// (exige token de autenticação — ver `functions/src/index.js`).
  static const String redeemCouponFunctionUrl =
      'https://us-central1-metodo1dia-app.cloudfunctions.net/redeemCoupon';

  // ---- Streaming de vídeo ----
  /// Endpoint da Cloud Function que resolve a URL real de streaming,
  /// validando acesso Premium no servidor (a URL nunca fica exposta no
  /// Firestore público). Ver `docs/ARQUITETURA_STREAMING.md`.
  static const String getVideoUrlFunctionUrl =
      'https://us-central1-metodo1dia-app.cloudfunctions.net/getVideoUrl';

  // ---- Biblioteca (e-books, cursos) ----
  /// Endpoint genérico que resolve arquivos protegidos por Premium —
  /// reutilizado por e-books e cursos (evita uma function por tipo).
  static const String getContentUrlFunctionUrl =
      'https://us-central1-metodo1dia-app.cloudfunctions.net/getContentUrl';

  static const String accompanimentAiFunctionUrl =
      'https://us-central1-metodo1dia-app.cloudfunctions.net/accompanimentAi';

  static const String googleCalendarFunctionUrl =
      'https://us-central1-metodo1dia-app.cloudfunctions.net/googleCalendar';

  /// Gestão de contas (criar / bloquear) — só Admin Técnico.
  static const String adminManageUserFunctionUrl =
      'https://us-central1-metodo1dia-app.cloudfunctions.net/adminManageUser';

  /// Frase de segurança da Amanda (nunca substitui profissionais).
  static const String amandaDisclaimer =
      'A Amanda é sua motivadora virtual e não substitui médico, '
      'nutricionista ou psicólogo. Procure um profissional quando precisar. 💜';

  // ---- Premium (IDs canônicos em AppConfig; preços de catálogo / vitrine) ----
  /// Legado — preferir [AppConfig.productMonthly].
  static const String premiumMonthlyId = 'metodo1dia_premium_mensal';
  static const String premiumQuarterlyId = 'metodo1dia_premium_trimestral';
  static const String premiumYearlyId = 'metodo1dia_premium_anual';

  /// Preços de vitrine (BRL). A loja manda quando [PAYMENTS_ENABLED] estiver true.
  static const double premiumMonthlyPrice = 199.00;
  static const double premiumQuarterlyPrice = 399.00;
  static const double premiumYearlyPrice = 1490.00;

  /// Equivalente mensal do trimestral: 399 / 3 = 133,00
  static const double premiumQuarterlyEquivalentMonthly =
      premiumQuarterlyPrice / 3;

  /// Equivalente mensal do anual: 1490 / 12 ≈ 124,166… → exibir R$ 124,17
  static const double premiumYearlyEquivalentMonthly = 124.17;

  /// Economia vs pagar mensal no mesmo período.
  static const double premiumQuarterlySavingsVsMonthly =
      (premiumMonthlyPrice * 3) - premiumQuarterlyPrice; // 198,00
  static const double premiumYearlySavingsVsMonthly =
      (premiumMonthlyPrice * 12) - premiumYearlyPrice; // 898,00

  /// Endpoint que inicia o teste grátis de 7 dias (Admin SDK).
  static const String startFreeTrialFunctionUrl =
      'https://us-central1-metodo1dia-app.cloudfunctions.net/startFreeTrial';
}
