import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/utils/date_only.dart';
import '../domain/subtask_model.dart';
import '../domain/task_model.dart';
import '../domain/task_schedule.dart';

import 'prefs_tasks_repository.dart';

export '../domain/task_schedule.dart' show TaskFilter, TaskSchedule;

const _uuid = Uuid();

class TasksNotifier extends Notifier<List<TaskModel>> {
  @override
  List<TaskModel> build() => ref.watch(tasksRepositoryProvider).loadAll()
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

  Future<void> _persist() => ref.read(tasksRepositoryProvider).saveAll(state);

  Future<TaskModel> create({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    String category = 'Geral',
    DateTime? dueDate,
    TimeOfDay? dueTime,
    List<int> repeatDays = const [],
  }) async {
    final maxOrder = state.isEmpty
        ? 0
        : state.map((t) => t.orderIndex).reduce((a, b) => a > b ? a : b);
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      category: category,
      dueDate: dueDate,
      dueTime: dueTime,
      repeatDays: repeatDays,
      isCompleted: false,
      completedAt: null,
      subtasks: const [],
      orderIndex: maxOrder + 1,
    );
    state = [...state, task];
    await _persist();
    return task;
  }

  /// Re-insere uma tarefa existente (mesmo ID). Usado pelo "Desfazer"
  /// após swipe-to-delete — preserva o id original e o `orderIndex`.
  Future<void> add(TaskModel task) async {
    state = [...state, task];
    await _persist();
  }

  Future<void> update(TaskModel task) async {
    state = [
      for (final t in state) if (t.id == task.id) task else t,
    ];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _persist();
  }

  /// Marca/desmarca a tarefa como feita (RF-TD-04).
  ///
  /// - Pontual: alterna `isCompleted`.
  /// - Recorrente: alterna a conclusão **do dia** [on] (padrão: hoje), em
  ///   `completedDates` — na próxima ocorrência ela volta a ficar pendente.
  Future<void> toggleCompleted(TaskModel task, {DateTime? on}) async {
    final day = dateOnly(on ?? ref.read(todayProvider));
    final bool nowDone;
    final TaskModel updated;

    if (task.isRepeating) {
      nowDone = !task.isCompletedOn(day);
      final dates = [
        for (final d in task.completedDates)
          if (!isSameDay(d, day)) d,
        if (nowDone) day,
      ];
      updated = task.copyWith(
        completedDates: dates,
        completedAt: nowDone ? DateTime.now() : null,
        clearCompletedAt: !nowDone && dates.isEmpty,
      );
    } else {
      nowDone = !task.isCompleted;
      updated = task.copyWith(
        isCompleted: nowDone,
        completedAt: nowDone ? DateTime.now() : null,
        clearCompletedAt: !nowDone,
      );
    }

    await update(updated);
    await ref.read(hapticsServiceProvider).light();
    // Som de sucesso só ao CONCLUIR (não ao reabrir)
    if (nowDone) {
      await ref.read(soundServiceProvider).playSuccess();
    }
  }

  /// Sub-tarefas (RF-TD-01).
  Future<void> addSubtask(String taskId, String title) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final updated = task.copyWith(
      subtasks: [
        ...task.subtasks,
        SubtaskModel(
          id: _uuid.v4(),
          title: title,
          isCompleted: false,
        ),
      ],
    );
    await update(updated);
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final updated = task.copyWith(
      subtasks: [
        for (final s in task.subtasks)
          if (s.id == subtaskId) s.copyWith(isCompleted: !s.isCompleted) else s,
      ],
    );
    await update(updated);
  }

  /// Reordena a lista (Drag & Drop — RF-TD-02).
  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [...state];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    state = [
      for (var i = 0; i < list.length; i++)
        list[i].copyWith(orderIndex: i),
    ];
    await _persist();
  }
}

final tasksProvider =
    NotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);

/// Aba selecionada na tela de Tarefas.
final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

/// Conteúdo da aba ativa — regras em [TaskSchedule.filter].
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  return TaskSchedule.filter(
    ref.watch(tasksProvider),
    ref.watch(taskFilterProvider),
    ref.watch(todayProvider),
  );
});

/// Tarefas de hoje (pendentes e já feitas) — usado pela tela Hoje.
final todayTasksProvider = Provider<List<TaskModel>>((ref) {
  return TaskSchedule.forDay(ref.watch(tasksProvider), ref.watch(todayProvider));
});

/// Quantas tarefas ainda pedem ação hoje.
final pendingTasksCountProvider = Provider<int>((ref) {
  return TaskSchedule.pendingCount(
    ref.watch(tasksProvider),
    ref.watch(todayProvider),
  );
});
