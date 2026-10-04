import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/habits/presentation/habits_screen.dart';
import '../features/pomodoro/presentation/pomodoro_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../shell/app_shell.dart';

/// Configuração central de rotas (GoRouter).
///
/// Todas as rotas são embrulhadas pelo `AppShell` (background animado
/// + GlassNavBar 3D no rodapé), inclusive `/settings` para manter
/// consistência visual.
class AppRouter {
  static final config = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/habits',
            builder: (context, state) => const HabitsScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: '/pomodoro',
            builder: (context, state) => const PomodoroScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
