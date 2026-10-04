import 'package:flutter/material.dart';

import 'app_style.dart';

/// Paleta de cores de um estilo visual, publicada no tema como
/// [ThemeExtension].
///
/// Widgets leem com `context.palette` — assim reagem sozinhos quando o
/// estilo muda (o Flutter reconstrói quem depende do `Theme`). Antes a
/// paleta era um campo estático global trocado em runtime, o que exigia
/// recriar a árvore inteira e não funcionava fora do `MaterialApp`.
/// Ver `docs/adr/0006-palette-como-theme-extension.md`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.style,
    required this.background,
    required this.surface,
    required this.surface2,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.panel,
    required this.onPanel,
    required this.onPanelMuted,
    required this.decoration,
    required this.isDark,
  });

  /// Estilo que originou a paleta.
  final AppStyle style;

  /// Fundo da tela.
  final Color background;

  /// Superfície padrão de cards.
  final Color surface;

  /// Superfície elevada (chips, campos, trilhas de progresso).
  final Color surface2;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Linhas finas, bordas e divisores.
  final Color border;

  /// Painel de destaque (grafite no editorial, vidro forte no glass).
  final Color panel;
  final Color onPanel;
  final Color onPanelMuted;

  /// Cor do traço das formas decorativas (círculos, hachuras).
  final Color decoration;

  final bool isDark;

  bool get isGlass => style == AppStyle.liquidGlass;

  /// Superfície elevada (nome antigo, mantido por clareza nas telas).
  Color get surfaceElevated => surface2;
  Color get glassBorder => border;

  /// Véu translúcido no sentido do texto (escurece no claro, clareia no
  /// escuro). Substitui `Colors.white.withValues(alpha: x)`, que some no
  /// estilo editorial.
  Color veil(double alpha) => textPrimary.withValues(alpha: alpha);

  /// Editorial — papel creme, tinta grafite, painéis escuros.
  static const editorial = AppPalette(
    style: AppStyle.editorial,
    background: Color(0xFFEDE5D8),
    surface: Color(0xFFF6F0E6),
    surface2: Color(0xFFE3D9CA),
    textPrimary: Color(0xFF2E2D2B),
    textSecondary: Color(0xFF6E685F),
    textTertiary: Color(0xFF9C958A),
    border: Color(0xFFD3C8B8),
    panel: Color(0xFF3B3A39),
    onPanel: Color(0xFFF2EBE0),
    onPanelMuted: Color(0xFFB5AEA3),
    decoration: Color(0xFF2E2D2B),
    isDark: false,
  );

  /// Liquid Glass — noite azulada com vidro translúcido.
  static const liquidGlass = AppPalette(
    style: AppStyle.liquidGlass,
    background: Color(0xFF0B0D1A),
    surface: Color(0x1AFFFFFF),
    surface2: Color(0x24FFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFBFC3DD),
    textTertiary: Color(0xFF8E93B5),
    border: Color(0x33FFFFFF),
    panel: Color(0x2EFFFFFF),
    onPanel: Color(0xFFFFFFFF),
    onPanelMuted: Color(0xFFBFC3DD),
    decoration: Color(0xFFFFFFFF),
    isDark: true,
  );

  static AppPalette forStyle(AppStyle style) => switch (style) {
        AppStyle.editorial => editorial,
        AppStyle.liquidGlass => liquidGlass,
      };

  /// Paleta do tema atual. Fora de um tema do app (ex.: um widget
  /// testado isolado) cai no editorial em vez de quebrar.
  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? editorial;

  @override
  AppPalette copyWith({
    AppStyle? style,
    Color? background,
    Color? surface,
    Color? surface2,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? panel,
    Color? onPanel,
    Color? onPanelMuted,
    Color? decoration,
    bool? isDark,
  }) {
    return AppPalette(
      style: style ?? this.style,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      panel: panel ?? this.panel,
      onPanel: onPanel ?? this.onPanel,
      onPanelMuted: onPanelMuted ?? this.onPanelMuted,
      decoration: decoration ?? this.decoration,
      isDark: isDark ?? this.isDark,
    );
  }

  /// Interpolação usada pelo `AnimatedTheme` ao trocar de estilo.
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      style: t < 0.5 ? style : other.style,
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surface2: c(surface2, other.surface2),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textTertiary: c(textTertiary, other.textTertiary),
      border: c(border, other.border),
      panel: c(panel, other.panel),
      onPanel: c(onPanel, other.onPanel),
      onPanelMuted: c(onPanelMuted, other.onPanelMuted),
      decoration: c(decoration, other.decoration),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// Atalhos: `context.palette.textPrimary`, `context.accent`.
extension AppPaletteContext on BuildContext {
  AppPalette get palette => AppPalette.of(this);

  /// Cor de destaque escolhida pelo usuário. O tema já a recebe como
  /// `colorScheme.primary`; ler daqui evita que uma feature importe as
  /// configurações só para pegar uma cor (ADR 0008).
  Color get accent => Theme.of(this).colorScheme.primary;

  /// Cor de texto do tema (no Liquid Glass, a escolhida pelo usuário).
  Color get foreground => Theme.of(this).colorScheme.onSurface;
}

/// Tokens que **não** dependem do estilo: espaçamento, raios e uma
/// função pura de contraste. Cores por estilo ficam em [AppPalette].
abstract final class AppColors {
  /// Texto legível sobre uma cor sólida qualquer (ex.: accent).
  static Color onColor(Color c) =>
      c.computeLuminance() > 0.55 ? const Color(0xFF2E2D2B) : Colors.white;

  // === Spacing scale (4px base) ===
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;

  // === Border radius scale ===
  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
}
