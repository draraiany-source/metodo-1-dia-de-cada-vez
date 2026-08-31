import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design_system/app_breakpoints.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_bottom_nav.dart';

/// Shell responsivo:
/// - Mobile: bottom navigation (pílula)
/// - Tablet/Desktop: NavigationRail lateral (não estica a barra inferior)
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final current = indexForLocation(location);
    final side = context.useSideNav;

    if (!side) {
      return Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: PremiumBottomNav(
          currentIndex: current < 0 ? 0 : current,
          onTap: (i) => context.go(kMainTabs[i].route),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _StudentSideNav(
            currentIndex: current < 0 ? 0 : current,
            onTap: (i) => context.go(kMainTabs[i].route),
            extended: context.isDesktopLayout,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _StudentSideNav extends StatelessWidget {
  const _StudentSideNav({
    required this.currentIndex,
    required this.onTap,
    required this.extended,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: extended,
      backgroundColor: AppColors.surface,
      selectedIndex: currentIndex.clamp(0, kMainTabs.length - 1),
      onDestinationSelected: onTap,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      selectedIconTheme: const IconThemeData(color: Colors.white),
      unselectedIconTheme:
          IconThemeData(color: AppColors.textSecondary.withOpacity(0.75)),
      selectedLabelTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.textSecondary.withOpacity(0.85),
        fontSize: 12,
      ),
      indicatorColor: AppColors.secondary.withOpacity(0.35),
      minWidth: 72,
      minExtendedWidth: 200,
      leading: Padding(
        padding: EdgeInsets.only(
          top: 16,
          bottom: 12,
          left: extended ? 12 : 0,
          right: extended ? 12 : 0,
        ),
        child: extended
            ? const Text(
                'Método 1 Dia',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              )
            : Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.vibeGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 18),
              ),
      ),
      destinations: [
        for (final tab in kMainTabs)
          NavigationRailDestination(
            icon: Icon(tab.fallback),
            selectedIcon: Icon(tab.fallback),
            label: Text(tab.label),
          ),
      ],
    );
  }
}
