import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Card com gradiente da marca — usado em destaques e frase do dia.
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.gradient = AppColors.brandGradient,
    this.padding = const EdgeInsets.all(20),
    this.borderLeft = false,
  });

  final Widget child;
  final Gradient gradient;
  final EdgeInsets padding;
  final bool borderLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: borderLeft
            ? const Border(
                left: BorderSide(color: AppColors.accent, width: 4),
              )
            : null,
      ),
      child: child,
    );
  }
}

/// Cabeçalho de seção reutilizável.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// "Chip" de XP roxo.
class XpBadge extends StatelessWidget {
  const XpBadge({super.key, required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('⚡ $xp XP',
          style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    );
  }
}

/// Badge de recurso premium/gratuito.
class TagBadge extends StatelessWidget {
  const TagBadge.free({super.key})
      : label = '✓ GRATUITO',
        color = AppColors.success;
  const TagBadge.premium({super.key})
      : label = '👑 PREMIUM',
        color = AppColors.warning;

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

/// Placeholder padrão para telas/módulos ainda em construção.
/// Mantém o app compilável e navegável enquanto o módulo é finalizado.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({
    super.key,
    required this.title,
    required this.emoji,
    this.description,
  });

  final String title;
  final String emoji;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              description ??
                  'Módulo com implementação base pronta.\nConteúdo completo em breve.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão de ícone quadrado (appbar).
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({super.key, required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
