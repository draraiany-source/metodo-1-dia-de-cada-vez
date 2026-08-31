import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../mascot/mascot_widget.dart';
import '../theme/app_colors.dart';
import '../widgets/lili_widgets.dart' show MascotePose;

/// ============================================================================
/// KIT DE EXPERIÊNCIA PREMIUM (Sprint V36 §2).
///
/// - [AppSnack]           → snackbars modernos (flutuante, ícone, tátil);
/// - [showAppSheet]       → bottom sheet padrão premium (alça, cantos, safe);
/// - [CelebrationOverlay] → celebração de vitória com confete animado,
///                          mascote e feedback tátil (Flutter puro, sem deps).
/// Respeita acessibilidade: com animações desativadas no sistema, o confete
/// é suprimido e a celebração vira um diálogo estático.
/// ============================================================================

class AppSnack {
  AppSnack._();

  static void success(BuildContext context, String message) =>
      _show(context, message, Icons.check_circle_rounded, AppColors.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, Icons.error_rounded, AppColors.danger);

  static void info(BuildContext context, String message) =>
      _show(context, message, Icons.info_rounded, AppColors.info);

  static void _show(
      BuildContext context, String message, IconData icon, Color color) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface2,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(.45)),
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(message,
                  style: AppTypography.body
                      .copyWith(color: AppColors.textPrimary)),
            ),
          ],
        ),
      ));
  }
}

/// Bottom sheet premium padrão: cantos arredondados, alça de arrasto,
/// respeito a teclado/safe area. Retorna o resultado do sheet.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required Widget child,
  bool isScrollControlled = true,
}) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(child: child),
          ],
        ),
      ),
    ),
  );
}

/// Celebração de vitória — conquista, promoção de liga, streak, meta batida.
class CelebrationOverlay {
  CelebrationOverlay._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    MascotePose pose = MascotePose.celebrando,
    String buttonLabel = 'Aê! 🎉',
  }) {
    HapticFeedback.heavyImpact();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Celebração',
      barrierColor: Colors.black.withOpacity(.72),
      transitionDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 260),
      transitionBuilder: (ctx, anim, _, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(anim.value),
        child: Opacity(opacity: anim.value.clamp(0, 1), child: child),
      ),
      pageBuilder: (ctx, _, __) => _CelebrationDialog(
        title: title,
        subtitle: subtitle,
        pose: pose,
        buttonLabel: buttonLabel,
        confetti: !reduceMotion,
      ),
    );
  }
}

class _CelebrationDialog extends StatefulWidget {
  const _CelebrationDialog({
    required this.title,
    required this.subtitle,
    required this.pose,
    required this.buttonLabel,
    required this.confetti,
  });

  final String title;
  final String? subtitle;
  final MascotePose pose;
  final String buttonLabel;
  final bool confetti;

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    if (widget.confetti) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.confetti)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => CustomPaint(
                  painter: _ConfettiPainter(_controller.value),
                ),
              ),
            ),
          ),
        Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MascotWidget(pose: widget.pose, height: 150),
                const SizedBox(height: AppSpacing.lg),
                Text(widget.title,
                    textAlign: TextAlign.center, style: AppTypography.h1),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySecondary),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(widget.buttonLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Confete leve: partículas determinísticas caindo com balanço, cores da
/// marca. Sem alocação por frame além do necessário.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);

  final double t;

  static final _rng = math.Random(7);
  static final List<_Particle> _particles = List.generate(64, (i) {
    return _Particle(
      x: _rng.nextDouble(),
      phase: _rng.nextDouble(),
      speed: .55 + _rng.nextDouble() * .8,
      size: 5 + _rng.nextDouble() * 6,
      sway: 12 + _rng.nextDouble() * 26,
      color: const [
        AppColors.primary,
        AppColors.secondary,
        AppColors.accent,
        AppColors.success,
        Color(0xFFF5C542),
      ][i % 5],
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in _particles) {
      final progress = (t * p.speed + p.phase) % 1.0;
      final dy = progress * (size.height + 40) - 20;
      final dx = p.x * size.width +
          math.sin(progress * math.pi * 4 + p.phase * 6) * p.sway;
      paint.color = p.color.withOpacity((1 - progress) * .9 + .1);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(progress * math.pi * 3 + p.phase * 5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * .55),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

class _Particle {
  const _Particle({
    required this.x,
    required this.phase,
    required this.speed,
    required this.size,
    required this.sway,
    required this.color,
  });
  final double x, phase, speed, size, sway;
  final Color color;
}
