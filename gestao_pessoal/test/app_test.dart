import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/app.dart';
import 'package:gestao_pessoal/features/habits/presentation/habit_form_dialog.dart';
import 'package:gestao_pessoal/routing/app_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers/fakes.dart';
import 'helpers/fixtures.dart';

/// Testes de widget do app inteiro (rotas, shell, tema e telas reais),
/// com armazenamento em memória e data fixa.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<void> pumpApp(
    WidgetTester tester, {
    InMemoryTasksRepository? tasks,
    InMemoryHabitsRepository? habits,
    InMemorySettingsRepository? settings,
  }) async {
    // Tela de celular (390 × 844 lógicos).
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(
          today: thu,
          tasks: tasks,
          habits: habits,
          settings: settings,
        ),
        child: const RitmoApp(),
      ),
    );
    // O GoRouter é estático: garante que cada teste começa na tela Hoje.
    AppRouter.config.go('/');
    await tester.pumpAndSettle();
  }

  testWidgets('Hoje: mostra o progresso do dia e conclui um item ao tocar',
      (tester) async {
    await pumpApp(
      tester,
      habits: InMemoryHabitsRepository([habit(id: 'agua')]),
      tasks: InMemoryTasksRepository([task(id: 'pr', title: 'Revisar PR', dueDate: thu)]),
    );

    expect(find.text('Hoje no radar'), findsOneWidget);
    expect(find.text('Revisar PR'), findsOneWidget);
    expect(find.text('00'), findsOneWidget);
    expect(find.text('/ 02'), findsOneWidget);

    await tester.tap(find.text('Revisar PR'));
    await tester.pumpAndSettle();

    expect(find.text('01'), findsOneWidget);
    expect(find.text('faltam 1'), findsOneWidget);
  });

  testWidgets('Hoje: sem nada agendado mostra o convite para criar',
      (tester) async {
    await pumpApp(tester);

    expect(find.text('/ 00'), findsOneWidget);
    expect(find.text('nada agendado'), findsOneWidget);
    expect(find.text('Criar hábito'), findsOneWidget);
  });

  testWidgets('Hoje: tarefa atrasada continua na lista com a marca',
      (tester) async {
    await pumpApp(
      tester,
      tasks: InMemoryTasksRepository([
        task(id: 'atrasada', title: 'Visitar a avó', dueDate: mon),
        task(
          id: 'ontem',
          title: 'Feita ontem',
          dueDate: wed,
          isCompleted: true,
          completedAt: wed,
        ),
      ]),
    );

    expect(find.text('Visitar a avó'), findsOneWidget);
    expect(find.text('Atrasada'), findsOneWidget);
    expect(find.text('Feita ontem'), findsNothing);
  });

  testWidgets('Tarefas: abas filtram pela regra do domínio', (tester) async {
    await pumpApp(
      tester,
      tasks: InMemoryTasksRepository([
        task(id: 'hoje', title: 'Pagar conta', dueDate: thu),
        task(id: 'depois', title: 'Dentista', dueDate: fri),
      ]),
    );

    await tester.tap(find.byTooltip('Tarefas'));
    await tester.pumpAndSettle();
    expect(find.text('Pagar conta'), findsOneWidget);
    expect(find.text('Dentista'), findsOneWidget);

    await tester.tap(find.text('Hoje'));
    await tester.pumpAndSettle();
    expect(find.text('Pagar conta'), findsOneWidget);
    expect(find.text('Dentista'), findsNothing);

    // As abas rolam na horizontal: "Concluídas" pode estar fora da tela
    // (a fonte de teste é mais larga que a real). Rola até ela, como o
    // usuário faria, antes de tocar.
    await tester.ensureVisible(find.text('Concluídas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluídas'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma concluída ainda'), findsOneWidget);
  });

  testWidgets('Configurações: oferece os dois estilos visuais', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();

    expect(find.text('Estilo visual'), findsOneWidget);
    expect(find.text('Editorial'), findsOneWidget);
    expect(find.text('Liquid Glass'), findsOneWidget);
  });

  Future<void> openNewHabitForm(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Hábitos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Novo hábito'));
    await tester.pumpAndSettle();
  }

  Finder inHabitForm(Finder f) =>
      find.descendant(of: find.byType(HabitFormDialog), matching: f);

  Future<void> tapCreate(WidgetTester tester) async {
    // Fecha o teclado antes, como a pessoa faz ao terminar de digitar.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final create = inHabitForm(find.widgetWithText(FilledButton, 'Criar'));
    await tester.ensureVisible(create);
    await tester.pumpAndSettle();
    await tester.tap(create);
    await tester.pumpAndSettle();
  }

  // Regressão: o hábito novo começava sem nenhum dia marcado, era salvo,
  // mas não aparecia em Hoje nem no calendário — parecia não ter sido criado.
  testWidgets('Hábitos: hábito novo vem com todos os dias e aparece no dia',
      (tester) async {
    await pumpApp(tester);
    await openNewHabitForm(tester);

    await tester.enterText(
      inHabitForm(find.byType(TextField)).first,
      'Ler 10 páginas',
    );
    await tapCreate(tester);

    expect(find.byType(HabitFormDialog), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Ler 10 páginas'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Ler 10 páginas'), findsOneWidget);
  });

  testWidgets('Hábitos: Criar sem nome explica o que falta', (tester) async {
    await pumpApp(tester);
    await openNewHabitForm(tester);

    await tapCreate(tester);

    expect(find.byType(HabitFormDialog), findsOneWidget);
    expect(find.text('Dê um nome ao hábito.'), findsOneWidget);
  });
}
