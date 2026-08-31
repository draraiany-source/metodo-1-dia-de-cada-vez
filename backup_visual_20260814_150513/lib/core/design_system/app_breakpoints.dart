import 'package:flutter/widgets.dart';

/// Breakpoints consistentes do Método 1 Dia.
///
/// Use [AppBreakpoints.of] ou os helpers em [BuildContext] via extensão.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  /// Largura máxima do conteúdo principal no aluno (evita cards esticados).
  static const double contentMaxWidth = 720;

  /// Largura máxima em desktop amplo (home com 2 colunas).
  static const double contentMaxWidthWide = 1100;

  /// Largura do painel administrativo da Personal.
  static const double personalContentMaxWidth = 1280;

  static AppScreenSize of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= tablet) return AppScreenSize.desktop;
    if (w >= mobile) return AppScreenSize.tablet;
    return AppScreenSize.mobile;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == AppScreenSize.mobile;

  static bool isTablet(BuildContext context) =>
      of(context) == AppScreenSize.tablet;

  static bool isDesktop(BuildContext context) =>
      of(context) == AppScreenSize.desktop;

  /// Preferir NavigationRail / Sidebar em vez de BottomNav.
  static bool useSideNav(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobile;
}

enum AppScreenSize { mobile, tablet, desktop }

extension AppBreakpointsX on BuildContext {
  AppScreenSize get screenSize => AppBreakpoints.of(this);
  bool get isMobileLayout => AppBreakpoints.isMobile(this);
  bool get isTabletLayout => AppBreakpoints.isTablet(this);
  bool get isDesktopLayout => AppBreakpoints.isDesktop(this);
  bool get useSideNav => AppBreakpoints.useSideNav(this);

  /// Padding horizontal responsivo (margens laterais adequadas).
  double get pagePaddingH {
    switch (screenSize) {
      case AppScreenSize.mobile:
        return 16;
      case AppScreenSize.tablet:
        return 24;
      case AppScreenSize.desktop:
        return 32;
    }
  }

  /// Colunas para grades de atalho.
  int get quickAccessColumns {
    switch (screenSize) {
      case AppScreenSize.mobile:
        return 2;
      case AppScreenSize.tablet:
        return 3;
      case AppScreenSize.desktop:
        return 4;
    }
  }

  /// Colunas para stats compactos (resumo).
  int get summaryColumns {
    switch (screenSize) {
      case AppScreenSize.mobile:
        return 4;
      case AppScreenSize.tablet:
      case AppScreenSize.desktop:
        return 4;
    }
  }
}
