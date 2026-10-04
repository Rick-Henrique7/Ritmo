import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/core_providers.dart';
import '../features/habits/data/habits_controller.dart';
import '../features/reminders/data/notification_actions.dart';
import '../features/reminders/data/prefs_snoozes_repository.dart';
import '../features/reminders/data/reminder_sync.dart';
import '../features/tasks/data/tasks_controller.dart';

/// Mantém o app igual ao que está gravado, mesmo quando outra parte do
/// sistema mexe nos dados (RF-NT-06, RF-NT-08).
///
/// - A ação "Concluir" de uma notificação grava num isolate separado; ele
///   manda um sinal por [reminderSyncPortName] e o app relê os dados na hora.
/// - Ao voltar do segundo plano, relê também (caso o sinal tenha se perdido).
/// - Liga o reagendamento dos avisos ([reminderSyncProvider]).
class ExternalChangesSync extends ConsumerStatefulWidget {
  const ExternalChangesSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ExternalChangesSync> createState() =>
      _ExternalChangesSyncState();
}

class _ExternalChangesSyncState extends ConsumerState<ExternalChangesSync> {
  final _port = ReceivePort();
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    IsolateNameServer.removePortNameMapping(reminderSyncPortName);
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      reminderSyncPortName,
    );
    _port.listen((_) => unawaited(_reload()));
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_reload()));
  }

  Future<void> _reload() async {
    try {
      await ref.read(prefsStoreProvider).reload();
    } catch (_) {
      return; // sem armazenamento real (testes): nada a recarregar
    }
    if (!mounted) return;
    ref
      ..invalidate(tasksProvider)
      ..invalidate(habitsProvider)
      ..invalidate(snoozesRepositoryProvider);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    IsolateNameServer.removePortNameMapping(reminderSyncPortName);
    _port.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(reminderSyncProvider);
    return widget.child;
  }
}
