import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/breathing_exercise.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/breathing_provider.dart';
import 'breathing_session_screen.dart';

/// Screen showing available breathing exercises
class BreathingScreen extends ConsumerWidget {
  const BreathingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(breathingExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathe'),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // Header
          Text(
            'Take a moment',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose a breathing exercise to help you feel centered.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Quick start card
          _QuickStartCard(),
          const SizedBox(height: AppSpacing.lg),

          // Exercise list
          Text(
            'Exercises',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...exercises.map((exercise) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ExerciseCard(exercise: exercise),
              )),

          // Grounding section
          const SizedBox(height: AppSpacing.lg),
          _GroundingSection(),
        ],
      ),
    );
  }
}

class _QuickStartCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: AppSpacing.cardPaddingLarge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: AppSpacing.borderRadiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.air,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Quick Calm',
                style: AppTypography.headlineSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'A 2-minute breathing exercise to help you reset.',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BreathingSessionScreen(
                      exercise: BreathingExercise.presets.first,
                      cycles: 4,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
              ),
              child: const Text('Start Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final BreathingExercise exercise;

  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BreathingSessionScreen(exercise: exercise),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getExerciseColor(exercise.type).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getExerciseIcon(exercise.type),
              color: _getExerciseColor(exercise.type),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      exercise.name,
                      style: AppTypography.titleMedium,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                      ),
                      child: Text(
                        exercise.pattern,
                        style: AppTypography.labelSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.benefit,
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.formattedDuration,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Color _getExerciseColor(BreathingExerciseType type) {
    switch (type) {
      case BreathingExerciseType.relaxing:
        return AppColors.moodCalm;
      case BreathingExerciseType.box:
        return AppColors.secondary;
      case BreathingExerciseType.energizing:
        return AppColors.moodEnergized;
      case BreathingExerciseType.calming:
        return AppColors.breatheOut;
    }
  }

  IconData _getExerciseIcon(BreathingExerciseType type) {
    switch (type) {
      case BreathingExerciseType.relaxing:
        return Icons.spa;
      case BreathingExerciseType.box:
        return Icons.crop_square;
      case BreathingExerciseType.energizing:
        return Icons.bolt;
      case BreathingExerciseType.calming:
        return Icons.nights_stay;
    }
  }
}

class _GroundingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grounding Exercise',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          onTap: () => _showGroundingExercise(context),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.self_improvement,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5-4-3-2-1 Grounding',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Use your senses to anchor yourself in the present moment.',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showGroundingExercise(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _GroundingExerciseSheet(),
    );
  }
}

class _GroundingExerciseSheet extends StatelessWidget {
  const _GroundingExerciseSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '5-4-3-2-1 Grounding',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This technique helps you anchor in the present moment using your five senses.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: const [
                    _GroundingStep(
                      number: 5,
                      sense: 'See',
                      instruction:
                          'Look around and name 5 things you can see.',
                      example: 'A lamp, a plant, your phone, a window, a book',
                    ),
                    _GroundingStep(
                      number: 4,
                      sense: 'Touch',
                      instruction:
                          'Notice 4 things you can physically feel.',
                      example:
                          'Your feet on the floor, the chair supporting you, your clothes, the air on your skin',
                    ),
                    _GroundingStep(
                      number: 3,
                      sense: 'Hear',
                      instruction:
                          'Listen for 3 things you can hear right now.',
                      example:
                          'Birds outside, the hum of a fan, distant traffic',
                    ),
                    _GroundingStep(
                      number: 2,
                      sense: 'Smell',
                      instruction: 'Identify 2 things you can smell.',
                      example: 'Coffee, fresh air, a candle',
                    ),
                    _GroundingStep(
                      number: 1,
                      sense: 'Taste',
                      instruction: 'Notice 1 thing you can taste.',
                      example:
                          'The lingering taste of your last drink, or just your mouth',
                    ),
                    SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GroundingStep extends StatelessWidget {
  final int number;
  final String sense;
  final String instruction;
  final String example;

  const _GroundingStep({
    required this.number,
    required this.sense,
    required this.instruction,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sense,
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  instruction,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'e.g. $example',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
