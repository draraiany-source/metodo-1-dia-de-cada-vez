import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../providers/progress_photos_providers.dart';

/// Página de Fotos de progresso — 100% privada e local (nunca sobe pra
/// nenhum servidor nem aparece em áreas públicas/sociais do app: os
/// arquivos ficam na pasta de documentos privada do próprio dispositivo,
/// ver [ProgressPhotosNotifier]).
class ProgressPhotosScreen extends ConsumerStatefulWidget {
  const ProgressPhotosScreen({super.key});

  @override
  ConsumerState<ProgressPhotosScreen> createState() =>
      _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends ConsumerState<ProgressPhotosScreen> {
  bool _saving = false;

  Future<void> _addPhoto(PhotoAngle angle) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: AppIconImage(AppIcons.camera, size: 24,
                  fallbackIcon: Icons.camera_alt_outlined),
              title: const Text('Câmera', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: AppIconImage(AppIcons.photos, size: 24,
                  fallbackIcon: Icons.photo_library_outlined),
              title: const Text('Galeria', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    setState(() => _saving = true);
    try {
      final saved =
          await ref.read(progressPhotosProvider.notifier).addFromSource(angle, source);
      if (saved) {
        await FeedbackService.play(FeedbackEvent.sucesso);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto salva com privacidade!')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmRemove(ProgressPhoto photo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Excluir foto?'),
        content: const Text(
            'Essa foto será apagada do dispositivo e não poderá ser recuperada.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(progressPhotosProvider.notifier).remove(photo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(progressPhotosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text('Fotos de evolução',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PressableScale(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: photos.isEmpty
                  ? _EmptyPhotos(saving: _saving, onAdd: _addPhoto)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      children: [
                        const _PrivacyBanner(),
                        const SizedBox(height: 16),
                        if (photos.length >= 2) ...[
                          Text('Antes e depois',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          _BeforeAfterRow(
                              before: photos.first, after: photos.last),
                          const SizedBox(height: 24),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Todas as fotos',
                                style: Theme.of(context).textTheme.titleMedium),
                            for (final angle in PhotoAngle.values)
                              PressableScale(
                                onTap: _saving ? null : () => _addPhoto(angle),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: Text('+ ${angle.label}',
                                        style: const TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: photos.length,
                          itemBuilder: (context, i) {
                            final p = photos[photos.length - 1 - i];
                            return FadeInUp(
                              delayMs: i * 30,
                              child: _PhotoTile(
                                photo: p,
                                onLongPress: () => _confirmRemove(p),
                              ),
                            );
                          },
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

class _PrivacyBanner extends StatelessWidget {
  const _PrivacyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: AppColors.info, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Suas fotos ficam só neste aparelho — nunca são enviadas ou '
              'exibidas publicamente.',
              style: TextStyle(color: AppColors.info, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeforeAfterRow extends StatelessWidget {
  const _BeforeAfterRow({required this.before, required this.after});
  final ProgressPhoto before;
  final ProgressPhoto after;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _ComparisonCard(label: 'Antes', photo: before)),
        const SizedBox(width: 12),
        Expanded(
            child: _ComparisonCard(label: 'Agora', photo: after)),
      ],
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.label, required this.photo});
  final String label;
  final ProgressPhoto photo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 0.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Image.file(File(photo.path), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        Text(DateFormatBr.data(photo.date),
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo, required this.onLongPress});
  final ProgressPhoto photo;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(photo.path), fit: BoxFit.cover),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(photo.angle.label,
                    style: const TextStyle(color: Colors.white, fontSize: 9)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPhotos extends StatelessWidget {
  const _EmptyPhotos({required this.saving, required this.onAdd});
  final bool saving;
  final ValueChanged<PhotoAngle> onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconImage(
              AppIcons.photos,
              size: 56,
              fallbackIcon: Icons.photo_camera_back_outlined,
            ),
            const SizedBox(height: 16),
            const Text(
                'Adicione suas primeiras fotos para acompanhar sua evolução.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const _PrivacyBanner(),
            const SizedBox(height: 20),
            if (saving)
              const CircularProgressIndicator(color: AppColors.secondary)
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final angle in PhotoAngle.values)
                    PressableScale(
                      onTap: () => onAdd(angle),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.heroPinkGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Adicionar ${angle.label}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
