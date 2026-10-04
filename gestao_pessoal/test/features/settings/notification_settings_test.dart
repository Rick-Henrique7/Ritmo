import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_pessoal/features/settings/domain/app_settings.dart';

void main() {
  test('configurações salvas antes das notificações ganham os padrões', () {
    final s = AppSettings.fromJsonString('{"style":"editorial"}');
    expect(s.notifications.enabled, isTrue);
    expect(s.notifications.morningMinutes, 8 * 60);
    expect(s.notifications.eveningMinutes, 20 * 60);
    expect(s.notifications.taskLeadMinutes, 0);
  });

  test('ida e volta em JSON preserva as escolhas', () {
    final custom = AppSettings.defaults.copyWith(
      notifications: NotificationSettings.defaults.copyWith(
        morningEnabled: false,
        eveningMinutes: 21 * 60 + 30,
        taskLeadMinutes: 15,
      ),
    );
    final back = AppSettings.fromJsonString(custom.toJsonString());
    expect(back.notifications.morningEnabled, isFalse);
    expect(back.notifications.eveningMinutes, 21 * 60 + 30);
    expect(back.notifications.taskLeadMinutes, 15);
  });

  test('antecedência fora das opções volta para "na hora"', () {
    final s = AppSettings.fromJsonString(
      '{"style":"editorial","notifications":{"taskLeadMinutes":7}}',
    );
    expect(s.notifications.taskLeadMinutes, 0);
  });
}
