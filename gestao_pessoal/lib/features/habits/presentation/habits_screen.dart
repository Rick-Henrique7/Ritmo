import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/swipe_delete_background.dart';
import '../data/habits_controller.dart';
import '../domain/habit_model.dart';
import 'habit_form_dialog.dart';
import 'widgets/habit_calendar_card.dart';
import 'widgets/habit_card.dart';
import 'widgets/streak_panel.dart';

/// Provider local do dia selecionado no calendário.
final _selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Marcadores do calendário (um por conclusão). Memoizado: só refaz a
/// lista quando os hábitos mudam — antes era recriada a cada build.
final _appointmentsProvider = Provider.autoDispose<List<Appointment>>((ref) {
  return [
    for (final habit in ref.watch(habitsProvider))
      for (final date in habit.completedDates)
        Appointment(
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          subject: habit.title,
          color: habit.color,
          id: '${habit.id}-${date.toIso8601String()}',
        ),
  ];
});

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(_selectedDayProvider);
    final habits = ref.watch(habitsForDayProvider(selectedDay));
    final allHabits = ref.watch(habitsProvider);
    final accent = context.accent;
    final bestStreak = ref.watch(bestStreakProvider);
    final doneOnDay = habits.where((h) => h.isCompletedOn(selectedDay)).length;
    final appointments = ref.watch(_appointmentsProvider);
    // Dias com hábito previsto não concluído (pintados no calendário).
    final incompleteDays = ref.watch(incompleteDaysProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          const ScreenHeader(
            eyebrow: 'Sua rotina',
            title: 'Hábitos',
            padding: EdgeInsets.fromLTRB(4, 12, 4, 8),
          ),
          const SizedBox(height: 16),

          // Sequência — painel com número grande
          StreakPanel(
            bestStreak: bestStreak,
            habitCount: allHabits.length,
            accent: accent,
          ),
          const SizedBox(height: 16),

          // Calendário Syncfusion (re-paint isolado do resto)
          RepaintBoundary(
            child: HabitCalendarCard(
              selectedDay: selectedDay,
              appointments: appointments,
              incompleteDays: incompleteDays,
              accent: accent,
              onDaySelected: (day) =>
                  ref.read(_selectedDayProvider.notifier).state = day,
            ),
          ),
          const SizedBox(height: 24),

          // Header da lista
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SectionLabel(
              '${_capitalize(DateFormatters.weekdayShort(selectedDay).replaceAll('.', ''))}, '
              '${selectedDay.day}/${selectedDay.month}',
              trailing: habits.isEmpty
                  ? null
                  : '$doneOnDay de ${habits.length} feitos',
            ),
          ),
          const SizedBox(height: 12),

          // Lista de hábitos do dia
          if (habits.isEmpty)
            LiquidGlassCard(
              child: Text(
                'Nenhum hábito previsto para este dia. Toque no + para criar um.',
                style: TextStyle(color: context.palette.textSecondary),
              ),
            )
          else
            ...habits.map(
              (habit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey('habit-${habit.id}'),
                  direction: DismissDirection.endToStart,
                  background: const SwipeDeleteBackground(),
                  confirmDismiss: (_) => showConfirmDeleteDialog(
                    context,
                    title: 'Excluir hábito?',
                    message: '"${habit.title}" e todo o seu histórico de '
                        'conclusões serão removidos. Essa ação pode ser '
                        'desfeita na barra inferior.',
                  ),
                  onDismissed: (_) => _onHabitDismissed(context, ref, habit),
                  child: HabitCard(
                    habit: habit,
                    day: selectedDay,
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo hábito',
        onPressed: () => _showCreateHabitDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Abre o formulário de criação (botão +).
  Future<void> _showCreateHabitDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const HabitFormDialog(),
    );
  }

  /// Remove o hábito e oferece "Desfazer" por 4 segundos na snackbar.
  Future<void> _onHabitDismissed(
      BuildContext context, WidgetRef ref, HabitModel habit) async {
    await ref.read(habitsProvider.notifier).remove(habit.id);
    if (!context.mounted) return;
    AppUndoSnackBar.show(
      context,
      icon: Icons.delete_outline,
      message: 'Hábito "${habit.title}" excluído',
      onUndo: () => ref.read(habitsProvider.notifier).add(habit),
    );
  }
}








