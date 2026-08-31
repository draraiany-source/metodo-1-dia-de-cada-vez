import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_icon_image.dart';

export '../theme/app_colors.dart';
export '../theme/app_theme.dart' show AppTextStyles, AppTheme;

/// Card grafite padrão do app.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glow = false,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool glow;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? AppTheme.radius;
    final box = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.softCardGradient,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(
          color: glow
              ? AppColors.secondary.withOpacity(0.28)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.42),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
          if (glow)
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.22),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        borderRadius: BorderRadius.circular(r),
        child: box,
      ),
    );
  }
}

/// Botão principal rosa/magenta.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconAsset,
    this.expand = true,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  /// PNG premium (ex.: [AppIcons.play]) — preferido quando existir asset.
  final String? iconAsset;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Widget? leading = iconAsset != null
        ? AppIconImage(
            iconAsset!,
            size: 20,
            fallbackIcon: icon ?? Icons.circle,
          )
        : (icon != null
            ? Icon(icon, size: 20, color: Colors.white)
            : null);
    final child = leading == null
        ? Text(label, style: AppTextStyles.button())
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.button()),
            ],
          );

    final btn = DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.heroPinkGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: SizedBox(
            height: height,
            width: expand ? double.infinity : null,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: expand ? 16 : 22),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    if (onPressed == null) {
      return Opacity(opacity: 0.45, child: btn);
    }
    return btn;
  }
}

/// Cabeçalho de seção com ação opcional.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.h3()),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.caption(color: AppColors.secondary).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

/// Métrica compacta (resumo do dia / evolução).
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.iconAsset,
    this.progress,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? iconAsset;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: iconAsset != null
                ? AppIconImage(
                    iconAsset!,
                    size: 32,
                    fallbackIcon: icon,
                    semanticLabel: label,
                  )
                : Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: 10),
          Text(label, style: AppTextStyles.caption()),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title().copyWith(fontSize: 14),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress!.clamp(0, 1),
                minHeight: 4,
                backgroundColor: AppColors.surface2,
                color: accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card de progresso circular (meta / consistência).
class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.percent,
    this.subtitle,
    this.accent = AppColors.secondary,
  });

  final String title;
  final double percent;
  final String? subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0.0, 1.0);
    return AppCard(
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: p,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surface2,
                  color: accent,
                ),
                Text(
                  '${(p * 100).round()}%',
                  style: AppTextStyles.caption(color: accent).copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title()),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: AppTextStyles.bodySecondary()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dica individual da Lily.
class LilyTip {
  const LilyTip({required this.title, required this.body});
  final String title;
  final String body;
}

/// Card “Dicas da Lily” — lateral no desktop, inferior no mobile.
class LilyTipsCard extends StatelessWidget {
  const LilyTipsCard({
    super.key,
    required this.tips,
    this.title = 'Dicas da Lily',
  });

  final List<LilyTip> tips;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.h3())),
              const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          for (final tip in tips) ...[
            Text(tip.title, style: AppTextStyles.title(color: AppColors.secondary)),
            const SizedBox(height: 2),
            Text(tip.body, style: AppTextStyles.bodySecondary()),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Estatística vertical simples.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.accent = AppColors.secondary,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 8),
          ],
          Text(value, style: AppTextStyles.title().copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(),
          ),
        ],
      ),
    );
  }
}
