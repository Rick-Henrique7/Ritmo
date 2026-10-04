import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/swipe_delete_background.dart';
import '../data/tasks_controller.dart';
import '../domain/task_model.dart';
import 'task_form_dialog.dart';
import 'widgets/task_filter_tabs.dart';
import 'widgets/task_tile.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    final tasks = ref.watch(filteredTasksProvider);
    final accent = context.accent;

    final pending = ref.watch(pendingTasksCountProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              eyebrow: pending == 0
                  ? 'Tudo em dia'
                  : '$pending ${pending == 1 ? 'pendente' : 'pendentes'}',
              title: 'Tarefas',
            ),
            TaskFilterTabs(
              current: filter,
              accent: accent,
              labelFor: _label,
              onChanged: (f) =>
                  ref.read(taskFilterProvider.notifier).state = f,
            ),
            const SizedBox(height: 8),
            Expanded(child: _body(context, ref, filter, tasks)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova tarefa',
        onPressed: () => _openTaskDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    TaskFilter filter,
    List<TaskModel> tasks,
  ) {
    return tasks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _emptyIconFor(filter),
                      size: 56,
                      color: context.palette.textTertiary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _emptyTitleFor(filter),
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _emptyHintFor(filter),
                      style: TextStyle(
                        color: context.palette.textSecondary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (filter == TaskFilter.all ||
                        filter == TaskFilter.today) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _openTaskDialog(context, null),
                        icon: const Icon(Icons.add),
                        label: const Text('Criar tarefa'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          // Lista simples: a ordem vem do agendamento (data + hora). O
          // ReorderableListView antigo mostrava a alça "=" no desktop/web
          // e o arrastar não funcionava de verdade — a lista é re-ordenada
          // por data a cada build e os índices da aba filtrada não batiam
          // com os da lista completa.
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  key: ValueKey('task-row-${task.id}'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey('task-dismiss-${task.id}'),
                    direction: DismissDirection.endToStart,
                    background: const SwipeDeleteBackground(),
                    confirmDismiss: (_) =>
                        _confirmDelete(context, task),
                    onDismissed: (_) =>
                        _onTaskDismissed(context, ref, task),
                    child: TaskTile(
                      task: task,
                      onTap: () => _openTaskDialog(context, task),
                    ),
                  ),
                );
              },
            );
  }

  String _label(TaskFilter f) => switch (f) {
        TaskFilter.all => 'Todas',
        TaskFilter.today => 'Hoje',
        TaskFilter.upcoming => 'Próximas',
        TaskFilter.completed => 'Concluídas',
      };

  IconData _emptyIconFor(TaskFilter f) => switch (f) {
        TaskFilter.all => Icons.checklist_outlined,
        TaskFilter.today => Icons.wb_sunny_outlined,
        TaskFilter.upcoming => Icons.upcoming_outlined,
        TaskFilter.completed => Icons.task_alt_outlined,
      };

  String _emptyTitleFor(TaskFilter f) => switch (f) {
        TaskFilter.all => 'Nenhuma tarefa por aqui',
        TaskFilter.today => 'Nada pendente para hoje',
        TaskFilter.upcoming => 'Sem tarefas futuras',
        TaskFilter.completed => 'Nenhuma concluída ainda',
      };

  String _emptyHintFor(TaskFilter f) => switch (f) {
        TaskFilter.all => 'Toque no + para criar a primeira.',
        TaskFilter.today =>
          'Tarefas com data, hora ou repetição para hoje aparecem aqui.',
        TaskFilter.upcoming =>
          'Tarefas atrasadas, futuras e recorrentes aparecem aqui.',
        TaskFilter.completed =>
          'Quando você marcar tarefas como concluídas, elas aparecem aqui.',
      };

  /// Abre o dialog no modo edição (se [existing] for não-nulo) ou criação.
  Future<void> _openTaskDialog(
      BuildContext context, TaskModel? existing) async {
    await showDialog<void>(
      context: context,
      builder: (_) => TaskFormDialog(existing: existing),
    );
  }

  /// Confirma a exclusão. Para tarefa recorrente ou com data futura,
  /// avisa que a cadeia inteira de ocorrências também sai — uma
  /// `TaskModel` recorrente representa todas as ocorrências.
  Future<bool?> _confirmDelete(BuildContext context, TaskModel task) {
    final palette = context.palette;
    final accent = Theme.of(context).colorScheme.primary;
    return showConfirmDeleteDialog(
      context,
      title: 'Excluir tarefa?',
      message: '"${task.title}" será removida permanentemente. '
          'Essa ação pode ser desfeita na barra inferior.',
      details: !_isRecurring(task)
          ? null
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.surface2,
                borderRadius: BorderRadius.circular(AppColors.radiusSm),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.repeat_rounded, size: 18, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _recurrenceWarning(task),
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }


  /// Detecta se a tarefa representa uma cadeia de ocorrências futuras.
  bool _isRecurring(TaskModel t) {
    if (t.repeatDays.isNotEmpty) return true;
    final due = t.dueDate;
    if (due == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return due.isAfter(today);
  }

  /// Texto do aviso exibido quando a tarefa é recorrente ou tem
  /// data futura — explica que excluir remove toda a cadeia.
  String _recurrenceWarning(TaskModel t) {
    if (t.repeatDays.isNotEmpty) {
      const labels = ['', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      final days = [...t.repeatDays]..sort();
      final list = days.map((d) => labels[d]).join(', ');
      return 'Esta tarefa se repete em $list. Excluir também remove '
          'todas as ocorrências futuras.';
    }
    return 'Esta tarefa tem data futura. Excluir também remove o '
        'agendamento pendente.';
  }

  /// Remove a tarefa e oferece "Desfazer" por 4s na snackbar.
  Future<void> _onTaskDismissed(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    await ref.read(tasksProvider.notifier).remove(task.id);
    if (!context.mounted) return;
    final recurring = _isRecurring(task);
    AppUndoSnackBar.show(
      context,
      icon: recurring ? Icons.event_repeat_outlined : Icons.delete_outline,
      message: recurring
          ? 'Tarefa "${task.title}" e suas próximas ocorrências foram excluídas'
          : 'Tarefa "${task.title}" excluída',
      onUndo: () => ref.read(tasksProvider.notifier).add(task),
    );
  }
}






