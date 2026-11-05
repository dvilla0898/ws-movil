import 'package:flutter/material.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../domain/task.dart';
import '../../domain/task_priority.dart';

/// Una fila del listado: casilla para marcarla, título, prioridad, fecha y
/// botón de eliminar. Al tocarla se abre la edición.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.now,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final Task task;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final due = task.dueDate;
    final overdue = task.isOverdueAt(now);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.isDone,
          semanticLabel: task.isDone ? strings.markPending : strings.markDone,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: task.isDone
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.outline,
                )
              : null,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _PriorityLabel(priority: task.priority),
              if (due != null)
                Text(
                  overdue
                      ? '${strings.overdue} · ${MaterialLocalizations.of(context).formatMediumDate(due)}'
                      : strings.dueOn(
                          MaterialLocalizations.of(
                            context,
                          ).formatMediumDate(due),
                        ),
                  style: TextStyle(
                    color: overdue ? theme.colorScheme.error : null,
                    fontWeight: overdue ? FontWeight.w600 : null,
                  ),
                ),
            ],
          ),
        ),
        trailing: IconButton(
          tooltip: strings.delete,
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _PriorityLabel extends StatelessWidget {
  const _PriorityLabel({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground) = switch (priority) {
      TaskPriority.high => (colors.errorContainer, colors.onErrorContainer),
      TaskPriority.medium => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      TaskPriority.low => (
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          AppStrings.of(context).priorityName(priority),
          style: TextStyle(color: foreground, fontSize: 12),
        ),
      ),
    );
  }
}
