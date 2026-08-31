import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_navigation.dart';

/// AppBar premium com voltar confiável (pilha + fallback Home).
class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PremiumAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.centerTitle = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final navCanPop = Navigator.maybeOf(context)?.canPop() == true;
    final routerCanPop = _safeRouterCanPop(context);
    final canPop = navCanPop || routerCanPop;
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              tooltip: 'Voltar',
              onPressed: () => AppNavigation.back(context),
              icon: Icon(
                canPop
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.home_rounded,
                size: 20,
                color: Colors.white,
              ),
            )
          : null,
      title: Text(
        title,
        style: AppTextStyles.h3().copyWith(fontSize: 18),
      ),
      actions: actions,
    );
  }

  static bool _safeRouterCanPop(BuildContext context) {
    try {
      return GoRouter.of(context).canPop();
    } catch (_) {
      return false;
    }
  }
}
