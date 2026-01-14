import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/mood.dart';
import '../../../core/models/ai_insight.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/providers/providers.dart';
import '../../journal/providers/journal_provider.dart';
import '../providers/insights_provider.dart';

/// Screen showing AI-generated insights and analytics
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    // Load insights when screen opens
    Future.microtask(() {
      ref.read(insightsProvider.notifier).loadInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final insightsState = ref.watch(insightsProvider);
    final journalState = ref.watch(journalProvider);
    final isAIConfigured = ref.watch(isAIConfiguredProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(insightsProvider.notifier).refresh(),
            tooltip: 'Refresh insights',
          ),
        ],
      ),
      body: insightsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : journalState.entries.isEmpty
              ? EmptyState(
                  icon: Icons.insights_outlined,
                  title: 'Start journaling',
                  message:
                      'Write a few entries to unlock personalized insights about your wellbeing.',
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(insightsProvider.notifier).refresh(),
                  child: ListView(
                    padding: AppSpacing.pagePadding,
                    children: [
                      // Stats row
                      _StatsRow(
                        totalEntries: insightsState.totalEntries,
                        currentStreak: insightsState.currentStreak,
                        thisWeekEntries: journalState.thisWeekEntries.length,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // AI Insights (if available)
                      if (insightsState.weeklyInsights != null) ...[
                        _WeeklyInsightsCard(
                          insights: insightsState.weeklyInsights!,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ] else if (!isAIConfigured) ...[
                        _AIConfigPrompt(),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Mood distribution
                      if (insightsState.moodDistribution.isNotEmpty) ...[
                        Text('Mood This Week',
                            style: AppTypography.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        _MoodDistributionCard(
                          distribution: insightsState.moodDistribution,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Top themes
                      if (insightsState.topThemes.isNotEmpty) ...[
                        Text('Themes', style: AppTypography.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        _ThemesCard(themes: insightsState.topThemes),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Recent patterns
                      _PatternsSection(),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalEntries;
  final int currentStreak;
  final int thisWeekEntries;

  const _StatsRow({
    required this.totalEntries,
    required this.currentStreak,
    required this.thisWeekEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.book_outlined,
            value: '$totalEntries',
            label: 'Entries',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            value: '$currentStreak',
            label: 'Day streak',
            accentColor: currentStreak > 0 ? AppColors.warning : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today,
            value: '$thisWeekEntries',
            label: 'This week',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? accentColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Icon(
            icon,
            color: accentColor ?? AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: accentColor ?? AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _WeeklyInsightsCard extends StatelessWidget {
  final WeeklyInsights insights;

  const _WeeklyInsightsCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.secondaryLight.withOpacity(0.2),
      borderColor: AppColors.secondary.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Weekly Reflection',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Observation
          Text(
            insights.observation,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          // Encouragement
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, color: AppColors.success, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    insights.encouragement,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Suggestion
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.info, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    insights.suggestion,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodDistributionCard extends StatelessWidget {
  final Map<Mood, int> distribution;

  const _MoodDistributionCard({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (a, b) => a + b);
    final sortedMoods = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AppCard(
      child: Column(
        children: sortedMoods.map((entry) {
          final percentage = total > 0 ? entry.value / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Text(entry.key.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  entry.key.label,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation(entry.key.color),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${entry.value}',
                  style: AppTypography.labelMedium,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ThemesCard extends StatelessWidget {
  final List<String> themes;

  const _ThemesCard({required this.themes});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: themes.map((theme) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
            ),
            child: Text(
              JournalTheme.getLabel(theme),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AIConfigPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.info.withOpacity(0.1),
      borderColor: AppColors.info.withOpacity(0.3),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.info),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock AI Insights',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure your AI API key to receive personalized weekly reflections and suggestions.',
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

class _PatternsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Understanding Your Patterns', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PatternTip(
                icon: Icons.schedule,
                title: 'Best time to journal',
                description:
                    'Try journaling at the same time each day to build a consistent habit.',
              ),
              const Divider(height: AppSpacing.lg),
              _PatternTip(
                icon: Icons.trending_up,
                title: 'Track your progress',
                description:
                    'Regular entries help reveal patterns in your mood and thoughts over time.',
              ),
              const Divider(height: AppSpacing.lg),
              _PatternTip(
                icon: Icons.psychology,
                title: 'Reflect without judgment',
                description:
                    'There are no right or wrong feelings. Each entry is a step toward self-understanding.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PatternTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PatternTip({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleMedium),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
