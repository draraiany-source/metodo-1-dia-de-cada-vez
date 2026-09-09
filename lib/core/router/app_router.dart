import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/workouts/presentation/workouts_screen.dart';
import '../../features/running/presentation/running_screen.dart';
import '../../features/nutrition/presentation/nutrition_screen.dart';
import '../../features/habits/presentation/habits_screen.dart';
import '../../features/evolution/presentation/evolution_screen.dart';
import '../../features/gamification/presentation/gamification_screen.dart';
import '../../features/gamification/presentation/leagues_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/premium/presentation/premium_screen.dart';
import '../../features/amanda/presentation/amanda_screen.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../../features/showcase/presentation/asset_showcase_screen.dart';
import '../../features/diary/presentation/diary_screen.dart';
import '../../features/goals/presentation/goals_screen.dart';
import '../../features/streak/presentation/streak_calendar_screen.dart';
import '../../features/rewards/presentation/rewards_store_screen.dart';
import '../../features/rewards/presentation/daily_chest_screen.dart';
import '../../features/rewards/presentation/rewards_history_screen.dart';
import '../../features/missions/presentation/missions_screen.dart';
import '../../features/plan/presentation/my_plan_screen.dart';
import '../../features/recipes/presentation/recipes_screen.dart';
import '../../features/evolution/presentation/measurements_screen.dart';
import '../../features/evolution/presentation/progress_photos_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/favorites_screen.dart';
import '../../features/profile/presentation/history_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/notification_preferences_screen.dart';
import '../../features/missions/presentation/missions_history_screen.dart';
import '../../features/ai_trainer/presentation/ai_trainer_screen.dart';
import '../../features/ai_trainer/presentation/ai_profile_screen.dart';
import '../../features/health_sync/presentation/health_sync_screen.dart';
import '../../features/nutrition/presentation/calorie_scanner_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/reminders/presentation/reminders_screen.dart';
import '../../features/checkin/presentation/checkin_screen.dart';
import '../../features/audio_courses/presentation/audio_courses_screen.dart';
import '../../features/nutrition/presentation/hydration_screen.dart';
import '../../features/pdf_recipes/presentation/pdf_recipes_screen.dart';
import '../../features/dashboard/presentation/premium_dashboard_screen.dart';
import '../../features/certificates/presentation/certificates_screen.dart';
import '../../features/referral/presentation/referral_screen.dart';
import '../../features/coupons/presentation/coupons_admin_screen.dart';
import '../../features/coupons/presentation/redeem_coupon_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/video_streaming/presentation/videos_screen.dart';
import '../../features/video_streaming/presentation/videos_admin_screen.dart';
import '../../features/personal_amanda/presentation/amanda_profile_screen.dart';
import '../../features/personal_amanda/presentation/amanda_assets_admin_screen.dart';
import '../../features/personal_amanda/presentation/amanda_profile_edit_screen.dart';
import '../../features/mascot_lili/presentation/lili_assets_admin_screen.dart';
import '../../features/personal_trainer/presentation/pt_hub_screen.dart';
import '../../features/nutrition/presentation/food_database_screen.dart';
import '../../features/nutrition/presentation/shopping_list_screen.dart';
import '../../features/nutrition/presentation/nutrition_dashboard_screen.dart';
import '../../features/nutrition/nutrition_routes.dart';
import '../../features/ebooks/presentation/ebooks_screen.dart';
import '../../features/ebooks/presentation/ebooks_admin_screen.dart';
import '../../features/courses/presentation/courses_screen.dart';
import '../../features/audio_courses/presentation/meditations_screen.dart';
import '../../features/audio_courses/presentation/lili_audios_screen.dart';
import '../../features/audio_courses/presentation/audio_courses_admin_screen.dart';
import '../../features/audio_programs/presentation/screens/audios_meditations_hub_screen.dart';
import '../../features/audio_programs/presentation/screens/program_detail_screen.dart';
import '../../features/audio_programs/presentation/screens/program_player_screen.dart';
import '../constants/app_constants.dart';
import '../services/analytics_service.dart';
import 'main_shell.dart';

/// Rotas nomeadas do app.
class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const workouts = '/workouts';
  static const running = '/running';
  static const nutrition = '/nutrition';
  static const habits = '/habits';
  static const evolution = '/evolution';
  static const gamification = '/gamification';
  static const leagues = '/leagues';
  static const community = '/community';
  static const profile = '/profile';
  static const premium = '/premium';
  static const amanda = '/amanda';
  static const admin = '/admin';
  static const showcase = '/showcase';
  static const diary = '/diary';
  static const goals = '/goals';
  static const streak = '/streak';
  static const rewards = '/rewards';
  static const dailyChest = '/rewards/daily-chest';
  static const rewardsHistory = '/rewards/history';
  static const missions = '/missions';
  static const plan = '/plan';
  static const missionsHistory = '/missions/history';
  static const aiTrainer = '/ai-trainer';
  static const aiProfile = '/ai-trainer/profile';
  static const healthSync = '/health-sync';
  static const calorieScanner = '/nutrition/calorie-scanner';
  static const calendar = '/calendar';
  static const reminders = '/reminders';
  static const checkin = '/checkin';
  static const audioCourses = '/audio-courses';
  static const audiosMeditations = '/audios-meditations';
  static const audioProgramDetail = '/audio-programs/:programId';
  static const audioProgramPlayer =
      '/audio-programs/:programId/play/:audioId';
  static const pdfRecipes = '/pdf-recipes';
  static const recipes = '/recipes';
  static const measurements = '/measurements';
  static const progressPhotos = '/progress-photos';
  static const editProfile = '/profile/edit';
  static const favorites = '/favorites';
  static const history = '/history';
  static const settings = '/settings';
  static const notificationPreferences = '/notifications/preferences';
  static const hydration = '/hydration';
  static const dashboard = '/dashboard';
  static const certificates = '/certificates';
  static const referral = '/referral';
  static const couponsAdmin = '/admin/coupons';
  static const redeemCoupon = '/coupons/redeem';
  static const reports = '/reports';
  static const videos = '/videos';
  static const videosAdmin = '/admin/videos';
  static const amandaProfile = '/amanda/perfil';
  static const amandaProfileEdit = '/admin/amanda-profile';
  static const amandaAssetsAdmin = '/admin/amanda-assets';
  static const liliAssetsAdmin = '/admin/lili-assets';
  static const personalTrainer = '/personal-trainer';
  static const foodDatabase = '/nutrition/food-database';
  static const shoppingList = '/nutrition/shopping-list';
  static const nutritionDashboard = NutritionRoutes.dashboard;
  static const ebooks = '/ebooks';
  static const ebooksAdmin = '/admin/ebooks';
  static const courses = '/courses';
  static const meditations = '/meditations';
  static const liliAudios = '/lili-audios';
  static const audioCoursesAdmin = '/admin/audio-courses';
}

/// Provider que indica se o onboarding já foi concluído.
final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(AppConstants.kOnboardingDone) ?? false;
});

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

/// Faz o GoRouter reavaliar o `redirect` sempre que a autenticação (ou o
/// modo visitante) mudar — sem isso, um logout/login feito em outra aba (ou
/// uma sessão do Firebase expirando) só seria refletido na navegação depois
/// de uma troca manual de rota.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Transição premium padrão: fade + leve deslize para cima.
///
/// Aplicada apenas nas telas full-screen. As abas do ShellRoute mantêm troca
/// instantânea (animar a bottom nav deixa o app lento e "borrachudo").
CustomTransitionPage<void> _fadeSlide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  // Reaproveita o stream do authStateProvider (já existente) em vez de
  // abrir um segundo listener em AuthRepository.authState() — evita fazer
  // a leitura do perfil no Firestore duas vezes a cada mudança de sessão.
  final refreshStream = _GoRouterRefreshStream(
    ref.watch(authStateProvider.stream),
  );
  ref.onDispose(refreshStream.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: kDebugMode, // não logar navegação em release
    refreshListenable: refreshStream,
    observers: [
      if (AnalyticsService.observer != null) AnalyticsService.observer!,
    ],
    // ---------------------------------------------------------------
    // Guarda global de navegação.
    //
    // Antes desta função não existia NENHUM redirect no GoRouter. Isso
    // significava que, no Flutter Web, ao atualizar a página (F5) o
    // navegador simplesmente recarregava a URL atual (ex.: "/register")
    // direto — sem passar pela Splash — e como não havia nada checando
    // se aquela rota fazia sentido para o estado da usuária, o app podia
    // "prender" a pessoa na tela de cadastro, ou perder o acesso à Home
    // ao atualizar a página. Esta função elimina esse problema: toda
    // navegação (inclusive o primeiro load/refresh do navegador) passa
    // por aqui e decide se a rota pedida é permitida.
    redirect: (context, state) async {
      final path = state.matchedLocation;

      // A Splash cuida sozinha da decisão inicial (mantém a animação e o
      // pequeno delay). Não interceptamos essa rota aqui.
      if (path == Routes.splash) return null;

      final prefs = await SharedPreferences.getInstance();
      final onboardingDone =
          prefs.getBool(AppConstants.kOnboardingDone) ?? false;
      final isGuest = prefs.getBool(AppConstants.kGuestMode) ?? false;
      final user = ref.read(currentUserProvider);
      final authenticated = user != null || isGuest;

      final isOnboarding = path == Routes.onboarding;
      final isAuthRoute = path == Routes.login || path == Routes.register;

      // 1) Onboarding ainda não visto na primeira vez → sempre onboarding.
      if (!onboardingDone) {
        return isOnboarding ? null : Routes.onboarding;
      }

      // 2) Sem sessão (nem visitante) → só libera telas de autenticação.
      //    IMPORTANTE: nunca força "/register" especificamente — se a rota
      //    pedida não for de auth, manda para "/login" (que tem os botões
      //    Entrar, Criar conta e Entrar como visitante).
      if (!authenticated) {
        return isAuthRoute ? null : Routes.login;
      }

      // 3) Já autenticada (ou visitante) → não deixamos "voltar sozinha"
      //    para onboarding/login/cadastro.
      if (isOnboarding || isAuthRoute) {
        // Personal/Admin entram no painel de gestão — não na Home do aluno.
        if (user != null &&
            (user.isPersonalTrainer || user.isAdmin) &&
            !isGuest) {
          return Routes.personalTrainer;
        }
        return Routes.home;
      }

      // 4) Personal autenticada que caiu na Home do aluno → redireciona.
      if (user != null &&
          (user.isPersonalTrainer || user.isAdmin) &&
          !isGuest &&
          path == Routes.home) {
        return Routes.personalTrainer;
      }

      // 5) Rotas /admin* exigem isAdmin — bloqueia deep-link / URL direta.
      if (path.startsWith('/admin')) {
        if (user == null || !user.isAdmin) {
          if (user != null && user.isPersonalTrainer && !isGuest) {
            return Routes.personalTrainer;
          }
          return Routes.home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        pageBuilder: (_, s) => _fadeSlide(s, const SplashScreen()),
      ),
      GoRoute(
        path: Routes.onboarding,
        pageBuilder: (_, s) => _fadeSlide(s, const OnboardingScreen()),
      ),
      GoRoute(
        path: Routes.login,
        pageBuilder: (_, s) => _fadeSlide(s, const LoginScreen()),
      ),
      GoRoute(
        path: Routes.register,
        pageBuilder: (_, s) => _fadeSlide(s, const RegisterScreen()),
      ),

      // Telas full-screen (fora do shell com bottom nav).
      GoRoute(
        path: Routes.amanda,
        pageBuilder: (_, s) => _fadeSlide(s, const AmandaScreen()),
      ),
      GoRoute(
        path: Routes.amandaProfile,
        pageBuilder: (_, s) => _fadeSlide(s, const AmandaProfileScreen()),
      ),
      GoRoute(
        path: Routes.amandaProfileEdit,
        pageBuilder: (_, s) =>
            _fadeSlide(s, const AmandaProfileEditScreen()),
      ),
      GoRoute(
        path: Routes.amandaAssetsAdmin,
        pageBuilder: (_, s) =>
            _fadeSlide(s, const AmandaAssetsAdminScreen()),
      ),
      GoRoute(
        path: Routes.liliAssetsAdmin,
        pageBuilder: (_, s) => _fadeSlide(s, const LiliAssetsAdminScreen()),
      ),
      GoRoute(
        path: Routes.personalTrainer,
        pageBuilder: (_, s) => _fadeSlide(s, const PtHubScreen()),
      ),
      GoRoute(
        path: Routes.foodDatabase,
        pageBuilder: (_, s) => _fadeSlide(s, const FoodDatabaseScreen()),
      ),
      GoRoute(
        path: Routes.shoppingList,
        pageBuilder: (_, s) => _fadeSlide(s, const ShoppingListScreen()),
      ),
      GoRoute(
        path: NutritionRoutes.dashboard,
        pageBuilder: (_, s) => _fadeSlide(s, const NutritionDashboardScreen()),
      ),
      GoRoute(
        path: Routes.ebooks,
        pageBuilder: (_, s) => _fadeSlide(s, const EbooksScreen()),
      ),
      GoRoute(
        path: Routes.ebooksAdmin,
        pageBuilder: (_, s) => _fadeSlide(s, const EbooksAdminScreen()),
      ),
      GoRoute(
        path: Routes.courses,
        pageBuilder: (_, s) => _fadeSlide(s, const CoursesScreen()),
      ),
      GoRoute(
        path: Routes.meditations,
        pageBuilder: (_, s) => _fadeSlide(s, const MeditationsScreen()),
      ),
      GoRoute(
        path: Routes.liliAudios,
        pageBuilder: (_, s) => _fadeSlide(s, const LiliAudiosScreen()),
      ),
      GoRoute(
        path: Routes.audioCoursesAdmin,
        pageBuilder: (_, s) =>
            _fadeSlide(s, const AudioCoursesAdminScreen()),
      ),
      GoRoute(
        path: Routes.premium,
        pageBuilder: (_, s) => _fadeSlide(s, const PremiumScreen()),
      ),
      GoRoute(
        path: Routes.gamification,
        pageBuilder: (_, s) => _fadeSlide(s, const GamificationScreen()),
      ),
      GoRoute(
        path: Routes.leagues,
        pageBuilder: (_, s) => _fadeSlide(s, const LeaguesScreen()),
      ),
      GoRoute(
        path: Routes.community,
        pageBuilder: (_, s) => _fadeSlide(s, const CommunityScreen()),
      ),
      GoRoute(
        path: Routes.admin,
        pageBuilder: (_, s) => _fadeSlide(s, const AdminScreen()),
      ),
      GoRoute(
        path: Routes.showcase,
        pageBuilder: (_, s) => _fadeSlide(s, const AssetShowcaseScreen()),
      ),
      GoRoute(
        path: Routes.diary,
        pageBuilder: (_, s) => _fadeSlide(s, const DiaryScreen()),
      ),
      GoRoute(
        path: Routes.goals,
        pageBuilder: (_, s) => _fadeSlide(s, const GoalsScreen()),
      ),
      GoRoute(
        path: Routes.streak,
        pageBuilder: (_, s) => _fadeSlide(s, const StreakCalendarScreen()),
      ),
      GoRoute(
        path: Routes.rewards,
        pageBuilder: (_, s) => _fadeSlide(s, const RewardsStoreScreen()),
      ),
      GoRoute(
        path: Routes.dailyChest,
        pageBuilder: (_, s) => _fadeSlide(s, const DailyChestScreen()),
      ),
      GoRoute(
        path: Routes.rewardsHistory,
        pageBuilder: (_, s) => _fadeSlide(s, const RewardsHistoryScreen()),
      ),
      GoRoute(
        path: Routes.missions,
        pageBuilder: (_, s) => _fadeSlide(s, const MissionsScreen()),
      ),
      GoRoute(
        path: Routes.plan,
        pageBuilder: (_, s) => _fadeSlide(s, const MyPlanScreen()),
      ),
      GoRoute(
        path: Routes.measurements,
        pageBuilder: (_, s) => _fadeSlide(s, const MeasurementsScreen()),
      ),
      GoRoute(
        path: Routes.progressPhotos,
        pageBuilder: (_, s) => _fadeSlide(s, const ProgressPhotosScreen()),
      ),
      GoRoute(
        path: Routes.editProfile,
        pageBuilder: (_, s) => _fadeSlide(s, const EditProfileScreen()),
      ),
      GoRoute(
        path: Routes.favorites,
        pageBuilder: (_, s) => _fadeSlide(s, const FavoritesScreen()),
      ),
      GoRoute(
        path: Routes.history,
        pageBuilder: (_, s) => _fadeSlide(s, const HistoryScreen()),
      ),
      GoRoute(
        path: Routes.settings,
        pageBuilder: (_, s) => _fadeSlide(s, const SettingsScreen()),
      ),
      GoRoute(
        path: Routes.notificationPreferences,
        pageBuilder: (_, s) =>
            _fadeSlide(s, const NotificationPreferencesScreen()),
      ),
      GoRoute(
        path: Routes.missionsHistory,
        pageBuilder: (_, s) => _fadeSlide(s, const MissionsHistoryScreen()),
      ),
      GoRoute(
        path: Routes.aiTrainer,
        pageBuilder: (_, s) => _fadeSlide(s, const AiTrainerScreen()),
      ),
      GoRoute(
        path: Routes.aiProfile,
        pageBuilder: (_, s) => _fadeSlide(s, const AiProfileScreen()),
      ),
      GoRoute(
        path: Routes.calorieScanner,
        pageBuilder: (_, s) => _fadeSlide(s, const CalorieScannerScreen()),
      ),
      GoRoute(
        path: Routes.calendar,
        pageBuilder: (_, s) => _fadeSlide(s, const CalendarScreen()),
      ),
      GoRoute(
        path: Routes.reminders,
        pageBuilder: (_, s) => _fadeSlide(s, const RemindersScreen()),
      ),
      GoRoute(
        path: Routes.checkin,
        pageBuilder: (_, s) => _fadeSlide(s, const CheckinScreen()),
      ),
      GoRoute(
        path: Routes.audioCourses,
        pageBuilder: (_, s) => _fadeSlide(s, const AudioCoursesScreen()),
      ),
      GoRoute(
        path: Routes.audiosMeditations,
        pageBuilder: (_, s) =>
            _fadeSlide(s, const AudiosMeditationsHubScreen()),
      ),
      GoRoute(
        path: '/audio-programs/:programId',
        pageBuilder: (_, s) {
          final id = s.pathParameters['programId']!;
          return _fadeSlide(s, ProgramDetailScreen(programId: id));
        },
      ),
      GoRoute(
        path: '/audio-programs/:programId/play/:audioId',
        pageBuilder: (_, s) {
          final programId = s.pathParameters['programId']!;
          final audioId = s.pathParameters['audioId']!;
          return _fadeSlide(
            s,
            ProgramPlayerScreen(programId: programId, audioId: audioId),
          );
        },
      ),
      GoRoute(
        path: Routes.pdfRecipes,
        pageBuilder: (_, s) => _fadeSlide(s, const PdfRecipesScreen()),
      ),
      GoRoute(
        path: Routes.hydration,
        pageBuilder: (_, s) => _fadeSlide(s, const HydrationScreen()),
      ),
      GoRoute(
        path: Routes.dashboard,
        pageBuilder: (_, s) => _fadeSlide(s, const PremiumDashboardScreen()),
      ),
      GoRoute(
        path: Routes.certificates,
        pageBuilder: (_, s) => _fadeSlide(s, const CertificatesScreen()),
      ),
      GoRoute(
        path: Routes.referral,
        pageBuilder: (_, s) => _fadeSlide(s, const ReferralScreen()),
      ),
      GoRoute(
        path: Routes.couponsAdmin,
        pageBuilder: (_, s) => _fadeSlide(s, const CouponsAdminScreen()),
      ),
      GoRoute(
        path: Routes.redeemCoupon,
        pageBuilder: (_, s) => _fadeSlide(s, const RedeemCouponScreen()),
      ),
      GoRoute(
        path: Routes.reports,
        pageBuilder: (_, s) => _fadeSlide(s, const ReportsScreen()),
      ),
      GoRoute(
        path: Routes.videos,
        pageBuilder: (_, s) => _fadeSlide(s, const VideosScreen()),
      ),
      GoRoute(
        path: Routes.videosAdmin,
        pageBuilder: (_, s) => _fadeSlide(s, const VideosAdminScreen()),
      ),
      GoRoute(
        path: Routes.healthSync,
        pageBuilder: (_, s) => _fadeSlide(s, const HealthSyncScreen()),
      ),
      GoRoute(
        path: Routes.running,
        pageBuilder: (_, s) => _fadeSlide(s, const RunningScreen()),
      ),

      // Shell com bottom navigation (5 abas principais).
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.workouts,
            builder: (_, __) => const WorkoutsScreen(),
          ),
          GoRoute(
            path: Routes.recipes,
            builder: (_, __) => const RecipesScreen(),
          ),
          GoRoute(
            path: Routes.evolution,
            builder: (_, __) => const EvolutionScreen(),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: Routes.habits,
            builder: (_, __) => const HabitsScreen(),
          ),
          GoRoute(
            path: Routes.nutrition,
            builder: (_, __) => const NutritionScreen(),
          ),
        ],
      ),
    ],
  );
});
