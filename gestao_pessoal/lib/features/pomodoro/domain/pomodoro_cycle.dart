import 'pomodoro_session_model.dart';

/// Regras do ciclo Pomodoro — funções puras, sem Flutter nem relógio.
///
/// O controller decide **quando** chamar; aqui fica **o que** acontece:
/// duração de cada modo, qual vem depois e quanto falta. Testado em
/// `test/features/pomodoro/pomodoro_cycle_test.dart`.
abstract final class PomodoroCycle {
  static const focus = Duration(minutes: 25);
  static const shortBreak = Duration(minutes: 5);
  static const longBreak = Duration(minutes: 15);

  /// A cada quantos focos concluídos vem a pausa longa.
  static const focusCyclesPerLongBreak = 4;

  static Duration durationOf(PomodoroType type) => switch (type) {
        PomodoroType.focus => focus,
        PomodoroType.shortBreak => shortBreak,
        PomodoroType.longBreak => longBreak,
      };

  /// Próximo modo quando [finished] termina sozinho.
  ///
  /// [completedFocusCycles] já conta o foco que acabou de terminar:
  /// foco 1, 2, 3 → pausa curta; foco 4 → pausa longa; pausa → foco.
  static PomodoroType nextAfterCompletion(
    PomodoroType finished, {
    required int completedFocusCycles,
  }) {
    if (finished != PomodoroType.focus) return PomodoroType.focus;
    return completedFocusCycles % focusCyclesPerLongBreak == 0
        ? PomodoroType.longBreak
        : PomodoroType.shortBreak;
  }

  /// Próximo modo pelo botão "pular": Foco → Pausa curta → Pausa longa →
  /// Foco. Pular não conta como foco concluído.
  static PomodoroType nextOnSkip(PomodoroType current) => switch (current) {
        PomodoroType.focus => PomodoroType.shortBreak,
        PomodoroType.shortBreak => PomodoroType.longBreak,
        PomodoroType.longBreak => PomodoroType.focus,
      };

  /// Segundos que faltam até [endsAt], vistos em [now].
  ///
  /// Arredonda para cima — o mostrador só chega a 00:00 quando o tempo
  /// acabou de fato — e nunca fica negativo.
  static int secondsLeft(DateTime endsAt, DateTime now) {
    final ms = endsAt.difference(now).inMilliseconds;
    if (ms <= 0) return 0;
    return (ms + 999) ~/ 1000;
  }
}
