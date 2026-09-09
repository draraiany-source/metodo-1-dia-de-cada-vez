import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../auth/providers/auth_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../data/calorie_vision_repository.dart';
import '../domain/food_analysis_models.dart';
import '../domain/macro_totals.dart';
import '../domain/meal.dart';
import '../domain/nutrition_enums.dart';
import '../domain/nutrition_models.dart';
import '../providers/food_log_providers.dart';
import '../providers/nutrition_ia_providers.dart';

final calorieVisionRepositoryProvider =
    Provider((ref) => CalorieVisionRepository());

const _privacyPrefKey = 'nutrition_ai_privacy_accepted_v1';
const _estimateDisclaimer =
    'Os valores são estimativas geradas por IA e podem variar conforme o '
    'preparo, quantidade e ingredientes utilizados.';

/// Analisar minha refeição — foto → IA → edição → diário.
class CalorieScannerScreen extends ConsumerStatefulWidget {
  const CalorieScannerScreen({super.key});

  @override
  ConsumerState<CalorieScannerScreen> createState() =>
      _CalorieScannerScreenState();
}

class _CalorieScannerScreenState extends ConsumerState<CalorieScannerScreen> {
  File? _photo;
  List<int>? _photoBytes;
  bool _loading = false;
  bool _saving = false;
  List<FoodAnalysisItem> _foods = [];
  String? _error;
  late MealType _mealType;
  bool _privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    _mealType = MealTypeInfo.fromHour(DateTime.now().hour);
    _loadPrivacy();
  }

  Future<void> _loadPrivacy() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _privacyAccepted = prefs.getBool(_privacyPrefKey) ?? false);
  }

  MacroTotals get _totals =>
      _foods.fold(MacroTotals.zero, (s, f) => s + f.macros);

  Future<bool> _ensurePrivacy() async {
    if (_privacyAccepted) return true;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Privacidade',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'A foto da sua refeição será processada para gerar uma estimativa '
          'nutricional. Não enviamos outros dados pessoais desnecessários '
          'para o serviço de IA.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (ok != true) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyPrefKey, true);
    setState(() => _privacyAccepted = true);
    return true;
  }

  Future<void> _pick(ImageSource source) async {
    if (_loading || _saving) return;
    if (!await _ensurePrivacy()) return;

    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (xfile == null) return;

      final bytes = await xfile.readAsBytes();
      if (bytes.isEmpty) {
        setState(() => _error =
            'Foto inválida. Tente outra imagem com os alimentos visíveis.');
        return;
      }

      setState(() {
        _photo = File(xfile.path);
        _photoBytes = bytes;
        _foods = [];
        _error = null;
      });
    } on PlatformException catch (e) {
      final isCamera = source == ImageSource.camera;
      await _showPermissionDenied(isCamera: isCamera, code: e.code);
    } catch (_) {
      final isCamera = source == ImageSource.camera;
      await _showPermissionDenied(isCamera: isCamera);
    }
  }

  Future<void> _showPermissionDenied({
    required bool isCamera,
    String? code,
  }) async {
    final title = isCamera
        ? 'Permissão de câmera'
        : 'Permissão da galeria';
    final msg = isCamera
        ? 'Precisamos da câmera para fotografar sua refeição. '
            'Você pode tentar novamente ou liberar o acesso nas configurações.'
        : 'Precisamos acessar suas fotos para analisar a refeição. '
            'Você pode tentar novamente ou liberar o acesso nas configurações.';

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(msg,
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _openAppSettings();
            },
            child: const Text('Abrir configurações'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _pick(isCamera ? ImageSource.camera : ImageSource.gallery);
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppSettings() async {
    try {
      if (Platform.isAndroid) {
        await launchUrl(Uri.parse('app-settings:'));
      } else if (Platform.isIOS) {
        await launchUrl(Uri.parse('app-settings:'));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Abra as Configurações do aparelho e permita câmera/fotos para o app.',
          ),
        ),
      );
    }
  }

  Future<void> _analyze() async {
    if (_loading || _saving || _photoBytes == null) return;
    if (!await _ensurePrivacy()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = ref.read(calorieVisionRepositoryProvider);
      final analysis = await repo.analyzeMeal(_photoBytes!);
      if (!mounted) return;

      if (analysis.isEmpty) {
        setState(() {
          _foods = [];
          _error =
              'Não identificamos alimentos nesta imagem. '
              'Tente tirar outra foto com os alimentos mais visíveis.';
        });
        return;
      }

      setState(() {
        _foods = List.of(analysis.foods);
      });
    } on CalorieVisionUnavailable catch (e) {
      setState(() => _error = e.toString());
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('Timeout') || msg.contains('timeout')) {
        setState(() => _error =
            'A análise demorou demais. Verifique a internet e tente novamente.');
      } else if (msg.contains('Socket') ||
          msg.contains('network') ||
          msg.contains('Failed host')) {
        setState(() => _error =
            'Sem conexão com a internet. Conecte-se e toque em Tentar novamente.');
      } else if (msg.contains('autenticado')) {
        setState(() => _error = msg);
      } else {
        setState(() => _error =
            'Não conseguimos analisar essa imagem. '
            'Tente tirar outra foto com os alimentos mais visíveis.');
      }
    } catch (_) {
      setState(() => _error =
          'Não conseguimos analisar essa imagem. '
          'Tente tirar outra foto com os alimentos mais visíveis.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editFood(FoodAnalysisItem item) async {
    final edited = await showModalBottomSheet<FoodAnalysisItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditFoodSheet(item: item),
    );
    if (edited == null) return;
    setState(() {
      _foods = [
        for (final f in _foods)
          if (f.id == item.id) edited else f,
      ];
    });
  }

  void _addFood() {
    final neu = FoodAnalysisItem(
      id: 'manual_${DateTime.now().microsecondsSinceEpoch}',
      name: 'Novo alimento',
      estimatedGrams: 100,
      calories: 100,
      proteinG: 5,
      carbsG: 10,
      fatG: 3,
      fiberG: 1,
      confidence: 1,
    );
    setState(() => _foods = [..._foods, neu]);
    _editFood(neu);
  }

  void _removeFood(FoodAnalysisItem item) {
    setState(() => _foods = _foods.where((f) => f.id != item.id).toList());
  }

  String _mealTypeApi(MealType t) => switch (t) {
        MealType.cafeDaManha => 'breakfast',
        MealType.lancheDaManha => 'morning_snack',
        MealType.almoco => 'lunch',
        MealType.lancheDaTarde => 'afternoon_snack',
        MealType.jantar => 'dinner',
        MealType.ceia => 'evening_snack',
        MealType.lancheExtra => 'snack',
      };

  Future<void> _save() async {
    if (_saving || _loading) return;
    if (_foods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos um alimento.')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null || user.id.isEmpty) {
      setState(() => _error =
          'Faça login para salvar a refeição no seu diário alimentar.');
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final entryId = now.microsecondsSinceEpoch.toString();
      final totals = _totals;

      String? imageUrl;
      if (_photoBytes != null && FirebaseService.isReady) {
        imageUrl = await ref.read(mealPhotoStorageServiceProvider).uploadMealPhoto(
              userId: user.id,
              imageId: entryId,
              bytes: _photoBytes!,
            );
      }

      final confirmedItems = _foods
          .map((f) => f
              .toMealItem(source: MealItemSource.userConfirmed)
              .confirmByUser())
          .toList();

      final meal = Meal(
        id: entryId,
        mealType: _mealType,
        recordedAt: now,
        items: confirmedItems,
        imageUrl: imageUrl,
        photoStoragePath: imageUrl,
        userConfirmed: true,
        notes: 'Estimativa IA revisada pelo usuário',
        source: 'ai_food_scan',
      );

      await ref.read(mealRepositoryProvider).saveMeal(meal);

      final diary = NutritionDiaryEntry(
        id: entryId,
        mealType: _mealTypeApi(_mealType),
        date:
            '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        createdAt: now,
        imageUrl: imageUrl,
        source: 'ai_food_scan',
        foods: _foods.map((f) => f.toMap()).toList(),
        totalCalories: totals.kcal,
        proteinG: totals.proteinG,
        carbsG: totals.carbsG,
        fatG: totals.fatG,
        fiberG: totals.fiberG,
      );

      try {
        await ref.read(nutritionDiaryRepositoryProvider).save(diary);
      } catch (_) {
        // dailyLogs já salvo; diary é espelho — não bloqueia o fluxo.
      }

      final mealName = _foods.map((f) => f.name).join(', ');
      await ref.read(foodLogProvider.notifier).add(
            mealName.isEmpty ? _mealType.label : mealName,
            totals.kcal,
            source: FoodEntrySource.foto,
            protein: totals.proteinG,
            carbs: totals.carbsG,
            fat: totals.fatG,
            mealType: _mealType,
          );

      ref
          .read(missionsProvider.notifier)
          .report(MissionEvent.refeicaoRegistrada);
      await FeedbackService.play(FeedbackEvent.sucesso);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refeição adicionada ao seu dia!')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error =
          'Não foi possível salvar no Firebase. Verifique a conexão e tente novamente.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loading || _saving;
    final totals = _totals;

    return Scaffold(
      appBar: AppBar(title: const Text('Analisar minha refeição')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Row(
              children: [
                AnimatedLiliMascot(
                  pose: MascotePose.checklist,
                  mood: LiliMood.respirando,
                  height: 72,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tire uma foto da sua refeição e veja uma estimativa '
                    'de calorias e macronutrientes.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AspectRatio(
              aspectRatio: 1.15,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  image: _photo != null
                      ? DecorationImage(
                          image: FileImage(_photo!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_photo == null)
                      const Icon(Icons.restaurant_menu,
                          size: 48, color: AppColors.textTertiary),
                    if (_loading)
                      Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                                color: AppColors.secondary),
                            SizedBox(height: 12),
                            Text(
                              'Analisando sua refeição…',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            if (_photo == null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: busy
                          ? null
                          : () => _pick(ImageSource.camera),
                      icon: AppIconImage(AppIcons.camera, size: 22,
                          fallbackIcon: Icons.camera_alt_outlined),
                      label: const Text('Tirar foto'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy
                          ? null
                          : () => _pick(ImageSource.gallery),
                      icon: AppIconImage(AppIcons.photos, size: 22,
                          fallbackIcon: Icons.photo_library_outlined),
                      label: const Text('Escolher da galeria'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy
                          ? null
                          : () => _pick(ImageSource.gallery),
                      icon: AppIconImage(AppIcons.retry, size: 22,
                          fallbackIcon: Icons.swap_horiz),
                      label: const Text('Trocar foto'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: busy || _photoBytes == null ? null : _analyze,
                      icon: AppIconImage(AppIcons.cameraFood, size: 22,
                          fallbackIcon: Icons.auto_awesome),
                      label: const Text('Analisar refeição'),
                    ),
                  ),
                ],
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                      color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_error!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: busy
                          ? null
                          : () {
                              if (_photoBytes != null) {
                                _analyze();
                              } else {
                                _pick(ImageSource.camera);
                              }
                            },
                      icon: AppIconImage(AppIcons.retry, size: 20,
                          fallbackIcon: Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ],

            if (_foods.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Sua refeição',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${totals.kcal} kcal',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _MacroCard(
                          label: 'Proteína', value: '${totals.proteinG} g')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _MacroCard(
                          label: 'Carboidratos',
                          value: '${totals.carbsG} g')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _MacroCard(
                          label: 'Gorduras', value: '${totals.fatG} g')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _MacroCard(
                          label: 'Fibras', value: '${totals.fiberG} g')),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _estimateDisclaimer,
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 11, height: 1.35),
              ),
              const SizedBox(height: 20),
              const Text(
                'Alimentos identificados',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ..._foods.map(
                (f) => _FoodTile(
                  item: f,
                  onTap: busy ? null : () => _editFood(f),
                  onDelete: busy ? null : () => _removeFood(f),
                ),
              ),
              TextButton.icon(
                onPressed: busy ? null : _addFood,
                icon: AppIconImage(AppIcons.add, size: 20,
                    fallbackIcon: Icons.add),
                label: const Text('Adicionar alimento'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tipo da refeição',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MealType.values
                    .where((t) => t != MealType.lancheExtra)
                    .map(
                      (t) => ChoiceChip(
                        label: Text(t.label),
                        selected: _mealType == t,
                        onSelected: busy
                            ? null
                            : (_) => setState(() => _mealType = t),
                        selectedColor:
                            AppColors.secondary.withOpacity(0.35),
                        labelStyle: TextStyle(
                          color: _mealType == t
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        backgroundColor: AppColors.surface,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: busy ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                      _saving ? 'Salvando…' : 'Adicionar ao meu dia'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textTertiary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  const _FoodTile({
    required this.item,
    this.onTap,
    this.onDelete,
  });

  final FoodAnalysisItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        '${item.estimatedGrams.round()} g · ${item.calories} kcal',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: AppIconImage(AppIcons.delete, size: 20,
                      fallbackIcon: Icons.delete_outline),
                  tooltip: 'Excluir alimento',
                ),
                AppIconImage(AppIcons.edit, size: 18,
                    fallbackIcon: Icons.edit_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditFoodSheet extends StatefulWidget {
  const _EditFoodSheet({required this.item});
  final FoodAnalysisItem item;

  @override
  State<_EditFoodSheet> createState() => _EditFoodSheetState();
}

class _EditFoodSheetState extends State<_EditFoodSheet> {
  late final TextEditingController _name;
  late final TextEditingController _grams;
  late final TextEditingController _kcal;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;
  late final TextEditingController _fiber;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _name = TextEditingController(text: i.name);
    _grams = TextEditingController(text: i.estimatedGrams.round().toString());
    _kcal = TextEditingController(text: i.calories.toString());
    _protein = TextEditingController(text: i.proteinG.toStringAsFixed(1));
    _carbs = TextEditingController(text: i.carbsG.toStringAsFixed(1));
    _fat = TextEditingController(text: i.fatG.toStringAsFixed(1));
    _fiber = TextEditingController(text: i.fiberG.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _name.dispose();
    _grams.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _fiber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Editar alimento',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _field('Nome', _name),
            _field('Quantidade (g)', _grams,
                keyboard: TextInputType.number),
            _field('Calorias', _kcal, keyboard: TextInputType.number),
            _field('Proteína (g)', _protein,
                keyboard: const TextInputType.numberWithOptions(decimal: true)),
            _field('Carboidrato (g)', _carbs,
                keyboard: const TextInputType.numberWithOptions(decimal: true)),
            _field('Gordura (g)', _fat,
                keyboard: const TextInputType.numberWithOptions(decimal: true)),
            _field('Fibra (g)', _fiber,
                keyboard: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  widget.item.copyWith(
                    name: _name.text.trim().isEmpty
                        ? widget.item.name
                        : _name.text.trim(),
                    estimatedGrams:
                        double.tryParse(_grams.text.replaceAll(',', '.')) ??
                            widget.item.estimatedGrams,
                    calories: int.tryParse(_kcal.text) ?? widget.item.calories,
                    proteinG:
                        double.tryParse(_protein.text.replaceAll(',', '.')) ??
                            widget.item.proteinG,
                    carbsG:
                        double.tryParse(_carbs.text.replaceAll(',', '.')) ??
                            widget.item.carbsG,
                    fatG: double.tryParse(_fat.text.replaceAll(',', '.')) ??
                        widget.item.fatG,
                    fiberG:
                        double.tryParse(_fiber.text.replaceAll(',', '.')) ??
                            widget.item.fiberG,
                    confidence: 1,
                  ),
                );
              },
              child: const Text('Salvar alterações'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(controller: c, keyboardType: keyboard),
        ],
      ),
    );
  }
}
