import 'package:flutter/material.dart';

import '../../../core/router/app_navigation.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/amanda_asset_models.dart';
import 'amanda_image.dart';

/// Banner grande da Home para a foto da Amanda (cover, cantos arredondados).
class AmandaHomeBanner extends StatelessWidget {
  const AmandaHomeBanner({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 700;
    final height = (size.width * (wide ? 0.26 : 0.38)).clamp(132.0, 200.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ??
            () => AppNavigation.open(context, Routes.amandaProfile),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(
                  child: AmandaImage(
                    category: AmandaAssetCategory.banner,
                    fallbacks: [
                      AmandaAssetCategory.profissional,
                      AmandaAssetCategory.principal,
                    ],
                    width: double.infinity,
                    height: double.infinity,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.zero,
                    fit: BoxFit.cover,
                    placeholderIcon: Icons.camera_alt_outlined,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.78),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: wide ? 22 : 16,
                  right: wide ? 22 : 16,
                  bottom: wide ? 18 : 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amanda Lopes',
                        style: AppTextStyles.h2().copyWith(
                          fontSize: wide ? 26 : 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Treinadora Pessoal On-line',
                        style: AppTextStyles.bodySecondary().copyWith(
                          color: Colors.white.withOpacity(0.88),
                          fontWeight: FontWeight.w600,
                          fontSize: wide ? 15 : 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
