import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/todo_item.dart';
import '../../../core/models/mood.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/ai_service.dart';

/// State for todo feature
class TodoState {
  final List<TodoItem> todos;
  final bool isLoading;
  final String? error;
  final List<TaskSuggestion> pendingSuggestions;

  const TodoState({
    this.todos = const [],
    this.isLoading = false,
    this.error,
    this.pendingSuggestions = const [],
  });

  TodoState copyWith({
    List<TodoItem>? todos,
    bool? isLoading,
    String? error,
    List<TaskSuggestion>? pendingSuggestions,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingSuggestions: pendingSuggestions ?? this.pendingSuggestions,
    );
  }

  /// Get incomplete todos
  List<TodoItem> get incompleteTodos =>
      todos.where((t) => !t.isCompleted).toList()
        ..sort((a, b) => b.priorityIndex.compareTo(a.priorityIndex));

  /// Get completed todos
  List<TodoItem> get completedTodos =>
      todos.where((t) => t.isCompleted).toList()
        ..sort((a, b) =>
            (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));

  /// Get AI-suggested todos
  List<TodoItem> get aiSuggestedTodos =>
      todos.where((t) => t.isFromAI && !t.isCompleted).toList();

  /// Get todos due today
  List<TodoItem> get todayTodos =>
      todos.where((t) => t.isDueToday && !t.isCompleted).toList();

  /// Get overdue todos
  List<TodoItem> get overdueTodos =>
      todos.where((t) => t.isOverdue).toList();

  /// Count of incomplete todos
  int get incompleteCount => incompleteTodos.length;

  /// Count of completed today
  int get completedTodayCount {
    final today = DateTime.now();
    return todos.where((t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      return t.completedAt!.year == today.year &&
          t.completedAt!.month == today.month &&
          t.completedAt!.day == today.day;
    }).length;
  }
}

/// Todo state notifier
class TodoNotifier extends StateNotifier<TodoState> {
  final Ref _ref;
  static const _uuid = Uuid();

  TodoNotifier(this._ref) : super(const TodoState());

  /// Load all todos from storage
  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true);
    try {
      final storage = _ref.read(storageServiceProvider);
      final todos = storage.getAllTodos();
      state = state.copyWith(todos: todos, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load todos',
      );
    }
  }

  /// Create a new todo
  Future<TodoItem> createTodo({
    required String title,
    String? description,
    TodoPriority priority = TodoPriority.medium,
    DateTime? dueDate,
    String? linkedJournalEntryId,
  }) async {
    final todo = TodoItem(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      priorityIndex: priority.index,
      dueDate: dueDate,
      linkedJournalEntryId: linkedJournalEntryId,
      sourceIndex: TodoSource.user.index,
    );

    final storage = _ref.read(storageServiceProvider);
    await storage.saveTodo(todo);

    state = state.copyWith(
      todos: [todo, ...state.todos],
    );

    return todo;
  }

  /// Create an AI-suggested todo
  Future<TodoItem> createAISuggestedTodo({
    required String title,
    String? description,
    TodoPriority priority = TodoPriority.medium,
    String? linkedJournalEntryId,
    String? aiContext,
  }) async {
    final todo = TodoItem(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      priorityIndex: priority.index,
      linkedJournalEntryId: linkedJournalEntryId,
      sourceIndex: TodoSource.ai.index,
      aiContext: aiContext,
    );

    final storage = _ref.read(storageServiceProvider);
    await storage.saveTodo(todo);

    state = state.copyWith(
      todos: [todo, ...state.todos],
    );

    return todo;
  }

  /// Update a todo
  Future<void> updateTodo({
    required String id,
    String? title,
    String? description,
    TodoPriority? priority,
    DateTime? dueDate,
  }) async {
    final index = state.todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final todo = state.todos[index];
    final updatedTodo = todo.copyWith(
      title: title,
      description: description,
      priorityIndex: priority?.index,
      dueDate: dueDate,
    );

    final storage = _ref.read(storageServiceProvider);
    await storage.saveTodo(updatedTodo);

    final updatedTodos = [...state.todos];
    updatedTodos[index] = updatedTodo;
    state = state.copyWith(todos: updatedTodos);
  }

  /// Toggle todo completion
  Future<void> toggleComplete(String id) async {
    final index = state.todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final todo = state.todos[index];
    final updatedTodo = todo.copyWith(
      isCompleted: !todo.isCompleted,
      completedAt: !todo.isCompleted ? DateTime.now() : null,
    );

    final storage = _ref.read(storageServiceProvider);
    await storage.saveTodo(updatedTodo);

    final updatedTodos = [...state.todos];
    updatedTodos[index] = updatedTodo;
    state = state.copyWith(todos: updatedTodos);
  }

  /// Delete a todo
  Future<void> deleteTodo(String id) async {
    final storage = _ref.read(storageServiceProvider);
    await storage.deleteTodo(id);

    state = state.copyWith(
      todos: state.todos.where((t) => t.id != id).toList(),
    );
  }

  /// Request AI task suggestions based on journal content
  Future<void> requestAISuggestions({
    required String journalContent,
    Mood? mood,
    String? journalEntryId,
  }) async {
    if (!_ref.read(isAIConfiguredProvider)) return;

    try {
      final aiService = _ref.read(aiServiceProvider);
      final suggestions = await aiService.suggestTasks(
        journalContent: journalContent,
        mood: mood,
      );

      state = state.copyWith(pendingSuggestions: suggestions);
    } catch (e) {
      // Silently fail - suggestions are optional
    }
  }

  /// Accept an AI suggestion and create a todo
  Future<void> acceptSuggestion(TaskSuggestion suggestion,
      {String? journalEntryId}) async {
    final priority = switch (suggestion.priority) {
      'high' => TodoPriority.high,
      'low' => TodoPriority.low,
      _ => TodoPriority.medium,
    };

    await createAISuggestedTodo(
      title: suggestion.title,
      description: suggestion.description,
      priority: priority,
      linkedJournalEntryId: journalEntryId,
      aiContext: 'Suggested based on your journal entry',
    );

    // Remove from pending
    state = state.copyWith(
      pendingSuggestions:
          state.pendingSuggestions.where((s) => s != suggestion).toList(),
    );
  }

  /// Dismiss a suggestion
  void dismissSuggestion(TaskSuggestion suggestion) {
    state = state.copyWith(
      pendingSuggestions:
          state.pendingSuggestions.where((s) => s != suggestion).toList(),
    );
  }

  /// Clear all pending suggestions
  void clearSuggestions() {
    state = state.copyWith(pendingSuggestions: []);
  }

  /// Get todos linked to a journal entry
  List<TodoItem> getTodosForEntry(String entryId) {
    return state.todos
        .where((t) => t.linkedJournalEntryId == entryId)
        .toList();
  }
}

/// Todo provider
final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier(ref);
});

/// Incomplete todos provider
final incompleteTodosProvider = Provider<List<TodoItem>>((ref) {
  return ref.watch(todoProvider).incompleteTodos;
});

/// Completed todos provider
final completedTodosProvider = Provider<List<TodoItem>>((ref) {
  return ref.watch(todoProvider).completedTodos;
});

/// Today's todos provider
final todayTodosProvider = Provider<List<TodoItem>>((ref) {
  return ref.watch(todoProvider).todayTodos;
});

/// AI suggestions provider
final aiSuggestionsProvider = Provider<List<TaskSuggestion>>((ref) {
  return ref.watch(todoProvider).pendingSuggestions;
});
