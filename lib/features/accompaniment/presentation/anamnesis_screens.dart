import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/personal_ai_icons.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/utils/firebase_error_mapper.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/feature_icon_card.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../personal_trainer/domain/pt_models.dart';
import '../../personal_trainer/providers/pt_providers.dart';
import '../domain/accompaniment_models.dart';
import '../domain/anamnesis_attention.dart';
import '../providers/accompaniment_providers.dart';

class AnamnesisConsentScreen extends ConsumerStatefulWidget {
  const AnamnesisConsentScreen({super.key});

  @override
  ConsumerState<AnamnesisConsentScreen> createState() =>
      _AnamnesisConsentScreenState();
}

class _AnamnesisConsentScreenState
    extends ConsumerState<AnamnesisConsentScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final student = ref
        .watch(ptMyStudentProfileProvider((userId: user.id, email: user.email)))
        .valueOrNull;

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Consentimento'),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: AppIconImage(
                PersonalAiIcons.anamnese,
                size: 80,
                fallbackIcon: Icons.assignment_outlined,
                semanticLabel: 'Anamnese',
              ),
            ),
            const SizedBox(height: 12),
            const Text('Consentimento para tratamento dos dados',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text(
              'Os dados da anamnese serão usados para planejamento do acompanhamento, '
              'personalização dos treinos, avaliação da evolução e comunicação com a Personal. '
              'Somente você, a Amanda e administradores autorizados podem acessá-los.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              title: const Text(
                'Li e concordo com o tratamento dos meus dados para as finalidades descritas.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Continuar',
              onPressed: !_agreed || student == null
                  ? null
                  : () async {
                      await ref.read(accompanimentRepositoryProvider).saveConsent(
                            userId: user.id,
                            studentId: student.id,
                          );
                      if (context.mounted) {
                        context.push(Routes.minhaAnamneseForm);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class AnamnesisFormScreen extends ConsumerStatefulWidget {
  const AnamnesisFormScreen({super.key, this.asTrainer = false, this.student});
  final bool asTrainer;
  final Student? student;

  @override
  ConsumerState<AnamnesisFormScreen> createState() => _AnamnesisFormScreenState();
}

class _AnamnesisFormScreenState extends ConsumerState<AnamnesisFormScreen> {
  final _goal = TextEditingController();
  final _profession = TextEditingController();
  final _activity = TextEditingController();
  final _painWhen = TextEditingController();
  final _healthDetails = TextEditingController();
  final _meds = TextEditingController();
  final Set<String> _objectives = {};
  final Set<String> _conditions = {};
  final Set<String> _pains = {};
  final Map<String, int> _painScale = {};
  bool _chest = false;
  bool _faint = false;
  bool _short = false;
  bool _palp = false;
  bool _cardio = false;
  bool _restrict = false;
  bool _saving = false;
  bool _hydrated = false;

  static const _objOpts = [
    'Emagrecimento',
    'Hipertrofia',
    'Definição',
    'Condicionamento físico',
    'Ganho de força',
    'Saúde',
    'Qualidade de vida',
    'Retorno ao exercício',
    'Outro',
  ];
  static const _healthOpts = [
    'Hipertensão',
    'Diabetes',
    'Cardiopatia',
    'Asma',
    'Problemas de coluna',
    'Lesões articulares',
    'Cirurgias anteriores',
    'Gestação',
    'Pós-parto',
    'Outra',
    'Nenhuma',
  ];
  static const _painOpts = [
    'Cervical',
    'Ombro',
    'Cotovelo',
    'Punho',
    'Lombar',
    'Quadril',
    'Joelho',
    'Tornozelo',
    'Outra',
  ];

  @override
  void dispose() {
    _goal.dispose();
    _profession.dispose();
    _activity.dispose();
    _painWhen.dispose();
    _healthDetails.dispose();
    _meds.dispose();
    super.dispose();
  }

  Future<void> _save(Student student) async {
    if (_objectives.isEmpty && _goal.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o objetivo principal.')),
      );
      return;
    }
    setState(() => _saving = true);
    final q = AnamnesisQuestionnaire(
      profession: _profession.text,
      goalFreeText: _goal.text,
      activityType: _activity.text,
      healthConditions: _conditions.toList(),
      healthDetails: _healthDetails.text,
      usesMedication: _meds.text.trim().isNotEmpty,
      medicationDetails: _meds.text,
      hasPain: _pains.isNotEmpty,
      painRegions: _pains.toList(),
      painScale: _painScale,
      painWhen: _painWhen.text,
      chestPainOnEffort: _chest,
      fainting: _faint,
      shortness: _short,
      palpitations: _palp,
      cardiacDiagnosis: _cardio,
      exerciseRestriction: _restrict,
    );
    final score = ref.read(accompanimentRepositoryProvider).scoreQuestionnaire(q);
    try {
      final existing =
          await ref.read(ptRepositoryProvider).fetchAnamnesis(student.id);
      await ref.read(ptRepositoryProvider).saveAnamnesis(StudentAnamnesis(
            studentId: student.id,
            trainerId: student.trainerId,
            mainObjective: _objectives.join(', '),
            trainingExperience: existing.trainingExperience,
            diseases: _conditions.join(', '),
            injuries: existing.injuries,
            surgeries: existing.surgeries,
            limitations: existing.limitations,
            medications: _meds.text,
            pains: _pains.join(', '),
            availability: existing.availability,
            weekDays: existing.weekDays,
            trainingLocation: existing.trainingLocation,
            equipment: existing.equipment,
            notes: existing.notes,
            questionnaire: q.toMap(),
            attentionLevel: score.level.name,
            attentionReasons: score.flags.map((f) => f.reason).toList(),
          ));
      ref.invalidate(ptAnamnesisProvider(student.id));
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedLiliMascot(
                pose: MascotePose.checklist,
                mood: LiliMood.viva,
                height: 88,
              ),
              SizedBox(height: 12),
              Text('Tudo certo! 💜 Sua anamnese foi enviada para Amanda.',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar. ${FirebaseErrorMapper.toUserMessage(e)}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.student != null) {
      return _scaffoldFor(widget.student!);
    }
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final studentAsync = ref.watch(
      ptMyStudentProfileProvider((userId: user.id, email: user.email)),
    );
    return studentAsync.when(
      loading: () => const Scaffold(
        appBar: PremiumAppBar(title: 'Minha anamnese'),
        body: AppLoading(message: 'Abrindo a anamnese…'),
      ),
      error: (e, _) => Scaffold(
        appBar: const PremiumAppBar(title: 'Minha anamnese'),
        body: AppErrorState(
          title: 'Não foi possível abrir a anamnese',
          message: FirebaseErrorMapper.toUserMessage(e),
        ),
      ),
      data: (student) {
        if (student == null) {
          return const Scaffold(
            appBar: PremiumAppBar(title: 'Minha anamnese'),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Você ainda não está vinculada a uma Personal. '
                  'Peça para a Amanda cadastrar o mesmo e-mail desta conta.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
              ),
            ),
          );
        }
        return _scaffoldFor(student);
      },
    );
  }

  Widget _scaffoldFor(Student student) {
        final anam = ref.watch(ptAnamnesisProvider(student.id));
        return Scaffold(
          appBar: const PremiumAppBar(title: 'Minha anamnese'),
          body: anam.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Erro ao carregar.')),
            data: (a) {
              if (!_hydrated) {
                _hydrated = true;
                final q = AnamnesisQuestionnaire.fromMap(a.questionnaire);
                _goal.text = q.goalFreeText;
                _profession.text = q.profession;
                _activity.text = q.activityType;
                _painWhen.text = q.painWhen;
                _healthDetails.text = q.healthDetails;
                _meds.text = q.medicationDetails;
                _conditions.addAll(q.healthConditions);
                _pains.addAll(q.painRegions);
                _painScale.addAll(q.painScale);
                _chest = q.chestPainOnEffort;
                _faint = q.fainting;
                _short = q.shortness;
                _palp = q.palpitations;
                _cardio = q.cardiacDiagnosis;
                _restrict = q.exerciseRestriction;
                if (a.mainObjective.isNotEmpty) {
                  _objectives.addAll(a.mainObjective.split(', '));
                }
              }
              final needsNotice = _chest || _faint || _short || _cardio || _restrict;
              return AppPage(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: AppIconImage(
                        PersonalAiIcons.anamnese,
                        size: 80,
                        fallbackIcon: Icons.assignment_outlined,
                        semanticLabel: 'Anamnese',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _chips('Objetivo principal', _objOpts, _objectives),
                    _field('Qual é sua principal meta?', _goal),
                    _field('Profissão', _profession),
                    _field('Já pratica atividade física? Qual?', _activity),
                    _chips('Condições de saúde informadas', _healthOpts, _conditions),
                    _field('Descreva, se necessário', _healthDetails),
                    _field('Utiliza algum medicamento? Se sim, descreva.', _meds),
                    _chips('Você sente dor atualmente?', _painOpts, _pains),
                    if (_pains.isNotEmpty) ...[
                      const Text('Escala de dor (0 a 10)',
                          style: TextStyle(color: Colors.white)),
                      for (final p in _pains)
                        Row(
                          children: [
                            SizedBox(width: 90, child: Text(p)),
                            Expanded(
                              child: Slider(
                                value: (_painScale[p] ?? 0).toDouble(),
                                max: 10,
                                divisions: 10,
                                label: '${_painScale[p] ?? 0}',
                                onChanged: (v) =>
                                    setState(() => _painScale[p] = v.round()),
                              ),
                            ),
                          ],
                        ),
                      _field('Descreva quando a dor acontece.', _painWhen),
                    ],
                    SwitchListTile(
                      title: const Text('Dor no peito durante esforço'),
                      value: _chest,
                      onChanged: (v) => setState(() => _chest = v),
                    ),
                    SwitchListTile(
                      title: const Text('Desmaios'),
                      value: _faint,
                      onChanged: (v) => setState(() => _faint = v),
                    ),
                    SwitchListTile(
                      title: const Text('Falta de ar desproporcional'),
                      value: _short,
                      onChanged: (v) => setState(() => _short = v),
                    ),
                    SwitchListTile(
                      title: const Text('Palpitações'),
                      value: _palp,
                      onChanged: (v) => setState(() => _palp = v),
                    ),
                    SwitchListTile(
                      title: const Text('Diagnóstico cardíaco informado'),
                      value: _cardio,
                      onChanged: (v) => setState(() => _cardio = v),
                    ),
                    SwitchListTile(
                      title: const Text('Restrição médica para exercícios'),
                      value: _restrict,
                      onChanged: (v) => setState(() => _restrict = v),
                    ),
                    if (needsNotice ||
                        (widget.asTrainer && a.attentionReasons.isNotEmpty)) ...[
                      const SizedBox(height: 8),
                      FeatureIconCard(
                        icon: PersonalAiIcons.pontosAtencao,
                        title: 'Pontos de atenção',
                        subtitle: widget.asTrainer &&
                                a.attentionReasons.isNotEmpty
                            ? a.attentionReasons.join(' · ')
                            : AnamnesisAttention.professionalNotice,
                        variant: FeatureIconCardVariant.list,
                        accent: AppColors.warning,
                        fallbackIcon: Icons.warning_amber_outlined,
                        onPress: () {
                          showDialog<void>(
                            context: context,
                            builder: (d) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text('Pontos de atenção'),
                              content: Text(
                                widget.asTrainer &&
                                        a.attentionReasons.isNotEmpty
                                    ? a.attentionReasons.join('\n')
                                    : AnamnesisAttention.professionalNotice,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: _saving ? 'Salvando…' : 'Enviar anamnese',
                      onPressed: _saving ? null : () => _save(student),
                    ),
                    const SizedBox(height: 12),
                    FeatureIconCard(
                      icon: PersonalAiIcons.analisarIA,
                      title: 'Analisar anamnese com IA',
                      subtitle: widget.asTrainer
                          ? 'Preparar consulta com IA'
                          : 'A Amanda usa este resumo para a consulta',
                      variant: FeatureIconCardVariant.list,
                      accent: AppColors.primary,
                      fallbackIcon: Icons.auto_awesome,
                      onPress: () async {
                        final text =
                            await ref.read(accompanimentAiProvider).run(
                          action: 'anamnesis_summary',
                          payload: a.questionnaire,
                        );
                        if (!context.mounted) return;
                        await showDialog<void>(
                          context: context,
                          builder: (d) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: const Text('Análise com IA'),
                            content:
                                SingleChildScrollView(child: Text(text)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        );
  }

  Widget _field(String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          maxLines: 2,
          decoration: InputDecoration(labelText: label),
        ),
      );

  Widget _chips(String title, List<String> opts, Set<String> selected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in opts)
                FilterChip(
                  label: Text(o),
                  selected: selected.contains(o),
                  onSelected: (v) => setState(() {
                    if (v) {
                      selected.add(o);
                    } else {
                      selected.remove(o);
                    }
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
