import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_scheduler.dart';

/// [NotificationScheduler] com `flutter_local_notifications` (ADR 0009).
///
/// Agenda em modo **inexato** (`inexactAllowWhileIdle`): não precisa da
/// permissão de alarme exato, restrita pelo Android 14 a despertadores e
/// agendas. O aviso pode chegar alguns minutos depois da hora.
///
/// Os horários são instantes absolutos em UTC: o app agenda ocorrências
/// avulsas (próximos 7 dias), então não precisa do banco de fusos horários.
class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const actionDone = 'concluir';
  static const actionSnooze = 'adiar';

  /// Payload do aviso de fim do foco (abre a tela Foco).
  static const focusPayload = 'route:/pomodoro';

  /// Ícone monocromático da barra de status (`res/drawable`).
  static const _icon = 'ic_stat_daily_flow';

  /// Abre o plugin. No app, com os dois callbacks; no isolate da ação em
  /// segundo plano, sem nenhum.
  static Future<FlutterLocalNotificationsPlugin> openPlugin({
    DidReceiveNotificationResponseCallback? onResponse,
    DidReceiveBackgroundNotificationResponseCallback? onBackgroundResponse,
  }) async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(_icon),
      ),
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
    return plugin;
  }

  static NotificationDetails _reminderDetails({required bool actions}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'lembretes',
        'Lembretes',
        channelDescription: 'Tarefas, hábitos e os resumos do dia',
        importance: Importance.high,
        priority: Priority.high,
        icon: _icon,
        actions: actions
            ? const [
                AndroidNotificationAction(actionDone, 'Concluir'),
                AndroidNotificationAction(actionSnooze, 'Adiar 1 h'),
              ]
            : null,
      ),
    );
  }

  static const _focusDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'foco',
      'Fim do foco',
      channelDescription: 'Aviso quando a sessão de foco termina',
      importance: Importance.high,
      priority: Priority.high,
      icon: _icon,
    ),
  );

  tz.TZDateTime _instant(DateTime at) => tz.TZDateTime.from(at, tz.UTC);

  @override
  Future<void> replaceAll(List<ScheduledNotification> plan) async {
    try {
      final keep = {for (final n in plan) n.id, focusNotificationId};
      final pending = await _plugin.pendingNotificationRequests();
      for (final p in pending) {
        if (!keep.contains(p.id)) await _plugin.cancel(p.id);
      }
      for (final n in plan) {
        await _plugin.zonedSchedule(
          n.id,
          n.title,
          n.body,
          _instant(n.at),
          _reminderDetails(actions: n.withActions),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: n.payload,
        );
      }
    } catch (e) {
      // Aviso que falha não pode derrubar o app.
      debugPrint('Notificações: falha ao reagendar ($e)');
    }
  }

  @override
  Future<void> scheduleFocusEnd(DateTime at) async {
    try {
      await _plugin.zonedSchedule(
        focusNotificationId,
        'Foco concluído',
        'Hora da pausa. Abra o Daily Flow para continuar.',
        _instant(at),
        _focusDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: focusPayload,
      );
    } catch (e) {
      debugPrint('Notificações: falha ao agendar o foco ($e)');
    }
  }

  @override
  Future<void> cancelFocusEnd() async {
    try {
      await _plugin.cancel(focusNotificationId);
    } catch (_) {}
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> requestPermission() async {
    try {
      return await _android?.requestNotificationsPermission() ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isPermitted() async {
    try {
      return await _android?.areNotificationsEnabled() ?? false;
    } catch (_) {
      return false;
    }
  }
}
