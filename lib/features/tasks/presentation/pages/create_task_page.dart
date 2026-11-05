import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependencies.dart';
import '../../../../app/l10n/app_strings.dart';
import '../cubit/task_form_cubit.dart';
import '../widgets/task_form.dart';

/// Pantalla para registrar una tarea. Devuelve `true` al guardarla.
class CreateTaskPage extends StatelessWidget {
  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskFormCubit.create(
        createTask: context.read<AppDependencies>().createTask,
      ),
      child: BlocConsumer<TaskFormCubit, TaskFormState>(
        listenWhen: (previous, current) =>
            current.status == TaskFormStatus.saved,
        listener: (context, state) => Navigator.of(context).pop(true),
        builder: (context, state) {
          final strings = AppStrings.of(context);
          return Scaffold(
            appBar: AppBar(title: Text(strings.newTask)),
            body: TaskForm(
              submitLabel: strings.save,
              saving:
                  state.status == TaskFormStatus.saving ||
                  state.status == TaskFormStatus.saved,
              failure: state.failure,
              onSubmit: context.read<TaskFormCubit>().submit,
            ),
          );
        },
      ),
    );
  }
}
