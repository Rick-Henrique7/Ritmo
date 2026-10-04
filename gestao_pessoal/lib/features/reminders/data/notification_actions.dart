import 'dart:async';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/database/prefs_store.dart';
import '../../../core/notifications/local_notification_scheduler.dart';
import '../../../core/utils/date_only.dart';
import '../../../routing/app_router.dart';
import '../../habits/data/prefs_habits_repository.dart';
import '../../tasks/data/prefs_tasks_repository.dart';
import '../../tasks/domain/task_schedule.dart';
import '../domain/reminder.dart';
import 'prefs_snoozes_repository.dart';
import 'reminder_sync.dart';

/// Nome da "porta" pela qual o isolate da ação avisa o app aberto que os
/// dados mudaram (ver `ExternalChangesSync`).
const reminderSyncPortName = 'daily_flow.reminders';

/// Botão tocado com o app fechado ou em segundo plano (RF-NT-06).
///
/// Roda num isolate separado, sem Riverpod e sem a árvore de widgets: lê o
/// armazenamento, grava a mudança, reagenda e avisa o app, se estiver
/// aberto, para recarregar.
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  DartPluginRegistrant.ensureInitialized();
  unawaited(handleNotificationAction(response.actionId, response.payload));
}

/// Toque com o app aberto: botões fazem o mesmo que em segundo plano;
/// o corpo do aviso abre a tela correspondente.
void onForegroundNotificationResponse(NotificationResponse response) {
  final action = response.actionId;
  if (action != null && action.isNotEmpty) {
    unawaited(handleNotificationAction(action, response.payload));
    return;
  }
  openRouteFor(response.payload);
}

/// Leva o usuário à tela do aviso (tarefa → Tarefas, hábito → Hábitos...).
void openRouteFor(String? payload) {
  if (payload == null) return;
  if (payload.startsWith('route:')) {
    AppRouter.config.go(payload.substring('route:'.length));
    return;
  }
  final p = ReminderPayload.decode(payload);
  if (p != null) AppRouter.config.go(p.route);
}

/// Aplica "Concluir" ou "Adiar 1 h" ao item do aviso.
Future<void> handleNotificationAction(
  String? actionId,
  String? payload, {
  DateTime? now,
}) async {
  final p = ReminderPayload.decode(payload);
  if (p == null || p.itemId == null) return;
  final clock = now ?? DateTime.now();

  final store = await PrefsStore.open();
  await store.reload();
  final snoozesRepo = PrefsSnoozesRepository(store);
  final snoozes = [
    for (final s in snoozesRepo.loadAll())
      if (s.until.isAfter(clock) && s.key != p.key) s,
  ];

  switch (actionId) {
    case LocalNotificationScheduler.actionDone:
      await _markDone(store, p, clock);
    case LocalNotificationScheduler.actionSnooze:
      snoozes.add(ReminderSnooze(
        key: p.key,
        until: clock.add(const Duration(hours: 1)),
      ));
    default:
      return;
  }
  await snoozesRepo.saveAll(snoozes);

  final plugin = await LocalNotificationScheduler.openPlugin();
  await syncRemindersFromStore(
    store: store,
    scheduler: LocalNotificationScheduler(plugin),
    now: clock,
  );

  // App aberto? Ele relê os dados (senão mostraria o item como pendente
  // e poderia sobrescrever a conclusão ao salvar outra coisa).
  IsolateNameServer.lookupPortByName(reminderSyncPortName)?.send('changed');
}

Future<void> _markDone(PrefsStore store, ReminderPayload p, DateTime now) async {
  final day = dateOnly(p.day);
  switch (p.kind) {
    case ReminderKind.task:
      final repo = PrefsTasksRepository(store);
      final tasks = repo.loadAll();
      await repo.saveAll([
        for (final t in tasks)
          if (t.id == p.itemId) TaskSchedule.markDone(t, day, now) else t,
      ]);
    case ReminderKind.habit:
      final repo = PrefsHabitsRepository(store);
      final habits = repo.loadAll();
      await repo.saveAll([
        for (final h in habits)
          if (h.id == p.itemId && !h.isCompletedOn(day))
            h.copyWith(completedDates: [...h.completedDates, day])
          else
            h,
      ]);
    case ReminderKind.morning:
    case ReminderKind.evening:
      break;
  }
}
