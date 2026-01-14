import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/mood.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A horizontal mood selector with emoji chips
class MoodSelector extends StatelessWidget {
  final Mood? selectedMood;
  final ValueChanged<Mood?> onMoodSelected;
  final bool allowDeselect;

  const MoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
    this.allowDeselect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: Mood.values.map((mood) {
              final isSelected = selectedMood == mood;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: _MoodChip(
                  mood: mood,
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected && allowDeselect) {
                      onMoodSelected(null);
                    } else {
                      onMoodSelected(mood);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MoodChip extends StatelessWidget {
  final Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? mood.color.withOpacity(0.2) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          border: Border.all(
            color: isSelected ? mood.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(fontSize: 18),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                mood.label,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      )
          .animate(target: isSelected ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 150.ms,
          ),
    );
  }
}

/// A grid layout for mood selection (for larger displays)
class MoodGrid extends StatelessWidget {
  final Mood? selectedMood;
  final ValueChanged<Mood?> onMoodSelected;

  const MoodGrid({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: Mood.values.map((mood) {
        final isSelected = selectedMood == mood;
        return _MoodGridItem(
          mood: mood,
          isSelected: isSelected,
          onTap: () => onMoodSelected(isSelected ? null : mood),
        );
      }).toList(),
    );
  }
}

class _MoodGridItem extends StatelessWidget {
  final Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodGridItem({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? mood.color.withOpacity(0.2) : AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected ? mood.color : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              mood.label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
