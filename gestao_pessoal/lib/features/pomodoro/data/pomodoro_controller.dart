import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/services/wakelock_service.dart';
import '../domain/pomodoro_cycle.dart';
import '../domain/pomodoro_session_model.dart';
import 'prefs_pomodoro_sessions_repository.dart';

const _uuid = Uuid();

/// Estado do timer de foco.
///
/// Enquanto roda, a fonte da verdade é [endsAt] (o horário de término),
/// não um contador: [remainingSeconds] é recalculado a partir do relógio.
/// Assim o tempo continua certo mesmo se o app ficar em segundo plano e
/// o `Timer` do Dart parar de disparar — ao voltar, o próximo tique
/// enxerga quanto tempo passou de verdade.
class PomodoroTimerState {
  const PomodoroTimerState({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.type,
    this.taskId,
    this.endsAt,
  });

  /// Timer parado no início de [type].
  factory PomodoroTimerState.idle(PomodoroType type, {String? taskId}) {
    final seconds = PomodoroCycle.durationOf(type).inSeconds;
    return PomodoroTimerState(
      remainingSeconds: seconds,
      totalSeconds: seconds,
      type: type,
      taskId: taskId,
    );
  }

  final int remainingSeconds;
  final int totalSeconds;
  final PomodoroType type;
  final String? taskId;

  /// Horário em que o modo atual termina; `null` quando parado/pausado.
  final DateTime? endsAt;

  bool get isRunning => endsAt != null;

  double get progress =>
      totalSeconds == 0 ? 0 : 1 - (remainingSeconds / totalSeconds);

  PomodoroTimerState copyWith({
    int? remainingSeconds,
    String? taskId,
    bool clearTaskId = false,
    DateTime? endsAt,
    bool clearEndsAt = false,
  }) {
    return PomodoroTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds,
      type: type,
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
    );
  }
}

/// Timer de foco: iniciar, pausar, parar, pular e concluir ciclos.
///
/// As regras (durações, próximo modo, tempo restante) estão em
/// [PomodoroCycle]; aqui só ficam os efeitos — relógio, tela acesa,
/// histórico, vibração e som.
class PomodoroTimerNotifier extends Notifier<PomodoroTimerState> {
  Timer? _ticker;
  int _completedFocusCycles = 0;
  late WakelockService _wakelock;

  DateTime _now() => ref.read(clockProvider)();

  @override
  PomodoroTimerState build() {
    _wakelock = ref.read(wakelockServiceProvider);
    ref.onDispose(() {
      _ticker?.cancel();
      unawaited(_wakelock.keepScreenOn(false));
    });
    return PomodoroTimerState.idle(PomodoroType.focus);
  }

  // === API pública ===

  void selectTask(String? taskId) {
    state = state.copyWith(taskId: taskId, clearTaskId: taskId == null);
  }

  void toggle() {
    if (state.isRunning) {
      pause();
    } else {
      start();
    }
  }

  /// Começa (ou retoma) a contagem: grava o horário de término.
  void start() {
    if (state.isRunning) return;
    final endsAt = _now().add(Duration(seconds: state.remainingSeconds));
    state = state.copyWith(endsAt: endsAt);
    // RF-NT-05: aviso do sistema caso o app esteja minimizado no fim.
    if (ref.read(focusAlertEnabledProvider)) {
      unawaited(ref.read(notificationSchedulerProvider).scheduleFocusEnd(endsAt));
    }
    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => unawaited(refresh()),
    );
    unawaited(_wakelock.keepScreenOn(true));
  }

  /// Congela o tempo restante; [start] continua de onde parou.
  void pause() {
    final endsAt = state.endsAt;
    if (endsAt == null) return;
    _stopTicker();
    state = state.copyWith(
      remainingSeconds: PomodoroCycle.secondsLeft(endsAt, _now()),
      clearEndsAt: true,
    );
  }

  /// Para e volta ao tempo cheio do modo atual (sem trocar de modo).
  void stop() => _resetTo(state.type);

  /// Avança para o próximo modo sem registrar sessão.
  void skip() => _resetTo(PomodoroCycle.nextOnSkip(state.type));

  /// Força o modo (Foco / Pausa curta / Pausa longa).
  void setType(PomodoroType type) => _resetTo(type);

  /// Recalcula o tempo restante pelo relógio e conclui o ciclo se acabou.
  ///
  /// Chamado pelo tique a cada 250 ms; seguro chamar a qualquer momento.
  Future<void> refresh() async {
    final endsAt = state.endsAt;
    if (endsAt == null) return;
    final left = PomodoroCycle.secondsLeft(endsAt, _now());
    if (left == 0) return _complete(endsAt);
    if (left != state.remainingSeconds) {
      state = state.copyWith(remainingSeconds: left);
    }
  }

  // === Interno ===

  Future<void> _complete(DateTime endedAt) async {
    final finished = state;
    if (finished.type == PomodoroType.focus) _completedFocusCycles++;
    // Troca o estado antes de qualquer await: um segundo tique não
    // conclui o mesmo ciclo duas vezes.
    _resetTo(PomodoroCycle.nextAfterCompletion(
      finished.type,
      completedFocusCycles: _completedFocusCycles,
    ));

    final history = ref.read(pomodoroHistoryProvider.notifier);
    final haptics = ref.read(hapticsServiceProvider);
    final sound = ref.read(soundServiceProvider);

    // Passa pelo notifier do histórico: as Estatísticas atualizam na hora.
    await history.record(PomodoroSessionModel(
      id: _uuid.v4(),
      taskId: finished.taskId,
      startTime: endedAt.subtract(Duration(seconds: finished.totalSeconds)),
      durationMinutes: (finished.totalSeconds / 60).round(),
      isCompleted: true,
      type: finished.type,
    ));
    await haptics.heavy();
    await sound.playSuccess();
  }

  void _resetTo(PomodoroType type) {
    _stopTicker();
    state = PomodoroTimerState.idle(type, taskId: state.taskId);
  }

  void _stopTicker() {
    if (_ticker == null) return;
    _ticker!.cancel();
    _ticker = null;
    unawaited(_wakelock.keepScreenOn(false));
    unawaited(ref.read(notificationSchedulerProvider).cancelFocusEnd());
  }
}

final pomodoroTimerProvider =
    NotifierProvider<PomodoroTimerNotifier, PomodoroTimerState>(
  PomodoroTimerNotifier.new,
);

/// Histórico de sessões concluídas (RF-ST-01), reativo.
class PomodoroHistoryNotifier extends Notifier<List<PomodoroSessionModel>> {
  @override
  List<PomodoroSessionModel> build() =>
      ref.watch(pomodoroSessionsRepositoryProvider).loadAll();

  Future<void> record(PomodoroSessionModel session) async {
    state = [...state, session];
    await ref.read(pomodoroSessionsRepositoryProvider).saveAll(state);
  }
}

final pomodoroHistoryProvider =
    NotifierProvider<PomodoroHistoryNotifier, List<PomodoroSessionModel>>(
  PomodoroHistoryNotifier.new,
);
