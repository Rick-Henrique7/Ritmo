import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/prefs_store.dart';
import '../../../core/notifications/notification_scheduler.dart';
import '../../../core/providers/core_providers.dart';
import '../../habits/data/habits_controller.dart';
import '../../habits/data/prefs_habits_repository.dart';
import '../../settings/data/prefs_settings_repository.dart';
import '../../settings/data/settings_controller.dart';
import '../../tasks/data/prefs_tasks_repository.dart';
import '../../tasks/data/tasks_controller.dart';
import '../domain/reminder_planner.dart';
import 'prefs_snoozes_repository.dart';

/// Mantém os avisos do aparelho iguais ao estado do app (RF-NT-08).
///
/// Observa tarefas, hábitos, configurações e o dia: qualquer mudança
/// recalcula o plano e substitui os avisos pendentes. A espera curta junta
/// várias mudanças seguidas (ex.: concluir três itens) num só reagendamento.
final reminderSyncProvider = Provider<void>((ref) {
  final scheduler = ref.watch(notificationSchedulerProvider);
  final tasks = ref.watch(tasksProvider);
  final habits = ref.watch(habitsProvider);
  final settings = ref.watch(settingsProvider).notifications;
  ref.watch(todayProvider);
  final snoozes = ref.watch(snoozesRepositoryProvider).loadAll();
  final clock = ref.read(clockProvider);

  final timer = Timer(const Duration(milliseconds: 400), () {
    unawaited(scheduler.replaceAll(ReminderPlanner.plan(
      tasks: tasks,
      habits: habits,
      settings: settings,
      snoozes: snoozes,
      now: clock(),
    )));
  });
  ref.onDispose(timer.cancel);
});

/// Mesmo cálculo, lendo direto do armazenamento — usado pela ação da
/// notificação, que roda num isolate sem Riverpod.
Future<void> syncRemindersFromStore({
  required PrefsStore store,
  required NotificationScheduler scheduler,
  required DateTime now,
}) {
  return scheduler.replaceAll(ReminderPlanner.plan(
    tasks: PrefsTasksRepository(store).loadAll(),
    habits: PrefsHabitsRepository(store).loadAll(),
    settings: PrefsSettingsRepository(store).load().notifications,
    snoozes: PrefsSnoozesRepository(store).loadAll(),
    now: now,
  ));
}
