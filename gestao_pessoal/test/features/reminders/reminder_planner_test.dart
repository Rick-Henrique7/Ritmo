import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/core/notifications/notification_scheduler.dart';
import 'package:gestao_pessoal/features/habits/domain/habit_model.dart';
import 'package:gestao_pessoal/features/reminders/domain/reminder.dart';
import 'package:gestao_pessoal/features/reminders/domain/reminder_planner.dart';
import 'package:gestao_pessoal/features/settings/domain/notification_settings.dart';
import 'package:gestao_pessoal/features/tasks/domain/task_model.dart';

import '../../helpers/fixtures.dart';

void main() {
  // Quinta, 01/10/2026, 7h — antes do resumo da manhã.
  final now = DateTime(2026, 10, 1, 7);
  const on = NotificationSettings.defaults;

  List<ScheduledNotification> plan({
    List<TaskModel> tasks = const [],
    List<HabitModel> habits = const [],
    NotificationSettings settings = on,
    List<ReminderSnooze> snoozes = const [],
    DateTime? at,
  }) =>
      ReminderPlanner.plan(
        tasks: tasks,
        habits: habits,
        settings: settings,
        snoozes: snoozes,
        now: at ?? now,
      );

  Iterable<ScheduledNotification> onDay(
    List<ScheduledNotification> p,
    DateTime day,
  ) =>
      p.where((n) =>
          n.at.year == day.year && n.at.month == day.month && n.at.day == day.day);

  ReminderKind kindOf(ScheduledNotification n) =>
      ReminderPayload.decode(n.payload)!.kind;

  group('resumo e pendências', () {
    test('resumo às 8h e pendências às 20h contam tarefas e hábitos do dia', () {
      final p = plan(
        tasks: [task(id: 'a', dueDate: thu), task(id: 'b', dueDate: thu)],
        habits: [habit(id: 'h')],
      );
      final today = onDay(p, thu).toList();
      final morning = today.firstWhere((n) => kindOf(n) == ReminderKind.morning);
      final evening = today.firstWhere((n) => kindOf(n) == ReminderKind.evening);

      expect(morning.at, DateTime(2026, 10, 1, 8));
      expect(morning.body, 'Hoje: 2 tarefas e 1 hábito');
      expect(evening.at, DateTime(2026, 10, 1, 20));
      expect(evening.body, 'Faltam 2 tarefas e 1 hábito hoje.');
    });

    test('dia sem nada previsto não gera resumo nem pendências', () {
      final p = plan(habits: [habit(frequencyDays: const [1])]); // só segunda
      expect(onDay(p, thu), isEmpty);
    });

    test('tudo feito: pendências da noite não são agendadas', () {
      final p = plan(
        tasks: [task(dueDate: thu, isCompleted: true, completedAt: thu)],
        habits: [habit(completedDates: [thu])],
        at: DateTime(2026, 10, 1, 18),
      );
      expect(onDay(p, thu), isEmpty);
    });

    test('resumo indica as atrasadas', () {
      final p = plan(tasks: [task(dueDate: mon)]);
      final morning = onDay(p, thu)
          .firstWhere((n) => kindOf(n) == ReminderKind.morning);
      expect(morning.body, 'Hoje: 1 tarefa · 1 atrasada');
    });

    test('horário que já passou hoje não é agendado', () {
      final p = plan(tasks: [task(dueDate: thu)], at: DateTime(2026, 10, 1, 9));
      final kinds = onDay(p, thu).map(kindOf);
      expect(kinds, isNot(contains(ReminderKind.morning)));
      expect(kinds, contains(ReminderKind.evening));
    });
  });

  group('tarefas com horário', () {
    test('avisa na hora, com botões', () {
      final p = plan(tasks: [
        task(id: 'dentista', title: 'Dentista', dueDate: thu,
            dueTime: const TimeOfDay(hour: 15, minute: 0)),
      ]);
      final n = p.firstWhere((n) => kindOf(n) == ReminderKind.task);
      expect(n.at, DateTime(2026, 10, 1, 15));
      expect(n.title, 'Dentista');
      expect(n.withActions, isTrue);
    });

    test('com antecedência de 15 min avisa às 14h45', () {
      final p = plan(
        tasks: [task(dueDate: thu, dueTime: const TimeOfDay(hour: 15, minute: 0))],
        settings: on.copyWith(taskLeadMinutes: 15),
      );
      final n = p.firstWhere((n) => kindOf(n) == ReminderKind.task);
      expect(n.at, DateTime(2026, 10, 1, 14, 45));
      expect(n.body, 'Em 15 min · 15:00');
    });

    test('concluída antes do horário não avisa', () {
      final p = plan(tasks: [
        task(dueDate: thu, dueTime: const TimeOfDay(hour: 15, minute: 0),
            isCompleted: true, completedAt: thu),
      ]);
      expect(p.where((n) => kindOf(n) == ReminderKind.task), isEmpty);
    });

    test('recorrente com horário avisa em cada dia previsto', () {
      final p = plan(tasks: [
        task(repeatDays: const [4, 5], // qui e sex
            dueTime: const TimeOfDay(hour: 9, minute: 30)),
      ]);
      final days = p
          .where((n) => kindOf(n) == ReminderKind.task)
          .map((n) => n.at.weekday)
          .toList();
      expect(days, [4, 5]);
    });
  });

  group('hábitos', () {
    test('avisa no horário só nos dias previstos', () {
      final p = plan(habits: [
        habit(title: 'Correr', frequencyDays: const [1, 3, 5],
            reminderTime: const TimeOfDay(hour: 7, minute: 30)),
      ]);
      final days = p
          .where((n) => kindOf(n) == ReminderKind.habit)
          .map((n) => n.at.weekday)
          .toSet();
      expect(days, {1, 3, 5});
    });

    test('hábito já feito no dia não avisa', () {
      final p = plan(habits: [
        habit(completedDates: [thu],
            reminderTime: const TimeOfDay(hour: 21, minute: 0)),
      ]);
      expect(
        onDay(p, thu).where((n) => kindOf(n) == ReminderKind.habit),
        isEmpty,
      );
    });
  });

  group('configurações e adiamento', () {
    test('chave geral desligada: nenhum aviso', () {
      final p = plan(
        tasks: [task(dueDate: thu)],
        settings: on.copyWith(enabled: false),
      );
      expect(p, isEmpty);
    });

    test('tipo desligado some, os outros continuam', () {
      final p = plan(
        tasks: [task(dueDate: thu)],
        settings: on.copyWith(morningEnabled: false),
      );
      final kinds = onDay(p, thu).map(kindOf);
      expect(kinds, isNot(contains(ReminderKind.morning)));
      expect(kinds, contains(ReminderKind.evening));
    });

    test('adiar 1 h move o aviso e mantém o mesmo id', () {
      final t = task(id: 'x', dueDate: thu,
          dueTime: const TimeOfDay(hour: 15, minute: 0));
      final original = plan(tasks: [t])
          .firstWhere((n) => kindOf(n) == ReminderKind.task);
      final key = ReminderPayload.keyFor(ReminderKind.task, thu, 'x');
      final snoozed = plan(
        tasks: [t],
        snoozes: [ReminderSnooze(key: key, until: DateTime(2026, 10, 1, 16, 5))],
        at: DateTime(2026, 10, 1, 15, 5),
      ).firstWhere((n) => kindOf(n) == ReminderKind.task);

      expect(snoozed.at, DateTime(2026, 10, 1, 16, 5));
      expect(snoozed.id, original.id);
    });
  });

  test('payload ida e volta preserva tipo, dia e item', () {
    final p = ReminderPayload(
      kind: ReminderKind.habit,
      day: thu,
      itemId: 'h1',
      title: 'Ler',
      body: 'x',
    );
    final back = ReminderPayload.decode(p.encode())!;
    expect(back.kind, ReminderKind.habit);
    expect(back.day, thu);
    expect(back.itemId, 'h1');
    expect(back.route, '/habits');
    expect(ReminderPayload.decode('lixo'), isNull);
  });

  test('ids estáveis e distintos por aviso', () {
    expect(stableId('task:a:2026-10-1'), stableId('task:a:2026-10-1'));
    expect(stableId('task:a:2026-10-1'), isNot(stableId('task:a:2026-10-2')));
    expect(stableId('qualquer'), greaterThan(focusNotificationId));
  });
}
