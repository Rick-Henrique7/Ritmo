import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/notifications/permission_prompt.dart';
import '../../../core/utils/color_hex.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../../../core/widgets/glass_input_field.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../../core/widgets/weekday_chip.dart';
import '../data/habits_controller.dart';
import '../domain/habit_model.dart';

/// Diálogo completo de criação OU edição de hábito.
///
/// Quando [existing] é `null` é criação; quando é uma [HabitModel] é
/// edição (campos pré-preenchidos) e o botão primário diz "Salvar".
///
/// Inclui nome, categoria, grade de ícones, paleta de cores,
/// frequência (dias da semana), lembrete e estimativa de duração.
class HabitFormDialog extends ConsumerStatefulWidget {
  const HabitFormDialog({super.key, this.existing});

  /// Se não-nulo, abre no modo edição com os campos preenchidos.
  final HabitModel? existing;

  bool get isEditing => existing != null;

  @override
  ConsumerState<HabitFormDialog> createState() => _HabitFormDialogState();
}

class _HabitFormDialogState extends ConsumerState<HabitFormDialog> {
  // Controllers com identidade única — NUNCA reaproveitar entre dois
  // TextField (compartilham estado e a digitação vaza).
  late final TextEditingController _titleCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _unitCtrl;

  late String _iconKey;
  late String _colorHex;
  TimeOfDay? _reminder;
  int? _durationMinutes;
  late final Set<int> _frequency;

  /// Mostra o motivo quando "Criar" é tocado sem nome ou sem dias.
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _categoryCtrl = TextEditingController(text: e?.category ?? '');
    _targetCtrl = TextEditingController(text: '${e?.targetValue ?? 1}');
    _unitCtrl = TextEditingController(text: e?.unit ?? 'vez');
    _iconKey = e?.iconKey ?? 'water';
    _colorHex = e?.colorHex ?? '#4F8A83';
    _reminder = e?.reminderTime;
    _durationMinutes = e?.durationMinutes;
    // Hábito novo começa todos os dias: sem nenhum dia marcado ele seria
    // salvo mas nunca apareceria em Hoje nem no calendário.
    _frequency = e != null ? {...e.frequencyDays} : {1, 2, 3, 4, 5, 6, 7};
  }

  /// Paleta de cores dos hábitos — tons terrosos/editoriais que
  /// funcionam tanto no papel creme quanto no vidro escuro.
  static const _palette = [
    '#E4553F', // Coral
    '#D9A441', // Mostarda
    '#4F8A83', // Verde-petróleo
    '#3E6FA8', // Azul-ardósia
    '#8A9A5B', // Oliva
    '#9C5B8A', // Ameixa
    '#C7774A', // Terracota
    '#5B5A57', // Grafite
  ];


  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminder ?? const TimeOfDay(hour: 7, minute: 0),
    );
    if (picked != null) setState(() => _reminder = picked);
  }

  /// Abre um picker com durações pré-definidas + opção "Sem estimativa".
  Future<void> _pickDuration() async {
    final picked = await showDialog<int?>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: LiquidGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimativa de duração',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Quanto tempo você pretende dedicar a este hábito?',
                style: TextStyle(color: context.palette.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mins in const [5, 10, 15, 20, 30, 45, 60, 90])
                    _DurationChip(
                      label: _formatDuration(mins),
                      active: _durationMinutes == mins,
                      onTap: () => Navigator.pop(ctx, mins),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, -1), // limpar
                    child: const Text('Sem estimativa'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, _durationMinutes),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _durationMinutes = picked < 0 ? null : picked);
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h${m.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    final error = _titleCtrl.text.trim().isEmpty
        ? 'Dê um nome ao hábito.'
        : _frequency.isEmpty
            ? 'Escolha pelo menos um dia da semana.'
            : null;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final notifier = ref.read(habitsProvider.notifier);
    final category = _categoryCtrl.text.trim().isEmpty
        ? 'Geral'
        : _categoryCtrl.text.trim();
    final unit = _unitCtrl.text.trim().isEmpty
        ? 'vez'
        : _unitCtrl.text.trim();

    if (widget.isEditing) {
      final updated = widget.existing!.copyWith(
        title: _titleCtrl.text.trim(),
        category: category,
        iconKey: _iconKey,
        colorHex: _colorHex,
        frequencyDays: _frequency.toList()..sort(),
        targetValue: int.tryParse(_targetCtrl.text) ?? 1,
        unit: unit,
        reminderTime: _reminder,
        clearReminderTime: _reminder == null,
        durationMinutes: _durationMinutes,
        clearDurationMinutes: _durationMinutes == null,
      );
      await notifier.update(updated);
    } else {
      await notifier.create(
        title: _titleCtrl.text.trim(),
        category: category,
        iconKey: _iconKey,
        colorHex: _colorHex,
        frequencyDays: _frequency.toList()..sort(),
        targetValue: int.tryParse(_targetCtrl.text) ?? 1,
        unit: unit,
        reminderTime: _reminder,
        durationMinutes: _durationMinutes,
      );
    }
    // Hábito com lembrete: bom momento para pedir a permissão de avisos.
    if (_reminder != null && mounted) {
      await askNotificationPermissionOnce(context, ref);
    }
    if (mounted) Navigator.pop(context);
  }

  /// Confirma a exclusão do hábito a partir do diálogo de edição.
  ///
  /// Mesmo diálogo da lista (`showConfirmDeleteDialog`): pergunta,
  /// remove, fecha o diálogo de edição e oferece "Desfazer" via snackbar.
  /// Sem isso, um hábito só podia ser excluído deslizando o card — quem
  /// clica pra editar não tem caminho de saída.
  Future<void> _confirmAndDelete() async {
    final habit = widget.existing;
    if (habit == null) return;

    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Excluir hábito?',
      message: '"${habit.title}" e todo o seu histórico de conclusões '
          'serão removidos. Essa ação pode ser desfeita na barra inferior.',
    );

    if (confirmed != true) return;
    if (!mounted) return;

    // Captura as dependências ANTES de fechar o diálogo — depois do pop
    // o `context` da árvore do diálogo já não tem Scaffold ancestral.
    final notifier = ref.read(habitsProvider.notifier);
    final habitSnapshot = habit;
    final outerContext = context; // contexto da árvore raiz (com Scaffold)

    // Fecha o diálogo de edição.
    Navigator.pop(context);

    await notifier.remove(habitSnapshot.id);

    if (!outerContext.mounted) return;
    AppUndoSnackBar.show(
      outerContext,
      icon: Icons.delete_outline,
      message: 'Hábito "${habitSnapshot.title}" excluído',
      onUndo: () => notifier.add(habitSnapshot),
    );
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
                widget.isEditing ? 'Editar hábito' : 'Novo hábito',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Nome
              GlassInputField(
                controller: _titleCtrl,
                hintText: 'Nome — Ex.: Beber 2L de Água',
              ),
              const SizedBox(height: 12),
              GlassInputField(
                controller: _categoryCtrl,
                hintText: 'Categoria',
              ),
              const SizedBox(height: 16),

              // Ícones (grid)
              Text(
                'Ícone',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in HabitIcons.all.entries)
                    GestureDetector(
                      onTap: () => setState(() => _iconKey = entry.key),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _iconKey == entry.key
                              ? colorFromHex(_colorHex).withValues(alpha: 0.35)
                              : context.palette.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _iconKey == entry.key
                                ? colorFromHex(_colorHex)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(entry.value,
                            color: _iconKey == entry.key
                                ? colorFromHex(_colorHex)
                                : context.palette.textPrimary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Paleta de cores
              Text(
                'Cor',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final hex in _palette)
                    GestureDetector(
                      onTap: () => setState(() => _colorHex = hex),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorFromHex(hex),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _colorHex == hex
                                ? context.palette.textPrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Meta + Unidade
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GlassInputField(
                      controller: _targetCtrl,
                      hintText: 'Meta',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GlassInputField(
                      controller: _unitCtrl,
                      hintText: 'Unidade (ml, min...)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Estimativa de duração
              Text(
                'Estimativa',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickDuration,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: _durationMinutes == null
                        ? context.palette.veil(0.06)
                        : accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _durationMinutes == null
                          ? context.palette.veil(0.18)
                          : accent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: _durationMinutes == null
                            ? context.palette.textSecondary
                            : context.palette.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _durationMinutes == null
                              ? 'Tempo estimado (ex: 30 min)'
                              : 'Estimado: ${_formatDuration(_durationMinutes!)}',
                          style: TextStyle(
                            color: _durationMinutes == null
                                ? context.palette.textSecondary
                                : context.palette.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_durationMinutes != null)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _durationMinutes = null),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: context.palette.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Frequência
              Text(
                'Frequência',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              WeekdayPicker(
                selected: _frequency,
                onToggle: (day) => setState(() {
                  if (!_frequency.remove(day)) _frequency.add(day);
                  _error = null;
                }),
              ),
              const SizedBox(height: 16),

              // Lembrete
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.notifications_outlined,
                    color: context.palette.textPrimary),
                title: Text(
                  _reminder == null
                      ? 'Sem lembrete'
                      : 'Lembrete às ${_reminder!.format(context)}',
                  style: TextStyle(color: context.palette.textPrimary),
                ),
                trailing: TextButton(
                  onPressed: _pickReminder,
                  child: Text(_reminder == null ? 'Definir' : 'Alterar'),
                ),
              ),
              const SizedBox(height: 8),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(color: context.accent, fontSize: 13),
                  ),
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Excluir só aparece quando estamos editando um hábito
                  // existente. Sem isso, o usuário não tem como remover
                  // o hábito a partir do diálogo — só deslizando o card.
                  if (widget.isEditing) ...[
                    TextButton.icon(
                      onPressed: _confirmAndDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: context.palette.textPrimary,
                      ),
                      label: Text(
                        'Excluir',
                        style: TextStyle(color: context.palette.textPrimary),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: context.palette.surface2,
                        foregroundColor: context.palette.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppColors.radiusSm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
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

/// Chip de duração para o picker de estimativa (5min, 10min, 1h...).
class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? accent : context.palette.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.onColor(accent) : context.palette.textPrimary,
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
