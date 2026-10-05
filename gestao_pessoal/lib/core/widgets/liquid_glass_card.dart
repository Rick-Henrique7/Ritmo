import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Card padrão do Ritmo. O visual segue o [AppStyle] ativo:
///
/// - **Editorial**: papel um tom mais claro que o fundo, borda fina de
///   tinta, cantos generosos. Com [panel] = `true` vira um painel
///   grafite (como os blocos escuros de revista) — use [context.palette.onPanel]
///   para o texto dentro dele.
/// - **Liquid Glass**: preenchimento translúcido sobre o fundo de manchas,
///   borda com reflexo de luz e sombra suave.
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
      GlassIntensity.subtle => 0.06,
      GlassIntensity.standard => 0.11,
      GlassIntensity.strong => 0.16,
    };
    // Sem BackdropFilter: o que fica atrás dos cartões é só o fundo de
    // manchas em degradê (ou uma cor lisa), que desfocado fica igual. O
    // desfoque refeito a cada quadro do fundo animado era o que travava o
    // Liquid Glass; o vidro fosco real ficou só na barra de navegação,
    // por onde o conteúdo passa por baixo.
    return RepaintBoundary(
      child: Container(
        padding: padding,
        // Mantém o conteúdo dentro dos cantos arredondados, como o
        // ClipRRect fazia antes.
        clipBehavior: Clip.antiAlias,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Densidade do card: `subtle` (quase invisível), `standard`, `strong`.
enum GlassIntensity { subtle, standard, strong }
