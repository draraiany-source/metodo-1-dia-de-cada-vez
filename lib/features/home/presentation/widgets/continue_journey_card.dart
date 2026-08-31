import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_gradients.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animations.dart';
import '../../../missions/providers/missions_providers.dart';
import '../../../personal_amanda/domain/amanda_asset_models.dart';
import '../../../personal_amanda/presentation/amanda_image.dart';

/// Cartão-herói da Home: mostra a Personal Amanda Lopes (foto real, quando
/// cadastrada — ver [AmandaImage]) junto de um botão "Continuar de onde
/// parei", que decide sozinho para onde levar a usuária com base no que
/// ainda falta fazer hoje (nada de texto fixo/genérico):
///
///  1. Treino de hoje ainda não feito     → Treinos
///  2. Refeição de hoje ainda não logada  → Nutrição
///  3. Água de hoje abaixo da meta        → Hidratação
///  4. Tudo em dia                        → Meu Plano (revisão/planejamento)
class ContinueJourneyCard extends ConsumerWidget {
  const ContinueJourneyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(missionsProvider);

    bool done(String id) {
      final def = MissionsCatalog.all.firstWhere((m) => m.id == id);
      return missions.progressOf(id).current >= def.target;
    }

    final (String label, String route) = missions.loading
        ? ('Ver meu plano de hoje', Routes.plan)
        : !done('d_treino')
            ? ('Continuar treino de hoje', Routes.workouts)
            : !done('d_refeicao')
                ? ('Registrar minha alimentação', Routes.nutrition)
                : !done('d_agua')
                    ? ('Registrar água', Routes.hydration)
                    : ('Ver meu plano de hoje', Routes.plan);

    return FadeInUp(
      delayMs: 40,
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppGradients.brand,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          // Foto real da Amanda (Firestore, com fallback elegante — nunca
          // usa a arte da Lili, que é uma personagem visualmente separada).
          const AmandaImage(
            category: AmandaAssetCategory.principal,
            size: 64,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sua personal',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Text('Amanda Lopes',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push(route),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5A189A),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
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
