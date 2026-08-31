import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/seed_data.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/lili_widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../domain/league_models.dart';
import '../providers/gamification_providers.dart';
import '../providers/league_providers.dart';

class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gamificationProvider);

    // Celebra a subida de nível no momento em que ela acontece.
    ref.listen<GamificationState>(gamificationProvider, (prev, next) {
      if (prev == null || next.level <= prev.level) return;
      FeedbackService.play(FeedbackEvent.levelUp);
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LiliAnimation(AppAssets.animXpGain, size: 110, repeat: false),
              const AnimatedLiliMascot(
                  pose: MascotePose.celebrando,
                  mood: LiliMood.comemorando,
                  height: 130),
              const SizedBox(height: 12),
              Text('Nível ${next.level}! 🎉',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Você subiu de nível. Continue firme!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuar')),
          ],
        ),
      );
    });

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Conquistas 🏆'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Nível
          GradientCard(
            gradient: AppColors.vibeGradient,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nível ${g.level}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${g.xp} XP total',
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 16),
                      LinearPercentIndicator(
                        percent: g.progress.clamp(0.0, 1.0),
                        lineHeight: 10,
                        barRadius: const Radius.circular(5),
                        backgroundColor: Colors.white24,
                        progressColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),
                      Text('${g.xpInLevel} / 1000 XP para o próximo nível',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const LiliMascot(pose: MascotePose.trofeu, height: 100),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Liga semanal (estilo Duolingo) — entrada para /leagues.
          Consumer(builder: (context, ref, _) {
            final liga = ref.watch(leagueProvider);
            final l = liga.league;
            return PressableScale(
              onTap: () => context.push(Routes.leagues),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: l.color.withOpacity(.55)),
                ),
                child: Row(
                  children: [
                    Text(l.emoji, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.label,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(
                            liga.loading
                                ? 'Carregando sua semana...'
                                : '${liga.weeklyXp} XP nesta semana',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textTertiary),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          Center(
            child: LiliAnimation(AppAssets.animTrophyShine, size: 90),
          ),
          const SizedBox(height: 8),
          const SectionHeader(title: 'Medalhas'),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: SeedData.achievements
                .map((a) => PressableScale(
                      onTap: a.unlocked
                          ? () {
                              FeedbackService.play(FeedbackEvent.conquista);
                              showDialog<void>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LiliAnimation(AppAssets.animMedalUnlock,
                                          size: 130, repeat: false),
                                      const SizedBox(height: 8),
                                      Text(a.title,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Fechar')),
                                  ],
                                ),
                              );
                            }
                          : null,
                      child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(
                          color: a.unlocked
                              ? AppColors.warning
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: a.unlocked ? 1 : 0.3,
                            child: Text(a.emoji,
                                style: const TextStyle(fontSize: 34)),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(a.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: a.unlocked
                                        ? Colors.white
                                        : AppColors.textTertiary)),
                          ),
                        ],
                      ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          const SectionHeader(title: 'Desafios ativos'),
          ...SeedData.challenges.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(c.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        XpBadge(xp: c.rewardXp),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(c.description,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 10),
                    LinearPercentIndicator(
                      percent: c.ratio.toDouble(),
                      lineHeight: 8,
                      barRadius: const Radius.circular(4),
                      backgroundColor: AppColors.background,
                      progressColor: AppColors.success,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 6),
                    Text('${c.progress} / ${c.goal}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              )),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SectionHeader(title: 'Ranking da semana'),
              LiliMascot(pose: MascotePose.rainha, height: 64),
            ],
          ),
          // Ranking vivo: a usuária entra com o XP REAL (fonte única) e é
          // reordenada dinamicamente. Antes o valor dela era fixo (850).
          ..._rankingComUsuaria(g.xp).asMap().entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  children: [
                    Text('${e.key + 1}º',
                        style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Text(e.value.$1[0],
                            style: const TextStyle(fontSize: 13))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            e.value.$3 ? '${e.value.$1} (você)' : e.value.$1,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: e.value.$3
                                    ? FontWeight.bold
                                    : FontWeight.normal))),
                    Text('${e.value.$2} XP',
                        style: TextStyle(
                            color: e.value.$3
                                ? AppColors.secondary
                                : AppColors.textSecondary)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Adversárias fixas (viriam do Firestore em produção).
  static const List<(String, int)> _oponentes = [
    ('Camila', 1420),
    ('Júlia', 720),
    ('Beatriz', 640),
  ];

  /// Monta o ranking incluindo a usuária com seu XP real e reordena.
  /// Retorna (nome, xp, ehVoce).
  static List<(String, int, bool)> _rankingComUsuaria(int xpUsuaria) {
    final lista = <(String, int, bool)>[
      for (final o in _oponentes) (o.$1, o.$2, false),
      ('Você', xpUsuaria, true),
    ];
    lista.sort((a, b) => b.$2.compareTo(a.$2));
    return lista;
  }
}
