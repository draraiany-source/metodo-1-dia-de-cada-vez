import 'package:flutter/material.dart';

import '../mascot/lily_catalog.dart';
import '../theme/app_colors.dart';
import 'lili_animated.dart';
import 'lily_character_widget.dart';

/// Sheet de conclusão com Lily — áudio ou meditação.
Future<void> showLilyJourneyCompleteSheet(
  BuildContext context, {
  required String message,
  String buttonLabel = 'Continuar',
  LilySituation situation = LilySituation.celebrating,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceDeep,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              LilyCharacterWidget(
                situation: situation,
                height: 160,
                mood: LiliMood.comemorando,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
