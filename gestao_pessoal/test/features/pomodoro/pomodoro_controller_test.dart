import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/features/pomodoro/data/pomodoro_controller.dart';
import 'package:gestao_pessoal/features/pomodoro/domain/pomodoro_session_model.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeClock clock;
  late InMemorySessionsRepository sessions;
  late CountingSound sound;
  late FakeWakelock wakelock;
  late FakeNotificationScheduler notifications;
  late ProviderContainer container;

  PomodoroTimerState state() => container.read(pomodoroTimerProvider);
  PomodoroTimerNotifier timer() =>
      container.read(pomodoroTimerProvider.notifier);

  setUp(() {
    clock = FakeClock(DateTime(2026, 10, 1, 9));
    sessions = InMemorySessionsRepository();
    sound = CountingSound();
    wakelock = FakeWakelock();
    notifications = FakeNotificationScheduler();
    container = ProviderContainer(
      overrides: testOverrides(
        today: thu,
        clock: clock,
        sessions: sessions,
        sound: sound,
        wakelock: wakelock,
        notifications: notifications,
      ),
    );
  });

  tearDown(() => container.dispose());

  test('começa parado em Foco com 25 minutos', () {
    expect(state().type, PomodoroType.focus);
    expect(state().remainingSeconds, 25 * 60);
    expect(state().isRunning, isFalse);
  });

  test('o tempo vem do relógio: 10 min depois faltam 15 min', () async {
    timer().start();
    clock.advance(const Duration(minutes: 10));
    await timer().refresh();

    expect(state().remainingSeconds, 15 * 60);
    expect(state().isRunning, isTrue);
  });

  test(
      'segundo plano não atrasa o timer (bug antigo: contava só os tiques '
      'recebidos)', () async {
    timer().start();
    // Nenhum tique durante 24 min — como o app minimizado.
    clock.advance(const Duration(minutes: 24));
    await timer().refresh();

    expect(state().remainingSeconds, 60);
  });

  test('pausar congela o tempo e retomar continua de onde parou', () async {
    timer().start();
    clock.advance(const Duration(minutes: 5));
    timer().pause();
    clock.advance(const Duration(hours: 1)); // pausado: não conta
    timer().start();
    clock.advance(const Duration(minutes: 5));
    await timer().refresh();

    expect(state().remainingSeconds, 15 * 60);
  });

  test('foco concluído grava a sessão, toca o som e vai para a pausa curta',
      () async {
    timer().start();
    clock.advance(const Duration(minutes: 25));
    await timer().refresh();

    expect(sessions.saved, hasLength(1));
    final s = sessions.saved.single;
    expect(s.type, PomodoroType.focus);
    expect(s.durationMinutes, 25);
    expect(s.startTime, DateTime(2026, 10, 1, 9));
    expect(sound.plays, 1);

    expect(state().type, PomodoroType.shortBreak);
    expect(state().remainingSeconds, 5 * 60);
    expect(state().isRunning, isFalse);
  });

  test('ciclo que terminou em segundo plano é concluído uma vez só',
      () async {
    timer().start();
    clock.advance(const Duration(hours: 3));
    await timer().refresh();
    await timer().refresh();

    expect(sessions.saved, hasLength(1));
    expect(
      sessions.saved.single.startTime,
      DateTime(2026, 10, 1, 9),
      reason: 'a sessão fica no horário em que de fato aconteceu',
    );
  });

  test('o quarto foco leva à pausa longa', () async {
    for (var i = 0; i < 4; i++) {
      timer().setType(PomodoroType.focus);
      timer().start();
      clock.advance(const Duration(minutes: 25));
      await timer().refresh();
    }
    expect(state().type, PomodoroType.longBreak);
  });

  test('parar volta ao tempo cheio do modo, sem gravar sessão', () async {
    timer().start();
    clock.advance(const Duration(minutes: 7));
    await timer().refresh();
    timer().stop();

    expect(state().remainingSeconds, 25 * 60);
    expect(state().isRunning, isFalse);
    expect(sessions.saved, isEmpty);
  });

  test('pular troca de modo sem gravar sessão', () {
    timer().skip();
    expect(state().type, PomodoroType.shortBreak);
    expect(sessions.saved, isEmpty);
  });

  test('a tela fica acesa só enquanto o timer roda', () {
    timer().start();
    expect(wakelock.on, isTrue);
    timer().pause();
    expect(wakelock.on, isFalse);
  });

  test('agenda o aviso de fim do foco e cancela ao pausar (RF-NT-05)', () {
    timer().start();
    expect(notifications.focusEndsAt, DateTime(2026, 10, 1, 9, 25));
    timer().pause();
    expect(notifications.focusEndsAt, isNull);
  });
}
