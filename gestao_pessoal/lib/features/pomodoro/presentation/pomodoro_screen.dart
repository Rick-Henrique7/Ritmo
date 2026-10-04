import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../tasks/data/tasks_controller.dart';
import '../data/pomodoro_controller.dart';
import '../domain/pomodoro_session_model.dart';
import 'pomodoro_timer_view.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(pomodoroTimerProvider);
    final controller = ref.read(pomodoroTimerProvider.notifier);
    final today = ref.watch(todayProvider);
    final pendingTasks = ref
        .watch(tasksProvider)
        .where((t) => !t.isCompletedOn(today))
        .toList();
    final accent = context.accent;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ScreenHeader(
              eyebrow: 'Uma coisa de cada vez',
              title: 'Foco',
            ),
            Expanded(child: PomodoroTimerView(state: timer)),

            // Seletor de modo (Foco / Pausa Curta / Pausa Longa)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: context.palette.isGlass
                  ? _GlassModeSelector(
                      current: timer.type,
                      accent: accent,
                      onChanged: controller.setType,
                    )
                  : _EditorialModeSelector(
                      current: timer.type,
                      accent: accent,
                      onChanged: controller.setType,
                    ),
            ),
            const SizedBox(height: 14),

            // Vincular a uma tarefa (RF-PO-03)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LiquidGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: 999,
                child: Row(
                  children: [
                    Icon(Icons.link, color: context.palette.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: timer.taskId,
                          borderRadius: BorderRadius.circular(16),
                          hint: Text(
                            'Vincular a uma tarefa',
                            style: TextStyle(color: context.palette.textSecondary),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Nenhuma'),
                            ),
                            for (final t in pendingTasks)
                              DropdownMenuItem<String?>(
                                value: t.id,
                                child: Text(
                                  t.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: controller.selectTask,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Controles (RF-PO-01)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CircleButton(
                    icon: Icons.stop_rounded,
                    tooltip: 'Parar',
                    onPressed: controller.stop,
                  ),
                  _CircleButton(
                    icon: timer.isRunning ? Icons.pause : Icons.play_arrow,
                    tooltip: timer.isRunning ? 'Pausar' : 'Iniciar',
                    color: accent,
                    size: 84,
                    onPressed: controller.toggle,
                  ),
                  _CircleButton(
                    icon: Icons.skip_next_rounded,
                    tooltip: 'Pular',
                    onPressed: controller.skip,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

String _modeLabel(PomodoroType type) => switch (type) {
      PomodoroType.focus => 'Foco',
      PomodoroType.shortBreak => 'Pausa curta',
      PomodoroType.longBreak => 'Pausa longa',
    };

/// Editorial: três rótulos em texto com sublinhado no accent.
class _EditorialModeSelector extends StatelessWidget {
  const _EditorialModeSelector({
    required this.current,
    required this.accent,
    required this.onChanged,
  });
  final PomodoroType current;
  final Color accent;
  final ValueChanged<PomodoroType> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final type in PomodoroType.values)
          InkWell(
            onTap: () => onChanged(type),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: [
                  Text(
                    _modeLabel(type),
                    style: t.titleSmall?.copyWith(
                      color: current == type
                          ? context.palette.textPrimary
                          : context.palette.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: current == type ? 22 : 0,
                    height: 2,
                    color: accent,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Liquid Glass: segmented control em vidro.
class _GlassModeSelector extends StatelessWidget {
  const _GlassModeSelector({
    required this.current,
    required this.accent,
    required this.onChanged,
  });
  final PomodoroType current;
  final Color accent;
  final ValueChanged<PomodoroType> onChanged;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GlassContainer(
        shape: LiquidRoundedSuperellipse(borderRadius: 20),
        settings: LiquidGlassSettings(
          thickness: 10,
          blur: 8,
          glassColor: Colors.white.withValues(alpha: 0.14),
          lightIntensity: 0.5,
          glowIntensity: 0.5,
          fresnelStrength: 0.8,
          ambientRim: 0.4,
        ),
        useOwnLayer: true,
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            for (final type in PomodoroType.values)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: current == type
                          ? accent.withValues(alpha: 0.85)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _modeLabel(type),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            current == type ? FontWeight.w700 : FontWeight.w500,
                        color: current == type
                            ? AppColors.onColor(accent)
                            : context.palette.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Botão circular. Com [color] vira o botão principal (cheio no accent);
/// sem cor é secundário (aro fino no editorial / vidro no glass).
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.size = 56,
  });
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final primary = color != null;
    final iconColor = primary ? AppColors.onColor(color!) : context.palette.textPrimary;
    final child = SizedBox(
      width: size,
      height: size,
      child: Icon(icon, color: iconColor, size: size * 0.45),
    );

    if (!context.palette.isGlass) {
      return Tooltip(
        message: tooltip,
        child: Material(
          color: primary ? color : Colors.transparent,
          shape: CircleBorder(
            side: primary
                ? BorderSide.none
                : BorderSide(color: context.palette.textPrimary, width: 1.1),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onPressed, child: child),
        ),
      );
    }

    final glassTint = color ?? Colors.white;
    return Tooltip(
      message: tooltip,
      child: RepaintBoundary(
        child: GlassContainer(
          shape: const LiquidOval(),
          settings: LiquidGlassSettings(
            thickness: 14,
            blur: 10,
            glassColor: glassTint.withValues(alpha: primary ? 0.55 : 0.12),
            lightIntensity: 0.6,
            glowIntensity: 0.7,
            fresnelStrength: 1.0,
            chromaticAberration: 0.015,
            ambientRim: 0.5,
            shadow: [
              BoxShadow(
                color: glassTint.withValues(alpha: primary ? 0.4 : 0.1),
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          useOwnLayer: true,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: child,
          ),
        ),
      ),
    );
  }
}
