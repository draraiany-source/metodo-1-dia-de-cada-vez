import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

/// Navegação segura — evita pilha quebrada e telas sem voltar.
class AppNavigation {
  AppNavigation._();

  /// Volta à tela anterior real (Navigator ou GoRouter).
  /// Só cai na Home se realmente não houver pilha.
  static void back(BuildContext context) {
    final nav = Navigator.maybeOf(context);
    if (nav != null && nav.canPop()) {
      nav.pop();
      return;
    }
    try {
      if (GoRouter.of(context).canPop()) {
        context.pop();
        return;
      }
    } catch (_) {}
    try {
      context.go(Routes.home);
    } catch (_) {
      nav?.maybePop();
    }
  }

  /// Abre tela interna empilhada (permite voltar).
  static Future<T?> open<T extends Object?>(
    BuildContext context,
    String location, {
    Object? extra,
  }) {
    return context.push<T>(location, extra: extra);
  }

  /// Troca aba do shell (substitui rota da aba — comportamento esperado do menu).
  static void switchTab(BuildContext context, String location) {
    context.go(location);
  }

  /// Rotas principais do shell (bottom nav / sidebar).
  static bool isShellTab(String location) {
    const tabs = {
      Routes.home,
      Routes.workouts,
      Routes.recipes,
      Routes.evolution,
      Routes.profile,
    };
    return tabs.any((t) => location == t || location.startsWith('$t/'));
  }
}
