import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependencies.dart';
import '../../../../app/l10n/app_strings.dart';
import '../../../../app/l10n/language_button.dart';
import '../../../../core/domain/failure.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../application/use_cases/list_tasks_use_case.dart';
import '../../domain/task.dart';
import '../cubit/tasks_cubit.dart';
import '../widgets/delete_task_dialog.dart';
import '../widgets/task_tile.dart';
import 'create_task_page.dart';
import 'edit_task_page.dart';

/// Pantalla principal: listado de tareas con filtros.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = context.read<AppDependencies>();
    return BlocProvider(
      create: (_) => TasksCubit(
        listTasks: dependencies.listTasks,
        toggleTaskStatus: dependencies.toggleTaskStatus,
        deleteTask: dependencies.deleteTask,
      )..load(),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView();

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showFailure(BuildContext context, Failure? failure) {
    if (failure != null && context.mounted) {
      _showMessage(context, AppStrings.of(context).failure(failure));
    }
  }

  Future<void> _openCreate(BuildContext context) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CreateTaskPage()));
    if (saved != true || !context.mounted) return;
    _showMessage(context, AppStrings.of(context).taskCreated);
    await context.read<TasksCubit>().load();
  }

  Future<void> _openEdit(BuildContext context, Task task) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditTaskPage(taskId: task.id)),
    );
    if (saved != true || !context.mounted) return;
    _showMessage(context, AppStrings.of(context).taskUpdated);
    await context.read<TasksCubit>().load();
  }

  Future<void> _toggle(BuildContext context, Task task) async {
    final failure = await context.read<TasksCubit>().toggle(task.id);
    if (context.mounted) _showFailure(context, failure);
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final confirmed = await DeleteTaskDialog.show(context, task);
    if (!confirmed || !context.mounted) return;

    final failure = await context.read<TasksCubit>().delete(task.id);
    if (!context.mounted) return;
    if (failure == null) {
      _showMessage(context, AppStrings.of(context).taskDeleted);
    } else {
      _showFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final authState = context.watch<AuthCubit>().state;
    final username = authState is AuthAuthenticated
        ? authState.session.username
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          const LanguageButton(),
          IconButton(
            key: const Key('logout'),
            tooltip: strings.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('new_task'),
        onPressed: () => _openCreate(context),
        icon: const Icon(Icons.add),
        label: Text(strings.newTask),
      ),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  strings.greeting(username),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<TaskFilter>(
                  segments: [
                    ButtonSegment(
                      value: TaskFilter.all,
                      label: Text(strings.filterAll),
                    ),
                    ButtonSegment(
                      value: TaskFilter.pending,
                      label: Text(strings.filterPending),
                    ),
                    ButtonSegment(
                      value: TaskFilter.done,
                      label: Text(strings.filterDone),
                    ),
                  ],
                  selected: {state.filter},
                  onSelectionChanged: (selection) =>
                      context.read<TasksCubit>().changeFilter(selection.first),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, TasksState state) {
    final strings = AppStrings.of(context);

    switch (state.status) {
      case TasksStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case TasksStatus.failure:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.failure(state.failure!)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.read<TasksCubit>().load(),
                child: Text(strings.retry),
              ),
            ],
          ),
        );
      case TasksStatus.ready:
        if (state.tasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.checklist, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    strings.emptyTasks,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(strings.emptyTasksHint, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        final now = DateTime.now();
        return RefreshIndicator(
          onRefresh: context.read<TasksCubit>().load,
          child: ListView.builder(
            // Deja espacio al final para que el botón no tape la última tarea.
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 88),
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return TaskTile(
                key: ValueKey(task.id),
                task: task,
                now: now,
                onTap: () => _openEdit(context, task),
                onToggle: () => _toggle(context, task),
                onDelete: () => _confirmDelete(context, task),
              );
            },
          ),
        );
    }
  }
}
