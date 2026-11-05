import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependencies.dart';
import '../../../../app/l10n/app_strings.dart';
import '../cubit/task_form_cubit.dart';
import '../widgets/task_form.dart';

/// Pantalla para actualizar una tarea. Devuelve `true` al guardarla.
class EditTaskPage extends StatelessWidget {
  const EditTaskPage({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context) {
    final dependencies = context.read<AppDependencies>();

    return BlocProvider(
      create: (_) => TaskFormCubit.edit(
        taskId: taskId,
        getTask: dependencies.getTask,
        updateTask: dependencies.updateTask,
      )..load(),
      child: BlocConsumer<TaskFormCubit, TaskFormState>(
        listenWhen: (previous, current) =>
            current.status == TaskFormStatus.saved,
        listener: (context, state) => Navigator.of(context).pop(true),
        builder: (context, state) {
          final strings = AppStrings.of(context);
          return Scaffold(
            appBar: AppBar(title: Text(strings.editTask)),
            body: switch (state.status) {
              TaskFormStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              TaskFormStatus.loadFailure => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    strings.failure(state.failure!),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              _ => TaskForm(
                submitLabel: strings.save,
                initialTask: state.initialTask,
                saving:
                    state.status == TaskFormStatus.saving ||
                    state.status == TaskFormStatus.saved,
                failure: state.failure,
                onSubmit: context.read<TaskFormCubit>().submit,
              ),
            },
          );
        },
      ),
    );
  }
}
