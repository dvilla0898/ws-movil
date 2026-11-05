import 'package:flutter/material.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../domain/task.dart';

/// Modal de confirmación para eliminar una tarea.
///
/// Solo pregunta: devuelve `true` si el usuario confirma. Quien lo abre es
/// quien llama al caso de uso de eliminar.
class DeleteTaskDialog extends StatelessWidget {
  const DeleteTaskDialog({super.key, required this.task});

  final Task task;

  static Future<bool> show(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteTaskDialog(task: task),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(Icons.delete_outline, color: colors.error),
      title: Text(strings.deleteTaskTitle),
      content: Text(strings.deleteTaskMessage(task.title)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(strings.cancel),
        ),
        FilledButton(
          key: const Key('confirm_delete'),
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(strings.delete),
        ),
      ],
    );
  }
}
