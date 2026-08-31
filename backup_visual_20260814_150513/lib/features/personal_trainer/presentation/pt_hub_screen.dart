import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import 'personal_dashboard_screen.dart';
import 'student_home_screen.dart';

/// Ponto de entrada único do módulo — decide automaticamente se mostra a
/// Área do Personal ou a Área do Aluno, com base em `isPersonalTrainer`.
/// Ambas ficam completamente separadas visualmente e funcionalmente a
/// partir daqui.
class PtHubScreen extends ConsumerWidget {
  const PtHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();
    return user.isPersonalTrainer
        ? const PersonalDashboardScreen()
        : const StudentHomeScreen();
  }
}
