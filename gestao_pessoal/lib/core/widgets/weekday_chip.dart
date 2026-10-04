import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Rótulos curtos dos dias da semana, indexados por `DateTime.weekday`
/// (1 = segunda … 7 = domingo). O índice 0 fica vazio de propósito.
const weekdayInitials = ['', 'S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

/// Bolinha de dia da semana para frequência de hábitos e repetição de
/// tarefas. Antes existia uma cópia em cada formulário.
class WeekdayChip extends StatelessWidget {
  const WeekdayChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Accent do usuário = cor primária do tema (core não lê configurações).
    final accent = Theme.of(context).colorScheme.primary;
    final palette = context.palette;
    final activeBg = palette.isGlass ? accent : palette.panel;
    final activeFg =
        palette.isGlass ? AppColors.onColor(accent) : palette.onPanel;
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? activeBg : palette.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? activeFg : palette.textPrimary,
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Linha com os 7 dias, alternando a seleção em [selected].
class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var day = 1; day <= 7; day++)
          WeekdayChip(
            label: weekdayInitials[day],
            active: selected.contains(day),
            onTap: () => onToggle(day),
          ),
      ],
    );
  }
}
