import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/models/journal_entry.dart';
import '../providers/journal_provider.dart';
import 'journal_entry_screen.dart';

/// Main journal screen showing list of entries
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalState = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => _showCalendar(context),
            tooltip: 'View calendar',
          ),
        ],
      ),
      body: journalState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : journalState.entries.isEmpty
              ? EmptyState(
                  icon: Icons.book_outlined,
                  title: 'Start Your Journey',
                  message:
                      'Write your first journal entry to begin reflecting on your day.',
                  actionLabel: 'Write Entry',
                  onAction: () => _navigateToNewEntry(context),
                )
              : _JournalEntryList(entries: journalState.entries),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNewEntry(context),
        tooltip: 'New entry',
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  void _navigateToNewEntry(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const JournalEntryScreen(),
      ),
    );
  }

  void _showCalendar(BuildContext context) {
    // TODO: Implement calendar view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calendar view coming soon')),
    );
  }
}

class _JournalEntryList extends StatelessWidget {
  final List<JournalEntry> entries;

  const _JournalEntryList({required this.entries});

  @override
  Widget build(BuildContext context) {
    // Group entries by date
    final groupedEntries = <String, List<JournalEntry>>{};
    for (final entry in entries) {
      final dateKey = _getDateKey(entry.createdAt);
      groupedEntries.putIfAbsent(dateKey, () => []).add(entry);
    }

    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        final dateKey = groupedEntries.keys.elementAt(index);
        final dateEntries = groupedEntries[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: AppSpacing.lg),
            _DateHeader(dateKey: dateKey, date: dateEntries.first.createdAt),
            const SizedBox(height: AppSpacing.sm),
            ...dateEntries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _JournalEntryCard(entry: entry),
                )),
          ],
        );
      },
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) return 'Today';
    if (entryDate == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMMM d').format(date);
  }
}

class _DateHeader extends StatelessWidget {
  final String dateKey;
  final DateTime date;

  const _DateHeader({required this.dateKey, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          dateKey,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (dateKey != 'Today' && dateKey != 'Yesterday')
          Text(
            DateFormat('yyyy').format(date),
            style: AppTypography.labelSmall,
          ),
      ],
    );
  }
}

class _JournalEntryCard extends ConsumerWidget {
  final JournalEntry entry;

  const _JournalEntryCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: () {
        ref.read(journalProvider.notifier).selectEntry(entry);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JournalEntryScreen(entry: entry),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time and mood
          Row(
            children: [
              Text(
                DateFormat('h:mm a').format(entry.createdAt),
                style: AppTypography.labelSmall,
              ),
              if (entry.mood != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: entry.mood!.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.mood!.emoji),
                      const SizedBox(width: 4),
                      Text(
                        entry.mood!.label,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Content preview
          Text(
            entry.content,
            style: AppTypography.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          // AI insight preview
          if (entry.aiInsight != null && entry.aiInsight!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withOpacity(0.3),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      entry.aiInsight!,
                      style: AppTypography.aiInsight,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Themes
          if (entry.detectedThemes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              children: entry.detectedThemes.take(3).map((theme) {
                return Chip(
                  label: Text(
                    theme,
                    style: AppTypography.labelSmall,
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
