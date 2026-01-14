import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/journal_entry.dart';
import '../../../core/models/mood.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mood_selector.dart';
import '../../../core/providers/providers.dart';
import '../providers/journal_provider.dart';
import '../../todos/providers/todo_provider.dart';

/// Screen for creating or editing a journal entry
class JournalEntryScreen extends ConsumerStatefulWidget {
  final JournalEntry? entry;

  const JournalEntryScreen({super.key, this.entry});

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  late TextEditingController _contentController;
  Mood? _selectedMood;
  bool _hasChanges = false;
  bool _isSaving = false;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    _selectedMood = widget.entry?.mood;
    _contentController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalProvider);
    final isAIConfigured = ref.watch(isAIConfiguredProvider);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasChanges) {
          _showDiscardDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Entry' : 'New Entry'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (_hasChanges) {
                _showDiscardDialog();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _showDeleteDialog,
                tooltip: 'Delete entry',
              ),
            TextButton(
              onPressed: _contentController.text.trim().isEmpty || _isSaving
                  ? null
                  : _saveEntry,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date display
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(
                  widget.entry?.createdAt ?? DateTime.now(),
                ),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Mood selector
              MoodSelector(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) {
                  setState(() {
                    _selectedMood = mood;
                    _hasChanges = true;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Content input
              Text(
                'What\'s on your mind?',
                style: AppTypography.labelMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                constraints: const BoxConstraints(minHeight: 200),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  minLines: 8,
                  style: AppTypography.journalBody,
                  decoration: InputDecoration(
                    hintText: 'Start writing...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: AppSpacing.cardPadding,
                  ),
                ),
              ),

              // AI insight (if editing and has insight)
              if (widget.entry?.aiInsight != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _AIInsightCard(insight: widget.entry!.aiInsight!),
              ],

              // Analyzing indicator
              if (journalState.isAnalyzing) ...[
                const SizedBox(height: AppSpacing.lg),
                _AnalyzingIndicator(),
              ],

              // AI configuration hint
              if (!isAIConfigured) ...[
                const SizedBox(height: AppSpacing.lg),
                _AIConfigHint(),
              ],

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final content = _contentController.text.trim();
      final notifier = ref.read(journalProvider.notifier);

      if (_isEditing) {
        await notifier.updateEntry(
          id: widget.entry!.id,
          content: content,
          mood: _selectedMood,
        );
      } else {
        final entry = await notifier.createEntry(
          content: content,
          mood: _selectedMood,
        );

        // Request AI task suggestions in background
        ref.read(todoProvider.notifier).requestAISuggestions(
              journalContent: content,
              mood: _selectedMood,
              journalEntryId: entry.id,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(journalProvider.notifier).deleteEntry(widget.entry!.id);
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AIInsightCard extends StatelessWidget {
  final String insight;

  const _AIInsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withOpacity(0.3),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Insight',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            insight,
            style: AppTypography.aiInsight,
          ),
        ],
      ),
    );
  }
}

class _AnalyzingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Generating insights...',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AIConfigHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.info,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Configure your AI API key in .env to enable insights and suggestions.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
