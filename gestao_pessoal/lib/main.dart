import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'app.dart';
import 'core/database/prefs_store.dart';
import 'core/notifications/local_notification_scheduler.dart';
import 'core/providers/core_providers.dart';
import 'features/reminders/data/notification_actions.dart';
import 'features/settings/data/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pré-aquece shaders do Liquid Glass (iOS 26 design language).
  await LiquidGlassWidgets.initialize();

  // Locale pt-BR para `DateFormat('pt_BR')`.
  await initializeDateFormatting('pt_BR');

  final store = await PrefsStore.open();

  // Avisos locais (ADR 0009). Toques com o app aberto vão para o primeiro
  // callback; botões tocados com o app fechado, para o segundo, num
  // isolate separado.
  final notifications = await LocalNotificationScheduler.openPlugin(
    onResponse: onForegroundNotificationResponse,
    onBackgroundResponse: onBackgroundNotificationResponse,
  );

  runApp(
    ProviderScope(
      overrides: [
        prefsStoreProvider.overrideWithValue(store),
        notificationSchedulerProvider.overrideWithValue(
          LocalNotificationScheduler(notifications),
        ),
        focusAlertEnabledProvider.overrideWith((ref) {
          final n = ref.watch(settingsProvider).notifications;
          return n.enabled && n.focusEnabled;
        }),
        // Liga a "porta" de feedback do core às configurações do usuário.
        feedbackPreferencesProvider.overrideWith((ref) {
          final s = ref.watch(settingsProvider);
          return FeedbackPreferences(
            haptics: s.hapticsEnabled,
            sound: s.soundEnabled,
          );
        }),
      ],
      child: LiquidGlassWidgets.wrap(child: const DailyFlowApp()),
    ),
  );

  // App aberto pelo toque num aviso: vai direto para a tela dele.
  final launch = await notifications.getNotificationAppLaunchDetails();
  if (launch?.didNotificationLaunchApp ?? false) {
    final payload = launch!.notificationResponse?.payload;
    WidgetsBinding.instance.addPostFrameCallback((_) => openRouteFor(payload));
  }
}
