import 'package:flutter/material.dart';

import '../utils/color_hex.dart';
import 'app_colors.dart';
import 'app_style.dart';

/// Tema central do Ritmo — um por [AppStyle].
///
/// - **Editorial**: tema claro, fonte **Jost** (geométrica, embutida em
///   `assets/fonts`), títulos em peso leve, accent coral, botões em
///   pílula grafite.
/// - **Liquid Glass**: tema escuro, fonte **DM Sans**, superfícies
///   translúcidas, accent configurável e cor de texto personalizável.
class AppTheme {
  AppTheme._();


  /// Monta o tema do [style]. `textColorHex` só vale no Liquid Glass
  /// (no editorial o texto é sempre tinta grafite para manter contraste
  /// com o papel creme).
  static ThemeData build({
    required AppStyle style,
    String? textColorHex,
    String? accentColorHex,
  }) {
    final p = AppPalette.forStyle(style);
    final accent = colorFromHex(accentColorHex ?? style.defaultAccentHex);
    final foreground = style.isGlass
        ? colorFromHex(textColorHex ?? '#FFFFFF')
        : p.textPrimary;
    final onAccent = AppColors.onColor(accent);

    // Fontes embutidas em assets/fonts (sem download em tempo de execução).
    final family = style.isGlass ? 'DMSans' : 'Jost';

    final base = ThemeData(
      useMaterial3: true,
      brightness: style.isGlass ? Brightness.dark : Brightness.light,
      // Fonte base do app inteiro — inclusive widgets que não herdam do
      // textTheme (dropdowns, campos com `style` próprio).
      fontFamily: family,
    );

    TextStyle font(double size, FontWeight weight, {double? height, double? spacing}) {
      final s = TextStyle(
        color: foreground,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing,
      );
      return s.copyWith(fontFamily: family);
    }

    // Editorial usa títulos leves (como capa de revista); glass, mais
    // encorpados para ler bem sobre o vidro.
    final display = style.isGlass ? FontWeight.w700 : FontWeight.w300;
    final heading = style.isGlass ? FontWeight.w600 : FontWeight.w400;

    final textTheme = TextTheme(
      displayLarge: font(56, display, height: 1.0, spacing: -1),
      displayMedium: font(44, display, height: 1.05),
      displaySmall: font(36, display, height: 1.1),
      headlineLarge: font(34, heading, height: 1.15),
      headlineMedium: font(30, heading, height: 1.15),
      headlineSmall: font(24, heading, height: 1.2),
      titleLarge: font(21, heading, height: 1.25),
      titleMedium: font(17, FontWeight.w500, height: 1.3),
      titleSmall: font(15, FontWeight.w500, height: 1.35),
      bodyLarge: font(16, FontWeight.w400, height: 1.5),
      bodyMedium: font(14, FontWeight.w400, height: 1.5),
      bodySmall: font(13, FontWeight.w400, height: 1.45),
      labelLarge: font(14, FontWeight.w500, height: 1.3),
      labelMedium: font(12, FontWeight.w500, height: 1.3),
      labelSmall: font(11, FontWeight.w500, height: 1.3, spacing: 0.3),
    );

    final colorScheme = (style.isGlass
            ? ColorScheme.dark(
                primary: accent,
                secondary: accent,
                surface: const Color(0xFF181B30),
                onSurface: foreground,
              )
            : ColorScheme.light(
                primary: accent,
                secondary: p.panel,
                surface: p.surface,
                onSurface: p.textPrimary,
                surfaceContainerHighest: p.surface2,
                outline: p.border,
                outlineVariant: p.border,
              ))
        .copyWith(
      onPrimary: onAccent,
      error: const Color(0xFFC0392B),
      onError: Colors.white,
    );

    final pill = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
    );
    final dialogSurface =
        style.isGlass ? const Color(0xF0161930) : p.surface;

    return base.copyWith(
      // Paleta do estilo publicada no tema: widgets leem `context.palette`.
      extensions: [p],
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: style.isGlass ? const Color(0xFF161930) : p.surface,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: foreground),
      dividerColor: p.border,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: foreground),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          side: BorderSide(color: p.border, width: 1),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: foreground,
        textColor: foreground,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle:
            textTheme.bodySmall?.copyWith(color: p.textSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: style.isGlass ? accent : p.panel,
          foregroundColor: style.isGlass ? onAccent : p.onPanel,
          shape: pill,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: style.isGlass ? foreground : p.textPrimary,
          shape: pill,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(color: p.border),
          shape: pill,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(pill),
          side: WidgetStatePropertyAll(BorderSide(color: p.border)),
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? (style.isGlass ? accent : p.panel)
                  : Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? (style.isGlass ? onAccent : p.onPanel)
                  : p.textSecondary),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: style.isGlass ? accent : p.panel,
        labelStyle: textTheme.labelLarge?.copyWith(color: p.textSecondary),
        secondaryLabelStyle:
            textTheme.labelLarge?.copyWith(color: p.onPanel),
        side: BorderSide(color: p.border),
        shape: pill,
        showCheckmark: false,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onAccent;
          return p.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return p.surface2;
        }),
        trackOutlineColor: WidgetStatePropertyAll(p.border),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: onAccent,
        elevation: style.isGlass ? 6 : 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppColors.space5,
          vertical: AppColors.space3,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: p.textTertiary),
        labelStyle: textTheme.bodyLarge?.copyWith(color: p.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: BorderSide(color: p.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: BorderSide(color: p.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: p.border,
        thumbColor: accent,
        overlayColor: accent.withValues(alpha: 0.15),
        trackHeight: 3,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dialogSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          side: BorderSide(color: p.border, width: 1),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: dialogSurface,
        surfaceTintColor: Colors.transparent,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: dialogSurface,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: dialogSurface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dialogSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppColors.radiusLg),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: style.isGlass ? const Color(0xF0161930) : p.panel,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: p.onPanel),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: p.surface2,
      ),
    );
  }
}
