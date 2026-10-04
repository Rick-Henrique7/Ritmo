import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../habits/data/habits_controller.dart';
import '../../habits/domain/habit_model.dart';
import '../../tasks/data/tasks_controller.dart';
import '../../tasks/domain/subtask_model.dart';
import '../../tasks/domain/task_model.dart';
import '../../tasks/presentation/widgets/overdue_tag.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = ref.watch(todayProvider);
    final accent = context.accent;
    final habitsToday = ref.watch(habitsForDayProvider(today));
    // Mesma regra da aba "Hoje" de Tarefas (TaskSchedule), incluindo as
    // já feitas hoje — para riscar na lista e contar no progresso.
    final todayTasks = ref.watch(todayTasksProvider);

    final habitsDone = habitsToday.where((h) => h.isCompletedOn(today)).length;
    final tasksDone =
        todayTasks.where((t) => TaskSchedule.isDoneOn(t, today)).length;
    final totalItems = habitsToday.length + todayTasks.length;
    final doneItems = habitsDone + tasksDone;
    final progress = totalItems == 0 ? 0.0 : doneItems / totalItems;

    final dateLabel = DateFormatters.fullDate(now);
    final capitalizedDate =
        dateLabel.isEmpty ? dateLabel : dateLabel[0].toUpperCase() + dateLabel.substring(1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            ScreenHeader(
              eyebrow: capitalizedDate,
              title: DateFormatters.greetingForHour(now.hour),
              actions: [
                HeaderAction(
                  icon: Icons.tune,
                  tooltip: 'Configurações',
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProgressHero(
                done: doneItems,
                total: totalItems,
                progress: progress,
                accent: accent,
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LiquidGlassCard(
                panel: true,
                borderRadius: 28,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(
                      'Hoje no radar',
                      trailing: totalItems == 0
                          ? null
                          : '$totalItems ${totalItems == 1 ? 'item' : 'itens'}',
                      color: context.palette.onPanel,
                    ),
                    const SizedBox(height: 10),
                    if (totalItems == 0)
                      _EmptyRadar(accent: accent)
                    else ...[
                      for (var i = 0; i < habitsToday.length; i++)
                        _HabitRow(
                          habit: habitsToday[i],
                          done: habitsToday[i].isCompletedOn(today),
                          accent: accent,
                          showDivider: i > 0,
                          onToggle: () => ref
                              .read(habitsProvider.notifier)
                              .toggleCompletionForDate(habitsToday[i], today),
                        ).animate().fadeIn(delay: (60 * i).ms),
                      for (var i = 0; i < todayTasks.length; i++)
                        _TaskRow(
                          task: todayTasks[i],
                          done: TaskSchedule.isDoneOn(todayTasks[i], today),
                          overdue: TaskSchedule.isOverdue(todayTasks[i], today),
                          accent: accent,
                          showDivider: habitsToday.isNotEmpty || i > 0,
                          onToggle: () => ref
                              .read(tasksProvider.notifier)
                              .toggleCompleted(todayTasks[i]),
                        ).animate().fadeIn(
                            delay: (60 * (habitsToday.length + i)).ms),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ArrowCta(
                          label: 'Ver tarefas',
                          color: context.palette.onPanelMuted,
                          accent: accent,
                          onTap: () => context.go('/tasks'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Criar',
        onPressed: () => _showCreateSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    final accent = context.accent;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.water_drop_outlined, color: accent),
                title: const Text('Novo hábito'),
                trailing: Icon(Icons.east, color: context.palette.textTertiary),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go('/habits');
                },
              ),
              ListTile(
                leading: Icon(Icons.task_alt, color: accent),
                title: const Text('Nova tarefa'),
                trailing: Icon(Icons.east, color: context.palette.textTertiary),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go('/tasks');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bloco de progresso em números grandes ("03 / 07"), no espírito
/// das capas editoriais.
class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.done,
    required this.total,
    required this.progress,
    required this.accent,
  });

  final int done;
  final int total;
  final double progress;
  final Color accent;

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final remaining = total - done;
    final big = t.displayLarge?.copyWith(
      fontSize: 92,
      height: 0.95,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feitos hoje',
          style: t.labelLarge?.copyWith(color: accent),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Números grandes encolhem para caber em telas estreitas ou
            // com fonte do sistema aumentada (em vez de estourar a linha).
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_two(done), style: big?.copyWith(color: accent)),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '/ ${_two(total)}',
                        style: t.displaySmall
                            ?.copyWith(color: context.palette.textTertiary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: t.headlineSmall?.copyWith(
                      color: context.palette.textPrimary,
                    ),
                  ),
                  Text(
                    total == 0
                        ? 'nada agendado'
                        : remaining == 0
                            ? 'dia completo'
                            : 'faltam $remaining',
                    style: t.labelMedium?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ThinProgress(value: progress, accent: accent),
      ],
    );
  }
}

/// Barra de progresso fina: trilho de 1px + preenchimento de 4px.
class _ThinProgress extends StatelessWidget {
  const _ThinProgress({required this.value, required this.accent});

  final double value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(height: 1, color: context.palette.textPrimary.withValues(alpha: 0.5)),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Container(
                width: c.maxWidth * v,
                height: 4,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRadar extends StatelessWidget {
  const _EmptyRadar({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dia livre por enquanto. Crie um hábito ou uma tarefa para '
            'começar a preencher o radar.',
            style: t.bodyMedium?.copyWith(color: context.palette.onPanelMuted),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ArrowCta(
              label: 'Criar hábito',
              color: context.palette.onPanelMuted,
              accent: accent,
              onTap: () => context.go('/habits'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha base do painel "Hoje no radar".
class _RadarRow extends StatelessWidget {
  const _RadarRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.accent,
    required this.showDivider,
    required this.onToggle,
    this.badge,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? badge;
  final bool done;
  final Color accent;
  final bool showDivider;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        if (showDivider)
          Container(height: 1, color: context.palette.onPanel.withValues(alpha: 0.12)),
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: t.bodyLarge?.copyWith(
                                color: done ? context.palette.onPanelMuted : context.palette.onPanel,
                                decoration: done ? TextDecoration.lineThrough : null,
                                decorationColor: context.palette.onPanelMuted,
                              ),
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            badge!,
                          ],
                        ],
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          style: t.bodySmall?.copyWith(color: context.palette.onPanelMuted),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _CheckDot(done: done, accent: accent),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.habit,
    required this.done,
    required this.accent,
    required this.showDivider,
    required this.onToggle,
  });

  final HabitModel habit;
  final bool done;
  final Color accent;
  final bool showDivider;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return _RadarRow(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: habit.color.withValues(alpha: 0.22),
          shape: BoxShape.circle,
        ),
        child: Icon(habit.icon, color: habit.color, size: 19),
      ),
      title: habit.title,
      subtitle: 'Hábito · ${habit.category}',
      done: done,
      accent: accent,
      showDivider: showDivider,
      onToggle: onToggle,
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.done,
    required this.overdue,
    required this.accent,
    required this.showDivider,
    required this.onToggle,
  });

  final TaskModel task;
  final bool done;
  final bool overdue;
  final Color accent;
  final bool showDivider;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final color = task.priority == TaskPriority.low
        ? context.palette.onPanelMuted
        : task.priority.colorAt(accent, muted: context.palette.onPanelMuted);
    return _RadarRow(
      leading: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Container(
            width: 4,
            height: 26,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
      title: task.title,
      subtitle: 'Tarefa · ${task.category} · ${task.priority.label.toLowerCase()}',
      badge: overdue ? OverdueTag(color: accent) : null,
      done: done,
      accent: accent,
      showDivider: showDivider,
      onToggle: onToggle,
    );
  }
}

/// Marcador redondo de concluído (cheio em accent quando feito).
class _CheckDot extends StatelessWidget {
  const _CheckDot({required this.done, required this.accent});
  final bool done;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? accent : Colors.transparent,
        border: Border.all(
          color: done ? accent : context.palette.onPanelMuted,
          width: 1.4,
        ),
      ),
      child: done
          ? Icon(Icons.check, size: 16, color: AppColors.onColor(accent))
          : null,
    );
  }
}
