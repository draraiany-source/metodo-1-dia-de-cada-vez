import 'package:flutter/material.dart';

import '../assets/app_icons.dart';
import 'app_icon_image.dart';

/// Tamanhos padronizados dos ícones 3D premium.
enum PremiumIconSize {
  /// Menu / chrome — ~28–32
  nav(30),

  /// Cards compactos — 40–52
  card(46),

  /// Destaque em hero / feature — 56–64
  highlight(60),

  /// Cards de treino — 90–110
  workout(100);

  const PremiumIconSize(this.px);
  final double px;
}

/// Ícone de feature 3D com proporção fixa e [BoxFit.contain].
/// Sem fundo branco, sem moldura — só o PNG transparente.
class PremiumFeatureIcon extends StatelessWidget {
  const PremiumFeatureIcon(
    this.assetPath, {
    super.key,
    this.size = PremiumIconSize.card,
    this.customSize,
    this.fallbackIcon = Icons.image_outlined,
    this.semanticLabel,
    this.padding = 4,
  });

  final String assetPath;
  final PremiumIconSize size;
  final double? customSize;
  final IconData fallbackIcon;
  final String? semanticLabel;
  final double padding;

  /// Atalhos semânticos.
  factory PremiumFeatureIcon.home({PremiumIconSize size = PremiumIconSize.nav}) =>
      PremiumFeatureIcon(AppIcons.home, size: size, fallbackIcon: Icons.home_rounded, semanticLabel: 'Início');
  factory PremiumFeatureIcon.workout({PremiumIconSize size = PremiumIconSize.card}) =>
      PremiumFeatureIcon(AppIcons.workout, size: size, fallbackIcon: Icons.fitness_center_rounded, semanticLabel: 'Treinos');
  factory PremiumFeatureIcon.recipes({PremiumIconSize size = PremiumIconSize.card}) =>
      PremiumFeatureIcon(AppIcons.recipes, size: size, fallbackIcon: Icons.restaurant_rounded, semanticLabel: 'Receitas');
  factory PremiumFeatureIcon.progress({PremiumIconSize size = PremiumIconSize.card}) =>
      PremiumFeatureIcon(AppIcons.progress, size: size, fallbackIcon: Icons.trending_up_rounded, semanticLabel: 'Evolução');
  factory PremiumFeatureIcon.profile({PremiumIconSize size = PremiumIconSize.nav}) =>
      PremiumFeatureIcon(AppIcons.profile, size: size, fallbackIcon: Icons.person_rounded, semanticLabel: 'Perfil');
  factory PremiumFeatureIcon.water({PremiumIconSize size = PremiumIconSize.card}) =>
      PremiumFeatureIcon(AppIcons.water, size: size, fallbackIcon: Icons.water_drop_rounded, semanticLabel: 'Água');
  factory PremiumFeatureIcon.running({PremiumIconSize size = PremiumIconSize.card}) =>
      PremiumFeatureIcon(AppIcons.running, size: size, fallbackIcon: Icons.directions_run_rounded, semanticLabel: 'Corrida');
  factory PremiumFeatureIcon.calories({PremiumIconSize size = PremiumIconSize.card}) =>
      PremiumFeatureIcon(AppIcons.calories, size: size, fallbackIcon: Icons.local_fire_department_rounded, semanticLabel: 'Calorias');

  @override
  Widget build(BuildContext context) {
    final px = customSize ?? size.px;
    return SizedBox(
      width: px,
      height: px,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: AppIconImage(
          assetPath,
          size: px - padding * 2,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          fallbackIcon: fallbackIcon,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }
}
