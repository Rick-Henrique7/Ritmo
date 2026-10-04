import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/glass_nav_bar.dart';
import 'animated_background.dart';

/// Shell padrão para todas as telas do app.
///
/// Fica em `lib/shell/` (nível do app, como `routing/`) e não em `core/`
/// porque o fundo depende das configurações do usuário — e `core/` não
/// importa features.
///
/// Empilha:
/// 1. `AnimatedBackground` (composição editorial ou blobs do glass)
/// 2. Conteúdo da rota atual
/// 3. `GlassNavBar` flutuante no rodapé
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const _items = [
    GlassNavItem(
      icon: Icons.wb_sunny_outlined,
      activeIcon: Icons.wb_sunny,
      label: 'Hoje',
      route: '/',
    ),
    GlassNavItem(
      icon: Icons.water_drop_outlined,
      activeIcon: Icons.water_drop,
      label: 'Hábitos',
      route: '/habits',
    ),
    GlassNavItem(
      icon: Icons.checklist_outlined,
      activeIcon: Icons.checklist,
      label: 'Tarefas',
      route: '/tasks',
    ),
    GlassNavItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer,
      label: 'Foco',
      route: '/pomodoro',
    ),
    GlassNavItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights,
      label: 'Stats',
      route: '/stats',
    ),
  ];

  /// Índice usado pelo fundo editorial para escolher a composição.
  int get _routeIndex {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].route == location) return i;
    }
    return location == '/settings' ? 5 : 0;
  }

  @override
  Widget build(BuildContext context) {
    // A paleta vem do tema (`context.palette`): ao trocar de estilo, o
    // Flutter reconstrói só quem depende dela — sem recriar a árvore.
    return AnimatedBackground(
      routeIndex: _routeIndex,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Sem `extendBody`: assim o FAB de cada tela fica acima da
        // nav bar flutuante em vez de escondido atrás dela.
        body: child,
        bottomNavigationBar: GlassNavBar(
          items: _items,
          currentRoute: location,
          onTap: (route) => context.go(route),
        ),
      ),
    );
  }
}
