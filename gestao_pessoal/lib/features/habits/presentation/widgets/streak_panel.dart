import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/liquid_glass_card.dart';

/// Painel grafite com a maior sequência atual em número grande.
class StreakPanel extends StatelessWidget {
  const StreakPanel({
    super.key,
    required this.bestStreak,
    required this.habitCount,
    required this.accent,
  });

  final int bestStreak;
  final int habitCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LiquidGlassCard(
        panel: true,
        borderRadius: 28,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maior sequência',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: accent),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        bestStreak.toString().padLeft(2, '0'),
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(color: accent, fontSize: 72),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        bestStreak == 1 ? 'dia' : 'dias',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: context.palette.onPanel),
                      ),
                    ],
                  ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.local_fire_department_outlined,
                      color: context.palette.onPanel, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    '${habitCount} '
                    '${habitCount == 1 ? 'hábito ativo' : 'hábitos ativos'}',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: context.palette.onPanelMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
