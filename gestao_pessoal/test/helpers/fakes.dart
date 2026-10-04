import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestao_pessoal/core/notifications/notification_scheduler.dart';
import 'package:gestao_pessoal/core/providers/core_providers.dart';
import 'package:gestao_pessoal/core/services/haptics_service.dart';
import 'package:gestao_pessoal/core/services/sound_service.dart';
import 'package:gestao_pessoal/core/services/wakelock_service.dart';
import 'package:gestao_pessoal/features/habits/data/prefs_habits_repository.dart';
import 'package:gestao_pessoal/features/habits/domain/habit_model.dart';
import 'package:gestao_pessoal/features/habits/domain/habits_repository.dart';
import 'package:gestao_pessoal/features/pomodoro/data/prefs_pomodoro_sessions_repository.dart';
import 'package:gestao_pessoal/features/pomodoro/domain/pomodoro_session_model.dart';
import 'package:gestao_pessoal/features/pomodoro/domain/pomodoro_sessions_repository.dart';
import 'package:gestao_pessoal/features/reminders/data/prefs_snoozes_repository.dart';
import 'package:gestao_pessoal/features/reminders/domain/reminder.dart';
import 'package:gestao_pessoal/features/settings/data/prefs_settings_repository.dart';
import 'package:gestao_pessoal/features/settings/domain/app_settings.dart';
import 'package:gestao_pessoal/features/settings/domain/settings_repository.dart';
import 'package:gestao_pessoal/features/tasks/data/prefs_tasks_repository.dart';
import 'package:gestao_pessoal/features/tasks/domain/task_model.dart';
import 'package:gestao_pessoal/features/tasks/domain/tasks_repository.dart';

/// Repositórios em memória — possíveis porque os controllers dependem das
/// interfaces do domínio, não do SharedPreferences.
class InMemoryTasksRepository implements TasksRepository {
  InMemoryTasksRepository([List<TaskModel>? initial]) : saved = [...?initial];

  List<TaskModel> saved;
  int saveCalls = 0;

  @override
  List<TaskModel> loadAll() => [...saved];

  @override
  Future<void> saveAll(List<TaskModel> tasks) async {
    saved = [...tasks];
    saveCalls++;
  }
}

class InMemoryHabitsRepository implements HabitsRepository {
  InMemoryHabitsRepository([List<HabitModel>? initial]) : saved = [...?initial];

  List<HabitModel> saved;

  @override
  List<HabitModel> loadAll() => [...saved];

  @override
  Future<void> saveAll(List<HabitModel> habits) async => saved = [...habits];
}

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this.saved = AppSettings.defaults]);

  AppSettings saved;

  @override
  AppSettings load() => saved;

  @override
  Future<void> save(AppSettings settings) async => saved = settings;
}

class InMemorySessionsRepository implements PomodoroSessionsRepository {
  List<PomodoroSessionModel> saved = [];

  @override
  List<PomodoroSessionModel> loadAll() => [...saved];

  @override
  Future<void> saveAll(List<PomodoroSessionModel> sessions) async =>
      saved = [...sessions];
}

class InMemorySnoozesRepository implements ReminderSnoozesRepository {
  List<ReminderSnooze> saved = [];

  @override
  List<ReminderSnooze> loadAll() => [...saved];

  @override
  Future<void> saveAll(List<ReminderSnooze> snoozes) async =>
      saved = [...snoozes];
}

/// Avisos em memória: registra o que seria agendado no aparelho.
class FakeNotificationScheduler implements NotificationScheduler {
  List<ScheduledNotification> plan = [];
  DateTime? focusEndsAt;
  bool permitted = true;

  @override
  Future<void> replaceAll(List<ScheduledNotification> plan) async =>
      this.plan = [...plan];

  @override
  Future<void> scheduleFocusEnd(DateTime at) async => focusEndsAt = at;

  @override
  Future<void> cancelFocusEnd() async => focusEndsAt = null;

  @override
  Future<bool> requestPermission() async => permitted;

  @override
  Future<bool> isPermitted() async => permitted;
}

/// Som silencioso: não cria AudioPlayer (sem plugin nativo no teste).
class SilentSound implements SoundService {
  @override
  bool get enabled => false;
  @override
  Future<void> playSuccess() async {}
  @override
  Future<void> dispose() async {}
}

/// Som que só conta quantas vezes tocou.
class CountingSound extends SilentSound {
  int plays = 0;

  @override
  Future<void> playSuccess() async => plays++;
}

/// Tela acesa em memória: guarda o último pedido.
class FakeWakelock implements WakelockService {
  bool on = false;

  @override
  Future<void> keepScreenOn(bool on) async => this.on = on;
}

/// Relógio controlado pelo teste: o tempo só anda com [advance].
class FakeClock {
  FakeClock(this.now);

  DateTime now;

  DateTime call() => now;

  void advance(Duration d) => now = now.add(d);
}

/// Overrides que isolam o app de armazenamento, relógio e plataforma.
List<Override> testOverrides({
  required DateTime today,
  InMemoryTasksRepository? tasks,
  InMemoryHabitsRepository? habits,
  InMemorySettingsRepository? settings,
  InMemorySessionsRepository? sessions,
  FakeClock? clock,
  SoundService? sound,
  FakeWakelock? wakelock,
  FakeNotificationScheduler? notifications,
}) {
  return [
    tasksRepositoryProvider.overrideWithValue(tasks ?? InMemoryTasksRepository()),
    habitsRepositoryProvider
        .overrideWithValue(habits ?? InMemoryHabitsRepository()),
    settingsRepositoryProvider
        .overrideWithValue(settings ?? InMemorySettingsRepository()),
    pomodoroSessionsRepositoryProvider
        .overrideWithValue(sessions ?? InMemorySessionsRepository()),
    snoozesRepositoryProvider.overrideWithValue(InMemorySnoozesRepository()),
    todayProvider.overrideWithValue(today),
    hapticsServiceProvider.overrideWithValue(HapticsService(enabled: false)),
    soundServiceProvider.overrideWithValue(sound ?? SilentSound()),
    wakelockServiceProvider.overrideWithValue(wakelock ?? FakeWakelock()),
    notificationSchedulerProvider
        .overrideWithValue(notifications ?? FakeNotificationScheduler()),
    clockProvider.overrideWithValue((clock ?? FakeClock(today)).call),
  ];
}
