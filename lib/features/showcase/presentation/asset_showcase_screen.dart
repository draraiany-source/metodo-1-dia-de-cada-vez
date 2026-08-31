import 'package:flutter/material.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/assets/app_icons_pack2.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/lili_content_widgets.dart';

/// Catálogo visual do Design System / biblioteca de assets Lili Fit.
/// Renderiza ícones, badges, banners, backgrounds e animações Lottie reais.
class AssetShowcaseScreen extends StatelessWidget {
  const AssetShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System · Lili Fit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AppLogo(width: 200),
          const SizedBox(height: 20),

          _title(context, 'Ícones (25)'),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final ic in AppAssets.allIcons)
                LiliIcon(ic, size: 30, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 24),

          _title(context, 'Medalhas'),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                LiliMedal(tier: 'bronze', label: 'Bronze'),
                SizedBox(width: 14),
                LiliMedal(tier: 'prata', label: 'Prata'),
                SizedBox(width: 14),
                LiliMedal(tier: 'ouro', label: 'Ouro'),
                SizedBox(width: 14),
                LiliMedal(tier: 'diamante', label: 'Diamante'),
                SizedBox(width: 14),
                LiliMedal(tier: 'elite', label: 'Elite'),
                SizedBox(width: 14),
                LiliMedal(tier: 'master', label: 'Master'),
                SizedBox(width: 14),
                LiliMedal(tier: 'lendario', label: 'Lendário'),
                SizedBox(width: 14),
                LiliMedal(tier: 'premium', label: 'Premium'),
                SizedBox(width: 14),
                LiliMedal(tier: 'vip', label: 'VIP'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _title(context, 'Conquistas'),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                LiliAchievement(id: 'primeiro_treino'),
                SizedBox(width: 14),
                LiliAchievement(id: '7_dias'),
                SizedBox(width: 14),
                LiliAchievement(id: '30_dias'),
                SizedBox(width: 14),
                LiliAchievement(id: '365_dias'),
                SizedBox(width: 14),
                LiliAchievement(id: 'meta_concluida'),
                SizedBox(width: 14),
                LiliAchievement(id: 'constancia'),
                SizedBox(width: 14),
                LiliAchievement(id: 'superacao'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _title(context, 'Banners'),
          const LiliBanner(id: 'treinos'),
          const SizedBox(height: 12),
          const LiliBanner(id: 'premium'),
          const SizedBox(height: 12),
          const LiliBanner(id: 'desafios'),
          const SizedBox(height: 16),

          _title(context, 'Animações Lottie'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                LiliAnimation(AppAssets.animLoading, size: 80),
                const Text('loading', style: TextStyle(fontSize: 11)),
              ]),
              Column(children: [
                LiliAnimation(AppAssets.animHeartPulse, size: 80),
                const Text('heart', style: TextStyle(fontSize: 11)),
              ]),
              Column(children: [
                LiliAnimation(AppAssets.animSuccessCheck, size: 80, repeat: false),
                const Text('check', style: TextStyle(fontSize: 11)),
              ]),
              Column(children: [
                LiliAnimation(AppAssets.animLevelUp, size: 80),
                const Text('level up', style: TextStyle(fontSize: 11)),
              ]),
            ],
          ),
          const SizedBox(height: 24),

          _title(context, 'Componentes'),
          LiliButton(label: 'Botão primário', icon: Icons.bolt, onPressed: () {}),
          const SizedBox(height: 10),
          const LiliButton(label: 'Botão desabilitado', onPressed: null),
          const SizedBox(height: 12),
          LiliCard(
            child: Row(
              children: [
                LiliIcon(AppAssets.icTreinos, color: AppColors.secondary),
                const SizedBox(width: 12),
                const Expanded(
                    child: Text('LiliCard — card padrão com sombra premium',
                        style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _title(context, 'Mascote Lili (15 poses reais)'),
          const Center(child: LiliMascot(pose: MascotePose.padrao, height: 240)),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                LiliMascot(pose: MascotePose.boasVindas, height: 130),
                SizedBox(width: 10),
                LiliMascot(pose: MascotePose.joinha, height: 130),
                SizedBox(width: 10),
                LiliMascot(pose: MascotePose.halteres, height: 130),
                SizedBox(width: 10),
                LiliMascot(pose: MascotePose.meditacao, height: 130),
                SizedBox(width: 10),
                LiliMascot(pose: MascotePose.trofeu, height: 130),
                SizedBox(width: 10),
                LiliMascot(pose: MascotePose.celebrando, height: 130),
                SizedBox(width: 10),
                LiliMascot(pose: MascotePose.rainha, height: 130),
                SizedBox(width: 10),
                LiliMascot(pose: MascotePose.triste, height: 130),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _title(context, 'Cenas (onboarding / vazio)'),
          const LiliScene(emoji: '💜', title: 'Bem-vinda ao Lili Fit!'),
          const SizedBox(height: 12),
          const LiliScene(
            emoji: '🏋️',
            title: 'Nenhum treino ainda',
            subtitle: 'Comece hoje, um dia de cada vez',
          ),
          const SizedBox(height: 24),

          _title(context, 'Ícones oficiais — pacote 1 (3D)'),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final path in AppIcons.all3d)
                SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      AppIconImage(path, size: 44),
                      const SizedBox(height: 4),
                      Text(
                        path.split('/').last.replaceAll('icon_', '').replaceAll('.png', ''),
                        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          _title(context, 'Ícones oficiais — pacote 2 (sistema)'),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final path in AppIconsPack2.all)
                SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      AppIconImage(path, size: 44),
                      const SizedBox(height: 4),
                      Text(
                        path.split('/').last.replaceAll('icon_', '').replaceAll('.png', ''),
                        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _title(BuildContext c, String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(t, style: Theme.of(c).textTheme.titleMedium),
      );
}
