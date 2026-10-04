import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../data/settings_controller.dart';
import '../domain/app_settings.dart';
import 'widgets/color_picker_dialog.dart';
import 'widgets/notification_settings_card.dart';
import 'widgets/settings_tiles.dart';
import 'widgets/style_preview.dart';

/// Configurações: estilo visual, fundo (Liquid Glass), cores, feedback e
/// cores do timer. Cada bloco é um widget pequeno em `widgets/`.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Abre o seletor de cor e grava o resultado com [save].
  Future<void> _pick(
    BuildContext context,
    String currentHex,
    Future<void> Function(String hex) save,
  ) async {
    final hex = await pickColorHex(context, currentHex);
    if (hex != null) await save(hex);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          children: [
            ScreenHeader(
              eyebrow: 'Ajuste do seu jeito',
              title: 'Configurações',
              onBack: () => context.go('/'),
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
            ),

            // === Estilo visual ===
            const SettingsSectionHeader('Estilo visual'),
            Row(
              children: [
                for (final style in AppStyle.values) ...[
                  if (style != AppStyle.values.first) const SizedBox(width: 12),
                  Expanded(
                    child: StylePreview(
                      style: style,
                      selected: settings.style == style,
                      onTap: () => notifier.updateStyle(style),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              settings.style.description,
              style: TextStyle(color: palette.textSecondary, fontSize: 13),
            ),

            // === Fundo e texto (só no Liquid Glass) ===
            if (settings.style.isGlass) ...[
              const SettingsSectionHeader('Fundo'),
              _WallpaperModeCard(
                mode: settings.wallpaperMode,
                onChanged: notifier.updateWallpaperMode,
              ),
              const SizedBox(height: 12),
              if (settings.wallpaperMode == WallpaperMode.animated) ...[
                ColorSettingCard(
                  title: 'Cor do papel de parede',
                  description: 'Define a cor-base dos blobs animados no fundo.',
                  hex: settings.wallpaperSeed,
                  onPick: () => _pick(
                    context,
                    settings.wallpaperSeed,
                    notifier.updateWallpaperSeed,
                  ),
                ),
                const SizedBox(height: 12),
                _BlobIntensityCard(
                  value: settings.blobIntensity,
                  onChanged: notifier.updateBlobIntensity,
                ),
              ] else
                ColorSettingCard(
                  title: 'Cor do fundo',
                  description:
                      'Escolha uma cor única sólida para todo o fundo da tela.',
                  hex: settings.wallpaperSolidColor,
                  onPick: () => _pick(
                    context,
                    settings.wallpaperSolidColor,
                    notifier.updateWallpaperSolidColor,
                  ),
                ),
              const SizedBox(height: 12),
              ColorSettingCard(
                title: 'Cor do texto',
                description: 'Personaliza a cor das letras do app inteiro.',
                hex: settings.textColor,
                onPick: () => _pick(
                  context,
                  settings.textColor,
                  notifier.updateTextColor,
                ),
                onReset: notifier.resetTextColor,
                resetMessage: 'Cor do texto restaurada',
              ),
            ],

            // === Cores ===
            const SettingsSectionHeader('Cores'),
            ColorSettingCard(
              title: 'Cor de destaque',
              description: 'Usada no botão +, números grandes, prioridade '
                  'alta, conclusões, aba ativa e formas do fundo.',
              hex: settings.accentColor,
              onPick: () => _pick(
                context,
                settings.accentColor,
                notifier.updateAccentColor,
              ),
              onReset: notifier.resetAccentColor,
              resetMessage: 'Cor de destaque restaurada',
            ),

            // === Geral ===
            const SettingsSectionHeader('Geral'),
            LiquidGlassCard(
              child: Column(
                children: [
                  _SwitchTile(
                    value: settings.hapticsEnabled,
                    onChanged: notifier.updateHapticsEnabled,
                    title: 'Vibração ao tocar',
                    subtitle:
                        'Feedback tátil em cliques e conclusões de tarefa/hábito',
                  ),
                  Divider(height: 1, color: palette.border),
                  _SwitchTile(
                    value: settings.soundEnabled,
                    onChanged: notifier.updateSoundEnabled,
                    title: 'Som de conclusão',
                    subtitle: 'Toca um "ding" ao concluir uma tarefa, um hábito '
                        'ou uma sessão de foco',
                  ),
                ],
              ),
            ),

            // === Notificações ===
            const SettingsSectionHeader('Notificações'),
            const NotificationSettingsCard(),

            // === Timer de foco ===
            const SettingsSectionHeader('Timer de foco'),
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cores do ciclo Pomodoro',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toque para personalizar o anel de cada modo.',
                    style: TextStyle(color: palette.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ColorRow(
                    label: 'Foco',
                    hex: settings.pomodoroFocusColor,
                    onTap: () => _pick(
                      context,
                      settings.pomodoroFocusColor,
                      notifier.updatePomodoroFocusColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ColorRow(
                    label: 'Pausa curta',
                    hex: settings.pomodoroShortBreakColor,
                    onTap: () => _pick(
                      context,
                      settings.pomodoroShortBreakColor,
                      notifier.updatePomodoroShortBreakColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ColorRow(
                    label: 'Pausa longa',
                    hex: settings.pomodoroLongBreakColor,
                    onTap: () => _pick(
                      context,
                      settings.pomodoroLongBreakColor,
                      notifier.updatePomodoroLongBreakColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // === Restaurar tudo ===
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await notifier.resetDefaults();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configurações restauradas')),
                    );
                  }
                },
                icon: Icon(Icons.restart_alt, color: palette.textSecondary),
                label: Text(
                  'Restaurar padrões',
                  style: TextStyle(color: palette.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animado × sólido (Liquid Glass).
class _WallpaperModeCard extends StatelessWidget {
  const _WallpaperModeCard({required this.mode, required this.onChanged});

  final WallpaperMode mode;
  final ValueChanged<WallpaperMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estilo do fundo',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mode.description,
            style: TextStyle(color: palette.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SegmentedButton<WallpaperMode>(
            segments: [
              for (final m in WallpaperMode.values)
                ButtonSegment<WallpaperMode>(
                  value: m,
                  label: Text(m.label),
                  icon: Icon(
                    m == WallpaperMode.animated
                        ? Icons.auto_awesome_outlined
                        : Icons.format_color_fill_outlined,
                  ),
                ),
            ],
            selected: {mode},
            onSelectionChanged: (sel) => onChanged(sel.first),
          ),
        ],
      ),
    );
  }
}

/// Intensidade (opacidade) dos blobs animados.
class _BlobIntensityCard extends StatelessWidget {
  const _BlobIntensityCard({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intensidade dos blobs',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(color: palette.textSecondary),
              ),
            ],
          ),
          Slider(
            value: value,
            max: 0.7,
            divisions: 14,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: TextStyle(color: palette.textPrimary)),
      subtitle: Text(subtitle, style: TextStyle(color: palette.textSecondary)),
    );
  }
}
