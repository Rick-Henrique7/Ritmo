import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Item de navegação com rótulo + ícone.
class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

/// Barra de navegação inferior flutuante (pílula).
///
/// - **Editorial**: pílula grafite, ícones creme, item ativo em accent
///   com um ponto embaixo (sem rótulo — o ponto já indica a aba).
/// - **Liquid Glass**: pílula de vidro fosco com blur, item ativo com
///   bolha translúcida.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.onTap,
  });

  final List<GlassNavItem> items;
  final String currentRoute;
  final ValueChanged<String> onTap;

  int get _activeIndex {
    for (var i = 0; i < items.length; i++) {
      if (items[i].route == currentRoute) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final glass = context.palette.isGlass;
    final radius = BorderRadius.circular(999);

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            _NavButton(
              item: items[i],
              active: i == _activeIndex,
              onTap: () => onTap(items[i].route),
            ),
        ],
      ),
    );

    final Widget bar = glass
        ? ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  color: Colors.white.withValues(alpha: 0.10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: row,
              ),
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              color: context.palette.panel,
            ),
            child: row,
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: SafeArea(top: false, child: bar),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });
  final GlassNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final glass = context.palette.isGlass;
    final idle = glass ? context.palette.textSecondary : context.palette.onPanelMuted;
    final color = active ? (glass ? context.palette.textPrimary : accent) : idle;

    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: item.label,
        child: Tooltip(
          message: item.label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: glass && active
                    ? accent.withValues(alpha: 0.28)
                    : Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    active ? item.activeIcon : item.icon,
                    size: 23,
                    color: color,
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: active ? 5 : 0,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glass ? context.palette.textPrimary : accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
