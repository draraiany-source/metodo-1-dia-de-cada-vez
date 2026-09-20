import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/seed_data.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/premium_bottom_nav.dart';
import '../../../models/domain_models.dart';
import '../../ai_trainer/providers/ai_trainer_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../nutrition/domain/nutrition_models.dart';
import '../../nutrition/providers/food_log_providers.dart';
import '../../nutrition/providers/water_log_providers.dart';
import '../../workouts/presentation/workout_detail_screen.dart';
import '../domain/planned_meal.dart';
import 'meal_detail_screen.dart';

/// ============================================================================
/// MEU PLANO — abas Hoje / Semana / Mês.
///
/// Princípio seguido em toda a tela: **nenhum número é inventado**.
///  - "Hoje": treino em destaque vem do catálogo real (`SeedData.workouts`,
///    rotacionado por dia da semana); cada refeição vem da receita real do
///    catálogo (`SeedData.recipes`, via `PlannedMealX`); o status de cada
///    refeição reflete o que foi REALMENTE registrado hoje no diário
///    alimentar (`foodLogProvider`).
///  - "Semana"/"Mês": agregados reais do histórico de missões
///    (`missionsProvider.history`) e dos diários de água/calorias
///    (`WaterLogNotifier` / `foodKcalHistory`) — nada fabricado na tela.
/// ============================================================================
class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  int _period = 0; // 0 = Hoje · 1 = Semana · 2 = Mês

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final navIndex = indexForLocation(location);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _PlanHeader(onBack: () => Navigator.of(context).maybePop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: _PeriodSelector(
                value: _period,
                onChanged: (i) => setState(() => _period = i),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.03), end: Offset.zero)
                        .animate(anim),
                    child: child,
                  ),
                ),
                child: switch (_period) {
                  0 => const _HojeTab(key: ValueKey('hoje')),
                  1 => const _SemanaTab(key: ValueKey('semana')),
                  _ => const _MesTab(key: ValueKey('mes')),
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PremiumBottomNav(
        currentIndex: navIndex,
        onTap: (i) => context.go(kMainTabs[i].route),
      ),
    );
  }
}

// ============================================================================
// CABEÇALHO
// ============================================================================
class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text('Meu Plano',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17)),
            Align(
              alignment: Alignment.centerLeft,
              child: PressableScale(
                onTap: onBack,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.arrow_back,
                      size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SELETOR SEGMENTADO — Hoje / Semana / Mês
// ============================================================================
class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  static const _labels = ['Hoje', 'Semana', 'Mês'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final slotWidth = constraints.maxWidth / _labels.length;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: slotWidth * value,
              width: slotWidth,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.heroPinkGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                for (int i = 0; i < _labels.length; i++)
                  SizedBox(
                    width: slotWidth,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onChanged(i),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: i == value
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight:
                                i == value ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          child: Text(_labels[i]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

// ============================================================================
// ABA "HOJE"
// ============================================================================
class _HojeTab extends ConsumerWidget {
  const _HojeTab({super.key});

  static const _slots = [
    MealType.cafeDaManha,
    MealType.almoco,
    MealType.lancheDaTarde,
    MealType.jantar,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = SeedData.workouts;
    final treino = workouts.isEmpty
        ? null
        : workouts[DateTime.now().weekday % workouts.length];

    final log = ref.watch(foodLogProvider);
    final registradas = log.map((e) => e.mealType).toSet();

    final kcalHoje = ref.watch(todayKcalProvider);
    final metaKcal = ref.watch(trainerProfileProvider).metaCalorica.round();
    final glasses = ref.watch(waterLogProvider);
    final user = ref.watch(currentUserProvider);
    final goalGlasses =
        ref.watch(waterDayProvider).effectiveGoalGlasses(user?.currentWeight);
    final litrosAtual = glasses * WaterCalculator.mlPerGlass / 1000;
    final litrosMeta = goalGlasses * WaterCalculator.mlPerGlass / 1000;
    final missions = ref.watch(missionsProvider);
    final treinoFeito = missions.progressOf('d_treino').current >= 1;
    final refeicoesFeitas =
        _slots.where((s) => registradas.contains(s)).length;

    return ListView(
      key: const PageStorageKey('hoje'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      children: [
        Text('Treino de hoje',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        treino == null
            ? _EmptyWorkoutCard(
                onTap: () => context.push(Routes.workouts),
              )
            : _WorkoutCard(workout: treino),
        const SizedBox(height: 24),
        Text('Refeições', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        for (int i = 0; i < _slots.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MealCard(
              mealType: _slots[i],
              done: registradas.contains(_slots[i]),
              delayMs: i * 60,
            ),
          ),
        const SizedBox(height: 8),
        Text('Resumo do dia', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        _DailySummaryCard(
          kcalAtual: kcalHoje,
          kcalMeta: metaKcal,
          litrosAtual: litrosAtual,
          litrosMeta: litrosMeta,
          treinoFeito: treinoFeito,
          refeicoesFeitas: refeicoesFeitas,
          refeicoesTotal: _slots.length,
        ),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A0F14),
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppColors.secondary.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.secondary.withOpacity(0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Treino de hoje',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(workout.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17)),
                          const SizedBox(height: 4),
                          Text('${workout.durationMin} min · ${workout.level}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                          const SizedBox(height: 14),
                          PressableScale(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      WorkoutDetailScreen(workout: workout)),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: AppColors.heroPinkGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.secondary.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Text('Iniciar treino',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const LiliMascot(pose: MascotePose.forte, height: 84),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWorkoutCard extends StatelessWidget {
  const _EmptyWorkoutCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            const LiliMascot(pose: MascotePose.triste, height: 84),
            const SizedBox(height: 12),
            const Text('Seu treino de hoje ainda não foi definido.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            PressableScale(
              onTap: onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.heroPinkGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Montar meu treino',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends ConsumerWidget {
  const _MealCard({
    required this.mealType,
    required this.done,
    this.delayMs = 0,
  });

  final MealType mealType;
  final bool done;
  final int delayMs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = mealType.plannedRecipe;

    return FadeInUp(
      delayMs: delayMs,
      offset: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: done
                ? AppColors.success.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: recipe == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MealDetailScreen(
                                mealType: mealType, recipe: recipe),
                          ),
                        ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary.withOpacity(0.14),
                      ),
                      child: Center(
                        child: Text(recipe?.emoji ?? '🍽️',
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mealType.label,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            recipe?.title ?? 'Refeição ainda não definida',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: recipe == null
                  ? null
                  : () async {
                      final notifier = ref.read(foodLogProvider.notifier);
                      if (done) {
                        await notifier.removeMealType(mealType);
                      } else {
                        await notifier.add(recipe.title, recipe.kcal,
                            protein: recipe.protein, mealType: mealType);
                        ref
                            .read(missionsProvider.notifier)
                            .report(MissionEvent.refeicaoRegistrada);
                      }
                    },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.success : Colors.transparent,
                  border: Border.all(
                    color: done
                        ? AppColors.success
                        : AppColors.textTertiary.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  const _DailySummaryCard({
    required this.kcalAtual,
    required this.kcalMeta,
    required this.litrosAtual,
    required this.litrosMeta,
    required this.treinoFeito,
    required this.refeicoesFeitas,
    required this.refeicoesTotal,
  });

  final int kcalAtual;
  final int kcalMeta;
  final double litrosAtual;
  final double litrosMeta;
  final bool treinoFeito;
  final int refeicoesFeitas;
  final int refeicoesTotal;

  @override
  Widget build(BuildContext context) {
    final kcalPct = kcalMeta > 0 ? (kcalAtual / kcalMeta).clamp(0.0, 1.0) : 0.0;
    final aguaPct =
        litrosMeta > 0 ? (litrosAtual / litrosMeta).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calorias',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('$kcalAtual / $kcalMeta kcal',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedProgressBar(value: kcalPct, color: AppColors.warning),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Água',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(
                  '${litrosAtual.toStringAsFixed(1)} / ${litrosMeta.toStringAsFixed(1)} L',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedProgressBar(value: aguaPct, color: AppColors.info),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryPill(
                  icon: treinoFeito ? Icons.check_circle : Icons.radio_button_unchecked,
                  label: treinoFeito ? 'Treino concluído' : 'Treino pendente',
                  color: treinoFeito ? AppColors.success : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryPill(
                  icon: Icons.restaurant,
                  label: '$refeicoesFeitas de $refeicoesTotal refeições',
                  color: refeicoesFeitas == refeicoesTotal
                      ? AppColors.success
                      : AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                maxLines: 2,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ABA "SEMANA" — dia a dia da semana corrente (segunda a domingo)
// ============================================================================
class _SemanaTab extends ConsumerWidget {
  const _SemanaTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(missionsProvider);
    final now = DateTime.now();
    final segunda = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final dias = List.generate(7, (i) => segunda.add(Duration(days: i)));

    bool feitoNoDia(DateTime d) => missions.history.any((r) =>
        r.id == 'd_treino' &&
        r.date.year == d.year &&
        r.date.month == d.month &&
        r.date.day == d.day);

    final treinosNaSemana = dias.where(feitoNoDia).length;
    final refeicoesNaSemana = missions.history
        .where((r) =>
            r.id == 'd_refeicao' &&
            !r.date.isBefore(segunda) &&
            r.date.isBefore(segunda.add(const Duration(days: 7))))
        .length;
    final progressoSemanal = (treinosNaSemana / 7).clamp(0.0, 1.0);

    return ListView(
      key: const PageStorageKey('semana'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      children: [
        FadeInUp(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progresso semanal',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                AnimatedProgressBar(
                    value: progressoSemanal, color: AppColors.secondary),
                const SizedBox(height: 8),
                Text('$treinosNaSemana de 7 dias com treino',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Dias da semana', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        FadeInUp(
          delayMs: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final d in dias)
                _WeekdayChip(
                  date: d,
                  isToday: _isSameDay(d, now),
                  done: feitoNoDia(d),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _StatRow(label: 'Treinos concluídos', value: '$treinosNaSemana'),
        _StatRow(
            label: 'Refeições registradas (dias)', value: '$refeicoesNaSemana'),
        const SizedBox(height: 8),
        Text('Água — últimos 7 dias',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        FutureBuilder<Map<DateTime, int>>(
          future: WaterLogNotifier.history(7),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const SizedBox(
                  height: 100,
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.secondary, strokeWidth: 2)));
            }
            final entries = snap.data!.entries.toList();
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final e in entries)
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          width: 18,
                          height: 12.0 + e.value.clamp(0, 10) * 6,
                          decoration: BoxDecoration(
                            color: AppColors.info,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(_weekdayLetter(e.key.weekday),
                            style: const TextStyle(
                                color: AppColors.textTertiary, fontSize: 10)),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _weekdayLetter(int weekday) =>
      const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'][weekday - 1];
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip(
      {required this.date, required this.isToday, required this.done});
  final DateTime date;
  final bool isToday;
  final bool done;

  static const _letters = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isToday ? AppColors.heroPinkGradient : null,
            color: isToday ? null : AppColors.surface,
            border: Border.all(
              color: isToday
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Center(
            child: done
                ? Icon(Icons.check,
                    size: 16,
                    color: isToday ? Colors.white : AppColors.success)
                : Text(_letters[date.weekday - 1],
                    style: TextStyle(
                        color: isToday
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
          ),
        ),
        const SizedBox(height: 4),
        Text('${date.day}',
            style: const TextStyle(
                color: AppColors.textTertiary, fontSize: 10)),
      ],
    );
  }
}

// ============================================================================
// ABA "MÊS" — agregado real do mês corrente
// ============================================================================
class _MesTab extends ConsumerWidget {
  const _MesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(missionsProvider);
    final now = DateTime.now();
    final inicioDoMes = DateTime(now.year, now.month, 1);
    final diasPassados = now.day;

    final treinosNoMes = missions.history
        .where((r) => r.id == 'd_treino' && !r.date.isBefore(inicioDoMes))
        .length;

    final metasAlcancadas = ['d_treino', 'd_agua', 'd_refeicao']
        .map((tipo) => missions.history
            .where((r) => r.id == tipo && !r.date.isBefore(inicioDoMes))
            .map((r) => '${r.date.year}-${r.date.month}-${r.date.day}')
            .toSet())
        .reduce((a, b) => a.intersection(b))
        .length;

    final percentualCumprimento =
        diasPassados > 0 ? (treinosNoMes / diasPassados).clamp(0.0, 1.0) : 0.0;

    final user = ref.watch(currentUserProvider);
    final gam = ref.watch(gamificationProvider);

    return ListView(
      key: const PageStorageKey('mes'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      children: [
        FadeInUp(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroPinkGradient,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cumprimento do plano',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${(percentualCumprimento * 100).round()}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28)),
                    ],
                  ),
                ),
                const Icon(Icons.local_fire_department,
                    color: Colors.white, size: 40),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _StatCardGrid(children: [
          _StatCard(
              icon: Icons.fitness_center,
              label: 'Treinos realizados',
              value: '$treinosNoMes',
              color: AppColors.primary),
          _StatCard(
              icon: Icons.local_fire_department,
              label: 'Sequência atual',
              value: '${gam.streak} dias',
              color: AppColors.warning),
          _StatCard(
              icon: Icons.emoji_events,
              label: 'Metas alcançadas',
              value: '$metasAlcancadas',
              color: AppColors.success),
          if (user?.startWeight != null && user?.currentWeight != null)
            _StatCard(
              icon: Icons.monitor_weight_outlined,
              label: 'Evolução de peso',
              value:
                  '${(user!.currentWeight! - user.startWeight!).toStringAsFixed(1)} kg',
              color: AppColors.info,
            ),
        ]),
        const SizedBox(height: 16),
        Text('Água — média mensal',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        FutureBuilder<Map<DateTime, int>>(
          future: WaterLogNotifier.history(30),
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox.shrink();
            final valores = snap.data!.values.toList();
            final mediaCopos = valores.isEmpty
                ? 0.0
                : valores.reduce((a, b) => a + b) / valores.length;
            final mediaLitros = mediaCopos * WaterCalculator.mlPerGlass / 1000;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, color: AppColors.info),
                  const SizedBox(width: 10),
                  Text('${mediaLitros.toStringAsFixed(1)} L/dia em média',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatCardGrid extends StatelessWidget {
  const _StatCardGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: children,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 2,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
