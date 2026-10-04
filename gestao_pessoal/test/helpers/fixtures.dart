import 'package:flutter/material.dart' show TimeOfDay;
import 'package:gestao_pessoal/features/habits/domain/habit_model.dart';
import 'package:gestao_pessoal/features/tasks/domain/subtask_model.dart';
import 'package:gestao_pessoal/features/tasks/domain/task_model.dart';

/// Quinta-feira, 1º de outubro de 2026 (weekday = 4). Todas as regras
/// recebem "hoje" como parâmetro — por isso os testes são determinísticos.
final thu = DateTime(2026, 10, 1);
final fri = DateTime(2026, 10, 2);
final wed = DateTime(2026, 9, 30);
final tue = DateTime(2026, 9, 29);
final mon = DateTime(2026, 9, 28);

TaskModel task({
  String id = 't',
  String title = 'Tarefa',
  DateTime? dueDate,
  TimeOfDay? dueTime,
  List<int> repeatDays = const [],
  bool isCompleted = false,
  DateTime? completedAt,
  List<DateTime> completedDates = const [],
  int orderIndex = 0,
}) {
  return TaskModel(
    id: id,
    title: title,
    description: null,
    priority: TaskPriority.medium,
    category: 'Geral',
    dueDate: dueDate,
    dueTime: dueTime,
    repeatDays: repeatDays,
    isCompleted: isCompleted,
    completedAt: completedAt,
    subtasks: const [],
    orderIndex: orderIndex,
    completedDates: completedDates,
  );
}

HabitModel habit({
  String id = 'h',
  String title = 'Hábito',
  TimeOfDay? reminderTime,
  List<int> frequencyDays = const [1, 2, 3, 4, 5, 6, 7],
  List<DateTime> completedDates = const [],
}) {
  return HabitModel(
    id: id,
    title: title,
    category: 'Geral',
    iconKey: 'water',
    colorHex: '#4F8A83',
    frequencyDays: frequencyDays,
    targetValue: 1,
    unit: 'vez',
    completedDates: completedDates,
    reminderTime: reminderTime,
  );
}
