import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets/app_icons.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import 'app_icon_image.dart';

/// Definição de uma aba da navegação inferior — pública para poder ser
/// reaproveitada tanto pelo [MainShell] (rotas do ShellRoute) quanto por
/// telas full-screen fora do shell (ex.: Meu Plano) que precisam mostrar a
/// MESMA barra sem duplicar o layout.
class NavTabItem {
  final String route;
  final String iconAsset;
  final IconData fallback;
  final String label;
  const NavTabItem(this.route, this.iconAsset, this.fallback, this.label);
}

/// As 5 abas principais do app — fonte única de verdade para a barra
/// inferior, usada pelo [MainShell] e por qualquer tela fora do shell que
/// precise exibir a mesma navegação (ex.: Meu Plano).
const kMainTabs = <NavTabItem>[
  NavTabItem(Routes.home, AppIcons.home, Icons.home_rounded, 'Início'),
  NavTabItem(
      Routes.workouts, AppIcons.workout, Icons.fitness_center_rounded,
      'Treinos'),
  NavTabItem(
      Routes.recipes, AppIcons.recipes, Icons.restaurant_rounded, 'Receitas'),
  NavTabItem(
      Routes.evolution, AppIcons.progress, Icons.trending_up_rounded,
      'Evolução'),
  NavTabItem(Routes.profile, AppIcons.profile, Icons.person_rounded, 'Perfil'),
];

int indexForLocation(String location) {
  final i = kMainTabs.indexWhere((t) => location.startsWith(t.route));
  return i < 0 ? -1 : i;
}

/// Barra de navegação inferior premium — pílula flutuante com
/// glassmorphism, indicador que desliza suavemente para a aba ativa e
/// microanimação de escala ao tocar.
class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.tabs = kMainTabs,
  });

  /// -1 quando a tela atual não corresponde a nenhuma das 5 abas (ex.:
  /// telas full-screen empilhadas por cima, como Meu Plano) — nesse caso
  /// nenhum item fica destacado.
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavTabItem> tabs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
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
                  duration: const Duration(milliseconds: 320),
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
                            color: AppColors.secondary.withOpacity(0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
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
                      child: _NavItem(
                        tab: tabs[i],
                        selected: i == currentIndex,
                        onTap: () {
                          if (i != currentIndex) {
                            HapticFeedback.selectionClick();
                          }
                          onTap(i);
                        },
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final NavTabItem tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedScale(
        scale: selected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: selected ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 220),
              child: AppIconImage(
                tab.iconAsset,
                size: 26,
                semanticLabel: tab.label,
                fallbackIcon: tab.fallback,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}
