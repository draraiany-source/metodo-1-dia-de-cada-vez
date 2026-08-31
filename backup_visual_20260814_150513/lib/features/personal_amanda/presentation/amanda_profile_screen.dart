import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/amanda_asset_models.dart';
import 'amanda_image.dart';

/// Perfil público da Amanda — quem ela é, pra dar rosto (dinâmico) à
/// personal trainer oficial do app.
class AmandaProfileScreen extends StatelessWidget {
  const AmandaProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amanda')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            const Center(
              child: AmandaImage(
                category: AmandaAssetCategory.profissional,
                size: 140,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Amanda',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const Text('Personal Trainer oficial · Método 1 Dia de Cada Vez',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sobre a Amanda',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text(
                    'Sua personal trainer virtual — monta treinos, adapta '
                    'sua alimentação, tira dúvidas e acompanha sua '
                    'evolução, um dia de cada vez.',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5),
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
