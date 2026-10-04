import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Cabeçalho editorial comum a todas as telas:
///
/// ```
/// ───────────────────────────────
/// Ritmo                [ações]
/// ───────────────────────────────
/// Linha de apoio (leve)
/// Título da tela
/// ```
///
/// Funciona nos dois estilos (as cores vêm de [AppColors]).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.actions = const [],
    this.onBack,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 8),
  });

  final String title;
  final String? eyebrow;
  final List<Widget> actions;

  /// Se definido, mostra uma seta de voltar antes do título.
  final VoidCallback? onBack;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HairlineRule(),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Text(
                  'Ritmo',
                  style: text.labelLarge?.copyWith(
                    color: context.palette.textPrimary,
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                ...actions,
              ],
            ),
          ),
          const HairlineRule(),
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkResponse(
                onTap: onBack,
                radius: 22,
                child: Icon(Icons.arrow_back, color: context.palette.textPrimary),
              ),
            ),
          const SizedBox(height: 18),
          if (eyebrow != null)
            Text(
              eyebrow!,
              style: text.titleMedium?.copyWith(
                color: context.palette.textPrimary,
                fontWeight: FontWeight.w300,
              ),
            ),
          Text(
            title,
            style: text.headlineMedium?.copyWith(color: context.palette.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// Ícone de ação compacto para o [ScreenHeader].
class HeaderAction extends StatelessWidget {
  const HeaderAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: context.palette.textPrimary, size: 22),
      onPressed: onTap,
    );
  }
}

/// Linha fina horizontal (1px) na cor de borda do estilo.
class HairlineRule extends StatelessWidget {
  const HairlineRule({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: color ?? context.palette.textPrimary.withValues(alpha: 0.55),
    );
  }
}

/// Rótulo de seção ("Hábitos", "Tarefas de hoje"...), com contador
/// opcional à direita.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing, this.color});

  final String text;
  final String? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = color ?? context.palette.textPrimary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(text, style: t.titleLarge?.copyWith(color: c)),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: t.labelMedium?.copyWith(color: c.withValues(alpha: 0.65)),
          ),
      ],
    );
  }
}

/// Seta "→" usada como chamada para ação (estilo editorial).
class ArrowCta extends StatelessWidget {
  const ArrowCta({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.accent,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final a = accent ?? Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.east, size: 34, color: a),
            Text(
              label,
              style: t.labelMedium?.copyWith(
                color: color ?? context.palette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
