import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Campo de entrada flat dark do Ritmo.
///
/// Design system "Financial App — Dark/Green":
/// - Background: `#1C1C1C` (surface-2)
/// - Border: 1px `#1E1E1E` (border)
/// - Border focused: 1.5px accent (configurável pelo usuário)
/// - Radius: 16px (radius-md)
/// - Texto: 15px, weight 400 (DM Sans via tema)
/// - Hint: `#7A7A7A` (text-secondary)
class GlassInputField extends StatelessWidget {
  const GlassInputField({
    super.key,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: context.palette.textPrimary,
          ),
      cursorColor: accent,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: context.palette.textTertiary,
            ),
        filled: true,
        fillColor: context.palette.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppColors.space5,
          vertical: AppColors.space3 + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: BorderSide(color: context.palette.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: BorderSide(color: context.palette.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }
}
