import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/breathing_exercise.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/providers/providers.dart';
import '../../journal/providers/journal_provider.dart';
import '../../journal/screens/journal_entry_screen.dart';
import '../../todos/providers/todo_provider.dart';
import '../../breathing/screens/breathing_session_screen.dart';

/// Home screen showing today's overview
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalState = ref.watch(journalProvider);
    final todoState = ref.watch(todoProvider);
    final storage = ref.watch(storageServiceProvider);

    final todayEntries = journalState.todayEntries;
    final incompleteTodos = todoState.incompleteTodos.take(3).toList();
    final streak = storage.calculateStreak();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _GreetingHeader()
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideX(begin: -0.1, end: 0),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),

            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pageHorizontal,
                child: _QuickActionsRow()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 100.ms),
              ),
            ),

            SliverToBoxAdapter(
              child: const SizedBox(height: AppSpacing.lg),
            ),

            // Streak card (if any)
            if (streak > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.pageHorizontal,
                  child: _StreakCard(streak: streak)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms),
                ),
              ),

            SliverToBoxAdapter(
              child: const SizedBox(height: AppSpacing.lg),
            ),

            // Today's journal entries
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pageHorizontal,
                child: _TodayJournalSection(entries: todayEntries)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms),
              ),
            ),

            SliverToBoxAdapter(
              child: const SizedBox(height: AppSpacing.lg),
            ),

            // Pending tasks
            if (incompleteTodos.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.pageHorizontal,
                  child: _TasksPreview(todos: incompleteTodos)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 400.ms),
                ),
              ),

            SliverToBoxAdapter(
              child: const SizedBox(height: AppSpacing.lg),
            ),

            // Breathing suggestion
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pageHorizontal,
                child: _BreathingSuggestion()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 500.ms),
              ),
            ),

            SliverToBoxAdapter(
              child: const SizedBox(height: AppSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTypography.displayMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.edit_outlined,
            label: 'Write',
            color: AppColors.primary,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const JournalEntryScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.air,
            label: 'Breathe',
            color: AppColors.breatheIn,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BreathingSessionScreen(
                    exercise: BreathingExercise.presets.first,
                    cycles: 3,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: AppSpacing.borderRadiusLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.titleMedium.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.2),
            AppColors.warning.withOpacity(0.1),
          ],
        ),
        borderRadius: AppSpacing.borderRadiusLg,
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: AppColors.warning,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak day streak!',
                  style: AppTypography.titleMedium,
                ),
                Text(
                  'Keep up the great work',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayJournalSection extends ConsumerWidget {
  final List entries;

  const _TodayJournalSection({required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Today\'s Journal', style: AppTypography.titleMedium),
            const Spacer(),
            if (entries.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Navigate to journal tab
                },
                child: const Text('See all'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (entries.isEmpty)
          AppCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const JournalEntryScreen(),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start today\'s entry',
                        style: AppTypography.titleMedium,
                      ),
                      Text(
                        'How are you feeling today?',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          )
        else
          ...entries.take(2).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
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
                    Row(
                      children: [
                        Text(
                          DateFormat('h:mm a').format(entry.createdAt),
                          style: AppTypography.labelSmall,
                        ),
                        if (entry.mood != null) ...[
                          const Spacer(),
                          Text(entry.mood!.emoji),
                          const SizedBox(width: 4),
                          Text(
                            entry.mood!.label,
                            style: AppTypography.labelSmall,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      entry.content,
                      style: AppTypography.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _TasksPreview extends ConsumerWidget {
  final List todos;

  const _TasksPreview({required this.todos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Tasks', style: AppTypography.titleMedium),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Navigate to todos tab
              },
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: todos.map((todo) {
              return ListTile(
                leading: GestureDetector(
                  onTap: () {
                    ref.read(todoProvider.notifier).toggleComplete(todo.id);
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textTertiary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  todo.title,
                  style: AppTypography.bodyMedium,
                ),
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _BreathingSuggestion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Take a moment', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BreathingSessionScreen(
                  exercise: BreathingExercise.presets.first,
                ),
              ),
            );
          },
          backgroundColor: AppColors.breatheIn.withOpacity(0.1),
          borderColor: AppColors.breatheIn.withOpacity(0.3),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.breatheIn.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.air,
                  color: AppColors.breatheIn,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2-minute calm',
                      style: AppTypography.titleMedium,
                    ),
                    Text(
                      'A quick breathing exercise to center yourself',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_outline,
                color: AppColors.breatheIn,
                size: 32,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
