import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/color_hex.dart';
import '../../../core/utils/date_formatters.dart';
import '../../settings/data/settings_controller.dart';
import '../data/pomodoro_controller.dart';
import '../domain/pomodoro_session_model.dart';

/// Timer circular minimalista do Pomodoro (RF-PO-01, RNF-PO-01).
///
/// Usa [CustomPaint] otimizado (sem AnimatedContainer) e mantém
/// `TweenAnimationBuilder` apenas para o gradiente do anel.
///
/// As cores são derivadas das configurações do usuário
/// (`SettingsNotifier.pomodoroFocusColor` etc.), permitindo
/// personalização total do visual do timer.
class PomodoroTimerView extends ConsumerWidget {
  const PomodoroTimerView({super.key, required this.state});

  final PomodoroTimerState state;

  Color _accentColor(String focusHex, String shortHex, String longHex) {
    switch (state.type) {
      case PomodoroType.focus:
        return colorFromHex(focusHex);
      case PomodoroType.shortBreak:
        return colorFromHex(shortHex);
      case PomodoroType.longBreak:
        return colorFromHex(longHex);
    }
  }


  String _label({required bool glass}) {
    switch (state.type) {
      case PomodoroType.focus:
        return glass ? 'FOCO' : 'Foco';
      case PomodoroType.shortBreak:
        return glass ? 'PAUSA CURTA' : 'Pausa curta';
      case PomodoroType.longBreak:
        return glass ? 'PAUSA LONGA' : 'Pausa longa';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = _accentColor(
      settings.pomodoroFocusColor,
      settings.pomodoroShortBreakColor,
      settings.pomodoroLongBreakColor,
    );

    // Herda a fonte do tema (Jost no editorial, DM Sans no glass, ambas
    // embutidas). Antes este widget usava GoogleFonts.spaceGrotesk
    // / GoogleFonts.inter, que disparavam download sob demanda da CDN do
    // Google Fonts (fonts.gstatic.com) na primeira vez que o usuário
    // entrava na aba Foco — gerava um delay visível de 1–3s.
    final theme = Theme.of(context);
    final glass = context.palette.isGlass;
    final labelStyle = glass
        ? theme.textTheme.labelLarge!.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: accent,
          )
        : theme.textTheme.titleMedium!.copyWith(color: accent);
    final timerStyle = theme.textTheme.displayLarge!.copyWith(
      fontSize: 76,
      fontWeight: glass ? FontWeight.w300 : FontWeight.w200,
      letterSpacing: -2,
      height: 1.0,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: context.palette.textPrimary,
    );
    final percentStyle = theme.textTheme.labelLarge!.copyWith(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: context.palette.textSecondary,
    );

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anel desenhado.
              Positioned.fill(
                child: CustomPaint(
                  painter: _TimerPainter(
                    progress: state.progress,
                    color: accent,
                    track: glass
                        ? context.palette.surfaceElevated
                        : context.palette.textPrimary.withValues(alpha: 0.35),
                    editorial: !glass,
                  ),
                ),
              ),
              // Conteúdo centralizado.
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _label(glass: glass),
                    textAlign: TextAlign.center,
                    style: labelStyle,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    DateFormatters.pomodoro(state.remainingSeconds),
                    textAlign: TextAlign.center,
                    style: timerStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(state.progress * 100).round()}%',
                    textAlign: TextAlign.center,
                    style: percentStyle,
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

class _TimerPainter extends CustomPainter {
  _TimerPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.editorial,
  });

  final double progress;
  final Color color;
  final Color track;

  /// Editorial: trilho de 1px + arco sólido fino com ponto na ponta.
  /// Glass: trilho grosso + arco com gradiente.
  final bool editorial;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 14;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (editorial) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      final sweep = 2 * math.pi * progress;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
      // Ponto na ponta do arco — marca o "agora".
      final angle = -math.pi / 2 + sweep;
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        9,
        Paint()..color = color,
      );
      return;
    }

    // Track
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [color.withValues(alpha: 0.6), color],
    ).createShader(rect);

    final progressPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.track != track ||
      oldDelegate.editorial != editorial;
}
