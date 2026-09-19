import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/user_role.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import 'personal_dashboard_screen.dart';
import 'student_home_screen.dart';

/// Ponto de entrada único do módulo — decide pela [resolveUserRole],
/// não por uma flag isolada.
class PtHubScreen extends ConsumerWidget {
  const PtHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final role = resolveUserRole(
      isPersonalTrainer: user.isPersonalTrainer,
      isAdmin: user.isAdmin,
    );
    return RolePermissions.of(role).canOpenPersonalCentral
        ? const PersonalDashboardScreen()
        : const StudentHomeScreen();
  }
}
