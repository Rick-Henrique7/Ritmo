/// Chaves centralizadas para `shared_preferences`.
///
/// Manter todas as chaves num único arquivo evita typos e facilita
/// refatorações quando o modelo de dados evoluir.
class PrefsKeys {
  PrefsKeys._();

  static const String habits = 'ritmo.habits';
  static const String tasks = 'ritmo.tasks';
  static const String pomodoroSessions = 'ritmo.pomodoro_sessions';
  static const String settings = 'ritmo.settings';
  static const String reminderSnoozes = 'ritmo.reminder_snoozes';
  static const String notificationPermissionAsked =
      'ritmo.notification_permission_asked';
}
