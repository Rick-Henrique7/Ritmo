import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/core_providers.dart';
import '../core/utils/date_only.dart';

/// Atualiza o "hoje" do app assim que ele volta do segundo plano.
///
/// O `todayProvider` já confere a data a cada minuto, mas ao abrir o app de
/// manhã isso pode levar até um minuto — tempo em que a tela mostraria o dia
/// anterior. Aqui a conferência é imediata no `resume`.
class DayRollover extends ConsumerStatefulWidget {
  const DayRollover({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DayRollover> createState() => _DayRolloverState();
}

class _DayRolloverState extends ConsumerState<DayRollover> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onResume: _checkDay);
  }

  void _checkDay() {
    final now = ref.read(clockProvider)();
    if (!isSameDay(now, ref.read(todayProvider))) {
      ref.invalidate(todayProvider);
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
