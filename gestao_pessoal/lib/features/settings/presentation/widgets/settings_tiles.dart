import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../core/widgets/liquid_glass_card.dart';

/// Título de seção da tela de Configurações.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 28, 4, 12),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: context.palette.textPrimary),
      ),
    );
  }
}

/// Card de uma cor configurável: amostra, código HEX, botão "Escolher" e,
/// opcionalmente, "Restaurar padrão". Antes eram quatro cópias quase
/// iguais na tela (cor dos blobs, do fundo sólido, do texto e de destaque).
class ColorSettingCard extends StatelessWidget {
  const ColorSettingCard({
    super.key,
    required this.title,
    required this.description,
    required this.hex,
    required this.onPick,
    this.onReset,
    this.resetMessage,
  });

  final String title;
  final String description;
  final String hex;
  final VoidCallback onPick;

  /// Se definido, mostra "Restaurar padrão".
  final Future<void> Function()? onReset;

  /// Mensagem da snackbar depois de restaurar.
  final String? resetMessage;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: palette.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorFromHex(hex),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border, width: 1.5),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  hex,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              FilledButton(onPressed: onPick, child: const Text('Escolher')),
            ],
          ),
          if (onReset != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await onReset!();
                  if (resetMessage != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(resetMessage!)),
                    );
                  }
                },
                icon: Icon(
                  Icons.restart_alt,
                  color: palette.textSecondary,
                  size: 18,
                ),
                label: Text(
                  'Restaurar padrão',
                  style: TextStyle(color: palette.textSecondary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Linha "bolinha de cor + rótulo" (cores do ciclo Pomodoro).
class ColorRow extends StatelessWidget {
  const ColorRow({
    super.key,
    required this.label,
    required this.hex,
    required this.onTap,
  });

  final String label;
  final String hex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorFromHex(hex),
                shape: BoxShape.circle,
                border: Border.all(color: palette.border, width: 1.5),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.tune, color: palette.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
