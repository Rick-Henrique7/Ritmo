import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/color_hex.dart';
import '../../domain/app_settings.dart';

/// Miniatura clicável de um estilo visual (Editorial / Liquid Glass),
/// desenhada com a paleta daquele estilo — não com a do tema atual.
/// Miniatura clicável de um estilo visual (Editorial / Liquid Glass).
class StylePreview extends StatelessWidget {
  const StylePreview({
    super.key,
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final AppStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.forStyle(style);
    final accent = colorFromHex(style.defaultAccentHex);
    final t = Theme.of(context).textTheme;
    final ring = selected
        ? Theme.of(context).colorScheme.primary
        : context.palette.border;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Estilo ${style.label}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: ring, width: selected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 0.82,
                  child: Stack(
                    children: [
                      Positioned.fill(child: ColoredBox(color: p.background)),
                      if (style.isGlass) ...[
                        Positioned(
                          left: -30,
                          top: -20,
                          child: _Blob(color: accent, size: 120),
                        ),
                        Positioned(
                          right: -40,
                          bottom: -10,
                          child: _Blob(
                            color: const Color(0xFF38BDF8),
                            size: 120,
                          ),
                        ),
                      ] else ...[
                        Positioned(
                          right: -36,
                          top: -30,
                          child: _Disc(color: accent, size: 110),
                        ),
                        Positioned(
                          left: -24,
                          bottom: -24,
                          child: _Disc(color: accent, size: 64),
                        ),
                      ],
                      // Mini "card" com linhas de texto
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 14,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: style.isGlass
                                ? Colors.white.withValues(alpha: 0.14)
                                : p.panel,
                            borderRadius: BorderRadius.circular(12),
                            border: style.isGlass
                                ? Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  )
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '07',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 26,
                                  height: 1,
                                  fontWeight: style.isGlass
                                      ? FontWeight.w700
                                      : FontWeight.w300,
                                  fontFamily: style.isGlass ? null : 'Jost',
                                ),
                              ),
                              const SizedBox(height: 8),
                              for (final w in const [0.9, 0.6])
                                FractionallySizedBox(
                                  widthFactor: w,
                                  child: Container(
                                    height: 4,
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: p.onPanel.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        style.label,
                        style: t.titleSmall?.copyWith(
                          color: context.palette.textPrimary,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: selected ? 1 : 0,
                      child: Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.75), color.withValues(alpha: 0)],
          ),
        ),
      );
}
