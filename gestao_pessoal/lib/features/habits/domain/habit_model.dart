import 'package:flutter/material.dart';

import '../../../core/utils/color_hex.dart';

/// Catálogo fixo de ícones permitidos para hábitos.
///
/// Mantemos um set fechado (em vez de aceitar `codePoint` arbitrário)
/// para evitar problemas com tree-shaking de ícones em builds de release.
class HabitIcons {
  HabitIcons._();

  static const Map<String, IconData> all = {
    'water': Icons.water_drop_outlined,
    'run': Icons.directions_run_outlined,
    'book': Icons.menu_book_outlined,
    'sleep': Icons.bedtime_outlined,
    'food': Icons.restaurant_outlined,
    'meditate': Icons.self_improvement_outlined,
    'music': Icons.music_note_outlined,
    'study': Icons.school_outlined,
    'workout': Icons.fitness_center_outlined,
    'sun': Icons.wb_sunny_outlined,
  };

  static IconData fromKey(String key) =>
      all[key] ?? Icons.water_drop_outlined;
}

/// Modelo imutável de Hábito.
///
/// Espelha o `HabitModel` definido no PRD (RF-HB-01..05).
class HabitModel {
  const HabitModel({
    required this.id,
    required this.title,
    required this.category,
    required this.iconKey,
    required this.colorHex,
    required this.frequencyDays,
    required this.targetValue,
    required this.unit,
    required this.completedDates,
    this.reminderTime,
    this.durationMinutes,
  });

  final String id;
  final String title;
  final String category;

  /// Chave do ícone no [HabitIcons].
  final String iconKey;

  /// Cor em hex (ex: `#06B6D4`).
  final String colorHex;

  /// Dias da semana em que o hábito se repete (1 = Segunda, 7 = Domingo).
  final List<int> frequencyDays;

  final int targetValue;
  final String unit;

  /// Datas em que o hábito foi marcado como concluído. A sequência
  /// (streak) é calculada a partir daqui por `HabitStreak.current`.
  final List<DateTime> completedDates;

  /// Horário do lembrete opcional (HH:mm).
  final TimeOfDay? reminderTime;

  /// Estimativa de tempo que o hábito leva para ser realizado, em
  /// minutos. `null` = sem estimativa.
  final int? durationMinutes;

  IconData get icon => HabitIcons.fromKey(iconKey);

  Color get color => colorFromHex(colorHex);

  bool isScheduledFor(DateTime day) {
    final weekday = day.weekday;
    return frequencyDays.contains(weekday);
  }

  bool isCompletedOn(DateTime day) {
    return completedDates.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    );
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? category,
    String? iconKey,
    String? colorHex,
    List<int>? frequencyDays,
    int? targetValue,
    String? unit,
    List<DateTime>? completedDates,
    TimeOfDay? reminderTime,
    bool clearReminderTime = false,
    int? durationMinutes,
    bool clearDurationMinutes = false,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      completedDates: completedDates ?? this.completedDates,
      reminderTime:
          clearReminderTime ? null : (reminderTime ?? this.reminderTime),
      durationMinutes:
          clearDurationMinutes ? null : (durationMinutes ?? this.durationMinutes),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'iconKey': iconKey,
        'colorHex': colorHex,
        'frequencyDays': frequencyDays,
        'targetValue': targetValue,
        'unit': unit,
        'completedDates':
            completedDates.map((d) => d.toIso8601String()).toList(),
        'reminderHour': reminderTime?.hour,
        'reminderMinute': reminderTime?.minute,
        'durationMinutes': durationMinutes,
      };

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    final reminderHour = json['reminderHour'] as int?;
    final reminderMinute = json['reminderMinute'] as int?;
    // Migração: documentos antigos usavam `iconCodePoint`.
    final iconKey = (json['iconKey'] as String?) ?? 'water';
    final duration = json['durationMinutes'];
    return HabitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      iconKey: iconKey,
      colorHex: json['colorHex'] as String,
      frequencyDays:
          (json['frequencyDays'] as List<dynamic>).cast<int>().toList(),
      targetValue: json['targetValue'] as int,
      unit: json['unit'] as String,
      completedDates: (json['completedDates'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      reminderTime: (reminderHour != null && reminderMinute != null)
          ? TimeOfDay(hour: reminderHour, minute: reminderMinute)
          : null,
      durationMinutes: duration is int ? duration : null,
    );
  }
}
