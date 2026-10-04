import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../core/widgets/liquid_glass_card.dart';

/// Abre o seletor de cor partindo de [currentHex]. Devolve o novo HEX
/// (`#RRGGBB`) ou `null` se o usuário cancelar.
Future<String?> pickColorHex(BuildContext context, String currentHex) async {
  final picked = await showDialog<Color>(
    context: context,
    builder: (_) => ColorPickerDialog(initial: colorFromHex(currentHex)),
  );
  return picked == null ? null : colorToHex(picked);
}

/// Diálogo com roda de cores e paleta primária (flex_color_picker).
class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key, required this.initial});
  final Color initial;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escolha uma cor',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: context.palette.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // ColorPicker da flex_color_picker
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: ColorPicker(
                  color: _current,
                  onColorChanged: (c) => _current = c,
                  width: 38,
                  height: 38,
                  borderRadius: 19,
                  spacing: 4,
                  runSpacing: 4,
                  wheelDiameter: 160,
                  heading: Text(
                    'Selecione',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                  ),
                  subheading: Text(
                    'Cor',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                  ),
                  wheelSubheading: Text(
                    'Tom',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                  ),
                  showMaterialName: false,
                  showColorName: false,
                  showColorCode: true,
                  copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                    copyButton: false,
                    pasteButton: false,
                    longPressMenu: false,
                  ),
                  pickersEnabled: const {
                    ColorPickerType.wheel: true,
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: false,
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _current),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
