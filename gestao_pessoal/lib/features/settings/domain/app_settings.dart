import 'dart:convert';

import '../../../core/constants/app_style.dart';
import 'notification_settings.dart';

export '../../../core/constants/app_style.dart';
export 'notification_settings.dart';

/// Modo de renderização do fundo da tela.
///
/// - [animated]: gradiente com blobs em loop infinito (default).
/// - [solid]: cor única estática, sem animação (mais leve p/ bateria).
enum WallpaperMode {
  animated,
  solid;

  String get label => switch (this) {
        WallpaperMode.animated => 'Gradiente animado',
        WallpaperMode.solid => 'Cor sólida',
      };

  String get description => switch (this) {
        WallpaperMode.animated =>
          'Blobs de gradiente se movem em loop infinito no fundo.',
        WallpaperMode.solid =>
          'Fundo com uma cor única fixa. Mais leve para a bateria.',
      };
}

/// Modelo imutável de configurações do app.
///
/// Persistido em `SharedPreferences` na chave [PrefsKeys.settings] como JSON.
class AppSettings {
  const AppSettings({
    required this.style,
    required this.wallpaperMode,
    required this.wallpaperSeed,
    required this.wallpaperSolidColor,
    required this.wallpaperSaturation,
    required this.blobIntensity,
    required this.hapticsEnabled,
    required this.textColor,
    required this.accentColor,
    required this.soundEnabled,
    required this.pomodoroFocusColor,
    required this.pomodoroShortBreakColor,
    required this.pomodoroLongBreakColor,
    this.notifications = NotificationSettings.defaults,
  });

  /// Estilo visual global (Editorial ou Liquid Glass).
  final AppStyle style;

  /// Modo de fundo do Liquid Glass: animado (gradiente) ou sólido.
  final WallpaperMode wallpaperMode;

  /// Cor-base dos blobs do background em HEX (ex: `#8B5CF6`).
  final String wallpaperSeed;

  /// Cor única usada quando [wallpaperMode] é [WallpaperMode.solid].
  final String wallpaperSolidColor;

  /// Saturação dos blobs (0.0 – 1.0).
  final double wallpaperSaturation;

  /// Intensidade/opacidade dos blobs (0.0 – 1.0).
  final double blobIntensity;

  /// Se `true`, vibra a cada interação marcante (concluir tarefa,
  /// hábito, tap em botões). `false` desativa todo feedback tátil.
  final bool hapticsEnabled;

  /// Cor das letras em HEX (ex: `#FFFFFF`). Só vale no Liquid Glass —
  /// no editorial o texto é sempre grafite para contrastar com o creme.
  final String textColor;

  /// Cor de destaque (accent) em HEX. Padrão depende do estilo: coral
  /// (`#E4553F`) no editorial, lilás (`#A78BFA`) no Liquid Glass. Usada
  /// no FAB, números grandes, check buttons, prioridade, aba ativa etc.
  final String accentColor;

  /// Se `true`, toca som de "ding" ao concluir tarefa/hábito.
  final bool soundEnabled;

  /// Cor do anel e label do modo **Foco** no Pomodoro.
  final String pomodoroFocusColor;

  /// Cor do anel e label do modo **Pausa Curta** no Pomodoro.
  final String pomodoroShortBreakColor;

  /// Cor do anel e label do modo **Pausa Longa** no Pomodoro.
  final String pomodoroLongBreakColor;

  /// Avisos e lembretes (RF-NT-07).
  final NotificationSettings notifications;

  static const defaults = AppSettings(
    style: AppStyle.editorial,
    wallpaperMode: WallpaperMode.animated,
    wallpaperSeed: '#7C5CFF',
    wallpaperSolidColor: '#0B0D1A',
    wallpaperSaturation: 1.0,
    blobIntensity: 0.35,
    hapticsEnabled: true,
    textColor: '#FFFFFF',
    accentColor: '#E4553F',
    soundEnabled: true,
    pomodoroFocusColor: '#E4553F',
    pomodoroShortBreakColor: '#4F8A83',
    pomodoroLongBreakColor: '#D9A441',
  );

  AppSettings copyWith({
    AppStyle? style,
    WallpaperMode? wallpaperMode,
    String? wallpaperSeed,
    String? wallpaperSolidColor,
    double? wallpaperSaturation,
    double? blobIntensity,
    bool? hapticsEnabled,
    bool? soundEnabled,
    String? textColor,
    String? accentColor,
    String? pomodoroFocusColor,
    String? pomodoroShortBreakColor,
    String? pomodoroLongBreakColor,
    NotificationSettings? notifications,
  }) {
    return AppSettings(
      style: style ?? this.style,
      wallpaperMode: wallpaperMode ?? this.wallpaperMode,
      wallpaperSeed: wallpaperSeed ?? this.wallpaperSeed,
      wallpaperSolidColor: wallpaperSolidColor ?? this.wallpaperSolidColor,
      wallpaperSaturation: wallpaperSaturation ?? this.wallpaperSaturation,
      blobIntensity: blobIntensity ?? this.blobIntensity,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      textColor: textColor ?? this.textColor,
      accentColor: accentColor ?? this.accentColor,
      pomodoroFocusColor: pomodoroFocusColor ?? this.pomodoroFocusColor,
      pomodoroShortBreakColor:
          pomodoroShortBreakColor ?? this.pomodoroShortBreakColor,
      pomodoroLongBreakColor:
          pomodoroLongBreakColor ?? this.pomodoroLongBreakColor,
      notifications: notifications ?? this.notifications,
    );
  }

  Map<String, dynamic> toJson() => {
        'style': style.name,
        'wallpaperMode': wallpaperMode.name,
        'wallpaperSeed': wallpaperSeed,
        'wallpaperSolidColor': wallpaperSolidColor,
        'wallpaperSaturation': wallpaperSaturation,
        'blobIntensity': blobIntensity,
        'hapticsEnabled': hapticsEnabled,
        'soundEnabled': soundEnabled,
        'textColor': textColor,
        'accentColor': accentColor,
        'pomodoroFocusColor': pomodoroFocusColor,
        'pomodoroShortBreakColor': pomodoroShortBreakColor,
        'pomodoroLongBreakColor': pomodoroLongBreakColor,
        'notifications': notifications.toJson(),
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    const d = AppSettings.defaults;
    final modeName = json['wallpaperMode'] as String?;
    final mode = WallpaperMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => d.wallpaperMode,
    );
    final styleName = json['style'] as String?;
    final style = AppStyle.values.firstWhere(
      (s) => s.name == styleName,
      orElse: () => AppStyle.editorial,
    );

    // Migração do visual antigo "Dark/Green": cores que eram o padrão
    // antigo viram o novo padrão (quem personalizou mantém a escolha).
    String migrate(String? value, List<String> oldDefaults, String fallback) {
      if (value == null) return fallback;
      return oldDefaults.contains(value.toUpperCase()) ? fallback : value;
    }

    final isLegacy = styleName == null;
    return AppSettings(
      style: style,
      wallpaperMode: mode,
      wallpaperSeed: migrate(json['wallpaperSeed'] as String?,
          isLegacy ? ['#00E676', '#8B5CF6'] : [], d.wallpaperSeed),
      wallpaperSolidColor: migrate(json['wallpaperSolidColor'] as String?,
          isLegacy ? ['#0D0D0D', '#0F172A'] : [], d.wallpaperSolidColor),
      wallpaperSaturation:
          (json['wallpaperSaturation'] as num?)?.toDouble() ?? 1.0,
      blobIntensity: isLegacy
          ? d.blobIntensity
          : (json['blobIntensity'] as num?)?.toDouble() ?? d.blobIntensity,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      textColor: json['textColor'] as String? ?? d.textColor,
      accentColor: migrate(json['accentColor'] as String?,
          isLegacy ? ['#00E676'] : [], style.defaultAccentHex),
      pomodoroFocusColor: migrate(json['pomodoroFocusColor'] as String?,
          isLegacy ? ['#00E676', '#F43F5E'] : [], d.pomodoroFocusColor),
      pomodoroShortBreakColor: migrate(
          json['pomodoroShortBreakColor'] as String?,
          isLegacy ? ['#00B85A', '#06B6D4'] : [],
          d.pomodoroShortBreakColor),
      pomodoroLongBreakColor: migrate(
          json['pomodoroLongBreakColor'] as String?,
          isLegacy ? ['#1A4D2E', '#34D399'] : [],
          d.pomodoroLongBreakColor),
      notifications: NotificationSettings.fromJson(
        json['notifications'] as Map<String, dynamic>?,
      ),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  static AppSettings fromJsonString(String? source) {
    if (source == null || source.isEmpty) return defaults;
    try {
      final raw = jsonDecode(source);
      if (raw is Map<String, dynamic>) return AppSettings.fromJson(raw);
    } catch (_) {}
    return defaults;
  }
}
