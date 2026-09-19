import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/mascot/mascot_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../auth/providers/auth_providers.dart';

/// Splash inicial — mostra logo animada e decide a próxima rota:
/// onboarding (1ª vez), home (logada) ou login.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _decideNext();
  }

  Future<void> _decideNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(AppConstants.kOnboardingDone) ?? false;
    final isGuest = prefs.getBool(AppConstants.kGuestMode) ?? false;
    final user = ref.read(currentUserProvider);

    if (!mounted) return;
    if (!onboardingDone) {
      context.go(Routes.onboarding);
    } else if (user != null || isGuest) {
      if (user != null && !isGuest) {
        context.go(homePathForUser(
          isPersonalTrainer: user.isPersonalTrainer,
          isAdmin: user.isAdmin,
        ));
      } else {
        context.go(Routes.home);
      }
    } else {
      context.go(Routes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    // Lily grande na abertura (~48% da tela), sem cortar e sem overflow.
    final lilyH = (h * 0.48).clamp(MascotSizes.auth, MascotSizes.showcaseMax);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.05).animate(
                  CurvedAnimation(
                      parent: _controller, curve: Curves.easeInOut),
                ),
                child: PopIn(
                  child: AnimatedLiliMascot(
                      pose: MascotePose.boasVindas,
                      mood: LiliMood.viva,
                      height: lilyH,
                      fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Um dia de cada vez',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
