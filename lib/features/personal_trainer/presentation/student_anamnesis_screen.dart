import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/personal_ai_icons.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';

/// Ficha de anamnese editável (Personal ou Aluno vinculado).
class StudentAnamnesisScreen extends ConsumerStatefulWidget {
  const StudentAnamnesisScreen({super.key, required this.student});
  final Student student;

  @override
  ConsumerState<StudentAnamnesisScreen> createState() =>
      _StudentAnamnesisScreenState();
}

class _StudentAnamnesisScreenState
    extends ConsumerState<StudentAnamnesisScreen> {
  late final TextEditingController _objective;
  late final TextEditingController _experience;
  late final TextEditingController _diseases;
  late final TextEditingController _injuries;
  late final TextEditingController _surgeries;
  late final TextEditingController _limitations;
  late final TextEditingController _medications;
  late final TextEditingController _pains;
  late final TextEditingController _availability;
  late final TextEditingController _location;
  late final TextEditingController _equipment;
  late final TextEditingController _notes;
  final Set<String> _weekDays = {};
  bool _hydrated = false;
  bool _saving = false;

  static const _dias = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];

  @override
  void initState() {
    super.initState();
    _objective = TextEditingController();
    _experience = TextEditingController();
    _diseases = TextEditingController();
    _injuries = TextEditingController();
    _surgeries = TextEditingController();
    _limitations = TextEditingController();
    _medications = TextEditingController();
    _pains = TextEditingController();
    _availability = TextEditingController();
    _location = TextEditingController();
    _equipment = TextEditingController();
    _notes = TextEditingController();
  }

  void _apply(StudentAnamnesis a) {
    _objective.text = a.mainObjective;
    _experience.text = a.trainingExperience;
    _diseases.text = a.diseases;
    _injuries.text = a.injuries;
    _surgeries.text = a.surgeries;
    _limitations.text = a.limitations;
    _medications.text = a.medications;
    _pains.text = a.pains;
    _availability.text = a.availability;
    _location.text = a.trainingLocation;
    _equipment.text = a.equipment;
    _notes.text = a.notes;
    _weekDays
      ..clear()
      ..addAll(a.weekDays);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(ptRepositoryProvider).saveAnamnesis(StudentAnamnesis(
            studentId: widget.student.id,
            trainerId: widget.student.trainerId,
            mainObjective: _objective.text.trim(),
            trainingExperience: _experience.text.trim(),
            diseases: _diseases.text.trim(),
            injuries: _injuries.text.trim(),
            surgeries: _surgeries.text.trim(),
            limitations: _limitations.text.trim(),
            medications: _medications.text.trim(),
            pains: _pains.text.trim(),
            availability: _availability.text.trim(),
            weekDays: _weekDays.toList(),
            trainingLocation: _location.text.trim(),
            equipment: _equipment.text.trim(),
            notes: _notes.text.trim(),
          ));
      ref.invalidate(ptAnamnesisProvider(widget.student.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anamnese salva.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _objective.dispose();
    _experience.dispose();
    _diseases.dispose();
    _injuries.dispose();
    _surgeries.dispose();
    _limitations.dispose();
    _medications.dispose();
    _pains.dispose();
    _availability.dispose();
    _location.dispose();
    _equipment.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(ptAnamnesisProvider(widget.student.id));
    async.whenData((a) {
      if (!_hydrated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _hydrated) return;
          _apply(a);
          setState(() => _hydrated = true);
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: 'Anamnese',
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '...' : 'Salvar',
                style: const TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
      body: SafeArea(
        child: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: AppIconImage(
                  PersonalAiIcons.anamnese,
                  size: 72,
                  fallbackIcon: Icons.assignment_outlined,
                  semanticLabel: 'Anamnese',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ficha de ${widget.student.name}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
              const SizedBox(height: 16),
              _field(_objective, 'Objetivo principal'),
              _field(_experience, 'Experiência com treino', maxLines: 2),
              _field(_diseases, 'Doenças'),
              _field(_injuries, 'Lesões'),
              _field(_surgeries, 'Cirurgias'),
              _field(_limitations, 'Limitações'),
              _field(_medications, 'Medicamentos'),
              _field(_pains, 'Dores'),
              _field(_availability, 'Disponibilidade para treino', maxLines: 2),
              const Text('Dias da semana',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in _dias)
                    FilterChip(
                      label: Text(d),
                      selected: _weekDays.contains(d),
                      onSelected: (v) => setState(() {
                        if (v) {
                          _weekDays.add(d);
                        } else {
                          _weekDays.remove(d);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _field(_location, 'Local de treino'),
              _field(_equipment, 'Equipamentos disponíveis', maxLines: 2),
              _field(_notes, 'Observações', maxLines: 3),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_saving ? 'Salvando...' : 'Salvar anamnese'),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
