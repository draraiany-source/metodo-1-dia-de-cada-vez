import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../domain/trainer_engine.dart';
import '../providers/ai_trainer_providers.dart';

/// Perfil físico usado pela IA para personalizar treinos e nutrição.
class AiProfileScreen extends ConsumerStatefulWidget {
  const AiProfileScreen({super.key});

  @override
  ConsumerState<AiProfileScreen> createState() => _AiProfileScreenState();
}

class _AiProfileScreenState extends ConsumerState<AiProfileScreen> {
  late TrainerProfile _p;

  @override
  void initState() {
    super.initState();
    _p = ref.read(trainerProfileProvider);
  }

  void _save() {
    ref.read(trainerProfileProvider.notifier).update(_p);
    FeedbackService.play(FeedbackEvent.sucesso);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Perfil atualizado! A Amanda já se adaptou 💜'),
          backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PremiumAppBar(title: 'Meu perfil físico'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                const AnimatedLiliMascot(
                    pose: MascotePose.checklist,
                    mood: LiliMood.respirando,
                    height: 84),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Quanto mais eu souber sobre você, mais preciso fica o seu treino.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _label('Idade: ${_p.idade} anos'),
            Slider(
              value: _p.idade.toDouble(),
              min: 14,
              max: 80,
              divisions: 66,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _p = _p.copyWith(idade: v.round())),
            ),

            _label('Peso: ${_p.pesoKg.toStringAsFixed(1)} kg'),
            Slider(
              value: _p.pesoKg,
              min: 40,
              max: 150,
              divisions: 110,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _p = _p.copyWith(pesoKg: v)),
            ),

            _label('Altura: ${_p.alturaM.toStringAsFixed(2)} m'),
            Slider(
              value: _p.alturaM,
              min: 1.40,
              max: 2.10,
              divisions: 70,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _p = _p.copyWith(alturaM: v)),
            ),

            _label('Treinos por semana: ${_p.diasPorSemana}x'),
            Slider(
              value: _p.diasPorSemana.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: AppColors.primary,
              onChanged: (v) =>
                  setState(() => _p = _p.copyWith(diasPorSemana: v.round())),
            ),
            const SizedBox(height: 8),

            _label('Sexo (para cálculos metabólicos)'),
            Wrap(
              spacing: 8,
              children: [
                for (final s in Sexo.values)
                  ChoiceChip(
                    label: Text(s == Sexo.feminino ? 'Feminino' : 'Masculino'),
                    selected: _p.sexo == s,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => setState(() => _p = _p.copyWith(sexo: s)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Objetivo'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in Objetivo.values)
                  ChoiceChip(
                    label: Text(o.label),
                    selected: _p.objetivo == o,
                    selectedColor: AppColors.primary,
                    onSelected: (_) =>
                        setState(() => _p = _p.copyWith(objetivo: o)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Nível físico'),
            Wrap(
              spacing: 8,
              children: [
                for (final n in NivelFisico.values)
                  ChoiceChip(
                    label: Text(n.label),
                    selected: _p.nivel == n,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => setState(() => _p = _p.copyWith(nivel: n)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Limitações físicas (a IA adapta os exercícios)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final l in Limitacao.values)
                  FilterChip(
                    label: Text(l.label),
                    selected: _p.limitacoes.contains(l),
                    selectedColor: AppColors.secondary,
                    onSelected: (sel) => setState(() {
                      final set = Set<Limitacao>.from(_p.limitacoes);
                      if (l == Limitacao.nenhuma) {
                        _p = _p.copyWith(limitacoes: {Limitacao.nenhuma});
                        return;
                      }
                      set.remove(Limitacao.nenhuma);
                      sel ? set.add(l) : set.remove(l);
                      if (set.isEmpty) set.add(Limitacao.nenhuma);
                      _p = _p.copyWith(limitacoes: set);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            const Text('🥗 Perfil nutricional',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _label('Peso inicial (kg) — opcional'),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: TextEditingController(
                  text: _p.pesoInicial?.toStringAsFixed(1) ?? ''),
              onChanged: (v) => _p = _p.copyWith(
                  pesoInicial: double.tryParse(v.replaceAll(',', '.'))),
            ),
            const SizedBox(height: 12),

            _label('Peso desejado (kg) — opcional'),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: TextEditingController(
                  text: _p.pesoDesejado?.toStringAsFixed(1) ?? ''),
              onChanged: (v) => _p = _p.copyWith(
                  pesoDesejado: double.tryParse(v.replaceAll(',', '.'))),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('% de gordura — opcional'),
                      TextField(
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        controller: TextEditingController(
                            text: _p.percentualGordura?.toStringAsFixed(1) ?? ''),
                        onChanged: (v) => _p = _p.copyWith(
                            percentualGordura:
                                double.tryParse(v.replaceAll(',', '.'))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Massa muscular (kg) — opcional'),
                      TextField(
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        controller: TextEditingController(
                            text: _p.massaMuscularKg?.toStringAsFixed(1) ?? ''),
                        onChanged: (v) => _p = _p.copyWith(
                            massaMuscularKg:
                                double.tryParse(v.replaceAll(',', '.'))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Nível de atividade física (usado no TDEE)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final n in NivelAtividade.values)
                  ChoiceChip(
                    label: Text(n.label),
                    selected: _p.nivelAtividade == n,
                    selectedColor: AppColors.primary,
                    onSelected: (_) =>
                        setState(() => _p = _p.copyWith(nivelAtividade: n)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Tipo de dieta'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in TipoDieta.values)
                  ChoiceChip(
                    label: Text(t.label),
                    selected: _p.tipoDieta == t,
                    selectedColor: AppColors.primary,
                    onSelected: (_) =>
                        setState(() => _p = _p.copyWith(tipoDieta: t)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            _TagInput(
              label: 'Restrições alimentares (ex.: glúten, lactose)',
              tags: _p.restricoesAlimentares,
              onChanged: (tags) =>
                  setState(() => _p = _p.copyWith(restricoesAlimentares: tags)),
            ),
            const SizedBox(height: 16),

            _TagInput(
              label: 'Alergias',
              tags: _p.alergias,
              onChanged: (tags) =>
                  setState(() => _p = _p.copyWith(alergias: tags)),
            ),
            const SizedBox(height: 16),

            _TagInput(
              label: 'Preferências alimentares (ex.: frango, aveia)',
              tags: _p.preferenciasAlimentares,
              onChanged: (tags) => setState(
                  () => _p = _p.copyWith(preferenciasAlimentares: tags)),
            ),
            const SizedBox(height: 16),

            _label('Fórmula da taxa metabólica basal'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Mifflin-St Jeor'),
                  selected: _p.formulaTmb == FormulaTmb.mifflinStJeor,
                  selectedColor: AppColors.primary,
                  onSelected: (_) => setState(
                      () => _p = _p.copyWith(formulaTmb: FormulaTmb.mifflinStJeor)),
                ),
                ChoiceChip(
                  label: const Text('Harris-Benedict'),
                  selected: _p.formulaTmb == FormulaTmb.harrisBenedict,
                  selectedColor: AppColors.primary,
                  onSelected: (_) => setState(
                      () => _p = _p.copyWith(formulaTmb: FormulaTmb.harrisBenedict)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Resumo calculado pela IA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('O que eu calculei para você',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _info('IMC', _p.imc.toStringAsFixed(1)),
                  _info('Peso ideal estimado', '${_p.pesoIdealKg.toStringAsFixed(1)} kg'),
                  _info('Taxa metabólica basal',
                      '${_p.tmb.round()} kcal/dia'),
                  _info('Gasto total diário (TDEE)',
                      '${_p.tdee.round()} kcal/dia'),
                  _info(
                      _p.ajusteCalorico < 0
                          ? 'Déficit calórico sugerido'
                          : _p.ajusteCalorico > 0
                              ? 'Superávit calórico sugerido'
                              : 'Ajuste calórico',
                      '${_p.ajusteCalorico.round()} kcal/dia'),
                  _info('Meta calórica diária', '${_p.metaCalorica.round()} kcal'),
                  _info('Meta de proteína', '${_p.metaProteinaG.round()} g'),
                  _info('Meta de carboidratos', '${_p.metaCarboidratoG.round()} g'),
                  _info('Meta de gordura', '${_p.metaGorduraG.round()} g'),
                  _info('Meta de fibras', '${_p.metaFibraG.round()} g'),
                  _info('Água recomendada',
                      '${_p.aguaLitros} L (${_p.aguaCopos} copos)'),
                  if (_p.progressoPesoKg != null)
                    _info(
                        _p.progressoPesoKg! <= 0 ? 'Perdido até agora' : 'Ganho até agora',
                        '${_p.progressoPesoKg!.abs().toStringAsFixed(1)} kg'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Salvar perfil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      );

  Widget _info(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: Colors.white70)),
            Text(v,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

/// Campo de tags simples (restrições/alergias/preferências) — digita e
/// aperta enter/vírgula pra criar um chip removível.
class _TagInput extends StatefulWidget {
  const _TagInput(
      {required this.label, required this.tags, required this.onChanged});
  final String label;
  final Set<String> tags;
  final ValueChanged<Set<String>> onChanged;

  @override
  State<_TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<_TagInput> {
  final _controller = TextEditingController();

  void _add(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    widget.onChanged({...widget.tags, v});
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(widget.label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Digite e pressione enter'),
          onSubmitted: _add,
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags
                .map((t) => Chip(
                      label: Text(t),
                      backgroundColor: AppColors.secondary.withOpacity(0.2),
                      onDeleted: () =>
                          widget.onChanged({...widget.tags}..remove(t)),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
