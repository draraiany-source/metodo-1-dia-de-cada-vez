import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_assets.dart';
import '../mascot/mascot_config.dart';
import '../theme/app_colors.dart';
import '../design_system/app_gradients.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_shadows.dart';
import '../design_system/app_typography.dart';
import '../../features/mascot_lili/domain/lili_asset_models.dart';
import '../../features/mascot_lili/providers/lili_assets_providers.dart';

/// Ícone SVG do Lili Fit, com tint opcional (usa a paleta da marca).
class LiliIcon extends StatelessWidget {
  const LiliIcon(this.asset,
      {super.key,
      this.size = 24,
      this.color = AppColors.secondary,
      this.semanticLabel});
  final String asset;
  final double size;
  final Color color;

  /// Descrição para leitores de tela (null = ícone decorativo).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
    );
  }
}

/// Logo completo (wordmark) em SVG.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width = 200});
  final double width;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset(AppAssets.imgLogo, width: width);
}

/// Marca (símbolo) em SVG, para avatares/ícones pequenos.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 64});
  final double size;
  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset(AppAssets.imgLogoMark, width: size, height: size);
}

/// As 15 poses reais da mascote Lili (arte 3D fornecida).
enum MascotePose {
  perfil,
  padrao,
  boasVindas,
  apontando,
  joinha,
  hidratacao,
  checklist,
  halteres,
  forte,
  meditacao,
  coracao,
  triste,
  trofeu,
  celebrando,
  rainha,
}

/// Caminho da pose — arte nova em `assets/mascot/png/` com fallback legado.
String _mascoteAsset(MascotePose pose) {
  if (MascotConfig.useNewMascot) {
    final file = switch (pose) {
      MascotePose.perfil => 'mascot_profile.png',
      MascotePose.padrao => 'mascot_default.png',
      MascotePose.boasVindas => 'mascot_welcome.png',
      MascotePose.apontando => 'mascot_pointing.png',
      MascotePose.joinha => 'mascot_thumbs_up.png',
      MascotePose.hidratacao => 'mascot_hydration.png',
      MascotePose.checklist => 'mascot_checklist.png',
      MascotePose.halteres => 'mascot_dumbbell.png',
      MascotePose.forte => 'mascot_strong.png',
      MascotePose.meditacao => 'mascot_meditation.png',
      MascotePose.coracao => 'mascot_heart.png',
      MascotePose.triste => 'mascot_sad.png',
      MascotePose.trofeu => 'mascot_trophy.png',
      MascotePose.celebrando => 'mascot_celebrating.png',
      MascotePose.rainha => 'mascot_queen.png',
    };
    return 'assets/mascot/png/$file';
  }
  return switch (pose) {
    MascotePose.perfil => AppAssets.mascotePerfil,
    MascotePose.padrao => AppAssets.mascotePadrao,
    MascotePose.boasVindas => AppAssets.mascoteBoasVindas,
    MascotePose.apontando => AppAssets.mascoteApontando,
    MascotePose.joinha => AppAssets.mascoteJoinha,
    MascotePose.hidratacao => AppAssets.mascoteHidratacao,
    MascotePose.checklist => AppAssets.mascoteChecklist,
    MascotePose.halteres => AppAssets.mascoteHalteres,
    MascotePose.forte => AppAssets.mascoteForte,
    MascotePose.meditacao => AppAssets.mascoteMeditacao,
    MascotePose.coracao => AppAssets.mascoteCoracao,
    MascotePose.triste => AppAssets.mascoteTriste,
    MascotePose.trofeu => AppAssets.mascoteTrofeu,
    MascotePose.celebrando => AppAssets.mascoteCelebrando,
    MascotePose.rainha => AppAssets.mascoteRainha,
  };
}

/// Mascote Lili Fit — renderiza a pose 3D real correspondente ao contexto.
///
/// Se por algum motivo o asset não existir (build antigo/sem sync), cai para
/// a versão vetorial de placeholder — nunca quebra o layout.
/// Rótulo acessível (leitor de tela) para cada pose da mascote.
String _mascoteLabel(MascotePose pose) {
  final acao = switch (pose) {
    MascotePose.perfil => 'sorrindo',
    MascotePose.padrao => 'em pé',
    MascotePose.boasVindas => 'acenando',
    MascotePose.apontando => 'apontando',
    MascotePose.joinha => 'fazendo joinha',
    MascotePose.hidratacao => 'segurando uma garrafa de água',
    MascotePose.checklist => 'com uma prancheta de treino',
    MascotePose.halteres => 'levantando halteres',
    MascotePose.forte => 'em pose de força',
    MascotePose.meditacao => 'meditando',
    MascotePose.coracao => 'segurando um coração',
    MascotePose.triste => 'sentada, desanimada',
    MascotePose.trofeu => 'segurando um troféu',
    MascotePose.celebrando => 'comemorando',
    MascotePose.rainha => 'usando uma coroa',
  };
  return 'Lili, a mascote, $acao';
}

/// Mapeia cada pose estática pra uma categoria de asset dinâmico — é assim
/// que uma imagem cadastrada no painel admin passa a valer pra todas as
/// telas que já usam aquela pose, sem precisar editar nenhuma tela.
LiliAssetCategory liliCategoryForPose(MascotePose pose) {
  return switch (pose) {
    MascotePose.perfil => LiliAssetCategory.feliz,
    MascotePose.padrao => LiliAssetCategory.feliz,
    MascotePose.boasVindas => LiliAssetCategory.incentivando,
    MascotePose.apontando => LiliAssetCategory.incentivando,
    MascotePose.joinha => LiliAssetCategory.animada,
    MascotePose.hidratacao => LiliAssetCategory.incentivando,
    MascotePose.checklist => LiliAssetCategory.pensando,
    MascotePose.halteres => LiliAssetCategory.treinando,
    MascotePose.forte => LiliAssetCategory.treinando,
    MascotePose.meditacao => LiliAssetCategory.alongando,
    MascotePose.coracao => LiliAssetCategory.feliz,
    MascotePose.triste => LiliAssetCategory.pensando,
    MascotePose.trofeu => LiliAssetCategory.conquista,
    MascotePose.celebrando => LiliAssetCategory.comemorando,
    MascotePose.rainha => LiliAssetCategory.premium,
  };
}

class LiliMascot extends ConsumerWidget {
  const LiliMascot({
    super.key,
    this.pose = MascotePose.padrao,
    this.height = 220,
    this.fit = BoxFit.contain,
    this.category,
  });

  final MascotePose pose;
  final double height;
  final BoxFit fit;

  /// Categoria explícita pra buscar asset dinâmico — quando omitida, é
  /// derivada automaticamente de [pose] via [liliCategoryForPose].
  final LiliAssetCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(liliAssetsProvider);
    final efetiva = category ?? liliCategoryForPose(pose);

    final dinamico = assetsAsync.maybeWhen(
      data: (all) => bestLiliAssetFor(all, efetiva),
      orElse: () => null,
    );

    if (dinamico != null && dinamico.url.isNotEmpty) {
      switch (dinamico.type) {
        case LiliAssetType.lottie:
          return Lottie.network(
            dinamico.url,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _staticFallback(),
          );
        case LiliAssetType.imagem:
          return CachedNetworkImage(
            imageUrl: dinamico.url,
            height: height,
            fit: fit,
            placeholder: (_, __) => SizedBox(
                height: height,
                width: height,
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2))),
            errorWidget: (_, __, ___) => _staticFallback(),
          );
        case LiliAssetType.rive:
          // Rive ainda não integrado (pacote `rive` não é dependência do
          // projeto hoje) — cai pro estático até isso ser adicionado.
          return _staticFallback();
      }
    }

    return _staticFallback();
  }

  Widget _staticFallback() {
    return Image.asset(
      _mascoteAsset(pose),
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      alignment: Alignment.bottomCenter,
      semanticLabel: _mascoteLabel(pose),
      errorBuilder: (_, __, ___) {
        // Fallback legado se a arte nova falhar.
        final legacy = switch (pose) {
          MascotePose.perfil => AppAssets.mascotePerfil,
          MascotePose.padrao => AppAssets.mascotePadrao,
          MascotePose.boasVindas => AppAssets.mascoteBoasVindas,
          MascotePose.apontando => AppAssets.mascoteApontando,
          MascotePose.joinha => AppAssets.mascoteJoinha,
          MascotePose.hidratacao => AppAssets.mascoteHidratacao,
          MascotePose.checklist => AppAssets.mascoteChecklist,
          MascotePose.halteres => AppAssets.mascoteHalteres,
          MascotePose.forte => AppAssets.mascoteForte,
          MascotePose.meditacao => AppAssets.mascoteMeditacao,
          MascotePose.coracao => AppAssets.mascoteCoracao,
          MascotePose.triste => AppAssets.mascoteTriste,
          MascotePose.trofeu => AppAssets.mascoteTrofeu,
          MascotePose.celebrando => AppAssets.mascoteCelebrando,
          MascotePose.rainha => AppAssets.mascoteRainha,
        };
        return Image.asset(
          legacy,
          height: height,
          fit: fit,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => SvgPicture.asset(
            AppAssets.avatarLiliPlaceholder,
            height: height,
            semanticsLabel: _mascoteLabel(pose),
          ),
        );
      },
    );
  }
}

/// Fundo com gradiente/asset premium reutilizável.
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient = AppGradients.splash,
  });
  final Widget child;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}

/// Exibe uma badge/medalha SVG com sombra.
class BadgeView extends StatelessWidget {
  const BadgeView(this.asset, {super.key, this.size = 120, this.locked = false});
  final String asset;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final img = SvgPicture.asset(asset, width: size, height: size);
    return Opacity(
      opacity: locked ? 0.35 : 1,
      child: locked
          ? ColorFiltered(
              colorFilter: const ColorFilter.mode(
                  Colors.grey, BlendMode.saturation),
              child: img)
          : img,
    );
  }
}

/// Animação Lottie helper.
class LiliAnimation extends StatelessWidget {
  const LiliAnimation(this.asset,
      {super.key, this.size = 120, this.repeat = true});
  final String asset;
  final double size;
  final bool repeat;

  @override
  Widget build(BuildContext context) =>
      Lottie.asset(asset, width: size, height: size, repeat: repeat);
}

/// Botão primário da marca (gradiente + glow).
class LiliButton extends StatelessWidget {
  const LiliButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient = AppGradients.vibe,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: onPressed == null ? null : gradient,
          color: onPressed == null ? AppColors.surface2 : null,
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: onPressed == null ? null : AppShadows.glowPurple,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTypography.button),
          ],
        ),
      ),
    );
  }
}

/// Card padrão do design system.
class LiliCard extends StatelessWidget {
  const LiliCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}
