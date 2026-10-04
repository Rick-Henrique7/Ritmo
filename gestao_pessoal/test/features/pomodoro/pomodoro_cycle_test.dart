import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/features/pomodoro/domain/pomodoro_cycle.dart';
import 'package:gestao_pessoal/features/pomodoro/domain/pomodoro_session_model.dart';

void main() {
  group('próximo modo', () {
    test('focos 1 a 3 levam à pausa curta e o 4º à pausa longa', () {
      final next = [
        for (var n = 1; n <= 4; n++)
          PomodoroCycle.nextAfterCompletion(
            PomodoroType.focus,
            completedFocusCycles: n,
          ),
      ];
      expect(next, [
        PomodoroType.shortBreak,
        PomodoroType.shortBreak,
        PomodoroType.shortBreak,
        PomodoroType.longBreak,
      ]);
    });

    test('qualquer pausa que termina volta ao foco', () {
      for (final pause in [PomodoroType.shortBreak, PomodoroType.longBreak]) {
        expect(
          PomodoroCycle.nextAfterCompletion(pause, completedFocusCycles: 4),
          PomodoroType.focus,
        );
      }
    });

    test('pular segue Foco → Pausa curta → Pausa longa → Foco', () {
      expect(PomodoroCycle.nextOnSkip(PomodoroType.focus),
          PomodoroType.shortBreak);
      expect(PomodoroCycle.nextOnSkip(PomodoroType.shortBreak),
          PomodoroType.longBreak);
      expect(PomodoroCycle.nextOnSkip(PomodoroType.longBreak),
          PomodoroType.focus);
    });
  });

  group('tempo restante', () {
    final end = DateTime(2026, 10, 1, 9, 25);

    test('conta pelo horário de término', () {
      expect(
        PomodoroCycle.secondsLeft(end, DateTime(2026, 10, 1, 9, 15)),
        600,
      );
    });

    test('arredonda para cima: 0,2 s restantes ainda mostram 00:01', () {
      final now = end.subtract(const Duration(milliseconds: 200));
      expect(PomodoroCycle.secondsLeft(end, now), 1);
    });

    test('nunca fica negativo depois do término', () {
      final now = end.add(const Duration(hours: 2));
      expect(PomodoroCycle.secondsLeft(end, now), 0);
    });
  });
}
