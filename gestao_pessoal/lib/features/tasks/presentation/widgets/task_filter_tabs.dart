import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/task_schedule.dart';

/// Abas de filtro em texto, com sublinhado no accent (estilo editorial).
class TaskFilterTabs extends StatelessWidget {
  const TaskFilterTabs({
    super.key,
    required this.current,
    required this.accent,
    required this.labelFor,
    required this.onChanged,
  });

  final TaskFilter current;
  final Color accent;
  final String Function(TaskFilter) labelFor;
  final ValueChanged<TaskFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          for (final f in TaskFilter.values)
            InkWell(
              onTap: () => onChanged(f),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 14, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelFor(f),
                      style: t.titleSmall?.copyWith(
                        color: f == current
                            ? context.palette.textPrimary
                            : context.palette.textTertiary,
                        fontWeight:
                            f == current ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: f == current ? 22 : 0,
                      color: accent,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
