/// Preferências de notificação (RF-NT-07).
///
/// Horários em **minutos desde a meia-noite** (8h = 480): um inteiro é
/// simples de guardar em JSON e de comparar, sem depender de `TimeOfDay`.
class NotificationSettings {
  const NotificationSettings({
    required this.enabled,
    required this.morningEnabled,
    required this.morningMinutes,
    required this.eveningEnabled,
    required this.eveningMinutes,
    required this.tasksEnabled,
    required this.taskLeadMinutes,
    required this.habitsEnabled,
    required this.focusEnabled,
  });

  /// Chave geral: desligada, nenhum aviso é agendado.
  final bool enabled;

  /// Resumo da manhã (RF-NT-01).
  final bool morningEnabled;
  final int morningMinutes;

  /// Pendências da noite (RF-NT-02).
  final bool eveningEnabled;
  final int eveningMinutes;

  /// Aviso de tarefa com horário (RF-NT-03) e quantos minutos antes.
  final bool tasksEnabled;
  final int taskLeadMinutes;

  /// Aviso de hábito no horário de lembrete (RF-NT-04).
  final bool habitsEnabled;

  /// Aviso de fim do foco (RF-NT-05).
  final bool focusEnabled;

  /// Opções de antecedência oferecidas na tela.
  static const leadOptions = [0, 5, 15, 30, 60];

  /// Padrões da versão piloto: tudo ligado, 8h, 20h, tarefas na hora.
  static const defaults = NotificationSettings(
    enabled: true,
    morningEnabled: true,
    morningMinutes: 8 * 60,
    eveningEnabled: true,
    eveningMinutes: 20 * 60,
    tasksEnabled: true,
    taskLeadMinutes: 0,
    habitsEnabled: true,
    focusEnabled: true,
  );

  NotificationSettings copyWith({
    bool? enabled,
    bool? morningEnabled,
    int? morningMinutes,
    bool? eveningEnabled,
    int? eveningMinutes,
    bool? tasksEnabled,
    int? taskLeadMinutes,
    bool? habitsEnabled,
    bool? focusEnabled,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      morningEnabled: morningEnabled ?? this.morningEnabled,
      morningMinutes: morningMinutes ?? this.morningMinutes,
      eveningEnabled: eveningEnabled ?? this.eveningEnabled,
      eveningMinutes: eveningMinutes ?? this.eveningMinutes,
      tasksEnabled: tasksEnabled ?? this.tasksEnabled,
      taskLeadMinutes: taskLeadMinutes ?? this.taskLeadMinutes,
      habitsEnabled: habitsEnabled ?? this.habitsEnabled,
      focusEnabled: focusEnabled ?? this.focusEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'morningEnabled': morningEnabled,
        'morningMinutes': morningMinutes,
        'eveningEnabled': eveningEnabled,
        'eveningMinutes': eveningMinutes,
        'tasksEnabled': tasksEnabled,
        'taskLeadMinutes': taskLeadMinutes,
        'habitsEnabled': habitsEnabled,
        'focusEnabled': focusEnabled,
      };

  /// Campos ausentes (configurações salvas antes das notificações) caem no
  /// padrão.
  factory NotificationSettings.fromJson(Map<String, dynamic>? json) {
    const d = defaults;
    if (json == null) return d;
    int minutes(Object? v, int fallback) {
      final n = v is int ? v : fallback;
      return n.clamp(0, 24 * 60 - 1);
    }

    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? d.enabled,
      morningEnabled: json['morningEnabled'] as bool? ?? d.morningEnabled,
      morningMinutes: minutes(json['morningMinutes'], d.morningMinutes),
      eveningEnabled: json['eveningEnabled'] as bool? ?? d.eveningEnabled,
      eveningMinutes: minutes(json['eveningMinutes'], d.eveningMinutes),
      tasksEnabled: json['tasksEnabled'] as bool? ?? d.tasksEnabled,
      taskLeadMinutes: leadOptions.contains(json['taskLeadMinutes'])
          ? json['taskLeadMinutes'] as int
          : d.taskLeadMinutes,
      habitsEnabled: json['habitsEnabled'] as bool? ?? d.habitsEnabled,
      focusEnabled: json['focusEnabled'] as bool? ?? d.focusEnabled,
    );
  }
}
