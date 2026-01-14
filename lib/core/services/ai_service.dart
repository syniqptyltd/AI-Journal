import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/mood.dart';
import '../models/ai_insight.dart';

/// AI Service for wellbeing-focused analysis and suggestions
/// Uses supportive, non-judgmental language
/// Never provides medical or diagnostic advice
class AIService {
  final String? _apiKey;
  final String _baseUrl;
  final String _model;

  AIService()
      : _apiKey = dotenv.env['AI_API_KEY'],
        _baseUrl =
            dotenv.env['AI_API_BASE_URL'] ?? 'https://api.openai.com/v1',
        _model = dotenv.env['AI_MODEL'] ?? 'gpt-4o-mini';

  bool get isConfigured =>
      _apiKey != null && _apiKey!.isNotEmpty && _apiKey != 'your-api-key-here';

  /// System prompt that ensures supportive, safe responses
  static const String _systemPrompt = '''
You are a supportive wellbeing companion in a journaling app called Mindful Path.
Your role is to help users reflect on their feelings and take small, positive actions.

IMPORTANT GUIDELINES:
- Never provide medical, psychological, or diagnostic advice
- Never suggest you are a therapist or medical professional
- Use warm, supportive, non-judgmental language
- Focus on gentle observations and small actionable suggestions
- Acknowledge feelings without trying to "fix" them
- Encourage self-compassion and small positive steps
- Keep responses concise and easy to read
- If someone seems in crisis, gently suggest speaking with a trusted person or professional

TONE EXAMPLES:
Good: "It sounds like you've had a lot on your plate lately."
Avoid: "You seem to be suffering from anxiety."

Good: "A short walk might feel nice right now."
Avoid: "You should exercise more to fix your mood."

Good: "It's okay to feel this way."
Avoid: "Don't worry, everything will be fine."
''';

  /// Analyze a journal entry and return insight
  Future<JournalAnalysis> analyzeJournalEntry({
    required String content,
    Mood? mood,
    List<String>? previousThemes,
  }) async {
    if (!isConfigured) {
      return JournalAnalysis.placeholder();
    }

    final moodContext = mood != null
        ? '\nThe user indicated they are ${mood.description}.'
        : '';

    final themesContext = previousThemes?.isNotEmpty == true
        ? '\nRecent themes in their journal: ${previousThemes!.join(", ")}.'
        : '';

    final prompt = '''
Analyze this journal entry and provide:
1. A brief, supportive insight (1-2 sentences)
2. Detected themes (choose from: stress, motivation, fatigue, positivity, anxiety, gratitude, relationships, work, self-care, growth)
3. One gentle suggestion for a small action they could take

$moodContext$themesContext

Journal entry:
"$content"

Respond in JSON format:
{
  "insight": "Your supportive insight here",
  "themes": ["theme1", "theme2"],
  "suggestion": {
    "text": "A gentle action suggestion",
    "type": "task|breathing|reflection"
  }
}
''';

    try {
      final response = await _makeRequest(prompt);
      return JournalAnalysis.fromJson(response);
    } catch (e) {
      return JournalAnalysis.placeholder();
    }
  }

  /// Generate weekly insights from multiple entries
  Future<WeeklyInsights> generateWeeklyInsights({
    required List<JournalEntrySummary> entries,
    required Map<String, int> moodDistribution,
  }) async {
    if (!isConfigured || entries.isEmpty) {
      return WeeklyInsights.placeholder();
    }

    final entriesSummary = entries
        .map((e) =>
            '- ${e.date}: ${e.preview}${e.mood != null ? " (${e.mood!.label})" : ""}')
        .join('\n');

    final moodSummary = moodDistribution.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key}: ${e.value} times')
        .join(', ');

    final prompt = '''
Based on this week's journal entries, provide supportive insights:

Entries:
$entriesSummary

Mood distribution: $moodSummary

Provide:
1. A supportive weekly observation (2-3 sentences, focus on patterns you notice)
2. One encouragement based on positive moments
3. One gentle suggestion for next week

Respond in JSON format:
{
  "observation": "Your observation here",
  "encouragement": "Positive reinforcement",
  "suggestion": "Gentle suggestion for next week",
  "dominantThemes": ["theme1", "theme2"]
}
''';

    try {
      final response = await _makeRequest(prompt);
      return WeeklyInsights.fromJson(response);
    } catch (e) {
      return WeeklyInsights.placeholder();
    }
  }

  /// Generate a contextual breathing exercise suggestion
  Future<BreathingSuggestion> suggestBreathingExercise({
    required Mood? currentMood,
    required String? recentJournalContent,
  }) async {
    if (!isConfigured) {
      return BreathingSuggestion.defaultSuggestion();
    }

    final moodContext = currentMood != null
        ? 'The user is ${currentMood.description}.'
        : 'The user has not indicated a specific mood.';

    final journalContext = recentJournalContent?.isNotEmpty == true
        ? '\nRecent journal: "${recentJournalContent!.substring(0, recentJournalContent.length.clamp(0, 200))}"'
        : '';

    final prompt = '''
$moodContext$journalContext

Suggest an appropriate breathing exercise from these options:
- relaxing: 4-4-6 pattern, good for general stress relief
- box: 4-4-4-4 pattern, good for focus and grounding
- energizing: 4-2-4 pattern, good for tiredness
- calming: 4-7-8 pattern, good for anxiety

Respond in JSON format:
{
  "exerciseId": "relaxing|box|energizing|calming",
  "reason": "A brief, kind reason for this suggestion (1 sentence)"
}
''';

    try {
      final response = await _makeRequest(prompt);
      return BreathingSuggestion.fromJson(response);
    } catch (e) {
      return BreathingSuggestion.defaultSuggestion();
    }
  }

  /// Generate task suggestions based on journal content
  Future<List<TaskSuggestion>> suggestTasks({
    required String journalContent,
    required Mood? mood,
  }) async {
    if (!isConfigured) {
      return [];
    }

    final moodContext =
        mood != null ? '\nThe user is ${mood.description}.' : '';

    final prompt = '''
Based on this journal entry, suggest 1-2 small, achievable tasks that might help the user feel better. Tasks should be:
- Simple and specific (doable in 5-30 minutes)
- Self-care oriented
- Non-overwhelming
$moodContext

Journal entry:
"$journalContent"

Respond in JSON format:
{
  "tasks": [
    {
      "title": "Short task title",
      "description": "Brief supportive description",
      "priority": "low|medium|high"
    }
  ]
}
''';

    try {
      final response = await _makeRequest(prompt);
      final tasksJson = response['tasks'] as List<dynamic>;
      return tasksJson
          .map((t) => TaskSuggestion.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Make API request
  Future<Map<String, dynamic>> _makeRequest(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 500,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'] as String;
    return jsonDecode(content) as Map<String, dynamic>;
  }
}

/// Result of journal entry analysis
class JournalAnalysis {
  final String insight;
  final List<String> themes;
  final ActionSuggestion? suggestion;

  JournalAnalysis({
    required this.insight,
    required this.themes,
    this.suggestion,
  });

  factory JournalAnalysis.fromJson(Map<String, dynamic> json) {
    return JournalAnalysis(
      insight: json['insight'] as String? ?? '',
      themes: (json['themes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      suggestion: json['suggestion'] != null
          ? ActionSuggestion.fromJson(json['suggestion'] as Map<String, dynamic>)
          : null,
    );
  }

  factory JournalAnalysis.placeholder() {
    return JournalAnalysis(
      insight: 'Thank you for taking time to write today.',
      themes: [],
      suggestion: null,
    );
  }
}

/// A suggested action from the AI
class ActionSuggestion {
  final String text;
  final String type; // task, breathing, reflection

  ActionSuggestion({required this.text, required this.type});

  factory ActionSuggestion.fromJson(Map<String, dynamic> json) {
    return ActionSuggestion(
      text: json['text'] as String? ?? '',
      type: json['type'] as String? ?? 'task',
    );
  }
}

/// Weekly insights summary
class WeeklyInsights {
  final String observation;
  final String encouragement;
  final String suggestion;
  final List<String> dominantThemes;

  WeeklyInsights({
    required this.observation,
    required this.encouragement,
    required this.suggestion,
    required this.dominantThemes,
  });

  factory WeeklyInsights.fromJson(Map<String, dynamic> json) {
    return WeeklyInsights(
      observation: json['observation'] as String? ?? '',
      encouragement: json['encouragement'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
      dominantThemes: (json['dominantThemes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  factory WeeklyInsights.placeholder() {
    return WeeklyInsights(
      observation: 'Keep writing to unlock weekly insights.',
      encouragement: 'Every entry is a step toward self-understanding.',
      suggestion: 'Try to write a little each day, even just a few sentences.',
      dominantThemes: [],
    );
  }
}

/// Breathing exercise suggestion
class BreathingSuggestion {
  final String exerciseId;
  final String reason;

  BreathingSuggestion({required this.exerciseId, required this.reason});

  factory BreathingSuggestion.fromJson(Map<String, dynamic> json) {
    return BreathingSuggestion(
      exerciseId: json['exerciseId'] as String? ?? 'relaxing',
      reason: json['reason'] as String? ?? '',
    );
  }

  factory BreathingSuggestion.defaultSuggestion() {
    return BreathingSuggestion(
      exerciseId: 'relaxing',
      reason: 'A moment of calm breathing can help center your thoughts.',
    );
  }
}

/// Task suggestion from AI
class TaskSuggestion {
  final String title;
  final String description;
  final String priority;

  TaskSuggestion({
    required this.title,
    required this.description,
    required this.priority,
  });

  factory TaskSuggestion.fromJson(Map<String, dynamic> json) {
    return TaskSuggestion(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
    );
  }
}

/// Summary of a journal entry for AI context
class JournalEntrySummary {
  final String date;
  final String preview;
  final Mood? mood;

  JournalEntrySummary({
    required this.date,
    required this.preview,
    this.mood,
  });
}
