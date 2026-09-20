import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/lily/lily_assets.dart';
import '../../../core/lily/lily_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/weekly_challenge_models.dart';

class ChallengeCompleteScreen extends StatefulWidget {
  const ChallengeCompleteScreen({
    super.key,
    required this.challenge,
    required this.progress,
    required this.unlocked,
  });

  final WeeklyChallenge challenge;
  final WeeklyChallengeProgress progress;
  final List<ChallengeAchievementDef> unlocked;

  @override
  State<ChallengeCompleteScreen> createState() =>
      _ChallengeCompleteScreenState();
}

class _ChallengeCompleteScreenState extends State<ChallengeCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.unlocked.isNotEmpty
        ? widget.unlocked.first
        : ChallengeAchievementDef.constancia;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              painter: _ConfettiPainter(_ctrl.value),
              size: MediaQuery.sizeOf(context),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  LilyImage(
                    asset: LilyAssets.trofeu,
                    height: 180,
                    semanticLabel: 'Lily comemorando',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Parabéns! Você concluiu o Desafio da Semana 🎉',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h2(),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Mais uma semana escolhendo cuidar de você.\nUm dia de cada vez.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.45,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text(badge.emoji, style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 6),
                        Text(
                          badge.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${widget.challenge.rewardXp} XP  ·  +${widget.challenge.rewardCoins} moedas',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      onPressed: () {
                        Share.share(
                          'Concluí o ${widget.challenge.title} no app 1 Dia de Cada Vez 💜\n'
                          'Mais uma semana escolhendo cuidar de mim. Um dia de cada vez.',
                        );
                      },
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('Compartilhar'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;
  final _rng = Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      AppColors.hotPink,
      AppColors.primary,
      AppColors.accent,
      AppColors.secondary,
      Colors.white,
    ];
    for (var i = 0; i < 48; i++) {
      final x = _rng.nextDouble() * size.width;
      final speed = 0.35 + _rng.nextDouble() * 0.8;
      final y = -20 + (t * speed * (size.height + 80));
      final paint = Paint()..color = colors[i % colors.length].withValues(alpha: 0.85);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 8 + i);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 8, height: 14),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
