import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../missions/providers/missions_providers.dart';
import '../data/calorie_vision_repository.dart';
import '../domain/nutrition_models.dart';
import '../providers/food_log_providers.dart';

final calorieVisionRepositoryProvider =
    Provider((ref) => CalorieVisionRepository());

/// Tira (ou escolhe) uma foto da comida e pede pra IA estimar as calorias.
/// A estimativa vem sempre com um nível de confiança e pode ser ajustada
/// manualmente antes de registrar — foto nunca substitui 100% uma balança.
class CalorieScannerScreen extends ConsumerStatefulWidget {
  const CalorieScannerScreen({super.key});

  @override
  ConsumerState<CalorieScannerScreen> createState() =>
      _CalorieScannerScreenState();
}

class _CalorieScannerScreenState extends ConsumerState<CalorieScannerScreen> {
  File? _photo;
  bool _loading = false;
  CalorieEstimate? _result;
  String? _error;
  final _nameController = TextEditingController();
  final _kcalController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _kcalController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (xfile == null) return;

    setState(() {
      _photo = File(xfile.path);
      _result = null;
      _error = null;
      _loading = true;
    });

    try {
      final bytes = await xfile.readAsBytes();
      final repo = ref.read(calorieVisionRepositoryProvider);
      final estimate = await repo.estimate(bytes);
      _nameController.text = estimate.name;
      _kcalController.text = estimate.kcal.toString();
      setState(() => _result = estimate);
    } on CalorieVisionUnavailable catch (e) {
      setState(() => _error = e.toString());
    } catch (_) {
      setState(() =>
          _error = 'Não consegui estimar as calorias agora. '
              'Você pode preencher manualmente abaixo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmar() async {
    final name = _nameController.text.trim();
    final kcal = int.tryParse(_kcalController.text.trim());
    if (name.isEmpty || kcal == null || kcal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confira o nome e as calorias.')),
      );
      return;
    }
    await ref.read(foodLogProvider.notifier).add(
          name,
          kcal,
          source: _photo != null
              ? FoodEntrySource.foto
              : FoodEntrySource.manual,
          protein: _result?.protein ?? 0,
          carbs: _result?.carbs ?? 0,
          fat: _result?.fat ?? 0,
        );
    ref.read(missionsProvider.notifier).report(MissionEvent.refeicaoRegistrada);
    await FeedbackService.play(FeedbackEvent.sucesso);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calorias por foto')),
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
                const Expanded(
                  child: Text(
                    'Tire uma foto do prato — eu estimo as calorias pra você '
                    'confirmar antes de registrar.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            AspectRatio(
              aspectRatio: 1.1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  image: _photo != null
                      ? DecorationImage(
                          image: FileImage(_photo!), fit: BoxFit.cover)
                      : null,
                ),
                child: _photo == null
                    ? const Center(
                        child: Icon(Icons.restaurant_menu,
                            size: 48, color: AppColors.textTertiary),
                      )
                    : (_loading
                        ? Container(
                            color: Colors.black45,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.secondary),
                            ),
                          )
                        : null),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Câmera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _loading ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeria'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_error != null)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  ],
                ),
              ),

            if (_result != null) ...[
              Row(
                children: [
                  const Text('Confiança da IA: ',
                      style: TextStyle(color: AppColors.textSecondary)),
                  _ConfidenceTag(level: _result!.confidence),
                ],
              ),
              const SizedBox(height: 12),
            ],

            const Text('Nome do alimento',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: _nameController),
            const SizedBox(height: 16),

            const Text('Calorias estimadas (kcal) — ajuste se precisar',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _kcalController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmar,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Registrar no diário alimentar'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estimativas por foto são aproximadas e não substituem '
              'orientação de uma nutricionista.',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceTag extends StatelessWidget {
  const _ConfidenceTag({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      'alta' => AppColors.success,
      'media' => AppColors.warning,
      _ => AppColors.danger,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(level, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
