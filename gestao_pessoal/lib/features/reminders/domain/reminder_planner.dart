import '../../../core/notifications/notification_scheduler.dart';
import '../../../core/utils/date_only.dart';
import '../../habits/domain/habit_model.dart';
import '../../settings/domain/notification_settings.dart';
import '../../tasks/domain/task_model.dart';
import '../../tasks/domain/task_schedule.dart';
import 'reminder.dart';

/// Decide **quais avisos existem e quando** — função pura, sem plugin, sem
/// relógio próprio (RF-NT-01 a 04, RF-NT-08).
///
/// O app chama a cada mudança de dados e substitui todos os avisos
/// pendentes pelo resultado. Por isso nada aqui precisa "lembrar" do que
/// já foi agendado: o plano é sempre recalculado do estado atual.
abstract final class ReminderPlanner {
  /// Quantos dias à frente agendar.
  static const horizonDays = 7;

  /// Limite de segurança (o Android aceita até 500 alarmes por app).
  static const maxNotifications = 400;

  static List<ScheduledNotification> plan({
    required List<TaskModel> tasks,
    required List<HabitModel> habits,
    required NotificationSettings settings,
    required List<ReminderSnooze> snoozes,
    required DateTime now,
  }) {
    if (!settings.enabled) return const [];

    final snoozedUntil = {
      for (final s in snoozes)
        if (s.until.isAfter(now)) s.key: s.until,
    };
    final out = <ScheduledNotification>[];

    void add(ReminderPayload p, DateTime at, {bool actions = false}) {
      final when = snoozedUntil[p.key] ?? at;
      if (!when.isAfter(now)) return;
      out.add(ScheduledNotification(
        id: stableId(p.key),
        at: when,
        title: p.title,
        body: p.body,
        payload: p.encode(),
        withActions: actions,
      ));
    }

    final today = dateOnly(now);
    for (var i = 0; i < horizonDays; i++) {
      final day = DateTime(today.year, today.month, today.day + i);

      final pendingTasks = TaskSchedule.forDay(tasks, day)
          .where((t) => !TaskSchedule.isDoneOn(t, day))
          .toList();
      final overdue =
          pendingTasks.where((t) => TaskSchedule.isOverdue(t, day)).length;
      final pendingHabits = habits
          .where((h) => h.isScheduledFor(day) && !h.isCompletedOn(day))
          .toList();
      final pendingTotal = pendingTasks.length + pendingHabits.length;

      // RF-NT-01 — resumo da manhã; nada previsto, nada enviado.
      if (settings.morningEnabled && pendingTotal > 0) {
        final late = overdue > 0
            ? ' · $overdue ${overdue == 1 ? 'atrasada' : 'atrasadas'}'
            : '';
        add(
          ReminderPayload(
            kind: ReminderKind.morning,
            day: day,
            title: 'Bom dia! Seu dia no Daily Flow',
            body: 'Hoje: ${_count(pendingTasks.length, pendingHabits.length)}'
                '$late',
          ),
          _at(day, settings.morningMinutes),
        );
      }

      // RF-NT-02 — pendências da noite; tudo feito, nada enviado.
      if (settings.eveningEnabled && pendingTotal > 0) {
        add(
          ReminderPayload(
            kind: ReminderKind.evening,
            day: day,
            title: 'Ainda dá tempo',
            body: '${pendingTotal == 1 ? 'Falta' : 'Faltam'} '
                '${_count(pendingTasks.length, pendingHabits.length)} hoje.',
          ),
          _at(day, settings.eveningMinutes),
        );
      }

      // RF-NT-03 — tarefa com horário (atrasadas não: a hora já passou).
      if (settings.tasksEnabled) {
        for (final t in pendingTasks) {
          final time = t.dueTime;
          if (time == null || !TaskSchedule.isScheduledFor(t, day)) continue;
          final lead = settings.taskLeadMinutes;
          final clock = _hhmm(time.hour, time.minute);
          add(
            ReminderPayload(
              kind: ReminderKind.task,
              day: day,
              itemId: t.id,
              title: t.title,
              body: lead == 0 ? 'Agora · $clock' : 'Em $lead min · $clock',
            ),
            _at(day, time.hour * 60 + time.minute - lead),
            actions: true,
          );
        }
      }

      // RF-NT-04 — hábito no horário de lembrete, só se ainda não feito.
      if (settings.habitsEnabled) {
        for (final h in pendingHabits) {
          final time = h.reminderTime;
          if (time == null) continue;
          add(
            ReminderPayload(
              kind: ReminderKind.habit,
              day: day,
              itemId: h.id,
              title: h.title,
              body: 'Hora do hábito · ${_hhmm(time.hour, time.minute)}',
            ),
            _at(day, time.hour * 60 + time.minute),
            actions: true,
          );
        }
      }
    }

    out.sort((a, b) => a.at.compareTo(b.at));
    return out.length > maxNotifications
        ? out.sublist(0, maxNotifications)
        : out;
  }

  /// "3 tarefas e 2 hábitos", "1 tarefa", "2 hábitos".
  static String _count(int tasks, int habits) {
    final parts = [
      if (tasks > 0) '$tasks ${tasks == 1 ? 'tarefa' : 'tarefas'}',
      if (habits > 0) '$habits ${habits == 1 ? 'hábito' : 'hábitos'}',
    ];
    return parts.join(' e ');
  }

  static DateTime _at(DateTime day, int minutes) =>
      DateTime(day.year, day.month, day.day, 0, minutes);

  static String _hhmm(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}
