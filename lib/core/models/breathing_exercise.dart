/// Types of breathing exercises available
enum BreathingExerciseType {
  relaxing, // 4-4-6 pattern
  box, // 4-4-4-4 pattern (box breathing)
  energizing, // 4-2-4 pattern
  calming, // 4-7-8 pattern
}

/// A breathing exercise configuration
class BreathingExercise {
  final String id;
  final String name;
  final String description;
  final BreathingExerciseType type;
  final int inhaleSeconds;
  final int holdAfterInhaleSeconds;
  final int exhaleSeconds;
  final int holdAfterExhaleSeconds;
  final int defaultCycles;
  final String benefit;

  const BreathingExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.inhaleSeconds,
    required this.holdAfterInhaleSeconds,
    required this.exhaleSeconds,
    required this.holdAfterExhaleSeconds,
    required this.defaultCycles,
    required this.benefit,
  });

  /// Total duration of one breath cycle
  int get cycleDuration =>
      inhaleSeconds +
      holdAfterInhaleSeconds +
      exhaleSeconds +
      holdAfterExhaleSeconds;

  /// Total exercise duration with default cycles
  int get totalDurationSeconds => cycleDuration * defaultCycles;

  /// Format duration for display
  String get formattedDuration {
    final minutes = totalDurationSeconds ~/ 60;
    final seconds = totalDurationSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    if (seconds == 0) return '${minutes}m';
    return '${minutes}m ${seconds}s';
  }

  /// Pattern description (e.g., "4-4-6")
  String get pattern {
    final parts = <String>[];
    parts.add('$inhaleSeconds');
    if (holdAfterInhaleSeconds > 0) parts.add('$holdAfterInhaleSeconds');
    parts.add('$exhaleSeconds');
    if (holdAfterExhaleSeconds > 0) parts.add('$holdAfterExhaleSeconds');
    return parts.join('-');
  }

  /// Predefined breathing exercises
  static const List<BreathingExercise> presets = [
    BreathingExercise(
      id: 'relaxing',
      name: 'Relaxing Breath',
      description: 'A gentle breathing pattern to help you unwind',
      type: BreathingExerciseType.relaxing,
      inhaleSeconds: 4,
      holdAfterInhaleSeconds: 4,
      exhaleSeconds: 6,
      holdAfterExhaleSeconds: 0,
      defaultCycles: 6,
      benefit: 'Reduces stress and promotes relaxation',
    ),
    BreathingExercise(
      id: 'box',
      name: 'Box Breathing',
      description: 'Equal-length breathing used by athletes and performers',
      type: BreathingExerciseType.box,
      inhaleSeconds: 4,
      holdAfterInhaleSeconds: 4,
      exhaleSeconds: 4,
      holdAfterExhaleSeconds: 4,
      defaultCycles: 4,
      benefit: 'Enhances focus and calms the nervous system',
    ),
    BreathingExercise(
      id: 'energizing',
      name: 'Energizing Breath',
      description: 'A quick pattern to boost alertness',
      type: BreathingExerciseType.energizing,
      inhaleSeconds: 4,
      holdAfterInhaleSeconds: 2,
      exhaleSeconds: 4,
      holdAfterExhaleSeconds: 0,
      defaultCycles: 8,
      benefit: 'Increases energy and mental clarity',
    ),
    BreathingExercise(
      id: 'calming',
      name: '4-7-8 Calming Breath',
      description: 'A deeply calming technique for anxiety relief',
      type: BreathingExerciseType.calming,
      inhaleSeconds: 4,
      holdAfterInhaleSeconds: 7,
      exhaleSeconds: 8,
      holdAfterExhaleSeconds: 0,
      defaultCycles: 4,
      benefit: 'Helps with anxiety and falling asleep',
    ),
  ];

  static BreathingExercise getById(String id) {
    return presets.firstWhere(
      (e) => e.id == id,
      orElse: () => presets.first,
    );
  }
}

/// Phases of a breathing cycle
enum BreathPhase {
  inhale,
  holdAfterInhale,
  exhale,
  holdAfterExhale;

  String get instruction {
    switch (this) {
      case BreathPhase.inhale:
        return 'Breathe in';
      case BreathPhase.holdAfterInhale:
        return 'Hold';
      case BreathPhase.exhale:
        return 'Breathe out';
      case BreathPhase.holdAfterExhale:
        return 'Hold';
    }
  }
}
