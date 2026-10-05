import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/features/habits/domain/habit_model.dart';
import 'package:gestao_pessoal/features/habits/domain/habit_rules.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('HabitStreak.current', () {
    test('sem conclusões é zero', () {
      expect(HabitStreak.current(habit(), thu), 0);
    });

    test('conta dias seguidos até hoje', () {
      final h = habit(completedDates: [tue, wed, thu]);
      expect(HabitStreak.current(h, thu), 3);
    });

    test('hoje ainda não feito não quebra a sequência', () {
      final h = habit(completedDates: [tue, wed]);
      expect(HabitStreak.current(h, thu), 2);
    });

    test('um dia previsto perdido quebra a sequência', () {
      final h = habit(completedDates: [mon, wed, thu]); // faltou terça
      expect(HabitStreak.current(h, thu), 2);
    });

    test('dias fora da frequência não quebram', () {
      // Só terça e quinta: feito nas duas -> 2, mesmo sem quarta.
      final h = habit(frequencyDays: const [2, 4], completedDates: [tue, thu]);
      expect(HabitStreak.current(h, thu), 2);
    });

    test('sequência antiga zera quando o usuário some por dias', () {
      final h = habit(completedDates: [mon, tue]);
      expect(HabitStreak.current(h, DateTime(2026, 10, 5)), 0);
    });
  });

  test('HabitStreak.best pega o maior entre os hábitos', () {
    final a = habit(id: 'a', completedDates: [thu]);
    final b = habit(id: 'b', completedDates: [tue, wed, thu]);
    expect(HabitStreak.best([a, b], thu), 3);
  });

  group('HabitCalendar.incompleteDays', () {
    test('marca dias previstos não feitos e ignora os feitos', () {
      final h = habit(frequencyDays: const [3, 4], completedDates: [thu]);
      final days = HabitCalendar.incompleteDays([h], thu, days: 7);
      expect(days, contains(wed));
      expect(days, isNot(contains(thu)));
      expect(days, isNot(contains(tue))); // terça não é dia previsto
    });

    test('sem hábitos não há dias incompletos', () {
      expect(HabitCalendar.incompleteDays([], thu), isEmpty);
    });
  });

  // Regressão: hábitos criados sem nenhum dia (0.1.0+1) ficavam invisíveis.
  test('hábito salvo sem dias volta como todos os dias', () {
    final json = habit().toJson()..['frequencyDays'] = <int>[];
    final migrated = HabitModel.fromJson(json);
    expect(migrated.frequencyDays, [1, 2, 3, 4, 5, 6, 7]);
    expect(migrated.isScheduledFor(thu), isTrue);
  });
}
