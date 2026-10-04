import 'package:flutter/material.dart';


enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Baixa';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.high:
        return 'Alta';
    }
  }

  /// Cor da prioridade **dinâmica**, respeitando o accent configurado
  /// pelo usuário.
  ///
  /// - `high`   → accent puro
  /// - `medium` → accent escurecido (HSV value 0.7)
  /// - `low`    → [muted] (cor de texto secundário do tema)
  ///
  /// As cores vêm por parâmetro: o domínio não conhece o tema.
  Color colorAt(Color accent, {required Color muted}) {
    switch (this) {
      case TaskPriority.low:
        return muted;
      case TaskPriority.medium:
        return HSVColor.fromColor(accent).withValue(0.7).toColor();
      case TaskPriority.high:
        return accent;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.drag_handle_rounded;
      case TaskPriority.high:
        return Icons.priority_high_rounded;
    }
  }

  String get code => name;
}

class SubtaskModel {
  const SubtaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final bool isCompleted;

  SubtaskModel copyWith({String? id, String? title, bool? isCompleted}) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory SubtaskModel.fromJson(Map<String, dynamic> json) => SubtaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool,
      );
}
