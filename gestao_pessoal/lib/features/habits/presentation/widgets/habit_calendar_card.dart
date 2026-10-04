import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/liquid_glass_card.dart';

/// Calendário mensal (Syncfusion): marca as conclusões de cada dia e
/// destaca os dias com hábito previsto não concluído.
class HabitCalendarCard extends StatelessWidget {
  const HabitCalendarCard({
    super.key,
    required this.selectedDay,
    required this.appointments,
    required this.incompleteDays,
    required this.accent,
    required this.onDaySelected,
  });
  final DateTime selectedDay;
  final List<Appointment> appointments;
  final Set<DateTime> incompleteDays;
  final Color accent;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return LiquidGlassCard(
      padding: const EdgeInsets.all(8),
      child: SfCalendar(
        view: CalendarView.month,
        backgroundColor: Colors.transparent,
        selectionDecoration: BoxDecoration(
          color: accent.withValues(alpha: 0.18),
          border: Border.all(color: accent, width: 1.5),
          shape: BoxShape.circle,
        ),
        todayHighlightColor: accent,
        todayTextStyle: TextStyle(
          color: context.palette.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        monthViewSettings: MonthViewSettings(
          monthCellStyle: MonthCellStyle(
            textStyle: TextStyle(color: context.palette.textPrimary),
            trailingDatesTextStyle: TextStyle(color: context.palette.textTertiary),
            leadingDatesTextStyle: TextStyle(color: context.palette.textTertiary),
          ),
          navigationDirection: MonthNavigationDirection.horizontal,
        ),
        headerStyle: CalendarHeaderStyle(
          textStyle: TextStyle(
            color: context.palette.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          backgroundColor: Colors.transparent,
        ),
        viewHeaderStyle: ViewHeaderStyle(
          dayTextStyle: TextStyle(color: context.palette.textSecondary, fontSize: 11),
          dateTextStyle: TextStyle(color: context.palette.textPrimary, fontSize: 16),
          backgroundColor: Colors.transparent,
        ),
        initialSelectedDate: selectedDay,
        initialDisplayDate: selectedDay,
        dataSource: _HabitDataSource(appointments),
        // Dias com hábito(s) previsto(s) **não** concluído(s) ficam
        // destacados em vermelho. Mantemos o número do dia + os
        // indicadores de appointment do Syncfusion.
        monthCellBuilder: (context, details) {
          final date = details.date;
          final isIncomplete = incompleteDays.contains(
            DateTime(date.year, date.month, date.day),
          );
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          final appts = details.appointments.cast<Appointment>();

          return Stack(
            fit: StackFit.expand,
            children: [
              // Fundo muted para dias incompletos (design system: sem
              // red/orange p/ estados negativos, usar surface-2).
              if (isIncomplete)
                Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: context.palette.veil(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              // Número do dia (texto secundário se incompleto)
              Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isIncomplete
                        ? context.palette.textSecondary
                        : context.palette.textPrimary,
                    fontWeight:
                        isToday ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              // Pontos de appointment (até 3 visíveis) — só pra dias
              // com conclusões registradas
              if (appts.isNotEmpty)
                Positioned(
                  bottom: 3,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final a in appts.take(3))
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: a.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
        onSelectionChanged: (details) {
          if (details.date != null) onDaySelected(details.date!);
        },
        cellBorderColor: Colors.transparent,
        showNavigationArrow: true,
      ),
    );
  }
}

class _HabitDataSource extends CalendarDataSource {
  _HabitDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].startTime;

  @override
  DateTime getEndTime(int index) => appointments![index].endTime;

  @override
  String getSubject(int index) => appointments![index].subject;

  @override
  Color getColor(int index) => appointments![index].color;
}
