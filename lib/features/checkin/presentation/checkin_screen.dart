import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../missions/providers/missions_providers.dart';
import '../domain/checkin_models.dart';
import '../providers/checkin_providers.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  bool _dormiuBem = true;
  int _humor = 1;
  int _energia = 3;
  int _agua = 4;
  bool _treinou = false;
  bool _correu = false;
  bool _alimentacaoSaudavel = false;
  bool _cumpriuMeta = false;
  final _pesoController = TextEditingController();
  final _obsController = TextEditingController();
  int? _resultado;

  @override
  void dispose() {
    _pesoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final entry = CheckinEntry(
      date: DateTime.now(),
      dormiuBem: _dormiuBem,
      humor: _humor,
      energia: _energia,
      aguaCopos: _agua,
      peso: double.tryParse(_pesoController.text.replaceAll(',', '.')),
      treinou: _treinou,
      correu: _correu,
      alimentacaoSaudavel: _alimentacaoSaudavel,
      cumpriuMeta: _cumpriuMeta,
      observacoes: _obsController.text.trim(),
    );
    await ref.read(checkinProvider.notifier).salvar(entry);
    ref.read(missionsProvider.notifier).report(MissionEvent.checkinFeito);
    await FeedbackService.play(FeedbackEvent.sucesso);
    setState(() => _resultado = entry.pontuacao);
  }

  @override
  Widget build(BuildContext context) {
    final jaFeito = ref.watch(todayCheckinProvider);

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Check-in diário'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                const AnimatedLiliMascot(
                  pose: MascotePose.checklist,
                  mood: LiliMood.respirando,
                  height: 76,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    jaFeito != null
                        ? 'Você já fez seu check-in hoje — pode refazer se quiser atualizar.'
                        : 'Leva 30 segundos. Como foi seu dia?',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_resultado != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                ),
                child: Row(
                  children: [
                    Text('$_resultado',
                        style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Text('/100',
                        style: TextStyle(color: AppColors.textSecondary)),
                    const Spacer(),
                    const Text('Check-in salvo!',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Text('Dormiu bem?',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Sim'),
                    selected: _dormiuBem,
                    onSelected: (_) => setState(() => _dormiuBem = true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Não'),
                    selected: !_dormiuBem,
                    onSelected: (_) => setState(() => _dormiuBem = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Humor',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < AppIcons.moodCheckin.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _humor = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _humor == i
                            ? AppColors.primary.withOpacity(0.25)
                            : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _humor == i
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: AppIconImage(
                        AppIcons.moodCheckin[i],
                        size: 36,
                        fallbackIcon: Icons.emoji_emotions_outlined,
                        semanticLabel: 'Humor $i',
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            Text('Nível de energia: $_energia/5',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            Slider(
              value: _energia.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: AppColors.primary,
              label: '$_energia',
              onChanged: (v) => setState(() => _energia = v.round()),
            ),
            const SizedBox(height: 8),

            Text('Água hoje: $_agua copos',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            Slider(
              value: _agua.toDouble(),
              min: 0,
              max: 12,
              divisions: 12,
              activeColor: AppColors.info,
              label: '$_agua',
              onChanged: (v) => setState(() => _agua = v.round()),
            ),
            const SizedBox(height: 12),

            const Text('Peso de hoje (opcional)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _pesoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(suffixText: 'kg'),
            ),
            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  avatar: AppIconImage(AppIcons.workout, size: 18,
                      fallbackIcon: Icons.fitness_center),
                  label: const Text('Treinou'),
                  selected: _treinou,
                  onSelected: (v) => setState(() => _treinou = v),
                ),
                FilterChip(
                  avatar: AppIconImage(AppIcons.running, size: 18,
                      fallbackIcon: Icons.directions_run),
                  label: const Text('Correu'),
                  selected: _correu,
                  onSelected: (v) => setState(() => _correu = v),
                ),
                FilterChip(
                  avatar: AppIconImage(AppIcons.recipes, size: 18,
                      fallbackIcon: Icons.restaurant),
                  label: const Text('Alimentação saudável'),
                  selected: _alimentacaoSaudavel,
                  onSelected: (v) => setState(() => _alimentacaoSaudavel = v),
                ),
                FilterChip(
                  avatar: AppIconImage(AppIcons.goals, size: 18,
                      fallbackIcon: Icons.flag),
                  label: const Text('Cumpriu a meta'),
                  selected: _cumpriuMeta,
                  onSelected: (v) => setState(() => _cumpriuMeta = v),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Observações do dia (opcional)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: _obsController, maxLines: 3),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salvar,
                icon: AppIconImage(AppIcons.checkin, size: 22,
                    fallbackIcon: Icons.check_circle_outline),
                label: const Text('Salvar check-in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
