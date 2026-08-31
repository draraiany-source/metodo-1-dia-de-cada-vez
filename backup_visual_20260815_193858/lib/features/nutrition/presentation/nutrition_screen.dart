import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/seed_data.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/mascot/mascot_sizes.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/feature_illustration_banner.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/router/app_router.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../ai_trainer/providers/ai_trainer_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../domain/nutrition_models.dart';
import '../domain/food_database_models.dart';
import '../providers/food_log_providers.dart';
import '../providers/water_log_providers.dart';
import 'food_database_screen.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {

  // Calculadora de IMC — campos independentes do perfil salvo, pra permitir
  // simular antes de confirmar.
  late final TextEditingController _pesoController;
  late final TextEditingController _alturaController;
  double? _imcSimulado;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider) ?? AppUser.demo();
    _pesoController = TextEditingController(
        text: user.currentWeight?.toStringAsFixed(1) ?? '');
    _alturaController = TextEditingController(
        text: user.height != null
            ? (user.height! * 100).toStringAsFixed(0)
            : '');
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  void _recalcularImc() {
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final alturaCm =
        double.tryParse(_alturaController.text.replaceAll(',', '.'));
    final alturaM = alturaCm != null ? alturaCm / 100 : null;
    setState(() {
      _imcSimulado = BmiCalculator.calculate(weightKg: peso, heightM: alturaM);
    });
  }

  Future<void> _salvarImcNoPerfil(AppUser user) async {
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final alturaCm =
        double.tryParse(_alturaController.text.replaceAll(',', '.'));
    if (peso == null || alturaCm == null || peso <= 0 || alturaCm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha peso e altura corretamente.')),
      );
      return;
    }
    final updated =
        user.copyWith(currentWeight: peso, height: alturaCm / 100);
    await ref.read(profileUpdaterProvider)(updated);
    ref.read(missionsProvider.notifier).report(MissionEvent.pesoRegistrado);
    await FeedbackService.play(FeedbackEvent.sucesso);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peso e altura atualizados! ⚖️')),
      );
    }
  }

  Future<void> _abrirRegistroManual() async {
    final nameController = TextEditingController();
    final kcalController = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registrar alimento',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Nome',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: nameController, autofocus: true),
            const SizedBox(height: 16),
            const Text('Calorias (kcal)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
                controller: kcalController, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final name = nameController.text.trim();
      final kcal = int.tryParse(kcalController.text.trim());
      if (name.isEmpty || kcal == null || kcal <= 0) return;
      await ref.read(foodLogProvider.notifier).add(name, kcal);
      ref
          .read(missionsProvider.notifier)
          .report(MissionEvent.refeicaoRegistrada);
      await FeedbackService.play(FeedbackEvent.sucesso);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();
    final waterGoalGlasses = WaterCalculator.goalGlassesFor(user.currentWeight);
    final goal = waterGoalGlasses;
    final glasses = ref.watch(waterLogProvider).clamp(0, goal);

    final foodEntries = ref.watch(foodLogProvider);
    final todayKcal = ref.watch(todayKcalProvider);
    final macros = ref.watch(todayMacrosProvider);
    final trainerProfile = ref.watch(trainerProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text('Nutrição 🥗',
                style: Theme.of(context).textTheme.headlineMedium),
            const Text('Coma bem, um dia de cada vez',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            const FeatureIllustrationBanner(
              assetPath: AppAssets.illustReceitasNutricaoDark,
              height: 132,
              backgroundColor: AppColors.surface,
              semanticLabel: 'Ilustração de receitas e nutrição',
            ),
            const SizedBox(height: 20),

            // Água — meta calculada a partir do peso cadastrado (~35ml/kg).
            Container(
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
                      // Gota anima quando a meta do dia é batida.
                      glasses >= goal
                          ? LiliAnimation(AppAssets.animWaterDrop, size: 56)
                          : const AnimatedLiliMascot(
                              pose: MascotePose.hidratacao,
                              mood: LiliMood.respirando,
                              height: MascotSizes.header),
                      const Text('💧 Água do dia',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      Text('$glasses / $goal copos',
                          style: const TextStyle(color: AppColors.info)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Meta de ${WaterCalculator.goalMlFor(user.currentWeight)} ml/dia '
                    '(~35ml por kg${user.currentWeight == null ? ' — cadastre seu peso na calculadora abaixo pra personalizar' : ''})',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(goal, (i) {
                      final filled = i < glasses;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final novo = i + 1;
                            final bateuMeta = glasses < goal && novo >= goal;
                            ref.read(waterLogProvider.notifier).setGlasses(novo);
                            // Missão de hidratação usa progresso absoluto.
                            ref
                                .read(missionsProvider.notifier)
                                .setProgress(MissionEvent.copoDeAgua, novo);
                            FeedbackService.play(bateuMeta
                                ? FeedbackEvent.sucesso
                                : FeedbackEvent.toqueLeve);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 40,
                            decoration: BoxDecoration(
                              color: filled
                                  ? AppColors.info
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.water_drop,
                                size: 16,
                                color: filled
                                    ? Colors.white
                                    : AppColors.textTertiary),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Calculadora de IMC
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚖️ Calculadora de IMC',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _NumberField(
                          label: 'Peso (kg)',
                          controller: _pesoController,
                          onChanged: (_) => _recalcularImc(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NumberField(
                          label: 'Altura (cm)',
                          controller: _alturaController,
                          onChanged: (_) => _recalcularImc(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Builder(builder: (_) {
                    final imc = _imcSimulado ?? user.bmi;
                    return Row(
                      children: [
                        Text(
                          imc != null ? imc.toStringAsFixed(1) : '—',
                          style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            BmiCalculator.categoryFor(imc),
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _salvarImcNoPerfil(user),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar peso e altura no perfil'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Calorias do dia
            Container(
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
                      const Text('🔥 Calorias de hoje',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      Text(
                          '$todayKcal / ${trainerProfile.metaCalorica.round()} kcal',
                          style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (todayKcal / trainerProfile.metaCalorica)
                          .clamp(0, 1)
                          .toDouble(),
                      backgroundColor: AppColors.background,
                      color: todayKcal > trainerProfile.metaCalorica
                          ? AppColors.warning
                          : AppColors.secondary,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Proteína ${macros.$1}/${trainerProfile.metaProteinaG.round()}g · '
                    'Carbo ${macros.$2}/${trainerProfile.metaCarboidratoG.round()}g · '
                    'Gordura ${macros.$3}/${trainerProfile.metaGorduraG.round()}g',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              context.push(Routes.calorieScanner),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Tirar foto'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _abrirRegistroManual,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Manual'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final item = await Navigator.of(context)
                            .push<FoodItem>(MaterialPageRoute(
                                builder: (_) => const FoodDatabaseScreen(
                                    selectMode: true)));
                        if (item == null) return;
                        await ref.read(foodLogProvider.notifier).add(
                              item.name,
                              item.kcal,
                              protein: item.protein,
                              carbs: item.carbs,
                              fat: item.fat,
                            );
                        ref
                            .read(missionsProvider.notifier)
                            .report(MissionEvent.refeicaoRegistrada);
                        await FeedbackService.play(FeedbackEvent.sucesso);
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar no banco de alimentos'),
                    ),
                  ),
                  if (foodEntries.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    for (final tipo in MealType.values)
                      if (foodEntries.any((e) => e.mealType == tipo)) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, top: 4),
                          child: Text(tipo.label,
                              style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ),
                        ...foodEntries
                            .where((e) => e.mealType == tipo)
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        e.source == FoodEntrySource.foto
                                            ? Icons.camera_alt_outlined
                                            : Icons.edit_outlined,
                                        size: 14,
                                        color: AppColors.textTertiary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(e.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13)),
                                      ),
                                      Text('${e.kcal} kcal',
                                          style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12)),
                                    ],
                                  ),
                                )),
                      ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Receitas saudáveis'),
            ...SeedData.recipes.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                            child: Text(r.emoji,
                                style: const TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('${r.category} · ${r.kcal} kcal · ${r.protein}g proteína',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline,
                            color: AppColors.secondary),
                        onPressed: () => _showRecipe(context, r),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showRecipe(BuildContext context, Recipe r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(r.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Text(r.title,
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Ingredientes',
                style: TextStyle(
                    color: AppColors.secondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...r.ingredients.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $i',
                      style: const TextStyle(color: Colors.white)),
                )),
            const SizedBox(height: 16),
            const Text('Preparo',
                style: TextStyle(
                    color: AppColors.secondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(r.steps, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(missionsProvider.notifier)
                      .report(MissionEvent.refeicaoRegistrada);
                  ref.read(foodLogProvider.notifier).add(r.title, r.kcal);
                  FeedbackService.play(FeedbackEvent.sucesso);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Refeição registrada! 🥗')),
                  );
                },
                icon: const Icon(Icons.restaurant),
                label: const Text('Registrar refeição'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
