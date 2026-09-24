import 'package:flutter/material.dart';

import '../auth/staff_sign_out_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_navigation.dart';

/// AppBar premium com voltar confiável (pilha + hub do perfil).
///
/// Em raízes de perfil (`isRoleRoot: true`) o Voltar fica oculto — o Android
/// back é tratado por [PopScope] nas telas raiz (não abre outro perfil).
///
/// Use [showStaffSignOut] em telas Admin/Personal/CMS para Sair sempre visível
/// (ícone compacto), além das actions específicas da tela.
class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PremiumAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.isRoleRoot = false,
    this.centerTitle = false,
    this.showStaffSignOut = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final bool isRoleRoot;
  final bool centerTitle;

  /// Inclui [StaffSignOutButton] compacto à direita (Admin/Personal/CMS).
  final bool showStaffSignOut;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final showLeading = showBack && !isRoleRoot;
    final mergedActions = <Widget>[
      ...?actions,
      if (showStaffSignOut) const StaffSignOutButton(compact: true),
    ];

    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: showLeading
          ? IconButton(
              tooltip: 'Voltar',
              onPressed: () => AppNavigation.back(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Colors.white,
              ),
            )
          : null,
      title: Text(
        title,
        style: AppTextStyles.h3().copyWith(fontSize: 18),
      ),
      actions: mergedActions.isEmpty ? null : mergedActions,
    );
  }
}
