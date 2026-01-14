import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/breathing_exercise.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/breathing_animation.dart';
import '../providers/breathing_provider.dart';

/// Full-screen breathing session
class BreathingSessionScreen extends ConsumerStatefulWidget {
  final BreathingExercise exercise;
  final int? cycles;

  const BreathingSessionScreen({
    super.key,
    required this.exercise,
    this.cycles,
  });

  @override
  ConsumerState<BreathingSessionScreen> createState() =>
      _BreathingSessionScreenState();
}

class _BreathingSessionScreenState
    extends ConsumerState<BreathingSessionScreen> {
  bool _showingIntro = true;

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait for better experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // Restore orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _startSession() {
    setState(() => _showingIntro = false);
    ref.read(breathingSessionProvider.notifier).startSession(
          widget.exercise,
          cycles: widget.cycles,
        );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(breathingSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _showingIntro
            ? _IntroView(
                exercise: widget.exercise,
                onStart: _startSession,
                onClose: () => Navigator.of(context).pop(),
              )
            : sessionState.isComplete
                ? _CompletionView(
                    exercise: widget.exercise,
                    onClose: () => Navigator.of(context).pop(),
                    onRepeat: _startSession,
                  )
                : _SessionView(
                    state: sessionState,
                  ),
      ),
    );
  }
}

class _IntroView extends StatelessWidget {
  final BreathingExercise exercise;
  final VoidCallback onStart;
  final VoidCallback onClose;

  const _IntroView({
    required this.exercise,
    required this.onStart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
          ),
          const Spacer(),

          // Exercise info
          Text(
            exercise.name,
            style: AppTypography.displayMedium,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: AppSpacing.md),
          Text(
            exercise.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms),
          const SizedBox(height: AppSpacing.xxl),

          // Pattern visualization
          Container(
            padding: AppSpacing.cardPaddingLarge,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusXl,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Text(
                  'Pattern',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PatternPhase(
                      label: 'Inhale',
                      seconds: exercise.inhaleSeconds,
                      color: AppColors.breatheIn,
                    ),
                    if (exercise.holdAfterInhaleSeconds > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _PatternPhase(
                        label: 'Hold',
                        seconds: exercise.holdAfterInhaleSeconds,
                        color: AppColors.breatheHold,
                      ),
                    ],
                    const SizedBox(width: AppSpacing.sm),
                    _PatternPhase(
                      label: 'Exhale',
                      seconds: exercise.exhaleSeconds,
                      color: AppColors.breatheOut,
                    ),
                    if (exercise.holdAfterExhaleSeconds > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _PatternPhase(
                        label: 'Hold',
                        seconds: exercise.holdAfterExhaleSeconds,
                        color: AppColors.breatheHold,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms),
          const SizedBox(height: AppSpacing.md),
          Text(
            exercise.formattedDuration,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 500.ms),

          const Spacer(),

          // Start button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onStart,
              child: const Text('Begin'),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _PatternPhase extends StatelessWidget {
  final String label;
  final int seconds;
  final Color color;

  const _PatternPhase({
    required this.label,
    required this.seconds,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$seconds',
            style: AppTypography.titleLarge.copyWith(
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall,
        ),
      ],
    );
  }
}

class _SessionView extends ConsumerWidget {
  final BreathingSessionState state;

  const _SessionView({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Controls
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(breathingSessionProvider.notifier).stop();
                  Navigator.of(context).pop();
                },
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  state.isPaused ? Icons.play_arrow : Icons.pause,
                ),
                onPressed: () {
                  if (state.isPaused) {
                    ref.read(breathingSessionProvider.notifier).resume();
                  } else {
                    ref.read(breathingSessionProvider.notifier).pause();
                  }
                },
              ),
            ],
          ),
        ),

        const Spacer(),

        // Breathing animation
        Stack(
          alignment: Alignment.center,
          children: [
            BreathingProgressRing(
              progress: state.overallProgress,
              currentCycle: state.currentCycle,
              totalCycles: state.totalCycles,
            ),
            BreathingAnimation(
              phase: state.currentPhase,
              progress: state.phaseProgress,
              secondsRemaining: state.phaseSecondsRemaining,
              isActive: state.isActive && !state.isPaused,
            ),
          ],
        ),

        const Spacer(),

        // Paused indicator
        if (state.isPaused)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            child: Text(
              'Paused',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms)
        else
          const SizedBox(height: AppSpacing.xxl + 24),
      ],
    );
  }
}

class _CompletionView extends StatelessWidget {
  final BreathingExercise exercise;
  final VoidCallback onClose;
  final VoidCallback onRepeat;

  const _CompletionView({
    required this.exercise,
    required this.onClose,
    required this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          const Spacer(),

          // Success icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 50,
              color: AppColors.success,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: AppSpacing.lg),

          // Completion message
          Text(
            'Well done',
            style: AppTypography.displayMedium,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You completed ${exercise.name}.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 500.ms),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Take a moment to notice how you feel.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 700.ms),

          const Spacer(),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRepeat,
                  child: const Text('Repeat'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: onClose,
                  child: const Text('Done'),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 900.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
