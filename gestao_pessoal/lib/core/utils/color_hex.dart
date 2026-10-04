import 'dart:ui' show Color;

/// Converte `#RRGGBB` (ou `RRGGBB`) em [Color] opaca. Valor inválido vira
/// preto em vez de lançar exceção — dado vindo do armazenamento não deve
/// derrubar a tela.
Color colorFromHex(String hex) {
  final clean = hex.replaceAll('#', '').trim();
  final value = int.tryParse(clean.length == 6 ? 'FF$clean' : clean, radix: 16);
  return Color(value ?? 0xFF000000);
}

/// Converte [color] em `#RRGGBB` maiúsculo (ignora a transparência).
String colorToHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
