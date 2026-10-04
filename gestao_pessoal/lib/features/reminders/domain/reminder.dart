import 'dart:convert';

import '../../../core/utils/date_only.dart';

/// Tipos de aviso (RF-NT-01 a 05).
enum ReminderKind { morning, evening, task, habit }

/// O que vai dentro de cada notificação: identifica o item e a tela.
///
/// Serializado em JSON no `payload` da notificação, para a ação
/// "Concluir"/"Adiar" saber em que item mexer mesmo sem o app aberto.
class ReminderPayload {
  const ReminderPayload({
    required this.kind,
    required this.day,
    this.itemId,
    this.title = '',
    this.body = '',
  });

  final ReminderKind kind;

  /// Dia a que o aviso se refere (a ação conclui naquele dia).
  final DateTime day;

  /// Id da tarefa ou do hábito; nulo no resumo e nas pendências.
  final String? itemId;

  /// Texto do aviso, para reagendar igual ao adiar.
  final String title;
  final String body;

  /// Chave única do aviso: base do id e dos adiamentos.
  String get key => keyFor(kind, day, itemId);

  static String keyFor(ReminderKind kind, DateTime day, [String? itemId]) {
    final d = dateOnly(day);
    final date = '${d.year}-${d.month}-${d.day}';
    return itemId == null ? '${kind.name}:$date' : '${kind.name}:$itemId:$date';
  }

  /// Tela aberta ao tocar no aviso.
  String get route => switch (kind) {
        ReminderKind.task => '/tasks',
        ReminderKind.habit => '/habits',
        _ => '/',
      };

  String encode() => jsonEncode({
        'kind': kind.name,
        'day': dateOnly(day).toIso8601String(),
        'itemId': itemId,
        'title': title,
        'body': body,
      });

  /// Payload inválido ou de versão antiga → `null` (a ação é ignorada).
  static ReminderPayload? decode(String? source) {
    if (source == null || source.isEmpty) return null;
    try {
      final m = jsonDecode(source) as Map<String, dynamic>;
      final kind =
          ReminderKind.values.firstWhere((k) => k.name == m['kind'] as String);
      return ReminderPayload(
        kind: kind,
        day: DateTime.parse(m['day'] as String),
        itemId: m['itemId'] as String?,
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}

/// Aviso adiado pelo botão "Adiar 1 h": guardado para sobreviver ao
/// reagendamento, que recalcula todos os avisos a cada mudança.
class ReminderSnooze {
  const ReminderSnooze({required this.key, required this.until});

  final String key;
  final DateTime until;

  Map<String, dynamic> toJson() =>
      {'key': key, 'until': until.toIso8601String()};

  factory ReminderSnooze.fromJson(Map<String, dynamic> json) => ReminderSnooze(
        key: json['key'] as String,
        until: DateTime.parse(json['until'] as String),
      );
}

/// Contrato de armazenamento dos adiamentos.
abstract interface class ReminderSnoozesRepository {
  List<ReminderSnooze> loadAll();
  Future<void> saveAll(List<ReminderSnooze> snoozes);
}
