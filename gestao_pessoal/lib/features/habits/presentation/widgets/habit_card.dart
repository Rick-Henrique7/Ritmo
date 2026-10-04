import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../data/habits_controller.dart';
import '../../domain/habit_model.dart';
import '../habit_form_dialog.dart';

/// Formata uma estimativa em minutos para o cartão de hábito.
String cardDurationLabel(int minutes) {
  if (minutes < 60) return '${minutes}min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '${h}h';
  return '${h}h${m.toString().padLeft(2, '0')}';
}

class HabitCard extends ConsumerWidget {
  const HabitCard({super.key, required this.habit, required this.day});
  final HabitModel habit;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = habit.isCompletedOn(day);
    final accent = context.accent;
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        onTap: () {
          // Tap em qualquer parte do card abre o dialog de edição
          // (mesmo padrão da tela de Tarefas).
          showDialog<void>(
            context: context,
            builder: (_) => HabitFormDialog(existing: habit),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(habit.icon, color: habit.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    Text(
                      'Meta: ${habit.targetValue} ${habit.unit} • ${habit.category}'
                      '${habit.durationMinutes != null ? ' • ${cardDurationLabel(habit.durationMinutes!)}' : ''}',
                      style: TextStyle(
                        color: context.palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: done ? 'Reabrir' : 'Concluir',
                icon: Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: done ? accent : context.palette.textTertiary,
                ),
                onPressed: () {
                  ref
                      .read(habitsProvider.notifier)
                      .toggleCompletionForDate(habit, day);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
