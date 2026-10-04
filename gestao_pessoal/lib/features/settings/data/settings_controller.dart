import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_settings.dart';
import 'prefs_settings_repository.dart';

/// Notifier que mantém as configurações do app em memória e persiste
/// cada mudança em [PrefsKeys.settings].
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> _persist() => ref.read(settingsRepositoryProvider).save(state);

  /// Troca o estilo visual. Ao trocar, a cor de destaque volta para o
  /// padrão do novo estilo (coral no editorial, lilás no glass) — uma
  /// cor escolhida para fundo escuro raramente funciona no creme.
  Future<void> updateStyle(AppStyle style) async {
    if (style == state.style) return;
    var next = state.copyWith(
      style: style,
      accentColor: style.defaultAccentHex,
    );
    if (style.isGlass && next.blobIntensity < 0.1) {
      next = next.copyWith(
        blobIntensity: AppSettings.defaults.blobIntensity,
        wallpaperMode: WallpaperMode.animated,
      );
    }
    state = next;
    await _persist();
  }

  Future<void> updateWallpaperSeed(String hex) async {
    state = state.copyWith(wallpaperSeed: hex);
    await _persist();
  }

  Future<void> updateWallpaperSolidColor(String hex) async {
    state = state.copyWith(wallpaperSolidColor: hex);
    await _persist();
  }

  Future<void> updateWallpaperMode(WallpaperMode mode) async {
    state = state.copyWith(wallpaperMode: mode);
    await _persist();
  }

  Future<void> updateBlobIntensity(double intensity) async {
    state = state.copyWith(blobIntensity: intensity);
    await _persist();
  }

  Future<void> updateSaturation(double saturation) async {
    state = state.copyWith(wallpaperSaturation: saturation);
    await _persist();
  }

  Future<void> updateHapticsEnabled(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    await _persist();
  }

  Future<void> updateSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _persist();
  }

  Future<void> updateTextColor(String hex) async {
    state = state.copyWith(textColor: hex);
    await _persist();
  }

  /// Restaura a cor do texto para o default (`#FFFFFF`).
  Future<void> resetTextColor() async {
    state = state.copyWith(textColor: AppSettings.defaults.textColor);
    await _persist();
  }

  Future<void> updateAccentColor(String hex) async {
    state = state.copyWith(accentColor: hex);
    await _persist();
  }

  /// Restaura a cor de destaque para o padrão do estilo atual.
  Future<void> resetAccentColor() async {
    state = state.copyWith(accentColor: state.style.defaultAccentHex);
    await _persist();
  }

  Future<void> updatePomodoroFocusColor(String hex) async {
    state = state.copyWith(pomodoroFocusColor: hex);
    await _persist();
  }

  Future<void> updatePomodoroShortBreakColor(String hex) async {
    state = state.copyWith(pomodoroShortBreakColor: hex);
    await _persist();
  }

  Future<void> updatePomodoroLongBreakColor(String hex) async {
    state = state.copyWith(pomodoroLongBreakColor: hex);
    await _persist();
  }

  /// Avisos e lembretes (RF-NT-07).
  Future<void> updateNotifications(NotificationSettings value) async {
    state = state.copyWith(notifications: value);
    await _persist();
  }

  Future<void> resetDefaults() async {
    // Mantém o estilo escolhido; restaura o resto.
    final style = state.style;
    state = AppSettings.defaults.copyWith(
      style: style,
      accentColor: style.defaultAccentHex,
    );
    await _persist();
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
