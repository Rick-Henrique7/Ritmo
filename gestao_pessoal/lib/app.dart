import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_theme.dart';
import 'features/settings/data/settings_controller.dart';
import 'routing/app_router.dart';
import 'shell/day_rollover.dart';

class DailyFlowApp extends ConsumerWidget {
  const DailyFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assiste estilo + cores configuradas p/ repassar pro tema — assim
    // todo o app (texto, accent, FAB, nav bar, switches) acompanha.
    final settings = ref.watch(settingsProvider);
    final theme = AppTheme.build(
      style: settings.style,
      textColorHex: settings.textColor,
      accentColorHex: settings.accentColor,
    );
    return DayRollover(
      child: MaterialApp.router(
        title: 'Daily Flow',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: theme,
        themeMode: settings.style.isGlass ? ThemeMode.dark : ThemeMode.light,
        routerConfig: AppRouter.config,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
