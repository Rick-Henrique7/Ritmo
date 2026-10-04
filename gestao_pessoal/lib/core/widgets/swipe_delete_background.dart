import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Fundo revelado ao deslizar um item para a esquerda (excluir).
class SwipeDeleteBackground extends StatelessWidget {
  const SwipeDeleteBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, palette.surface2],
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Excluir',
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.delete_outline, color: palette.textPrimary, size: 22),
        ],
      ),
    );
  }
}
