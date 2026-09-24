import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import 'session_sign_out.dart';

/// Botão visível “Sair da conta” para Personal e Admin.
class StaffSignOutButton extends ConsumerWidget {
  const StaffSignOutButton({
    super.key,
    this.compact = false,
  });

  /// Se true, só ícone (AppBar apertada). Senão, ícone + texto.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (compact) {
      return IconButton(
        tooltip: 'Sair da conta',
        icon: const Icon(Icons.logout, color: AppColors.danger),
        onPressed: () => signOutAndGoToLogin(context, ref),
      );
    }
    return TextButton.icon(
      onPressed: () => signOutAndGoToLogin(context, ref),
      icon: const Icon(Icons.logout, color: AppColors.danger, size: 18),
      label: const Text(
        'Sair da conta',
        style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
      ),
    );
  }
}
