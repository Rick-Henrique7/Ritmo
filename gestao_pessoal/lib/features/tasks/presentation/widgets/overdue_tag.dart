import 'package:flutter/material.dart';

/// Etiqueta pequena "Atrasada" para tarefas de dias anteriores ainda não
/// feitas. Cor de destaque em contorno: chama atenção sem alarmar.
class OverdueTag extends StatelessWidget {
  const OverdueTag({super.key, this.color});

  /// Padrão: cor de destaque do tema.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c, width: 1),
      ),
      child: Text(
        'Atrasada',
        style: TextStyle(
          color: c,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}
