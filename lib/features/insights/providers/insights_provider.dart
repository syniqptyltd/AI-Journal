import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/mood.dart';
import '../../../core/models/ai_insight.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/ai_service.dart';
import '../../journal/providers/journal_provider.dart';

/// State for insights feature
class InsightsState {
  final WeeklyInsights? weeklyInsights;
  final bool isLoading;
  final String? error;
  final Map<Mood, int> moodDistribution;
  final List<String> topThemes;
  final int totalEntries;
  final int currentStreak;

  const InsightsState({
    this.weeklyInsights,
    this.isLoading = false,
    this.error,
    this.moodDistribution = const {},
    this.topThemes = const [],
    this.totalEntries = 0,
    this.currentStreak = 0,
  });

  InsightsState copyWith({
    WeeklyInsights? weeklyInsights,
    bool? isLoading,
    String? error,
    Map<Mood, int>? moodDistribution,
    List<String>? topThemes,
    int? totalEntries,
    int? currentStreak,
  }) {
    return InsightsState(
      weeklyInsights: weeklyInsights ?? this.weeklyInsights,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      moodDistribution: moodDistribution ?? this.moodDistribution,
      topThemes: topThemes ?? this.topThemes,
      totalEntries: totalEntries ?? this.totalEntries,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}

/// Insights notifier
class InsightsNotifier extends StateNotifier<InsightsState> {
  final Ref _ref;

  InsightsNotifier(this._ref) : super(const InsightsState());

  /// Load and generate insights
  Future<void> loadInsights() async {
    state = state.copyWith(isLoading: true);

    try {
      final journalState = _ref.read(journalProvider);
      final storage = _ref.read(storageServiceProvider);
      final entries = journalState.thisWeekEntries;

      // Calculate stats
      final moodDistribution = <Mood, int>{};
      final allThemes = <String>[];

      for (final entry in entries) {
        if (entry.mood != null) {
          moodDistribution[entry.mood!] =
              (moodDistribution[entry.mood!] ?? 0) + 1;
        }
        allThemes.addAll(entry.detectedThemes);
      }

      // Get top themes
      final themeCounts = <String, int>{};
      for (final theme in allThemes) {
        themeCounts[theme] = (themeCounts[theme] ?? 0) + 1;
      }
      final sortedThemes = themeCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topThemes = sortedThemes.take(5).map((e) => e.key).toList();

      // Calculate streak
      final streak = storage.calculateStreak();

      state = state.copyWith(
        moodDistribution: moodDistribution,
        topThemes: topThemes,
        totalEntries: journalState.entries.length,
        currentStreak: streak,
        isLoading: false,
      );

      // Generate AI insights if configured and have entries
      if (_ref.read(isAIConfiguredProvider) && entries.isNotEmpty) {
        await _generateAIInsights(entries, moodDistribution);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load insights',
      );
    }
  }

  Future<void> _generateAIInsights(
    List entries,
    Map<Mood, int> moodDistribution,
  ) async {
    try {
      final aiService = _ref.read(aiServiceProvider);

      final entrySummaries = entries.take(7).map((e) {
        final preview = e.content.length > 100
            ? '${e.content.substring(0, 100)}...'
            : e.content;
        return JournalEntrySummary(
          date: DateFormat('MMM d').format(e.createdAt),
          preview: preview,
          mood: e.mood,
        );
      }).toList();

      final moodDistributionStrings = moodDistribution.map(
        (k, v) => MapEntry(k.label, v),
      );

      final insights = await aiService.generateWeeklyInsights(
        entries: entrySummaries,
        moodDistribution: moodDistributionStrings,
      );

      state = state.copyWith(weeklyInsights: insights);
    } catch (e) {
      // Silently fail - insights are optional
    }
  }

  /// Refresh insights
  Future<void> refresh() async {
    await loadInsights();
  }
}

/// Insights provider
final insightsProvider =
    StateNotifierProvider<InsightsNotifier, InsightsState>((ref) {
  return InsightsNotifier(ref);
});
