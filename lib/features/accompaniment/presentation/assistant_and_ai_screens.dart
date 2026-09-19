import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/personal_ai_icons.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/feature_icon_card.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/accompaniment_models.dart';
import '../providers/accompaniment_providers.dart';

class MethodAssistantScreen extends ConsumerStatefulWidget {
  const MethodAssistantScreen({super.key});

  @override
  ConsumerState<MethodAssistantScreen> createState() =>
      _MethodAssistantScreenState();
}

class _MethodAssistantScreenState extends ConsumerState<MethodAssistantScreen> {
  final _text = TextEditingController();
  final _log = <({bool mine, String text})>[];
  bool _busy = false;
  bool _lastOffline = false;
  int _sendGen = 0;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final q = _text.text.trim();
    if (q.isEmpty || _busy) return;
    _text.clear();
    final gen = ++_sendGen;
    setState(() {
      _log.add((mine: true, text: q));
      _busy = true;
    });
    final result =
        await ref.read(accompanimentAiProvider).studentAssistant(q);
    if (!mounted || gen != _sendGen) return;
    setState(() {
      _log.add((mine: false, text: result.text));
      _busy = false;
      _lastOffline = result.usedOfflineFallback;
    });
  }

  void _cancel() {
    _sendGen++;
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PremiumAppBar(title: 'Assistente do Método'),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Assistente virtual com IA — este chat NÃO é a Amanda.',
              style: TextStyle(
                  color: AppColors.warning, fontWeight: FontWeight.w700),
            ),
          ),
          if (_lastOffline)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'A IA na nuvem não respondeu. Esta mensagem veio do modo local.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12, height: 1.35),
              ),
            ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Preparando resposta...',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FeatureIconCard(
                  icon: PersonalAiIcons.assistenteIA,
                  title: 'Assistente IA',
                  subtitle:
                      'Seu assistente inteligente para ajudar na organização da sua rotina e no uso do Método.',
                  variant: FeatureIconCardVariant.list,
                  iconSize: 64,
                  accent: AppColors.accent,
                  fallbackIcon: Icons.auto_awesome,
                ),
                const SizedBox(height: 12),
                for (final m in _log)
                  Align(
                    alignment:
                        m.mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: m.mine
                            ? AppColors.primary.withOpacity(0.3)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(m.text),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (_log.isNotEmpty &&
                      _log.last.text.contains('Amanda'))
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => context.push(Routes.faleComAmanda),
                        child: const Text('Enviar para Amanda'),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _text,
                          decoration: const InputDecoration(
                            hintText: 'Como usar o aplicativo?',
                          ),
                        ),
                      ),
                      if (_busy)
                        IconButton(
                          onPressed: _cancel,
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Cancelar',
                        )
                      else
                        IconButton(
                          onPressed: _send,
                          icon: const Icon(Icons.send_rounded),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainer = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final settings = ref.watch(aiSettingsProvider(trainer.id));
    return Scaffold(
      appBar: const PremiumAppBar(title: 'Inteligência Artificial'),
      body: AppPage(
        child: settings.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Não foi possível carregar.'),
          data: (s) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A IA organiza, resume e sugere. A decisão final continua sendo da Amanda.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              _sw(ref, trainer.id, s, 'Ativar IA', s.enabled, (v) =>
                  AiSettings(
                    enabled: v,
                    replySuggestions: s.replySuggestions,
                    anamnesisSummary: s.anamnesisSummary,
                    evolutionInsights: s.evolutionInsights,
                    consultSummary: s.consultSummary,
                    studentAssistant: s.studentAssistant,
                    workoutDraft: s.workoutDraft,
                  )),
              _sw(ref, trainer.id, s, 'Sugestões de resposta', s.replySuggestions,
                  (v) => AiSettings(
                        enabled: s.enabled,
                        replySuggestions: v,
                        anamnesisSummary: s.anamnesisSummary,
                        evolutionInsights: s.evolutionInsights,
                        consultSummary: s.consultSummary,
                        studentAssistant: s.studentAssistant,
                        workoutDraft: s.workoutDraft,
                      )),
              _sw(ref, trainer.id, s, 'Resumo automático de anamnese',
                  s.anamnesisSummary, (v) => AiSettings(
                    enabled: s.enabled,
                    replySuggestions: s.replySuggestions,
                    anamnesisSummary: v,
                    evolutionInsights: s.evolutionInsights,
                    consultSummary: s.consultSummary,
                    studentAssistant: s.studentAssistant,
                    workoutDraft: s.workoutDraft,
                  )),
              _sw(ref, trainer.id, s, 'Insights de evolução', s.evolutionInsights,
                  (v) => AiSettings(
                        enabled: s.enabled,
                        replySuggestions: s.replySuggestions,
                        anamnesisSummary: s.anamnesisSummary,
                        evolutionInsights: v,
                        consultSummary: s.consultSummary,
                        studentAssistant: s.studentAssistant,
                        workoutDraft: s.workoutDraft,
                      )),
              _sw(ref, trainer.id, s, 'Resumo de consultas', s.consultSummary,
                  (v) => AiSettings(
                        enabled: s.enabled,
                        replySuggestions: s.replySuggestions,
                        anamnesisSummary: s.anamnesisSummary,
                        evolutionInsights: s.evolutionInsights,
                        consultSummary: v,
                        studentAssistant: s.studentAssistant,
                        workoutDraft: s.workoutDraft,
                      )),
              _sw(ref, trainer.id, s, 'Assistente virtual das alunas',
                  s.studentAssistant, (v) => AiSettings(
                    enabled: s.enabled,
                    replySuggestions: s.replySuggestions,
                    anamnesisSummary: s.anamnesisSummary,
                    evolutionInsights: s.evolutionInsights,
                    consultSummary: s.consultSummary,
                    studentAssistant: v,
                    workoutDraft: s.workoutDraft,
                  )),
              _sw(ref, trainer.id, s, 'Rascunho de treino', s.workoutDraft,
                  (v) => AiSettings(
                        enabled: s.enabled,
                        replySuggestions: s.replySuggestions,
                        anamnesisSummary: s.anamnesisSummary,
                        evolutionInsights: s.evolutionInsights,
                        consultSummary: s.consultSummary,
                        studentAssistant: s.studentAssistant,
                        workoutDraft: v,
                      )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sw(
    WidgetRef ref,
    String trainerId,
    AiSettings current,
    String label,
    bool value,
    AiSettings Function(bool) next,
  ) {
    return SwitchListTile(
      title: Text(label),
      value: current.enabled ? value : false,
      onChanged: !current.enabled && label != 'Ativar IA'
          ? null
          : (v) async {
              await ref
                  .read(accompanimentRepositoryProvider)
                  .saveAiSettings(trainerId, next(v));
              ref.invalidate(aiSettingsProvider);
            },
    );
  }
}
