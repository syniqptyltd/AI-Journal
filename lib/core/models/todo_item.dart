import 'package:hive/hive.dart';

part 'todo_item.g.dart';

/// Source of a todo item
enum TodoSource {
  user, // Created manually by user
  ai, // Suggested by AI
}

/// Priority level for tasks
enum TodoPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.high:
        return 'High';
    }
  }
}

/// A to-do item that can be user-created or AI-suggested
@HiveType(typeId: 1)
class TodoItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  int sourceIndex; // TodoSource as index

  @HiveField(7)
  int priorityIndex; // TodoPriority as index

  @HiveField(8)
  String? linkedJournalEntryId;

  @HiveField(9)
  DateTime? dueDate;

  @HiveField(10)
  String? aiContext; // Why AI suggested this

  TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.sourceIndex = 0,
    this.priorityIndex = 1,
    this.linkedJournalEntryId,
    this.dueDate,
    this.aiContext,
  });

  TodoSource get source => TodoSource.values[sourceIndex];
  set source(TodoSource value) => sourceIndex = value.index;

  TodoPriority get priority => TodoPriority.values[priorityIndex];
  set priority(TodoPriority value) => priorityIndex = value.index;

  bool get isFromAI => source == TodoSource.ai;

  /// Creates a copy with updated fields
  TodoItem copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    int? sourceIndex,
    int? priorityIndex,
    String? linkedJournalEntryId,
    DateTime? dueDate,
    String? aiContext,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      sourceIndex: sourceIndex ?? this.sourceIndex,
      priorityIndex: priorityIndex ?? this.priorityIndex,
      linkedJournalEntryId: linkedJournalEntryId ?? this.linkedJournalEntryId,
      dueDate: dueDate ?? this.dueDate,
      aiContext: aiContext ?? this.aiContext,
    );
  }

  /// Check if task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }
}
