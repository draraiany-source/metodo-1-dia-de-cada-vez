import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/amanda_asset_models.dart';
import '../providers/amanda_assets_providers.dart';
import 'amanda_image.dart';

/// Grade responsiva da galeria — abre foto em tela cheia ao toque.
class AmandaPhotoGallery extends ConsumerWidget {
  const AmandaPhotoGallery({
    super.key,
    required this.category,
    this.count = 3,
    this.aspectRatio = 0.82,
    this.fallbacks = const [],
  });

  final AmandaAssetCategory category;
  final int count;
  final double aspectRatio;
  final List<AmandaAssetCategory> fallbacks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(amandaAssetsProvider).valueOrNull ?? const [];
    final list = amandaAssetsFor(all, category);
    final n = list.isEmpty ? count.clamp(2, 4) : list.length.clamp(1, 12);

    return LayoutBuilder(builder: (context, c) {
      final gap = 10.0;
      final cols = c.maxWidth >= 520 ? 3 : 2;
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var i = 0; i < n; i++)
            SizedBox(
              width: w,
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: GestureDetector(
                  onTap: list.isEmpty || i >= list.length
                      ? null
                      : () => _openLightbox(context, list, i),
                  child: AmandaImage(
                    category: category,
                    fallbacks: fallbacks,
                    assetIndex: i,
                    width: w,
                    height: w / aspectRatio,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                    fit: BoxFit.cover,
                    placeholderIcon: Icons.add_photo_alternate_outlined,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// Galeria completa (várias categorias) com lightbox.
class AmandaFullGalleryGrid extends ConsumerWidget {
  const AmandaFullGalleryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(amandaAssetsProvider).valueOrNull ?? const [];
    final list = amandaPublicGallery(all);

    if (list.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'Galeria em breve — fotos cadastradas no painel aparecem aqui.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return LayoutBuilder(builder: (context, c) {
      final gap = 10.0;
      final cols = c.maxWidth >= 520 ? 3 : 2;
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var i = 0; i < list.length; i++)
            SizedBox(
              width: w,
              child: AspectRatio(
                aspectRatio: 0.85,
                child: GestureDetector(
                  onTap: () => _openLightbox(context, list, i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: list[i].url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const ColoredBox(color: AppColors.surface2),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: AppColors.surface2,
                        child: Icon(Icons.broken_image_outlined,
                            color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

void _openLightbox(
    BuildContext context, List<AmandaAsset> list, int initialIndex) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _AmandaLightbox(
        urls: list.map((e) => e.url).toList(),
        initialIndex: initialIndex,
      ),
    ),
  );
}

class _AmandaLightbox extends StatefulWidget {
  const _AmandaLightbox({required this.urls, required this.initialIndex});
  final List<String> urls;
  final int initialIndex;

  @override
  State<_AmandaLightbox> createState() => _AmandaLightboxState();
}

class _AmandaLightboxState extends State<_AmandaLightbox> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${_index + 1} / ${widget.urls.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: CachedNetworkImage(
              imageUrl: widget.urls[i],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class AmandaPhotoSection extends StatelessWidget {
  const AmandaPhotoSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12.5, height: 1.35)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class AmandaMainPortrait extends StatelessWidget {
  const AmandaMainPortrait({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final height = (w * 0.95).clamp(220.0, 360.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: AmandaImage(
        category: AmandaAssetCategory.capa,
        fallbacks: const [
          AmandaAssetCategory.profissional,
          AmandaAssetCategory.banner,
          AmandaAssetCategory.principal,
        ],
        width: w,
        height: height,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        fit: BoxFit.cover,
        placeholderIcon: Icons.person_outline_rounded,
      ),
    );
  }
}
