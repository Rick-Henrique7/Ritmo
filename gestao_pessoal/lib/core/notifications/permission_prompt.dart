import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/prefs_keys.dart';
import '../providers/core_providers.dart';

/// Pede a permissão de notificação **uma vez**, no momento em que ela faz
/// sentido: logo depois de o usuário criar algo com horário (RF-NT-07).
///
/// Antes do pedido do Android, uma frase explica o motivo — a recomendação
/// do próprio Google para não assustar com um pedido sem contexto.
Future<void> askNotificationPermissionOnce(
  BuildContext context,
  WidgetRef ref,
) async {
  final scheduler = ref.read(notificationSchedulerProvider);
  if (await scheduler.isPermitted()) return;
  try {
    final store = ref.read(prefsStoreProvider);
    if (store.readRaw(PrefsKeys.notificationPermissionAsked) == 'true') return;
    await store.writeRaw(PrefsKeys.notificationPermissionAsked, 'true');
  } catch (_) {
    return; // sem armazenamento (testes)
  }
  if (!context.mounted) return;

  final accept = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Ativar avisos?'),
      content: const Text(
        'O Daily Flow pode avisar no horário das tarefas e dos hábitos, e '
        'mandar um resumo de manhã e das pendências à noite. Tudo é '
        'agendado no seu celular; nada sai dele.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Agora não'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Ativar'),
        ),
      ],
    ),
  );
  if (accept == true) await scheduler.requestPermission();
}
