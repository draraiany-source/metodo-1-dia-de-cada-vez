import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/lily/lily_image.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../rewards/providers/rewards_providers.dart';
import '../data/weekly_challenge_notifications.dart';
import '../domain/weekly_challenge_models.dart';
import '../providers/weekly_challenge_providers.dart';
import 'challenge_complete_screen.dart';

const _weekday = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];

class WeeklyChallengeDetailScreen extends ConsumerWidget {
  const WeeklyChallengeDetailScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final published = ref.watch(publishedChallengesProvider);
    final staff = ref.watch(staffWeeklyChallengesProvider);
    final challenge = [
      ...?published.valueOrNull,
      ...?staff.valueOrNull,
      WeeklyChallenge.seedCurrent(),
    ].cast<WeeklyChallenge?>().firstWhere(
          (c) => c?.id == challengeId,
          orElse: () => null,
        );

    if (challenge == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PremiumAppBar(title: 'Desafio da Semana'),
        body: const Center(
          child: Text('Desafio não encontrado.',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final progress = ref.watch(challengeProgressProvider(challenge.id)).valueOrNull;
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: 'Desafio da Semana',
        actions: [
          IconButton(
            tooltip: 'Meus desafios',
            onPressed: () => context.push(Routes.myChallenges),
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: challenge.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        challenge.imageUrl,
                        height: 180,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => LilyImage(
                          asset: challenge.resolvedLilyAsset,
                          height: 180,
                          semanticLabel: challenge.title,
                        ),
                      ),
                    )
                  : LilyImage(
                      asset: challenge.resolvedLilyAsset,
                      height: 180,
                      semanticLabel: challenge.title,
                    ),
            ),
            const SizedBox(height: 8),
            Text(challenge.title, style: AppTextStyles.h2()),
            const SizedBox(height: 6),
            Text(
              '${challenge.category.emoji}  ${challenge.category.label}  ·  ${challenge.periodLabel}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _Card(
              title: 'Descrição',
              child: Text(
                challenge.fullDescription.isEmpty
                    ? challenge.shortDescription
                    : challenge.fullDescription,
                style: const TextStyle(
                    color: AppColors.textSecondary, height: 1.4),
              ),
            ),
            _Card(
              title: 'Objetivo',
              child: Text(
                challenge.objective,
                style: const TextStyle(color: Colors.white, height: 1.4),
              ),
            ),
            _Card(
              title: 'Regras',
              child: Text(
                challenge.rules,
                style: const TextStyle(
                    color: AppColors.textSecondary, height: 1.45),
              ),
            ),
            _Card(
              title: 'Período',
              child: Text(
                'Início: ${_fmt(challenge.startDate)}\n'
                'Término: ${_fmt(challenge.endDate)}',
                style: const TextStyle(color: Colors.white, height: 1.4),
              ),
            ),
            const SizedBox(height: 8),
            _ProgressBlock(challenge: challenge, progress: progress),
            const SizedBox(height: 16),
            const Text(
              'Calendário da semana',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
            const SizedBox(height: 10),
            _WeekCalendar(challenge: challenge, progress: progress),
            const SizedBox(height: 18),
            if (progress?.status != ParticipationStatus.completed)
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _markToday(context, ref, challenge, user),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    progress == null ||
                            progress.status == ParticipationStatus.notStarted
                        ? 'Participar e marcar hoje'
                        : 'Marcar atividade de hoje',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            _Card(
              title: 'Mensagem da Amanda',
              accent: true,
              child: Text(
                challenge.motivationalMessage.isEmpty
                    ? 'Um dia de cada vez. Você está no caminho.'
                    : challenge.motivationalMessage,
                style: const TextStyle(
                    color: Colors.white, height: 1.4, fontSize: 15),
              ),
            ),
            _Card(
              title: 'Recompensa',
              child: Text(
                '🏅 ${challenge.rewardTitle}\n'
                '+${challenge.rewardXp} XP  ·  +${challenge.rewardCoins} moedas',
                style: const TextStyle(color: Colors.white, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _markToday(
    BuildContext context,
    WidgetRef ref,
    WeeklyChallenge challenge,
    AppUser user,
  ) async {
    final repo = ref.read(weeklyChallengeRepositoryProvider);
    final uid = challengeUserId(user);
    var progress = ref.read(challengeProgressProvider(challenge.id)).valueOrNull;
    if (progress == null ||
        progress.status == ParticipationStatus.notStarted) {
      progress = await repo.join(
        challenge: challenge,
        userId: uid,
        displayName: user.name,
      );
      await WeeklyChallengeNotifications.scheduleFor(challenge);
    }
    final today = DateTime.now();
    if (progress!.isDayDone(today)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hoje já está marcado. Continue assim!')),
        );
      }
      return;
    }
    final (next, justCompleted) = await repo.toggleDay(
      challenge: challenge,
      userId: uid,
      day: today,
      completed: true,
      displayName: user.name,
    );
    await WeeklyChallengeNotifications.notifyProgress(
      challenge: challenge,
      completed: next.completedCount,
    );
    ref.invalidate(challengeProgressProvider(challenge.id));
    ref.invalidate(myChallengeProgressListProvider);
    await FeedbackService.play(FeedbackEvent.toqueLeve);
    if (!context.mounted) return;
    if (justCompleted) {
      await _finishChallenge(context, ref, challenge, next);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dia marcado! ${next.completedCount} de ${challenge.requiredDays}.',
          ),
        ),
      );
    }
  }

  Future<void> _finishChallenge(
    BuildContext context,
    WidgetRef ref,
    WeeklyChallenge challenge,
    WeeklyChallengeProgress progress,
  ) async {
    final repo = ref.read(weeklyChallengeRepositoryProvider);
    final all = await repo.fetchMyProgress(progress.userId);
    final unlocked = repo.evaluateNewAchievements(
      all: all,
      justFinished: progress,
      challenge: challenge,
    );
    ref.read(gamificationProvider.notifier).addXp(
          challenge.rewardXp > 0
              ? challenge.rewardXp
              : AppConstants.xpPerWeeklyChallenge,
        );
    ref.read(rewardsProvider.notifier).earn(
          challenge.rewardCoins > 0
              ? challenge.rewardCoins
              : AppConstants.coinsPerChallenge,
        );
    await FeedbackService.play(FeedbackEvent.conquista);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChallengeCompleteScreen(
          challenge: challenge,
          progress: progress,
          unlocked: unlocked,
        ),
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.challenge, required this.progress});
  final WeeklyChallenge challenge;
  final WeeklyChallengeProgress? progress;

  @override
  Widget build(BuildContext context) {
    final done = progress?.completedCount ?? 0;
    final ratio = (done / challenge.requiredDays).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.softCardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progresso: $done de ${challenge.requiredDays} dias concluídos',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: AppColors.surfaceElevated,
              color: AppColors.hotPink,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekCalendar extends ConsumerWidget {
  const _WeekCalendar({required this.challenge, required this.progress});
  final WeeklyChallenge challenge;
  final WeeklyChallengeProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final days = challenge.calendarDays;
    return Column(
      children: [
        for (final day in days)
          _DayTile(
            day: day,
            done: progress?.isDayDone(day) ?? false,
            onToggle: () async {
              final repo = ref.read(weeklyChallengeRepositoryProvider);
              var p = progress;
              if (p == null || p.status == ParticipationStatus.notStarted) {
                p = await repo.join(
                  challenge: challenge,
                  userId: challengeUserId(user),
                  displayName: user.name,
                );
              }
              final marking = !(p!.isDayDone(day));
              final (next, justCompleted) = await repo.toggleDay(
                challenge: challenge,
                userId: challengeUserId(user),
                day: day,
                completed: marking,
                displayName: user.name,
              );
              ref.invalidate(challengeProgressProvider(challenge.id));
              if (justCompleted && context.mounted) {
                await WeeklyChallengeDetailScreen(challengeId: challenge.id)
                    ._finishChallenge(context, ref, challenge, next);
              }
            },
          ),
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.done,
    required this.onToggle,
  });
  final DateTime day;
  final bool done;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final label = _weekday[(day.weekday - 1) % 7];
    final today = DateTime.now();
    final isToday = day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: done
                ? AppColors.primary.withValues(alpha: 0.18)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isToday
                  ? AppColors.hotPink
                  : done
                      ? AppColors.primary
                      : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  label,
                  style: TextStyle(
                    color: done ? AppColors.accent : Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                done ? 'concluído' : (isToday ? 'hoje' : 'pendente'),
                style: TextStyle(
                  color: done
                      ? AppColors.success
                      : isToday
                          ? AppColors.hotPink
                          : AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? AppColors.success : AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child, this.accent = false});
  final String title;
  final Widget child;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent
              ? AppColors.hotPink.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: accent ? AppColors.hotPink : AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
