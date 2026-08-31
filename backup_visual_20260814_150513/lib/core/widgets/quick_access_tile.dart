import 'package:flutter/material.dart';

import '../design_system/app_spacing.dart';
import '../services/feedback_service.dart';
import '../theme/app_colors.dart';
import 'app_icon_image.dart';

/// Atalho compacto: ícone visível + título + descrição + indicador.
/// Altura controlada — não vira card vazio gigante.
class QuickAccessTile extends StatelessWidget {
  const QuickAccessTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.emoji,
    this.iconAsset,
    this.icon,
    this.accent = AppColors.primary,
    this.trailing,
    this.showChevron = false,
  });

  final String title;
  final String? subtitle;
  final String? emoji;
  final String? iconAsset;
  final IconData? icon;
  final Color accent;
  final String? trailing;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FeedbackService.play(FeedbackEvent.toqueLeve);
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: accent.withOpacity(0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                alignment: Alignment.center,
                child: _buildIcon(),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    trailing!,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withOpacity(0.7),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (iconAsset != null) {
      return AppIconImage(
        iconAsset!,
        size: 24,
        semanticLabel: title,
        fallbackIcon: icon ?? Icons.image_not_supported_outlined,
      );
    }
    if (icon != null) {
      return Icon(icon, color: accent, size: 22);
    }
    return Text(emoji ?? '•', style: const TextStyle(fontSize: 22));
  }
}

/// Tile em grade (ícone em cima, texto embaixo) — compacto para Acessos Rápidos.
class QuickAccessGridTile extends StatelessWidget {
  const QuickAccessGridTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.emoji,
    this.iconAsset,
    this.icon,
    this.accent = AppColors.primary,
  });

  final String title;
  final String? subtitle;
  final String? emoji;
  final String? iconAsset;
  final IconData? icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FeedbackService.play(FeedbackEvent.toqueLeve);
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.35), accent.withOpacity(0.12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: _icon(),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    if (iconAsset != null) {
      return AppIconImage(
        iconAsset!,
        size: 22,
        semanticLabel: title,
        fallbackIcon: icon ?? Icons.image_not_supported_outlined,
      );
    }
    if (icon != null) return Icon(icon, color: Colors.white, size: 20);
    return Text(emoji ?? '•', style: const TextStyle(fontSize: 20));
  }
}
