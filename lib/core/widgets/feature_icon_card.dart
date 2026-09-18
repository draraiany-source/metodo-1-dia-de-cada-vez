import 'package:flutter/material.dart';

import '../design_system/app_spacing.dart';
import '../services/feedback_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_icon_image.dart';

enum FeatureIconCardVariant {
  /// Cards principais da grade (ícone 72–96).
  primary,

  /// Cards secundários (ícone 48–64).
  compact,

  /// Linha de lista (ícone 36–48).
  list,

  /// Atalho pequeno (ícone 28–36).
  shortcut,
}

/// Card padronizado do módulo Personal / Consultoria / IA.
///
/// Ícone 1:1 com [BoxFit.contain] — sem clip no PNG, para não cortar o brilho neon.
class FeatureIconCard extends StatelessWidget {
  const FeatureIconCard({
    super.key,
    required this.icon,
    required this.title,
    this.onPress,
    this.subtitle,
    this.disabled = false,
    this.badge,
    this.iconSize,
    this.variant = FeatureIconCardVariant.primary,
    this.semanticLabel,
    this.accent = AppColors.secondary,
    this.fallbackIcon = Icons.image_not_supported_outlined,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onPress;
  final bool disabled;
  final String? badge;
  final double? iconSize;
  final FeatureIconCardVariant variant;
  final String? semanticLabel;
  final Color accent;
  final IconData fallbackIcon;

  double get _resolvedIconSize {
    if (iconSize != null) return iconSize!;
    return switch (variant) {
      FeatureIconCardVariant.primary => 80,
      FeatureIconCardVariant.compact => 56,
      FeatureIconCardVariant.list => 40,
      FeatureIconCardVariant.shortcut => 32,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tappable = !disabled && onPress != null;
    final label = semanticLabel ??
        (subtitle == null ? title : '$title. $subtitle');
    final content = switch (variant) {
      FeatureIconCardVariant.list || FeatureIconCardVariant.shortcut =>
        _ListBody(
          icon: icon,
          title: title,
          subtitle: subtitle,
          badge: badge,
          iconSize: _resolvedIconSize,
          accent: accent,
          fallbackIcon: fallbackIcon,
          showChevron: tappable,
        ),
      _ => _GridBody(
          icon: icon,
          title: title,
          subtitle: subtitle,
          badge: badge,
          iconSize: _resolvedIconSize,
          accent: accent,
          fallbackIcon: fallbackIcon,
          showChevron: tappable,
        ),
    };

    return Semantics(
      button: tappable,
      enabled: tappable,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: tappable
              ? () {
                  FeedbackService.play(FeedbackEvent.toqueLeve);
                  onPress!();
                }
              : null,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.softCardGradient,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: accent.withValues(alpha: 0.28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: accent.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Opacity(opacity: disabled ? 0.45 : 1, child: content),
          ),
          ),
        ),
      ),
    );
  }
}

class _GridBody extends StatelessWidget {
  const _GridBody({
    required this.icon,
    required this.title,
    required this.iconSize,
    required this.accent,
    required this.fallbackIcon,
    this.subtitle,
    this.badge,
    this.showChevron = true,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final double iconSize;
  final Color accent;
  final IconData fallbackIcon;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconWell(
                icon: icon,
                size: iconSize,
                accent: accent,
                fallbackIcon: fallbackIcon,
                title: title,
              ),
              const Spacer(),
              if (badge != null) _Badge(text: badge!),
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title().copyWith(fontSize: 14),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption().copyWith(fontSize: 11.5, height: 1.3),
            ),
          ],
        ],
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.icon,
    required this.title,
    required this.iconSize,
    required this.accent,
    required this.fallbackIcon,
    this.subtitle,
    this.badge,
    this.showChevron = true,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final double iconSize;
  final Color accent;
  final IconData fallbackIcon;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          _IconWell(
            icon: icon,
            size: iconSize,
            accent: accent,
            fallbackIcon: fallbackIcon,
            title: title,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title().copyWith(fontSize: 14),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption()
                        .copyWith(fontSize: 11.5, height: 1.3),
                  ),
                ],
              ],
            ),
          ),
          if (badge != null) ...[
            _Badge(text: badge!),
            const SizedBox(width: 4),
          ],
          if (showChevron)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
        ],
      ),
    );
  }
}

/// Quadrado 1:1 com padding interno — o PNG não é recortado.
class _IconWell extends StatelessWidget {
  const _IconWell({
    required this.icon,
    required this.size,
    required this.accent,
    required this.fallbackIcon,
    required this.title,
  });

  final String icon;
  final double size;
  final Color accent;
  final IconData fallbackIcon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final well = size + 16;
    return SizedBox(
      width: well,
      height: well,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: AppIconImage(
            icon,
            size: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            fallbackIcon: fallbackIcon,
            semanticLabel: title,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Duas colunas iguais — mobile-first, sem esticar ícones.
class FeatureIconPair extends StatelessWidget {
  const FeatureIconPair({
    super.key,
    required this.left,
    required this.right,
    this.spacing = 10,
  });

  final Widget left;
  final Widget right;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: spacing),
        Expanded(child: right),
      ],
    );
  }
}
