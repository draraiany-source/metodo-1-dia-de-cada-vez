import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../models/app_user.dart';
import '../../ai_trainer/domain/trainer_engine.dart';
import '../../ai_trainer/providers/ai_trainer_providers.dart';
import '../../auth/providers/auth_providers.dart';

/// Editar perfil — atualiza [AppUser] (nome, nascimento, foto, altura, peso,
/// meta) e o [TrainerProfile] real da IA Personal Trainer (objetivo, nível
/// de atividade, limitações/preferências de treino, restrições
/// alimentares). Nenhum sistema de perfil novo: os dois já existiam.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nome;
  late TextEditingController _altura;
  late TextEditingController _pesoAtual;
  late TextEditingController _metaPeso;
  late TextEditingController _restricoes;

  DateTime? _nascimento;
  String? _fotoPath;
  late Objetivo _objetivo;
  late NivelAtividade _nivelAtividade;
  late Set<Limitacao> _limitacoes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider) ?? AppUser.demo();
    final profile = ref.read(trainerProfileProvider);
    _nome = TextEditingController(text: user.name);
    _altura = TextEditingController(
        text: user.height != null ? (user.height! * 100).toStringAsFixed(0) : '');
    _pesoAtual =
        TextEditingController(text: user.currentWeight?.toStringAsFixed(1) ?? '');
    _metaPeso =
        TextEditingController(text: user.goalWeight?.toStringAsFixed(1) ?? '');
    _restricoes =
        TextEditingController(text: profile.restricoesAlimentares.join(', '));
    _nascimento = user.birthDate;
    _fotoPath = user.photoUrl;
    _objetivo = profile.objetivo;
    _nivelAtividade = profile.nivelAtividade;
    _limitacoes = {...profile.limitacoes};
  }

  @override
  void dispose() {
    _nome.dispose();
    _altura.dispose();
    _pesoAtual.dispose();
    _metaPeso.dispose();
    _restricoes.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              title: const Text('Câmera', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.white),
              title: const Text('Galeria', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final xfile = await ImagePicker()
        .pickImage(source: source, imageQuality: 80, maxWidth: 800);
    if (xfile == null) return;

    final docsDir = await getApplicationDocumentsDirectory();
    final folder = Directory('${docsDir.path}/avatar');
    if (!await folder.exists()) await folder.create(recursive: true);
    final savedPath =
        '${folder.path}/${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(xfile.path).copy(savedPath);
    setState(() => _fotoPath = savedPath);
  }

  Future<void> _pickNascimento() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nascimento ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _nascimento = picked);
  }

  Future<void> _salvar() async {
    final user = ref.read(currentUserProvider) ?? AppUser.demo();

    double? parse(String s) => double.tryParse(s.trim().replaceAll(',', '.'));
    final alturaCm = parse(_altura.text);
    final peso = parse(_pesoAtual.text);
    final meta = parse(_metaPeso.text);

    if (_nome.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Informe seu nome.')));
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(profileUpdaterProvider)(user.copyWith(
        name: _nome.text.trim(),
        birthDate: _nascimento,
        photoUrl: _fotoPath,
        height: alturaCm != null ? alturaCm / 100 : null,
        currentWeight: peso,
        goalWeight: meta,
      ));

      final restricoesSet = _restricoes.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet();

      await ref.read(trainerProfileProvider.notifier).update(
            ref.read(trainerProfileProvider).copyWith(
                  objetivo: _objetivo,
                  nivelAtividade: _nivelAtividade,
                  limitacoes: _limitacoes.isEmpty
                      ? {Limitacao.nenhuma}
                      : _limitacoes,
                  restricoesAlimentares: restricoesSet,
                  alturaM: alturaCm != null ? alturaCm / 100 : null,
                  pesoKg: peso,
                  pesoDesejado: meta,
                ),
          );

      await FeedbackService.play(FeedbackEvent.sucesso);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado! ✨')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text('Editar perfil',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PressableScale(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(Icons.close,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  Center(
                    child: PressableScale(
                      onTap: _escolherFoto,
                      child: Stack(
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 96,
                              height: 96,
                              child: _fotoPath != null
                                  ? Image.file(File(_fotoPath!), fit: BoxFit.cover)
                                  : const LiliMascot(
                                      pose: MascotePose.perfil, height: 96),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Field(label: 'Nome', controller: _nome),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickNascimento,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Data de nascimento'),
                      child: Text(
                        _nascimento != null
                            ? DateFormatBr.data(_nascimento!)
                            : 'Toque para escolher',
                        style: TextStyle(
                            color: _nascimento != null
                                ? Colors.white
                                : AppColors.textTertiary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          child: _Field(
                              label: 'Altura (cm)',
                              controller: _altura,
                              numeric: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _Field(
                              label: 'Peso atual (kg)',
                              controller: _pesoAtual,
                              numeric: true)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Field(
                      label: 'Meta de peso (kg)',
                      controller: _metaPeso,
                      numeric: true),
                  const SizedBox(height: 20),
                  const Text('Objetivo',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final o in Objetivo.values)
                        ChoiceChip(
                          label: Text(o.label),
                          selected: _objetivo == o,
                          onSelected: (_) => setState(() => _objetivo = o),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Nível de atividade',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final n in NivelAtividade.values)
                        ChoiceChip(
                          label: Text(n.label),
                          selected: _nivelAtividade == n,
                          onSelected: (_) =>
                              setState(() => _nivelAtividade = n),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Preferências de treino (limitações físicas)',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final l in Limitacao.values)
                        FilterChip(
                          label: Text(l.label),
                          selected: _limitacoes.contains(l),
                          onSelected: (sel) => setState(() {
                            if (l == Limitacao.nenhuma) {
                              _limitacoes = {Limitacao.nenhuma};
                              return;
                            }
                            _limitacoes.remove(Limitacao.nenhuma);
                            sel
                                ? _limitacoes.add(l)
                                : _limitacoes.remove(l);
                            if (_limitacoes.isEmpty) {
                              _limitacoes = {Limitacao.nenhuma};
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _Field(
                    label: 'Restrições alimentares (separadas por vírgula)',
                    controller: _restricoes,
                    hint: 'ex.: lactose, glúten',
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saving ? null : _salvar,
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Salvar alterações'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.numeric = false,
    this.hint,
  });
  final String label;
  final TextEditingController controller;
  final bool numeric;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          numeric ? const TextInputType.numberWithOptions(decimal: true) : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
