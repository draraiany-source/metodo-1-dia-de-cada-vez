import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Diálogo de confirmação antes de desativar / remover conteúdo (soft delete).
Future<bool> confirmDeactivate(
  BuildContext context, {
  required String title,
  String message =
      'O item deixa de aparecer para as alunas, mas não é apagado de vez.',
  String confirmLabel = 'Desativar',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            minimumSize: const Size(120, 48),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok == true;
}
