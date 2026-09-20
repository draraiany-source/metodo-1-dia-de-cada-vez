import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../assets/app_icons.dart';
import '../design_system/app_breakpoints.dart';
import '../router/app_router.dart';
import '../widgets/app_icon_image.dart';
import '../widgets/premium_bottom_nav.dart';
import '../widgets/premium_ui.dart';
import 'app_navigation.dart';

/// Shell responsivo: bottom nav (mobile) / sidebar premium (tablet+desktop).
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final current = indexForLocation(location);
    final side = context.useSideNav;
    final user = ref.watch(currentUserProvider);

    if (!side) {
      return Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: child,
        bottomNavigationBar: PremiumBottomNav(
          currentIndex: current,
          onTap: (i) => AppNavigation.switchTab(context, kMainTabs[i].route),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          DesktopSidebar(
            currentIndex: current,
            onTap: (i) => AppNavigation.switchTab(context, kMainTabs[i].route),
            extended: context.isDesktopLayout,
            userName: (user?.name.isNotEmpty ?? false) ? user!.name : 'Aluna',
            isPremium: user?.isPremium ?? false,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Menu lateral desktop — LILY FIT + abas + premium CTA.
class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.extended = true,
    this.userName = 'Aluna',
    this.isPremium = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended;
  final String userName;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final width = extended ? 248.0 : 84.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDeep,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  extended ? 16 : 10,
                  20,
                  extended ? 16 : 10,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (extended) ...[
                      Text('LILY FIT',
                          style: AppTextStyles.h2(color: AppColors.secondary)),
                      const SizedBox(height: 2),
                      Text(
                        'MÉTODO 1 DIA DE CADA VEZ',
                        style: AppTextStyles.caption().copyWith(
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ] else
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroPinkGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'LF',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                    for (var i = 0; i < kMainTabs.length; i++) ...[
                      _SideItem(
                        tab: kMainTabs[i],
                        selected: i == currentIndex,
                        extended: extended,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTap(i);
                        },
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (extended) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Text(
                          'ATALHOS',
                          style: AppTextStyles.caption().copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      _SideLink(
                        iconAsset: AppIcons.gps,
                        fallback: Icons.directions_run_rounded,
                        label: 'Corrida GPS',
                        onTap: () => context.push(Routes.running),
                      ),
                      const SizedBox(height: 4),
                      _SideLink(
                        iconAsset: AppIcons.calendar,
                        fallback: Icons.calendar_month_rounded,
                        label: 'Meu Plano',
                        onTap: () => context.push(Routes.plan),
                      ),
                      const SizedBox(height: 4),
                      _SideLink(
                        iconAsset: AppIcons.favorites,
                        fallback: Icons.bookmark_rounded,
                        label: 'Favoritos',
                        onTap: () => context.push(Routes.favorites),
                      ),
                      const SizedBox(height: 4),
                      _SideLink(
                        iconAsset: AppIcons.settings,
                        fallback: Icons.settings_rounded,
                        label: 'Configurações',
                        onTap: () => context.push(Routes.settings),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (extended) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(extended ? 16 : 10, 0, extended ? 16 : 10, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SidebarPremiumCard(
                      onTap: () => context.push(Routes.premium),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.surface2,
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption(color: Colors.white)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                isPremium ? 'Membro Premium' : 'Plano gratuito',
                                style: AppTextStyles.caption(
                                  color: isPremium
                                      ? AppColors.secondary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SidebarPremiumCard extends StatelessWidget {
  const _SidebarPremiumCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppIconImage(
                    AppIcons.premium,
                    size: 28,
                    fallbackIcon: Icons.workspace_premium_rounded,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'LILY FIT PREMIUM',
                      style: AppTextStyles.caption(color: Colors.white)
                          .copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Desbloqueie conteúdos exclusivos, planos personalizados e acompanhe sua transformação.',
                style: AppTextStyles.caption(color: Colors.white)
                    .copyWith(fontSize: 11.5, height: 1.35),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'CONHECER PREMIUM',
                  style: AppTextStyles.caption(color: AppColors.primaryDark)
                      .copyWith(fontWeight: FontWeight.w900, fontSize: 11.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideLink extends StatelessWidget {
  const _SideLink({
    required this.iconAsset,
    required this.fallback,
    required this.label,
    required this.onTap,
  });

  final String iconAsset;
  final IconData fallback;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              AppIconImage(
                iconAsset,
                size: 26,
                fallbackIcon: fallback,
                semanticLabel: label,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption(color: AppColors.textSecondary)
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideItem extends StatefulWidget {
  const _SideItem({
    required this.tab,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final NavTabItem tab;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  State<_SideItem> createState() => _SideItemState();
}

class _SideItemState extends State<_SideItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: widget.extended ? 12 : 0,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              gradient: selected ? AppColors.sidebarActiveGradient : null,
              color: !selected && _hover ? AppColors.surface2 : null,
              borderRadius: BorderRadius.circular(14),
              border: selected
                  ? Border.all(color: AppColors.secondary.withOpacity(0.35))
                  : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.18),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: widget.extended
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                AppIconImage(
                  widget.tab.iconAsset,
                  size: 36,
                  fallbackIcon: widget.tab.fallback,
                  semanticLabel: widget.tab.label,
                ),
                if (widget.extended) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.tab.label,
                      style: AppTextStyles.title().copyWith(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
