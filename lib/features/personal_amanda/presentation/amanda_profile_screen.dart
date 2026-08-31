import 'package:flutter/material.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import 'amanda_photo_gallery.dart';
import '../domain/amanda_asset_models.dart';

/// Perfil público — Quem Sou Eu, com espaços para fotos reais da Amanda.
class AmandaProfileScreen extends StatelessWidget {
  const AmandaProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Quem Sou Eu'),
      body: SafeArea(
        child: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AmandaMainPortrait(),
              const SizedBox(height: 16),
              const Center(
                child: AppIconImage(
                  AppIcons.personal,
                  size: 48,
                  fallbackIcon: Icons.sports_gymnastics_rounded,
                  semanticLabel: 'Personal Amanda',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Amanda Lopes',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Treinadora Pessoal On-line',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
              const SizedBox(height: 6),
              const Text(
                'Método 1 Dia de Cada Vez',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sobre a Amanda',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Text(
                      'Personal trainer oficial do aplicativo. Monta treinos, '
                      'orienta a alimentação, tira dúvidas e acompanha a sua '
                      'evolução — um dia de cada vez.',
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const AmandaPhotoSection(
                title: 'Galeria',
                subtitle: 'Fotos extras da Amanda. Os espaços ficam prontos '
                    'até as imagens serem cadastradas.',
                child: AmandaPhotoGallery(
                  category: AmandaAssetCategory.galeria,
                  count: 3,
                ),
              ),
              const SizedBox(height: 24),
              const AmandaPhotoSection(
                title: 'Trajetória profissional',
                subtitle: 'Formação, certificações e momentos da carreira.',
                child: AmandaPhotoGallery(
                  category: AmandaAssetCategory.trajetoria,
                  count: 3,
                  aspectRatio: 1,
                ),
              ),
              const SizedBox(height: 24),
              const AmandaPhotoSection(
                title: 'Treinos e atendimentos',
                subtitle: 'Registros de treinos, orientação e acompanhamento.',
                child: AmandaPhotoGallery(
                  category: AmandaAssetCategory.treinos,
                  count: 3,
                  aspectRatio: 1,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
