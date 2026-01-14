import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/journal_entry.dart';
import '../../../core/models/mood.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/ai_service.dart';

/// State for journal feature
class JournalState {
  final List<JournalEntry> entries;
  final bool isLoading;
  final String? error;
  final JournalEntry? selectedEntry;
  final bool isAnalyzing;

  const JournalState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
    this.selectedEntry,
    this.isAnalyzing = false,
  });

  JournalState copyWith({
    List<JournalEntry>? entries,
    bool? isLoading,
    String? error,
    JournalEntry? selectedEntry,
    bool? isAnalyzing,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedEntry: selectedEntry ?? this.selectedEntry,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }

  /// Get entries for today
  List<JournalEntry> get todayEntries =>
      entries.where((e) => e.isToday).toList();

  /// Get entries for this week
  List<JournalEntry> get thisWeekEntries =>
      entries.where((e) => e.isThisWeek).toList();

  /// Get mood distribution for the week
  Map<Mood, int> get weeklyMoodDistribution {
    final distribution = <Mood, int>{};
    for (final entry in thisWeekEntries) {
      if (entry.mood != null) {
        distribution[entry.mood!] = (distribution[entry.mood!] ?? 0) + 1;
      }
    }
    return distribution;
  }

  /// Get all detected themes from recent entries
  List<String> get recentThemes {
    final themes = <String>{};
    for (final entry in thisWeekEntries) {
      themes.addAll(entry.detectedThemes);
    }
    return themes.toList();
  }
}

/// Journal state notifier
class JournalNotifier extends StateNotifier<JournalState> {
  final Ref _ref;
  static const _uuid = Uuid();

  JournalNotifier(this._ref) : super(const JournalState());

  /// Load all journal entries from storage
  Future<void> loadEntries() async {
    state = state.copyWith(isLoading: true);
    try {
      final storage = _ref.read(storageServiceProvider);
      final entries = storage.getAllJournalEntries();
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load entries',
      );
    }
  }

  /// Create a new journal entry
  Future<JournalEntry> createEntry({
    required String content,
    Mood? mood,
  }) async {
    final now = DateTime.now();
    final entry = JournalEntry(
      id: _uuid.v4(),
      content: content,
      createdAt: now,
      updatedAt: now,
      moodIndex: mood?.index,
    );

    final storage = _ref.read(storageServiceProvider);
    await storage.saveJournalEntry(entry);

    state = state.copyWith(
      entries: [entry, ...state.entries],
    );

    // Analyze entry with AI in background
    _analyzeEntry(entry);

    return entry;
  }

  /// Update an existing entry
  Future<void> updateEntry({
    required String id,
    String? content,
    Mood? mood,
  }) async {
    final index = state.entries.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final entry = state.entries[index];
    final updatedEntry = entry.copyWith(
      content: content,
      moodIndex: mood?.index ?? entry.moodIndex,
      updatedAt: DateTime.now(),
    );

    final storage = _ref.read(storageServiceProvider);
    await storage.saveJournalEntry(updatedEntry);

    final updatedEntries = [...state.entries];
    updatedEntries[index] = updatedEntry;
    state = state.copyWith(entries: updatedEntries);

    // Re-analyze if content changed
    if (content != null && content != entry.content) {
      _analyzeEntry(updatedEntry);
    }
  }

  /// Delete an entry
  Future<void> deleteEntry(String id) async {
    final storage = _ref.read(storageServiceProvider);
    await storage.deleteJournalEntry(id);

    state = state.copyWith(
      entries: state.entries.where((e) => e.id != id).toList(),
    );
  }

  /// Select an entry for viewing/editing
  void selectEntry(JournalEntry? entry) {
    state = state.copyWith(selectedEntry: entry);
  }

  /// Analyze entry with AI
  Future<void> _analyzeEntry(JournalEntry entry) async {
    if (!_ref.read(isAIConfiguredProvider)) return;

    state = state.copyWith(isAnalyzing: true);

    try {
      final aiService = _ref.read(aiServiceProvider);
      final analysis = await aiService.analyzeJournalEntry(
        content: entry.content,
        mood: entry.mood,
        previousThemes: state.recentThemes,
      );

      // Update entry with AI insights
      final updatedEntry = entry.copyWith(
        detectedThemes: analysis.themes,
        aiInsight: analysis.insight,
      );

      final storage = _ref.read(storageServiceProvider);
      await storage.saveJournalEntry(updatedEntry);

      final index = state.entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        final updatedEntries = [...state.entries];
        updatedEntries[index] = updatedEntry;
        state = state.copyWith(entries: updatedEntries, isAnalyzing: false);
      }
    } catch (e) {
      state = state.copyWith(isAnalyzing: false);
    }
  }

  /// Get entries for a specific date
  List<JournalEntry> getEntriesForDate(DateTime date) {
    return state.entries.where((entry) {
      return entry.createdAt.year == date.year &&
          entry.createdAt.month == date.month &&
          entry.createdAt.day == date.day;
    }).toList();
  }
}

/// Journal provider
final journalProvider =
    StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  return JournalNotifier(ref);
});

/// Today's entries provider
final todayEntriesProvider = Provider<List<JournalEntry>>((ref) {
  return ref.watch(journalProvider).todayEntries;
});

/// This week's entries provider
final thisWeekEntriesProvider = Provider<List<JournalEntry>>((ref) {
  return ref.watch(journalProvider).thisWeekEntries;
});
