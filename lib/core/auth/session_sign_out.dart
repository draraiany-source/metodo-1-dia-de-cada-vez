import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../router/app_router.dart';

/// Logout único para Aluno, Personal e Admin.
///
/// Limpa Auth, sessão local, visitante e o cache do stream de perfil,
/// depois vai para o login sem empilhar tela autenticada.
Future<void> signOutAndGoToLogin(BuildContext context, WidgetRef ref) async {
  await ref.read(authRepositoryProvider).signOut();
  ref.read(localSessionProvider.notifier).clear();
  await ref.read(guestSessionProvider.notifier).exit();
  ref.invalidate(authStateProvider);
  if (!context.mounted) return;
  context.go(Routes.login);
}
