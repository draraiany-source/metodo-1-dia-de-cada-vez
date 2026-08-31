import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/gamification/providers/gamification_providers.dart';
import '../providers/lili_guide_provider.dart';
import '../services/feedback_service.dart';
import '../mascot/mascot_sizes.dart';
import '../theme/app_colors.dart';
import 'lili_animated.dart';
import 'lili_speech.dart';

/// A Lili como guia: reage ao estado real do app com expressão, fala e ação.
///
/// Basta soltar `const LiliGuide()` numa tela — ela lê `liliGuideProvider` e
/// se adapta sozinha (sequência perdida, missão pronta, meta batida, etc.).
class LiliGuide extends ConsumerStatefulWidget {
  const LiliGuide({
    super.key,
    this.mascotHeight = MascotSizes.guide,
    this.showCta = true,
  });

  final double mascotHeight;
  final bool showCta;

  @override
  ConsumerState<LiliGuide> createState() => _LiliGuideState();
}

class _LiliGuideState extends ConsumerState<LiliGuide> {
  bool _reagiuAQuebra = false;

  @override
  Widget build(BuildContext context) {
    final guide = ref.watch(liliGuideProvider);

    // Quando a sequência foi perdida, a Lili acolhe uma única vez e o app
    // limpa o sinal — ela não fica repetindo a má notícia.
    if (guide.situation == LiliSituation.sequenciaPerdida && !_reagiuAQuebra) {
      _reagiuAQuebra = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Vibração suave: acolhimento, não alarme.
        FeedbackService.play(FeedbackEvent.toqueLeve);
      });
    }

    // Celebra quando há recompensa esperando.
    final celebrando = guide.situation == LiliSituation.recompensaEsperando ||
        guide.situation == LiliSituation.metaPassosBatida;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: celebrando
              ? AppColors.secondary.withOpacity(0.45)
              : AppColors.primary.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: (celebrando ? AppColors.secondary : AppColors.primary)
                .withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedLiliMascot(
            pose: guide.pose,
            mood: guide.mood,
            height: widget.mascotHeight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LiliSpeechBubble(
              // Trocar a fala reinicia a digitação — é o gatilho natural.
              key: ValueKey(guide.fala),
              text: guide.fala,
              // Respeita quem desativou animações no sistema.
              animate: !MediaQuery.of(context).disableAnimations,
              trailing: (widget.showCta && guide.cta != null && guide.rota != null)
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                        ),
                        onPressed: () {
                          FeedbackService.play(FeedbackEvent.toqueLeve);
                          // Ao agir, a Lili para de falar da sequência perdida.
                          ref
                              .read(gamificationProvider.notifier)
                              .acknowledgeStreakBreak();
                          context.push(guide.rota!);
                        },
                        child: Text(guide.cta!,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
