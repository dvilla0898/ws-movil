import 'package:flutter/material.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../core/domain/failure.dart';
import '../../application/task_input.dart';
import '../../domain/task.dart';
import '../../domain/task_priority.dart';
import '../../domain/value_objects/task_description.dart';
import '../../domain/value_objects/task_title.dart';

/// Campos del formulario de tarea. Lo comparten las pantallas de registrar y
/// actualizar; la validación la hace el caso de uso, aquí solo se muestran
/// los errores que devuelve.
class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    required this.submitLabel,
    required this.saving,
    required this.onSubmit,
    this.initialTask,
    this.failure,
  });

  final String submitLabel;
  final bool saving;
  final ValueChanged<TaskInput> onSubmit;
  final Task? initialTask;
  final Failure? failure;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late TaskPriority _priority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _title = TextEditingController(text: task?.title);
    _description = TextEditingController(text: task?.description);
    _priority = task?.priority ?? TaskPriority.medium;
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: DateTime(today.year - 5),
      lastDate: DateTime(today.year + 10),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    widget.onSubmit(
      TaskInput(
        title: _title.text,
        description: _description.text,
        priority: _priority,
        dueDate: _dueDate,
      ),
    );
  }

  String? _errorFor(AppStrings strings, String field) {
    final failure = widget.failure;
    if (failure is ValidationFailure && failure.field == field) {
      return strings.failure(failure);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final failure = widget.failure;
    final dueDate = _dueDate;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          key: const Key('task_title'),
          controller: _title,
          enabled: !widget.saving,
          maxLength: TaskTitle.maxLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: strings.titleLabel,
            border: const OutlineInputBorder(),
            errorText: _errorFor(strings, 'title'),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('task_description'),
          controller: _description,
          enabled: !widget.saving,
          minLines: 3,
          maxLines: 6,
          maxLength: TaskDescription.maxLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: strings.descriptionLabel,
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
            errorText: _errorFor(strings, 'description'),
          ),
        ),
        const SizedBox(height: 16),
        Text(strings.priorityLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<TaskPriority>(
          segments: [
            for (final priority in TaskPriority.values)
              ButtonSegment(
                value: priority,
                label: Text(strings.priorityName(priority)),
              ),
          ],
          selected: {_priority},
          onSelectionChanged: widget.saving
              ? null
              : (selection) => setState(() => _priority = selection.first),
        ),
        const SizedBox(height: 24),
        Text(strings.dueDateLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.event_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dueDate == null
                    ? strings.noDueDate
                    : MaterialLocalizations.of(
                        context,
                      ).formatFullDate(dueDate),
              ),
            ),
            if (dueDate != null)
              IconButton(
                tooltip: strings.clearDate,
                icon: const Icon(Icons.close),
                onPressed: widget.saving
                    ? null
                    : () => setState(() => _dueDate = null),
              ),
            TextButton(
              onPressed: widget.saving ? null : _pickDate,
              child: Text(strings.pickDate),
            ),
          ],
        ),
        if (failure != null && failure is! ValidationFailure) ...[
          const SizedBox(height: 16),
          Text(
            strings.failure(failure),
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const Key('task_submit'),
          onPressed: widget.saving ? null : _submit,
          icon: widget.saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
