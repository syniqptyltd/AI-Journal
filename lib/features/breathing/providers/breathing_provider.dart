import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/breathing_exercise.dart';
import '../../../core/models/mood.dart';
import '../../../core/providers/providers.dart';

/// State for an active breathing session
class BreathingSessionState {
  final BreathingExercise exercise;
  final bool isActive;
  final bool isPaused;
  final int currentCycle;
  final int totalCycles;
  final BreathPhase currentPhase;
  final int phaseSecondsRemaining;
  final int totalSecondsRemaining;
  final bool isComplete;

  const BreathingSessionState({
    required this.exercise,
    this.isActive = false,
    this.isPaused = false,
    this.currentCycle = 1,
    this.totalCycles = 4,
    this.currentPhase = BreathPhase.inhale,
    this.phaseSecondsRemaining = 4,
    this.totalSecondsRemaining = 0,
    this.isComplete = false,
  });

  BreathingSessionState copyWith({
    BreathingExercise? exercise,
    bool? isActive,
    bool? isPaused,
    int? currentCycle,
    int? totalCycles,
    BreathPhase? currentPhase,
    int? phaseSecondsRemaining,
    int? totalSecondsRemaining,
    bool? isComplete,
  }) {
    return BreathingSessionState(
      exercise: exercise ?? this.exercise,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      currentCycle: currentCycle ?? this.currentCycle,
      totalCycles: totalCycles ?? this.totalCycles,
      currentPhase: currentPhase ?? this.currentPhase,
      phaseSecondsRemaining: phaseSecondsRemaining ?? this.phaseSecondsRemaining,
      totalSecondsRemaining: totalSecondsRemaining ?? this.totalSecondsRemaining,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Progress through current phase (0.0 to 1.0)
  double get phaseProgress {
    final phaseDuration = _getPhaseDuration(currentPhase, exercise);
    if (phaseDuration == 0) return 1.0;
    return 1.0 - (phaseSecondsRemaining / phaseDuration);
  }

  /// Overall progress (0.0 to 1.0)
  double get overallProgress {
    final totalDuration = exercise.cycleDuration * totalCycles;
    if (totalDuration == 0) return 1.0;
    return 1.0 - (totalSecondsRemaining / totalDuration);
  }

  int _getPhaseDuration(BreathPhase phase, BreathingExercise exercise) {
    switch (phase) {
      case BreathPhase.inhale:
        return exercise.inhaleSeconds;
      case BreathPhase.holdAfterInhale:
        return exercise.holdAfterInhaleSeconds;
      case BreathPhase.exhale:
        return exercise.exhaleSeconds;
      case BreathPhase.holdAfterExhale:
        return exercise.holdAfterExhaleSeconds;
    }
  }
}

/// Breathing session controller
class BreathingSessionNotifier extends StateNotifier<BreathingSessionState> {
  Timer? _timer;
  final Ref _ref;

  BreathingSessionNotifier(this._ref)
      : super(BreathingSessionState(
          exercise: BreathingExercise.presets.first,
        ));

  /// Start a new breathing session
  void startSession(BreathingExercise exercise, {int? cycles}) {
    _timer?.cancel();

    final totalCycles = cycles ?? exercise.defaultCycles;
    final totalSeconds = exercise.cycleDuration * totalCycles;

    state = BreathingSessionState(
      exercise: exercise,
      isActive: true,
      isPaused: false,
      currentCycle: 1,
      totalCycles: totalCycles,
      currentPhase: BreathPhase.inhale,
      phaseSecondsRemaining: exercise.inhaleSeconds,
      totalSecondsRemaining: totalSeconds,
      isComplete: false,
    );

    _startTimer();
  }

  /// Pause the session
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isPaused: true);
  }

  /// Resume the session
  void resume() {
    state = state.copyWith(isPaused: false);
    _startTimer();
  }

  /// Stop the session
  void stop() {
    _timer?.cancel();
    state = state.copyWith(
      isActive: false,
      isPaused: false,
    );
  }

  /// Complete the session
  void complete() {
    _timer?.cancel();
    state = state.copyWith(
      isActive: false,
      isComplete: true,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isPaused) return;
      _tick();
    });
  }

  void _tick() {
    if (state.totalSecondsRemaining <= 1) {
      complete();
      return;
    }

    var phaseSeconds = state.phaseSecondsRemaining - 1;
    var currentPhase = state.currentPhase;
    var currentCycle = state.currentCycle;

    // Move to next phase if current phase is complete
    if (phaseSeconds <= 0) {
      final nextPhase = _getNextPhase(currentPhase, state.exercise);
      if (nextPhase == null) {
        // Cycle complete
        if (currentCycle >= state.totalCycles) {
          complete();
          return;
        }
        currentCycle++;
        currentPhase = BreathPhase.inhale;
        phaseSeconds = state.exercise.inhaleSeconds;
      } else {
        currentPhase = nextPhase;
        phaseSeconds = _getPhaseDuration(nextPhase);
      }
    }

    state = state.copyWith(
      phaseSecondsRemaining: phaseSeconds,
      currentPhase: currentPhase,
      currentCycle: currentCycle,
      totalSecondsRemaining: state.totalSecondsRemaining - 1,
    );
  }

  BreathPhase? _getNextPhase(BreathPhase current, BreathingExercise exercise) {
    switch (current) {
      case BreathPhase.inhale:
        if (exercise.holdAfterInhaleSeconds > 0) {
          return BreathPhase.holdAfterInhale;
        }
        return BreathPhase.exhale;
      case BreathPhase.holdAfterInhale:
        return BreathPhase.exhale;
      case BreathPhase.exhale:
        if (exercise.holdAfterExhaleSeconds > 0) {
          return BreathPhase.holdAfterExhale;
        }
        return null; // Cycle complete
      case BreathPhase.holdAfterExhale:
        return null; // Cycle complete
    }
  }

  int _getPhaseDuration(BreathPhase phase) {
    switch (phase) {
      case BreathPhase.inhale:
        return state.exercise.inhaleSeconds;
      case BreathPhase.holdAfterInhale:
        return state.exercise.holdAfterInhaleSeconds;
      case BreathPhase.exhale:
        return state.exercise.exhaleSeconds;
      case BreathPhase.holdAfterExhale:
        return state.exercise.holdAfterExhaleSeconds;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Breathing session provider
final breathingSessionProvider =
    StateNotifierProvider<BreathingSessionNotifier, BreathingSessionState>(
        (ref) {
  return BreathingSessionNotifier(ref);
});

/// Available exercises provider
final breathingExercisesProvider = Provider<List<BreathingExercise>>((ref) {
  return BreathingExercise.presets;
});

/// AI-suggested exercise provider
final suggestedExerciseProvider =
    FutureProvider.family<BreathingExercise, SuggestionContext>(
        (ref, context) async {
  final aiService = ref.read(aiServiceProvider);

  if (!aiService.isConfigured) {
    return BreathingExercise.presets.first;
  }

  try {
    final suggestion = await aiService.suggestBreathingExercise(
      currentMood: context.mood,
      recentJournalContent: context.recentContent,
    );
    return BreathingExercise.getById(suggestion.exerciseId);
  } catch (e) {
    return BreathingExercise.presets.first;
  }
});

/// Context for breathing suggestion
class SuggestionContext {
  final Mood? mood;
  final String? recentContent;

  SuggestionContext({this.mood, this.recentContent});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionContext &&
          runtimeType == other.runtimeType &&
          mood == other.mood &&
          recentContent == other.recentContent;

  @override
  int get hashCode => mood.hashCode ^ recentContent.hashCode;
}
