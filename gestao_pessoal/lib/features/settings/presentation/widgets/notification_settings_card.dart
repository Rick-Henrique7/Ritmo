import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../data/settings_controller.dart';
import '../../domain/notification_settings.dart';

/// Configurações → Notificações (RF-NT-07): chave geral, um interruptor por
/// tipo de aviso, horários e antecedência, e o estado da permissão.
class NotificationSettingsCard extends ConsumerStatefulWidget {
  const NotificationSettingsCard({super.key});

  @override
  ConsumerState<NotificationSettingsCard> createState() =>
      _NotificationSettingsCardState();
}

class _NotificationSettingsCardState
    extends ConsumerState<NotificationSettingsCard> {
  late Future<bool> _permitted;

  @override
  void initState() {
    super.initState();
    _permitted = ref.read(notificationSchedulerProvider).isPermitted();
  }

  Future<void> _requestPermission() async {
    await ref.read(notificationSchedulerProvider).requestPermission();
    setState(() {
      _permitted = ref.read(notificationSchedulerProvider).isPermitted();
    });
  }

  void _save(NotificationSettings value) =>
      ref.read(settingsProvider.notifier).updateNotifications(value);

  Future<void> _pickTime(int current, void Function(int) onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) onPicked(picked.hour * 60 + picked.minute);
  }

  static String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  static String _leadLabel(int lead) => lead == 0 ? 'Na hora' : '$lead min antes';

  @override
  Widget build(BuildContext context) {
    final n = ref.watch(settingsProvider.select((s) => s.notifications));
    final palette = context.palette;

    Widget toggle({
      required String title,
      required String subtitle,
      required bool value,
      required ValueChanged<bool> onChanged,
      Widget? trailing,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: value,
            onChanged: onChanged,
            title: Text(title, style: TextStyle(color: palette.textPrimary)),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
            ),
          ),
          // Horário ou antecedência numa linha própria: não aperta o título
          // em telas estreitas ou com fonte grande.
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing),
        ],
      );
    }

    Widget timeButton(int minutes, ValueChanged<int> onPicked, bool enabled) {
      return TextButton(
        onPressed: enabled ? () => _pickTime(minutes, onPicked) : null,
        child: Text(_hhmm(minutes)),
      );
    }

    final on = n.enabled;
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          toggle(
            title: 'Avisos',
            subtitle: 'Liga ou desliga todas as notificações do app',
            value: on,
            onChanged: (v) => _save(n.copyWith(enabled: v)),
          ),
          if (on) ...[
            Divider(height: 1, color: palette.border),
            toggle(
              title: 'Resumo da manhã',
              subtitle: 'O que há para hoje',
              value: n.morningEnabled,
              onChanged: (v) => _save(n.copyWith(morningEnabled: v)),
              trailing: timeButton(
                n.morningMinutes,
                (m) => _save(n.copyWith(morningMinutes: m)),
                n.morningEnabled,
              ),
            ),
            toggle(
              title: 'Pendências da noite',
              subtitle: 'Só se ainda faltar algo',
              value: n.eveningEnabled,
              onChanged: (v) => _save(n.copyWith(eveningEnabled: v)),
              trailing: timeButton(
                n.eveningMinutes,
                (m) => _save(n.copyWith(eveningMinutes: m)),
                n.eveningEnabled,
              ),
            ),
            toggle(
              title: 'Tarefas com horário',
              subtitle: 'Com botões Concluir e Adiar 1 h',
              value: n.tasksEnabled,
              onChanged: (v) => _save(n.copyWith(tasksEnabled: v)),
              trailing: DropdownButton<int>(
                value: n.taskLeadMinutes,
                underline: const SizedBox.shrink(),
                onChanged: n.tasksEnabled
                    ? (v) => _save(n.copyWith(taskLeadMinutes: v))
                    : null,
                items: [
                  for (final lead in NotificationSettings.leadOptions)
                    DropdownMenuItem(value: lead, child: Text(_leadLabel(lead))),
                ],
              ),
            ),
            toggle(
              title: 'Hábitos',
              subtitle: 'No horário de lembrete de cada hábito',
              value: n.habitsEnabled,
              onChanged: (v) => _save(n.copyWith(habitsEnabled: v)),
            ),
            toggle(
              title: 'Fim do foco',
              subtitle: 'Quando a sessão termina com o app minimizado',
              value: n.focusEnabled,
              onChanged: (v) => _save(n.copyWith(focusEnabled: v)),
            ),
            Divider(height: 1, color: palette.border),
            FutureBuilder<bool>(
              future: _permitted,
              builder: (context, snap) {
                if (snap.data ?? true) return const SizedBox(height: 4);
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 20, color: palette.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'O Android está bloqueando os avisos. Se tocar em '
                          'Permitir não abrir nada, libere em Configurações '
                          'do Android → Apps → Daily Flow → Notificações.',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _requestPermission,
                        child: const Text('Permitir'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
