import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/notifications/permission_prompt.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/glass_input_field.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../../core/widgets/weekday_chip.dart';
import '../data/tasks_controller.dart';
import '../domain/subtask_model.dart';
import '../domain/task_model.dart';

/// Diálogo de criação OU edição de uma tarefa.
///
/// Quando [existing] é `null` é criação; quando é uma [TaskModel] é
/// edição e o botão primário diz "Salvar".
class TaskFormDialog extends ConsumerStatefulWidget {
  const TaskFormDialog({super.key, this.existing});
  final TaskModel? existing;

  bool get isEditing => existing != null;

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  // Controllers com keys explícitas para garantir identidade única.
  // Importante: NUNCA reaproveitar o mesmo controller em dois TextField
  // — eles compartilham estado e digitação num aparece no outro.
  late final TextEditingController _titleCtrl;
  late final TextEditingController _categoryCtrl;

  late TaskPriority _priority;
  // _dueDate default = HOJE (meia-noite) p/ que toda tarefa nova já
  // apareça em "Hoje" imediatamente. Mesmo se o usuário limpar com o
  // × (ficando sem data), a tarefa ainda entra em "Hoje" como ad-hoc
  // — ver `_isScheduledFor` no controller.
  late DateTime? _dueDate;
  TimeOfDay? _dueTime;
  late final Set<int> _repeatDays;

  /// Aparece quando "Criar" é tocado sem nome (antes nada acontecia).
  bool _missingTitle = false;

  static DateTime _todayMidnight() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _categoryCtrl = TextEditingController(text: e?.category ?? '');
    _priority = e?.priority ?? TaskPriority.medium;
    _dueDate = e?.dueDate ?? _todayMidnight();
    _dueTime = e?.dueTime;
    _repeatDays = {...?e?.repeatDays};
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _missingTitle = true);
      return;
    }
    final category = _categoryCtrl.text.trim();
    final notifier = ref.read(tasksProvider.notifier);

    if (widget.isEditing) {
      final updated = widget.existing!.copyWith(
        title: _titleCtrl.text.trim(),
        priority: _priority,
        category: category.isEmpty ? 'Geral' : category,
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
        dueTime: _dueTime,
        clearDueTime: _dueTime == null,
        repeatDays: _repeatDays.toList()..sort(),
      );
      await notifier.update(updated);
    } else {
      await notifier.create(
        title: _titleCtrl.text.trim(),
        priority: _priority,
        category: category.isEmpty ? 'Geral' : category,
        dueDate: _dueDate,
        dueTime: _dueTime,
        repeatDays: _repeatDays.toList()..sort(),
      );
    }
    // Tarefa com horário: bom momento para pedir a permissão de avisos.
    if (_dueTime != null && mounted) {
      await askNotificationPermissionOnce(context, ref);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing ? 'Editar tarefa' : 'Nova tarefa',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Título
              GlassInputField(
                key: const ValueKey('task-title-field'),
                controller: _titleCtrl,
                hintText: 'Título',
              ),
              const SizedBox(height: 12),

              // Prioridade — mesmo visual do GlassInputField (o tema
              // já define preenchimento, borda arredondada e foco), sem
              // container extra por fora que vazava nos cantos.
              DropdownButtonFormField<TaskPriority>(
                initialValue: _priority,
                isExpanded: true,
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
                decoration: const InputDecoration(
                  hintText: 'Prioridade',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppColors.space5,
                    vertical: AppColors.space3 + 2,
                  ),
                ),
                iconEnabledColor: context.palette.textSecondary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.palette.textPrimary,
                    ),
                items: [
                  for (final p in TaskPriority.values)
                    DropdownMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          Icon(
                              p.icon,
                              color: p.colorAt(
                                accent,
                                muted: context.palette.textSecondary,
                              ),
                              size: 18,
                            ),
                          const SizedBox(width: 8),
                          Text(p.label),
                        ],
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _priority = v ?? _priority),
              ),
              const SizedBox(height: 12),

              // Categoria (controller separado do título)
              GlassInputField(
                key: const ValueKey('task-category-field'),
                controller: _categoryCtrl,
                hintText: 'Categoria',
              ),
              const SizedBox(height: 16),

              // Data + Hora
              Text(
                'Quando',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _PickerButton(
                      icon: Icons.event_outlined,
                      label: _dueDate == null
                          ? 'Data'
                          : DateFormatters.shortDate(_dueDate!),
                      active: _dueDate != null,
                      onTap: _pickDate,
                      onClear: _dueDate == null
                          ? null
                          : () => setState(() => _dueDate = null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerButton(
                      icon: Icons.schedule,
                      label: _dueTime == null
                          ? 'Hora'
                          : '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}',
                      active: _dueTime != null,
                      onTap: _pickTime,
                      onClear: _dueTime == null
                          ? null
                          : () => setState(() => _dueTime = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Repetição (dias da semana)
              Text(
                'Repetir',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              WeekdayPicker(
                selected: _repeatDays,
                onToggle: (day) => setState(() {
                  if (!_repeatDays.remove(day)) _repeatDays.add(day);
                }),
              ),
              const SizedBox(height: 20),
              if (_missingTitle)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Dê um nome à tarefa.',
                    style: TextStyle(color: context.accent, fontSize: 13),
                  ),
                ),

              // Ações
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(widget.isEditing ? 'Salvar' : 'Criar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão de seleção estilo Liquid Glass para data/hora.
class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? accent.withValues(alpha: 0.25)
              : context.palette.veil(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? accent
                : context.palette.veil(0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  active ? context.palette.textPrimary : context.palette.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: active
                      ? context.palette.textPrimary
                      : context.palette.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: context.palette.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
