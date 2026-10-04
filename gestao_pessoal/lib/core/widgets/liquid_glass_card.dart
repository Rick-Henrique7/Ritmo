import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Card padrão do Ritmo. O visual segue o [AppStyle] ativo:
///
/// - **Editorial**: papel um tom mais claro que o fundo, borda fina de
///   tinta, cantos generosos. Com [panel] = `true` vira um painel
///   grafite (como os blocos escuros de revista) — use [context.palette.onPanel]
///   para o texto dentro dele.
/// - **Liquid Glass**: vidro fosco (`BackdropFilter`), preenchimento
///   translúcido, borda com reflexo de luz e sombra suave.
///
/// O nome foi mantido por compatibilidade com o código das telas.
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppColors.space5),
    this.borderRadius = AppColors.radiusLg,
    this.gradient,
    this.intensity = GlassIntensity.standard,
    this.panel = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Gradient? gradient;
  final GlassIntensity intensity;

  /// Painel de destaque (grafite no editorial / vidro mais denso no glass).
  final bool panel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    if (context.palette.isGlass) return _glass(radius);

    final Color? fill = gradient != null
        ? null
        : panel
            ? context.palette.panel
            : intensity == GlassIntensity.subtle
                ? Colors.transparent
                : context.palette.surface;
    return RepaintBoundary(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: fill,
          gradient: gradient,
          borderRadius: radius,
          border: panel || gradient != null
              ? null
              : Border.all(color: context.palette.border, width: 1),
        ),
        child: child,
      ),
    );
  }

  Widget _glass(BorderRadius radius) {
    final fillAlpha = switch (intensity) {
      GlassIntensity.subtle => 0.05,
      GlassIntensity.standard => 0.09,
      GlassIntensity.strong => 0.14,
    };
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: gradient ??
                    LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(
                            alpha: fillAlpha + (panel ? 0.10 : 0.04)),
                        Colors.white.withValues(alpha: fillAlpha * 0.6),
                      ],
                    ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: panel ? 0.32 : 0.2),
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Densidade do card: `subtle` (quase invisível), `standard`, `strong`.
enum GlassIntensity { subtle, standard, strong }
