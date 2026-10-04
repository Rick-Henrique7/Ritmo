import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'liquid_glass_card.dart';

/// Pergunta "Excluir …?" padronizada. Devolve `true` se confirmado,
/// `false` se cancelado e `null` se fechado tocando fora.
///
/// [details] mostra um aviso extra abaixo da mensagem (ex.: tarefa
/// recorrente). Antes havia três cópias deste diálogo.
Future<bool?> showConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String message,
  Widget? details,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      final palette = ctx.palette;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: LiquidGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.delete_outline, color: palette.textPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(color: palette.textSecondary, fontSize: 14),
              ),
              if (details != null) ...[
                const SizedBox(height: 12),
                details,
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.surface2,
                      foregroundColor: palette.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Excluir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
