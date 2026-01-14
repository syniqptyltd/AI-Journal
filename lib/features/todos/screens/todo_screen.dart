import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/todo_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/services/ai_service.dart';
import '../providers/todo_provider.dart';

/// Main to-do list screen
class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoProvider);
    final pendingSuggestions = todoState.pendingSuggestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do'),
        actions: [
          if (todoState.completedTodos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () => _showCompletedTodos(context, ref),
              tooltip: 'Completed tasks',
            ),
        ],
      ),
      body: todoState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // AI Suggestions banner
                if (pendingSuggestions.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _AISuggestionsBanner(
                      suggestions: pendingSuggestions,
                    ),
                  ),

                // Incomplete todos
                if (todoState.incompleteTodos.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'All done!',
                      message: 'You have no pending tasks. Enjoy the moment.',
                      actionLabel: 'Add Task',
                      onAction: () => _showAddTodoDialog(context, ref),
                    ),
                  )
                else
                  SliverPadding(
                    padding: AppSpacing.pagePadding,
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final todo = todoState.incompleteTodos[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _TodoItemCard(todo: todo),
                          );
                        },
                        childCount: todoState.incompleteTodos.length,
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context, ref),
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddTodoSheet(ref: ref),
    );
  }

  void _showCompletedTodos(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CompletedTodosSheet(ref: ref),
    );
  }
}

class _TodoItemCard extends ConsumerWidget {
  final TodoItem todo;

  const _TodoItemCard({required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) {
        ref.read(todoProvider.notifier).deleteTodo(todo.id);
      },
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                ref.read(todoProvider.notifier).toggleComplete(todo.id);
              },
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getPriorityColor(todo.priority),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          todo.title,
                          style: AppTypography.titleMedium,
                        ),
                      ),
                      if (todo.isFromAI)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'AI',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (todo.description != null &&
                      todo.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      todo.description!,
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (todo.aiContext != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      todo.aiContext!,
                      style: AppTypography.aiInsight.copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return AppColors.error;
      case TodoPriority.medium:
        return AppColors.warning;
      case TodoPriority.low:
        return AppColors.textTertiary;
    }
  }
}

class _AISuggestionsBanner extends ConsumerWidget {
  final List<TaskSuggestion> suggestions;

  const _AISuggestionsBanner({required this.suggestions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: AppSpacing.pagePadding,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Suggested for you',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ref.read(todoProvider.notifier).clearSuggestions();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 30),
                ),
                child: Text(
                  'Dismiss all',
                  style: AppTypography.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _SuggestionChip(suggestion: suggestion),
            );
          }),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.1, end: 0, duration: 300.ms);
  }
}

class _SuggestionChip extends ConsumerWidget {
  final TaskSuggestion suggestion;

  const _SuggestionChip({required this.suggestion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: AppTypography.bodyMedium,
                ),
                if (suggestion.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    suggestion.description,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              ref.read(todoProvider.notifier).acceptSuggestion(suggestion);
            },
            color: AppColors.primary,
            tooltip: 'Add task',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(todoProvider.notifier).dismissSuggestion(suggestion);
            },
            color: AppColors.textTertiary,
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }
}

class _AddTodoSheet extends StatefulWidget {
  final WidgetRef ref;

  const _AddTodoSheet({required this.ref});

  @override
  State<_AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<_AddTodoSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TodoPriority _priority = TodoPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('New Task', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'What do you need to do?',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Priority', style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<TodoPriority>(
            segments: TodoPriority.values.map((p) {
              return ButtonSegment(
                value: p,
                label: Text(p.label),
              );
            }).toList(),
            selected: {_priority},
            onSelectionChanged: (selected) {
              setState(() => _priority = selected.first);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _titleController.text.trim().isEmpty ? null : _save,
              child: const Text('Add Task'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() async {
    await widget.ref.read(todoProvider.notifier).createTodo(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          priority: _priority,
        );
    if (mounted) Navigator.of(context).pop();
  }
}

class _CompletedTodosSheet extends StatelessWidget {
  final WidgetRef ref;

  const _CompletedTodosSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final completedTodos = ref.watch(completedTodosProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Completed (${completedTodos.length})',
                    style: AppTypography.headlineSmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: AppSpacing.pageHorizontal,
                itemCount: completedTodos.length,
                itemBuilder: (context, index) {
                  final todo = completedTodos[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              todo.title,
                              style: AppTypography.bodyMedium.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.undo),
                            onPressed: () {
                              ref.read(todoProvider.notifier).toggleComplete(todo.id);
                            },
                            tooltip: 'Mark incomplete',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
