import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../data/tasks_controller.dart';
import '../../domain/subtask_model.dart';
import '../../domain/task_model.dart';
import 'overdue_tag.dart';

/// Cartão de tarefa com tap para editar + check para concluir.
class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task, required this.onTap});
  final TaskModel task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueLine = _dueLine(task);
    final accent = context.accent;
    // Recorrente: "feita" vale para hoje; pontual: concluída de vez.
    final today = ref.watch(todayProvider);
    final done = TaskSchedule.isDoneOn(task, today);
    final overdue = TaskSchedule.isOverdue(task, today);
    // Mapeia prioridade para a cor — high usa accent (customizado),
    // medium usa accent escurecido, low fica muted gray.
    final Color priorityColor = switch (task.priority) {
      TaskPriority.high => accent,
      TaskPriority.medium => HSVColor.fromColor(accent).withValue(0.7).toColor(),
      TaskPriority.low => context.palette.textSecondary,
    };
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: done
                            ? TextDecoration.lineThrough
                            : null,
                        color: done
                            ? context.palette.textSecondary
                            : context.palette.textPrimary,
                      ),
                    ),
                  ),
                  if (overdue) ...[
                    const SizedBox(width: 6),
                    const OverdueTag(),
                  ],
                  IconButton(
                    tooltip: done ? 'Reabrir' : 'Concluir',
                    icon: Icon(
                      done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: done
                          ? accent
                          : context.palette.textTertiary,
                    ),
                    onPressed: () =>
                        ref.read(tasksProvider.notifier).toggleCompleted(task),
                  ),
                ],
              ),
              if (dueLine != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 16),
                  child: Row(
                    children: [
                      Icon(Icons.event_outlined,
                          size: 14, color: context.palette.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dueLine,
                          style: TextStyle(
                            color: context.palette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (task.subtasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    'Sub-tarefas: ${task.completedSubtasksCount}/${task.subtasks.length}',
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _dueLine(TaskModel t) {
    final parts = <String>[];
    if (t.dueDate != null) {
      parts.add(DateFormatters.shortDate(t.dueDate!));
    }
    if (t.dueTime != null) {
      parts.add(
        '${t.dueTime!.hour.toString().padLeft(2, '0')}:${t.dueTime!.minute.toString().padLeft(2, '0')}',
      );
    }
    if (t.repeatDays.isNotEmpty) {
      parts.add('Repete: ${_formatRepeat(t.repeatDays)}');
    }
    if (t.category.isNotEmpty) {
      parts.add(t.category);
    }
    return parts.isEmpty ? null : parts.join(' • ');
  }

  String _formatRepeat(List<int> days) {
    const labels = ['', 'S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final sorted = [...days]..sort();
    return sorted.map((d) => labels[d]).join(' ');
  }
}
