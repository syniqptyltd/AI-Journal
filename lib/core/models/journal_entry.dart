import 'package:hive/hive.dart';
import 'mood.dart';

part 'journal_entry.g.dart';

/// A journal entry created by the user
/// Stores personal reflections with optional mood tracking
@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  int? moodIndex; // Stored as index for Hive compatibility

  @HiveField(5)
  List<String> detectedThemes;

  @HiveField(6)
  String? aiInsight;

  JournalEntry({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.moodIndex,
    List<String>? detectedThemes,
    this.aiInsight,
  }) : detectedThemes = detectedThemes ?? [];

  Mood? get mood => moodIndex != null ? Mood.values[moodIndex!] : null;

  set mood(Mood? value) {
    moodIndex = value?.index;
  }

  /// Creates a copy with updated fields
  JournalEntry copyWith({
    String? content,
    DateTime? updatedAt,
    int? moodIndex,
    List<String>? detectedThemes,
    String? aiInsight,
  }) {
    return JournalEntry(
      id: id,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moodIndex: moodIndex ?? this.moodIndex,
      detectedThemes: detectedThemes ?? this.detectedThemes,
      aiInsight: aiInsight ?? this.aiInsight,
    );
  }

  /// Check if entry was created today
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  /// Check if entry was created this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return createdAt.isAfter(weekAgo);
  }

  /// Word count for analytics
  int get wordCount {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }
}
