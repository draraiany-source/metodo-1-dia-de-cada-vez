import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/lily/lily_assets.dart';
import '../../../core/lily/lily_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/weekly_challenge_notifications.dart';
import '../domain/weekly_challenge_models.dart';
import '../providers/weekly_challenge_providers.dart';

class WeeklyChallengeEditorScreen extends ConsumerStatefulWidget {
  const WeeklyChallengeEditorScreen({super.key, this.challengeId});
  final String? challengeId;

  @override
  ConsumerState<WeeklyChallengeEditorScreen> createState() =>
      _WeeklyChallengeEditorScreenState();
}

class _WeeklyChallengeEditorScreenState
    extends ConsumerState<WeeklyChallengeEditorScreen> {
  final _title = TextEditingController();
  final _short = TextEditingController();
  final _full = TextEditingController();
  final _rules = TextEditingController();
  final _objective = TextEditingController();
  final _message = TextEditingController();
  final _reward = TextEditingController(text: 'Constância');
  final _xp = TextEditingController(text: '120');
  final _coins = TextEditingController(text: '40');
  final _required = TextEditingController(text: '5');
  final _total = TextEditingController(text: '7');
  final _minMinutes = TextEditingController(text: '30');

  WeeklyChallengeCategory _category = WeeklyChallengeCategory.treino;
  ChallengeCompletionMode _mode = ChallengeCompletionMode.manual;
  ChallengeAudience _audience = ChallengeAudience.all;
  String _lily = LilyAssets.treinoHalteres;
  String _imageUrl = '';
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 6));
  WeeklyChallenge? _existing;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.challengeId;
    if (id == null || id.isEmpty) {
      final seed = WeeklyChallenge.seedCurrent();
      _apply(seed, keepId: false);
      setState(() => _loading = false);
      return;
    }
    final c = await ref.read(weeklyChallengeRepositoryProvider).getById(id);
    if (c != null) {
      _existing = c;
      _apply(c, keepId: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _apply(WeeklyChallenge c, {required bool keepId}) {
    _title.text = c.title;
    _short.text = c.shortDescription;
    _full.text = c.fullDescription;
    _rules.text = c.rules;
    _objective.text = c.objective;
    _message.text = c.motivationalMessage;
    _reward.text = c.rewardTitle;
    _xp.text = '${c.rewardXp}';
    _coins.text = '${c.rewardCoins}';
    _required.text = '${c.requiredDays}';
    _total.text = '${c.totalDays}';
    _minMinutes.text = '${c.minWorkoutMinutes}';
    _category = c.category;
    _mode = c.completionMode;
    _audience = c.audience;
    _lily = c.resolvedLilyAsset;
    _imageUrl = c.imageUrl;
    _start = c.startDate;
    _end = c.endDate;
    if (!keepId) _existing = null;
  }

  WeeklyChallenge _build(WeeklyChallengeStatus status) {
    final user = ref.read(currentUserProvider) ?? AppUser.uiFallback();
    return WeeklyChallenge(
      id: _existing?.id ?? '',
      title: _title.text.trim(),
      shortDescription: _short.text.trim(),
      fullDescription: _full.text.trim(),
      rules: _rules.text.trim(),
      objective: _objective.text.trim(),
      category: _category,
      startDate: _start,
      endDate: _end,
      requiredDays: int.tryParse(_required.text) ?? 5,
      totalDays: int.tryParse(_total.text) ?? 7,
      motivationalMessage: _message.text.trim(),
      rewardTitle: _reward.text.trim(),
      rewardXp: int.tryParse(_xp.text) ?? 120,
      rewardCoins: int.tryParse(_coins.text) ?? 40,
      status: status,
      imageUrl: _imageUrl,
      lilyAsset: _lily,
      audience: _audience,
      completionMode: _mode,
      minWorkoutMinutes: int.tryParse(_minMinutes.text) ?? 30,
      createdBy: _existing?.createdBy ?? user.id,
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
  }

  Future<void> _save(WeeklyChallengeStatus status) async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do desafio.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final challenge = _build(status);
      final repo = ref.read(weeklyChallengeRepositoryProvider);
      final id = await repo.saveChallenge(challenge);
      if (status == WeeklyChallengeStatus.published) {
        await WeeklyChallengeNotifications.scheduleFor(
          WeeklyChallenge(
            id: id,
            title: challenge.title,
            shortDescription: challenge.shortDescription,
            fullDescription: challenge.fullDescription,
            rules: challenge.rules,
            objective: challenge.objective,
            category: challenge.category,
            startDate: challenge.startDate,
            endDate: challenge.endDate,
            requiredDays: challenge.requiredDays,
            totalDays: challenge.totalDays,
            motivationalMessage: challenge.motivationalMessage,
            rewardTitle: challenge.rewardTitle,
            rewardXp: challenge.rewardXp,
            rewardCoins: challenge.rewardCoins,
            status: status,
            imageUrl: challenge.imageUrl,
            lilyAsset: challenge.lilyAsset,
            audience: challenge.audience,
            targetUserIds: challenge.targetUserIds,
            completionMode: challenge.completionMode,
            minWorkoutMinutes: challenge.minWorkoutMinutes,
            createdBy: challenge.createdBy,
            createdAt: challenge.createdAt,
          ),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == WeeklyChallengeStatus.draft
                ? 'Rascunho salvo.'
                : 'Desafio publicado.'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickCover() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final ext = file.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    final id = _existing?.id.isNotEmpty == true
        ? _existing!.id
        : 'tmp_${DateTime.now().millisecondsSinceEpoch}';
    final url = await ref
        .read(weeklyChallengeRepositoryProvider)
        .uploadCover(id, bytes, ext);
    if (url != null && mounted) setState(() => _imageUrl = url);
  }

  Future<void> _pickDate({required bool start}) async {
    final initial = start ? _start : _end;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
        if (_end.isBefore(_start)) {
          _end = _start.add(const Duration(days: 6));
        }
      } else {
        _end = picked;
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _short.dispose();
    _full.dispose();
    _rules.dispose();
    _objective.dispose();
    _message.dispose();
    _reward.dispose();
    _xp.dispose();
    _coins.dispose();
    _required.dispose();
    _total.dispose();
    _minMinutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: _existing == null ? 'Novo desafio' : 'Editar desafio',
        showStaffSignOut: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Nome do desafio'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _short,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Descrição curta'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _full,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Descrição completa'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rules,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Regras'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _objective,
            decoration: const InputDecoration(labelText: 'Objetivo'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<WeeklyChallengeCategory>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: WeeklyChallengeCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _category = v;
                _lily = v.lilyAsset;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ChallengeCompletionMode>(
            value: _mode,
            decoration: const InputDecoration(labelText: 'Como contar o progresso'),
            items: ChallengeCompletionMode.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (v) => setState(() => _mode = v ?? _mode),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ChallengeAudience>(
            value: _audience,
            decoration: const InputDecoration(
              labelText: 'Público',
              helperText:
                  'Desafios específicos para alunas escolhidas já ficam preparados.',
            ),
            items: ChallengeAudience.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (v) => setState(() => _audience = v ?? _audience),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _required,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Dias necessários'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _total,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total de dias'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _minMinutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minutos mínimos de treino (se usar cronômetro)',
            ),
          ),
          const SizedBox(height: 16),
          const Text('Período',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(start: true),
                  child: Text(
                    'Início ${_start.day}/${_start.month}/${_start.year}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(start: false),
                  child: Text(
                    'Término ${_end.day}/${_end.month}/${_end.year}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _message,
            maxLines: 3,
            decoration:
                const InputDecoration(labelText: 'Mensagem motivacional'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reward,
            decoration: const InputDecoration(labelText: 'Recompensa / selo'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _xp,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'XP'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _coins,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Moedas'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Imagem da Lily',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final asset in LilyAssets.all)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _lily = asset),
                      child: Container(
                        width: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _lily == asset
                                ? AppColors.hotPink
                                : AppColors.border,
                            width: _lily == asset ? 2 : 1,
                          ),
                        ),
                        child: LilyImage(asset: asset, height: 100),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickCover,
            icon: const Icon(Icons.image_outlined),
            label: Text(_imageUrl.isEmpty
                ? 'Enviar imagem própria'
                : 'Imagem enviada — tocar para trocar'),
          ),
          const SizedBox(height: 24),
          if (_saving)
            const Center(child: CircularProgressIndicator())
          else ...[
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () => _save(WeeklyChallengeStatus.published),
              child: const Text('Publicar desafio'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _save(WeeklyChallengeStatus.draft),
              child: const Text('Salvar como rascunho'),
            ),
          ],
        ],
      ),
    );
  }
}
