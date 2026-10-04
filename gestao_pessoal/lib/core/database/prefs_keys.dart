/// Chaves centralizadas para `shared_preferences`.
///
/// Manter todas as chaves num único arquivo evita typos e facilita
/// refatorações quando o modelo de dados evoluir.
class PrefsKeys {
  PrefsKeys._();

  static const String habits = 'daily_flow.habits';
  static const String tasks = 'daily_flow.tasks';
  static const String pomodoroSessions = 'daily_flow.pomodoro_sessions';
  static const String settings = 'daily_flow.settings';
  static const String reminderSnoozes = 'daily_flow.reminder_snoozes';
  static const String notificationPermissionAsked =
      'daily_flow.notification_permission_asked';
}
