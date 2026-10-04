import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/prefs_store.dart';
import '../notifications/notification_scheduler.dart';
import '../services/haptics_service.dart';
import '../services/sound_service.dart';
import '../services/wakelock_service.dart';
import '../utils/date_only.dart';

/// Providers de infraestrutura compartilhados por todas as features.
///
/// Ficam em `core/` (e não dentro de uma feature) para que nenhuma
/// feature precise importar outra só para acessar armazenamento ou
/// serviços de plataforma. Ver `docs/adr/0002-providers-em-core.md`.

/// Armazenamento local. Não tem implementação padrão: o `main.dart`
/// (composition root) injeta a instância já aberta via override.
final prefsStoreProvider = Provider<PrefsStore>((ref) {
  throw UnimplementedError(
    'prefsStoreProvider precisa ser sobrescrito no main() com PrefsStore.open().',
  );
});

/// Preferências de feedback (vibração e som) consumidas pelos serviços.
///
/// `core/` não conhece a feature de configurações. Em vez de importá-la
/// (o que criaria dependência circular), o core declara esta "porta" e
/// o `main.dart` a liga às configurações do usuário com um override —
/// inversão de dependência (o "D" do SOLID).
class FeedbackPreferences {
  const FeedbackPreferences({this.haptics = true, this.sound = true});

  final bool haptics;
  final bool sound;
}

final feedbackPreferencesProvider = Provider<FeedbackPreferences>(
  (ref) => const FeedbackPreferences(),
);

/// Vibração. Vira no-op quando o usuário desliga em Configurações.
final hapticsServiceProvider = Provider<HapticsService>((ref) {
  return HapticsService(enabled: ref.watch(feedbackPreferencesProvider).haptics);
});

/// Som de conclusão. O player é liberado quando o provider é recriado
/// (antes, cada mudança nas configurações vazava um `AudioPlayer`).
final soundServiceProvider = Provider<SoundService>((ref) {
  final service =
      SoundService(enabled: ref.watch(feedbackPreferencesProvider).sound);
  ref.onDispose(service.dispose);
  return service;
});

/// Avisos do sistema. Padrão sem efeito (testes); o `main.dart` liga a
/// implementação com o plugin de notificações.
final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => const NoopNotificationScheduler(),
);

/// O usuário quer o aviso de fim do foco? "Porta" como a
/// [FeedbackPreferences]: o `main.dart` liga às configurações.
final focusAlertEnabledProvider = Provider<bool>((ref) => true);

/// Mantém a tela acesa durante o timer de foco.
final wakelockServiceProvider = Provider<WakelockService>(
  (ref) => const WakelockService(),
);

/// Relógio do app. Quem precisa de "agora" com hora (o timer de foco)
/// lê daqui em vez de chamar `DateTime.now()` — os testes avançam o
/// tempo sem esperar de verdade.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((ref) => DateTime.now);

/// Data de hoje (sem hora), atualizada quando o dia vira.
///
/// Todas as regras que dependem de "hoje" leem daqui. Isso dá uma chave
/// estável para os providers (antes `DateTime.now()` com segundos virava
/// chave nova a cada build) e permite fixar a data nos testes.
///
/// A virada é detectada comparando com o relógio a cada minuto, e também
/// ao voltar do segundo plano (`DayRollover`). Antes era um único `Timer`
/// agendado para a meia-noite: com o celular dormindo, esse timer atrasava
/// (o relógio dele para durante o sono do aparelho) e o app amanhecia
/// mostrando o dia anterior, com as tarefas de ontem ainda na tela.
final todayProvider = Provider<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  final today = dateOnly(clock());
  final timer = Timer.periodic(const Duration(minutes: 1), (_) {
    if (!isSameDay(clock(), today)) ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);
  return today;
});
