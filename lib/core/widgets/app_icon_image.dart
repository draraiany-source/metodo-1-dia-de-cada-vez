import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../assets/app_icons.dart';

/// ============================================================================
/// COMPONENTE REUTILIZÁVEL DE ÍCONE PNG.
///
/// Carrega os ícones PNG oficiais (transparentes) de forma segura e performática:
/// - `errorBuilder` → nunca deixa buraco na tela; cai no [fallbackIcon].
/// - `cacheWidth` → decodifica no tamanho de exibição (não carrega 1024² para
///   mostrar 24px), poupando memória em Android/iPhone.
/// - `Semantics` → acessível a leitores de tela (TalkBack/VoiceOver).
/// - Sem tint sobre o PNG colorido (regra visual do briefing).
///
/// Uso:
/// ```dart
/// AppIconImage(AppIcons.home, size: 28, semanticLabel: 'Início')
/// AppIconImage(AppIcons.premium, size: 40, onTap: () => ...)
/// ```
/// ============================================================================
class AppIconImage extends StatelessWidget {
  const AppIconImage(
    this.assetPath, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticLabel,
    this.borderRadius,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    this.onTap,
    this.filterQuality = FilterQuality.medium,
  });

  final String assetPath;

  /// Atalho para width = height = size.
  final double? size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;
  final BorderRadius? borderRadius;

  /// Ícone Material mostrado se o PNG falhar ao carregar.
  final IconData fallbackIcon;
  final VoidCallback? onTap;
  final FilterQuality filterQuality;

  double? get _w => width ?? size;
  double? get _h => height ?? size;

  @override
  Widget build(BuildContext context) {
    // Decodifica no tamanho de exibição (x devicePixelRatio) para economizar
    // memória. Só aplica quando há uma largura conhecida.
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
    final int? cacheW =
        _w != null ? (_w! * dpr).round().clamp(1, 1024) : null;

    Widget image = Image.asset(
      assetPath,
      width: _w,
      height: _h,
      fit: fit,
      filterQuality: filterQuality,
      cacheWidth: cacheW,
      errorBuilder: (context, error, stack) {
        if (kDebugMode) {
          debugPrint('AppIconImage falhou: $assetPath → $error');
        }
        return SizedBox(
          width: _w,
          height: _h,
          child: Icon(fallbackIcon, size: (_w ?? 24) * 0.85),
        );
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    // Acessibilidade: rotula quando informa algo; senão, decorativo.
    image = semanticLabel != null
        ? Semantics(label: semanticLabel, image: true, child: image)
        : ExcludeSemantics(child: image);

    if (onTap != null) {
      image = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        // Área de toque mínima confortável (acessibilidade).
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: image,
        ),
      );
    }

    return image;
  }
}

/// Favorito com PNG do catálogo — evita coração Material genérico.
class FavoriteAssetIcon extends StatelessWidget {
  const FavoriteAssetIcon({
    super.key,
    required this.active,
    this.size = 22,
  });

  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1 : 0.38,
      child: AppIconImage(
        AppIcons.favorite,
        size: size,
        fallbackIcon: Icons.bookmark_rounded,
        semanticLabel: active ? 'Favorito' : 'Favoritar',
      ),
    );
  }
}
