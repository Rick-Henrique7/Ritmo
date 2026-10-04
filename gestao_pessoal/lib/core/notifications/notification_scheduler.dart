/// Um aviso a agendar no aparelho.
class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
    this.withActions = false,
  });

  /// Identificador estável: o mesmo aviso recebe o mesmo id em todo
  /// reagendamento (ver `stableId`).
  final int id;
  final DateTime at;
  final String title;
  final String body;

  /// Dados para a ação e para abrir a tela certa ao tocar (JSON).
  final String payload;

  /// Mostra os botões "Concluir" e "Adiar 1 h".
  final bool withActions;

  @override
  String toString() => 'ScheduledNotification($id, $at, $title — $body)';
}

/// Porta para os avisos do sistema. O core declara; a implementação com o
/// plugin fica em `local_notification_scheduler.dart` e é ligada no
/// `main.dart`. Nos testes, um fake grava o que seria agendado.
abstract interface class NotificationScheduler {
  /// Substitui todos os avisos pendentes do plano (exceto o do foco).
  Future<void> replaceAll(List<ScheduledNotification> plan);

  /// Aviso de fim do foco (RF-NT-05). Agendar de novo substitui o anterior.
  Future<void> scheduleFocusEnd(DateTime at);
  Future<void> cancelFocusEnd();

  /// Pede a permissão do Android 13+. `true` se liberada.
  Future<bool> requestPermission();

  /// A permissão está liberada?
  Future<bool> isPermitted();
}

/// Usado quando nada foi ligado (testes, plataformas sem suporte).
class NoopNotificationScheduler implements NotificationScheduler {
  const NoopNotificationScheduler();

  @override
  Future<void> replaceAll(List<ScheduledNotification> plan) async {}
  @override
  Future<void> scheduleFocusEnd(DateTime at) async {}
  @override
  Future<void> cancelFocusEnd() async {}
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<bool> isPermitted() async => false;
}

/// Id do aviso de fim do foco (fora da faixa dos ids calculados).
const focusNotificationId = 1;

/// Hash FNV-1a de 31 bits: o mesmo texto dá sempre o mesmo id, em qualquer
/// execução ou isolate (o `String.hashCode` do Dart não garante isso).
int stableId(String key) {
  var hash = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  final id = hash & 0x7FFFFFFF;
  return id <= focusNotificationId ? id + 2 : id;
}
