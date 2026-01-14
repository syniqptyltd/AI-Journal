import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';
import '../models/todo_item.dart';

/// Local storage service using Hive
/// Handles all data persistence with encryption support ready
class StorageService {
  static const String _journalBoxName = 'journal_entries';
  static const String _todoBoxName = 'todo_items';
  static const String _settingsBoxName = 'settings';

  late Box<JournalEntry> _journalBox;
  late Box<TodoItem> _todoBox;
  late Box<dynamic> _settingsBox;

  bool _isInitialized = false;

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(JournalEntryAdapter());
    Hive.registerAdapter(TodoItemAdapter());

    // Open boxes
    _journalBox = await Hive.openBox<JournalEntry>(_journalBoxName);
    _todoBox = await Hive.openBox<TodoItem>(_todoBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);

    _isInitialized = true;
  }

  // === Journal Operations ===

  /// Get all journal entries sorted by date (newest first)
  List<JournalEntry> getAllJournalEntries() {
    final entries = _journalBox.values.toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  /// Get journal entries for a specific date
  List<JournalEntry> getJournalEntriesForDate(DateTime date) {
    return _journalBox.values.where((entry) {
      return entry.createdAt.year == date.year &&
          entry.createdAt.month == date.month &&
          entry.createdAt.day == date.day;
    }).toList();
  }

  /// Get journal entries from the last N days
  List<JournalEntry> getRecentJournalEntries(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final entries = _journalBox.values
        .where((entry) => entry.createdAt.isAfter(cutoff))
        .toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  /// Get a single journal entry by ID
  JournalEntry? getJournalEntry(String id) {
    try {
      return _journalBox.values.firstWhere((entry) => entry.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Save a journal entry
  Future<void> saveJournalEntry(JournalEntry entry) async {
    await _journalBox.put(entry.id, entry);
  }

  /// Delete a journal entry
  Future<void> deleteJournalEntry(String id) async {
    await _journalBox.delete(id);
  }

  // === Todo Operations ===

  /// Get all todos sorted by creation date
  List<TodoItem> getAllTodos() {
    final todos = _todoBox.values.toList();
    todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return todos;
  }

  /// Get incomplete todos
  List<TodoItem> getIncompleteTodos() {
    final todos =
        _todoBox.values.where((todo) => !todo.isCompleted).toList();
    todos.sort((a, b) {
      // Sort by priority first, then by creation date
      final priorityCompare = b.priorityIndex.compareTo(a.priorityIndex);
      if (priorityCompare != 0) return priorityCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
    return todos;
  }

  /// Get completed todos
  List<TodoItem> getCompletedTodos() {
    final todos =
        _todoBox.values.where((todo) => todo.isCompleted).toList();
    todos.sort((a, b) =>
        (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));
    return todos;
  }

  /// Get todos linked to a journal entry
  List<TodoItem> getTodosForJournalEntry(String entryId) {
    return _todoBox.values
        .where((todo) => todo.linkedJournalEntryId == entryId)
        .toList();
  }

  /// Get AI-suggested todos
  List<TodoItem> getAISuggestedTodos() {
    return _todoBox.values
        .where((todo) => todo.isFromAI && !todo.isCompleted)
        .toList();
  }

  /// Get a single todo by ID
  TodoItem? getTodo(String id) {
    try {
      return _todoBox.values.firstWhere((todo) => todo.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Save a todo
  Future<void> saveTodo(TodoItem todo) async {
    await _todoBox.put(todo.id, todo);
  }

  /// Delete a todo
  Future<void> deleteTodo(String id) async {
    await _todoBox.delete(id);
  }

  // === Settings Operations ===

  /// Get a setting value
  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  /// Save a setting value
  Future<void> saveSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  /// Check if onboarding is complete
  bool get isOnboardingComplete {
    return getSetting<bool>('onboarding_complete') ?? false;
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await saveSetting('onboarding_complete', true);
  }

  // === Statistics ===

  /// Get journal entry count
  int get journalEntryCount => _journalBox.length;

  /// Get completed todo count
  int get completedTodoCount =>
      _todoBox.values.where((todo) => todo.isCompleted).length;

  /// Get current streak (consecutive days with journal entries)
  int calculateStreak() {
    final entries = getAllJournalEntries();
    if (entries.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      final hasEntry = entries.any((entry) =>
          entry.createdAt.year == checkDate.year &&
          entry.createdAt.month == checkDate.month &&
          entry.createdAt.day == checkDate.day);

      if (hasEntry) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (streak == 0) {
        // Allow for today not having an entry yet
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Close all boxes
  Future<void> close() async {
    await _journalBox.close();
    await _todoBox.close();
    await _settingsBox.close();
  }
}
