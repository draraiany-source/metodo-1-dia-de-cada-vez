import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/user_role.dart';
import 'app_router.dart';

/// Navegação segura — evita pilha quebrada e cruzamento de perfis no Voltar.
class AppNavigation {
  AppNavigation._();

  /// Hub (tela inicial do papel) para o [path] atual.
  ///
  /// Personal em rotas `/admin/*` da whitelist volta para a Central da Personal,
  /// nunca para a Home da Aluna.
  static String hubForPath(String path) {
    if (path == Routes.admin ||
        path == Routes.adminUsers ||
        path == Routes.adminSubscriptions ||
        path == Routes.couponsAdmin) {
      return Routes.admin;
    }
    if (path.startsWith('/admin')) {
      if (isPersonalAllowedAdminPath(path)) {
        return Routes.personalTrainer;
      }
      return Routes.admin;
    }
    if (path == Routes.personalTrainer ||
        path.startsWith('${Routes.personalTrainer}/') ||
        path == Routes.painelPersonal ||
        path.startsWith('${Routes.painelPersonal}/')) {
      return Routes.personalTrainer;
    }
    return Routes.home;
  }

  /// `true` se [path] é a raiz do perfil (não deve “voltar” para outro papel).
  static bool isRoleRootPath(String path) {
    return path == Routes.home ||
        path == Routes.personalTrainer ||
        path == Routes.admin ||
        path == Routes.login ||
        path == Routes.splash ||
        path == Routes.onboarding;
  }

  /// Volta à tela anterior real (Navigator ou GoRouter).
  ///
  /// Se não houver pilha: vai ao hub do perfil atual.
  /// Se já estiver na raiz do perfil: **não faz nada** (não abre outro perfil).
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

    String path;
    try {
      path = GoRouterState.of(context).uri.path;
    } catch (_) {
      return;
    }

    if (isRoleRootPath(path)) {
      return;
    }

    final hub = hubForPath(path);
    if (path == hub) return;
    try {
      context.go(hub);
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
