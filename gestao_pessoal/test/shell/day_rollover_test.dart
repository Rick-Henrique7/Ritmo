import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/core/providers/core_providers.dart';
import 'package:gestao_pessoal/shell/day_rollover.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets(
      'ao voltar do segundo plano num novo dia, "hoje" muda na hora '
      '(bug antigo: amanhecia mostrando o dia anterior)', (tester) async {
    final clock = FakeClock(DateTime(2026, 10, 2, 22));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [clockProvider.overrideWithValue(clock.call)],
        child: DayRollover(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Consumer(
              builder: (_, ref, __) =>
                  Text('dia ${ref.watch(todayProvider).day}'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('dia 2'), findsOneWidget);

    // App minimizado durante a noite; o celular dorme e acorda no dia 3.
    // O Flutter exige a sequência real de estados (não pula de paused para
    // resumed): resumed → inactive → hidden → paused e o caminho de volta.
    void goTo(List<AppLifecycleState> states) {
      for (final s in states) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
    }

    goTo(const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]);
    clock.advance(const Duration(hours: 10));
    goTo(const [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);
    await tester.pump();

    expect(find.text('dia 3'), findsOneWidget);

    // Desmonta para cancelar o timer do todayProvider.
    await tester.pumpWidget(const SizedBox());
  });
}
