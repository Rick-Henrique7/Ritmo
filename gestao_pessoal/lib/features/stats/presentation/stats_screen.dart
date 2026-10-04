import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../data/stats_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);
    final accent = context.accent;
    // Todas as contas vêm prontas do domínio (StatsCalculator).
    final summary = ref.watch(statsSummaryProvider);
    final completedTasks = summary.completedTasks;
    final totalMinutes = summary.focusMinutes;
    final streak = summary.bestStreak;
    final dailyBars = summary.bars;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          const ScreenHeader(
            eyebrow: 'Seu progresso',
            title: 'Estatísticas',
            padding: EdgeInsets.fromLTRB(4, 12, 4, 16),
          ),
          // Filtro de período (RF-ST-01)
          SegmentedButton<StatsPeriod>(
            segments: const [
              ButtonSegment(value: StatsPeriod.weekly, label: Text('Semana')),
              ButtonSegment(value: StatsPeriod.monthly, label: Text('Mês')),
              ButtonSegment(value: StatsPeriod.yearly, label: Text('Ano')),
            ],
            selected: {period},
            onSelectionChanged: (s) =>
                ref.read(statsPeriodProvider.notifier).state = s.first,
          ),
          const SizedBox(height: 16),

          // KPIs — painel com número grande + dois secundários
          LiquidGlassCard(
            panel: true,
            borderRadius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarefas concluídas',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: accent),
                ),
                Text(
                  completedTasks.toString().padLeft(2, '0'),
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(color: accent, fontSize: 80),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: context.palette.onPanel.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _KpiCard(
                        label: 'Minutos de foco',
                        value: '$totalMinutes',
                        icon: Icons.timer_outlined,
                      ),
                    ),
                    Expanded(
                      child: _KpiCard(
                        label: 'Maior sequência',
                        value: '$streak ${streak == 1 ? 'dia' : 'dias'}',
                        icon: Icons.local_fire_department_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Gráfico de barras (RF-ST-02) — customizado com Flutter puro
          // para evitar sobreposição de labels do fl_chart.
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produtividade diária',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _CustomBarChart(
                    data: dailyBars,
                    period: period,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Heatmap (RF-ST-03) — últimas 8 semanas
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consistência',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _Heatmap(days: summary.habitDays),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: context.palette.onPanelMuted, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: t.titleLarge?.copyWith(color: context.palette.onPanel),
              ),
              Text(
                label,
                style: t.labelMedium?.copyWith(color: context.palette.onPanelMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// BarChart customizado com Flutter puro.
///
/// Substitui o `BarChart` do fl_chart porque mesmo com `interval` no
/// SideTitles, a versão 0.68 ainda renderiza todos os labels
/// sobrepostos em eixos categóricos. Aqui controlamos exatamente
/// quantos labels aparecem com base no período selecionado.
class _CustomBarChart extends StatelessWidget {
  const _CustomBarChart({required this.data, required this.period});
  final List<DailyCount> data;
  final StatsPeriod period;

  /// Quais índices de data devem mostrar label no eixo X.
  List<int> _labelIndices() {
    if (data.isEmpty) return const [];
    final n = data.length;
    return switch (period) {
      StatsPeriod.weekly =>
        List.generate(n, (i) => i), // todos os 7
      StatsPeriod.monthly => [
        for (var i = 0; i < n; i++) if (i % 5 == 0) i,
        if (n - 1 % 5 != 0 && !((n - 1) % 5 == 0)) n - 1,
      ],
      StatsPeriod.yearly => List.generate(n, (i) => i),
    };
  }

  String _labelFor(DateTime day) {
    return switch (period) {
      StatsPeriod.weekly =>
        DateFormat('E', 'pt_BR').format(day).substring(0, 1),
      StatsPeriod.monthly => '${day.day}',
      StatsPeriod.yearly => DateFormat('MMM', 'pt_BR').format(day),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Sem dados',
          style: TextStyle(color: context.palette.textSecondary),
        ),
      );
    }
    final accent = context.accent;
    final accentDim = HSVColor.fromColor(accent).withValue(0.7).toColor();
    final maxValue =
        data.fold<int>(0, (acc, e) => e.count > acc ? e.count : acc);
    final labelsToShow = _labelIndices().toSet();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < data.length; i++) ...[
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          margin: EdgeInsets.symmetric(
                            horizontal: data.length > 12 ? 1 : 6,
                          ),
                          duration: const Duration(milliseconds: 400),
                          height: maxValue == 0
                              ? 4
                              : (data[i].count / maxValue) *
                                  (constraints.maxHeight - 20) +
                                  4,
                          decoration: BoxDecoration(
                            // Editorial: barras grafite e o melhor dia em
                            // accent. Glass: fade de opacidade do accent.
                            color: context.palette.isGlass
                                ? null
                                : (data[i].count == maxValue && maxValue > 0
                                    ? accent
                                    : context.palette.textPrimary
                                        .withValues(alpha: 0.75)),
                            gradient: context.palette.isGlass
                                ? LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [accentDim, accent],
                                  )
                                : null,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 18,
              child: Row(
                children: [
                  for (var i = 0; i < data.length; i++)
                    Expanded(
                      child: Center(
                        child: labelsToShow.contains(i)
                            ? Text(
                                _labelFor(data[i].day),
                                style: TextStyle(
                                  color: context.palette.textTertiary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Últimas 8 semanas; cada bolinha é um dia com algum hábito feito.
class _Heatmap extends ConsumerWidget {
  const _Heatmap({required this.days});

  /// Dias (sem hora) com pelo menos um hábito concluído.
  final Set<DateTime> days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = context.accent;
    final today = ref.watch(todayProvider);
    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: List.generate(56, (i) {
        final day = DateTime(today.year, today.month, today.day - 55 + i);
        final completed = days.contains(day);
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: completed
                ? accent.withValues(alpha: 0.85)
                : context.palette.veil(0.08),
            borderRadius: BorderRadius.circular(7),
          ),
        );
      }),
    );
  }
}
