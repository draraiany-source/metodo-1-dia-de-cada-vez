import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets/app_icons.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import 'app_icon_image.dart';

class NavTabItem {
  final String route;
  final String iconAsset;
  final IconData fallback;
  final String label;
  const NavTabItem(this.route, this.iconAsset, this.fallback, this.label);
}

const kMainTabs = <NavTabItem>[
  NavTabItem(Routes.home, AppIcons.home, Icons.home_rounded, 'Início'),
  NavTabItem(Routes.workouts, AppIcons.workout, Icons.fitness_center_rounded,
      'Treinos'),
  NavTabItem(
      Routes.recipes, AppIcons.recipes, Icons.restaurant_rounded, 'Receitas'),
  NavTabItem(Routes.evolution, AppIcons.progress, Icons.trending_up_rounded,
      'Evolução'),
  NavTabItem(Routes.profile, AppIcons.profile, Icons.person_rounded, 'Perfil'),
];

int indexForLocation(String location) {
  final i = kMainTabs.indexWhere((t) => location.startsWith(t.route));
  return i < 0 ? -1 : i;
}

/// Bottom nav flutuante — mobile.
class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.tabs = kMainTabs,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavTabItem> tabs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / tabs.length;
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              if (currentIndex >= 0)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: slotWidth * currentIndex,
                  width: slotWidth,
                  top: 10,
                  bottom: 10,
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.heroPinkGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  for (int i = 0; i < tabs.length; i++)
                    SizedBox(
                      width: slotWidth,
                      child: InkWell(
                        onTap: () {
                          if (i != currentIndex) {
                            HapticFeedback.selectionClick();
                          }
                          onTap(i);
                        },
                        customBorder: const CircleBorder(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIconImage(
                              tabs[i].iconAsset,
                              size: 30,
                              fallbackIcon: tabs[i].fallback,
                              semanticLabel: tabs[i].label,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tabs[i].label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: i == currentIndex
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: i == currentIndex
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
