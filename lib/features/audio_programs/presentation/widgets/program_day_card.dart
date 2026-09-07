import 'package:flutter/material.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/audio_program.dart';

class ProgramDayCard extends StatelessWidget {
  final ProgramAudio audio;
  final bool isCompleted;
  final bool isFavorite;
  final bool isCurrent;
  final bool inProgress;
  final VoidCallback onTap;

  const ProgramDayCard({
    super.key,
    required this.audio,
    required this.isCompleted,
    required this.isFavorite,
    required this.isCurrent,
    this.inProgress = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceElevated,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: isCurrent
            ? const BorderSide(color: AppColors.secondary, width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: _DayBadge(
          day: audio.day,
          isCompleted: isCompleted,
          inProgress: inProgress || isCurrent,
        ),
        title: Text(
          'Dia ${audio.day} · ${audio.title}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          audio.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppColors.secondary : AppColors.textTertiary,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool inProgress;

  const _DayBadge({
    required this.day,
    required this.isCompleted,
    required this.inProgress,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    if (isCompleted) {
      bg = AppColors.success;
    } else if (inProgress) {
      bg = AppColors.secondary;
    } else {
      bg = AppColors.primary;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(Icons.check, color: AppColors.textOnPink)
          : Text(
              '$day',
              style: const TextStyle(
                color: AppColors.textOnPink,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
