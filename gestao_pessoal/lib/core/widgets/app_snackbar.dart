import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Snackbar padronizado do Ritmo — usado para "Desfazer" exclusões
/// de hábitos/tarefas.
///
/// Visual:
/// - Fundo grafite (editorial) ou vidro escuro opaco (glass)
/// - Texto `onPanel`
/// - Ícone à esquerda em `accent` (configurável pelo usuário)
/// - Ação "Desfazer" em `accent` (configurável pelo usuário)
/// - `behavior: floating` com margem inferior para não cobrir a nav bar
/// - Raio 12px (radius-sm) e leve sombra (depth via surface-2 vs background)
///
/// Comportamento:
/// - 4 segundos (padrão Material 3) — o usuário tem tempo de ler e decidir
/// - Tocar em "Desfazer" chama o callback E fecha explicitamente o snackbar
///   (senão fica "travado" até o timeout expirar, sensação de bug)
/// - `dismissDirection` permite arrastar para cima para fechar
class AppUndoSnackBar {
  AppUndoSnackBar._();

  /// Mostra um snackbar com ação "Desfazer" padronizada.
  ///
  /// - [icon]: ícone à esquerda (ex: `Icons.delete_outline`)
  /// - [message]: texto principal
  /// - [onUndo]: callback ao tocar em "Desfazer". Após executar,
  ///   o snackbar é fechado explicitamente.
  static void show(
    BuildContext context, {
    required IconData icon,
    required String message,
    required VoidCallback onUndo,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: context.palette.onPanel,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            context.palette.isGlass ? const Color(0xF0161930) : context.palette.panel,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 84), // 84px = nav bar safe-area
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: context.palette.isGlass
              ? BorderSide(color: context.palette.border, width: 1)
              : BorderSide.none,
        ),
        duration: const Duration(seconds: 4),
        dismissDirection: DismissDirection.up,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: accent,
          onPressed: () {
            onUndo();
            // Fecha explicitamente — sem isso o snackbar fica "travado"
            // até o timeout expirar (sensação de bug).
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
