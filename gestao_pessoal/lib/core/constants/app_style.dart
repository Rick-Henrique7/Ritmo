/// Estilo visual global do Ritmo, escolhido em Configurações.
///
/// - [editorial]: papel creme, tinta grafite, círculos coral e painéis
///   escuros — inspirado em layouts editoriais / Bauhaus. É o padrão.
/// - [liquidGlass]: fundo escuro com blobs animados e superfícies de
///   vidro fosco (blur + borda com reflexo de luz).
enum AppStyle {
  editorial,
  liquidGlass;

  String get label => switch (this) {
        AppStyle.editorial => 'Editorial',
        AppStyle.liquidGlass => 'Liquid Glass',
      };

  String get description => switch (this) {
        AppStyle.editorial =>
          'Papel creme, tipografia leve, círculos coral e painéis grafite.',
        AppStyle.liquidGlass =>
          'Fundo escuro animado com cartões de vidro fosco translúcido.',
      };

  /// Cor de destaque padrão de cada estilo (aplicada ao trocar de estilo).
  String get defaultAccentHex => switch (this) {
        AppStyle.editorial => '#E4553F',
        AppStyle.liquidGlass => '#A78BFA',
      };

  bool get isGlass => this == AppStyle.liquidGlass;
}
