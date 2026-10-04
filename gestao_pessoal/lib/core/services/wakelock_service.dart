import 'package:wakelock_plus/wakelock_plus.dart';

/// Mantém a tela acesa enquanto algo precisa ficar visível (o timer de
/// foco rodando).
///
/// Wrapper fino do `wakelock_plus`: o resto do app depende desta classe,
/// não do plugin, e os testes trocam por uma versão em memória.
class WakelockService {
  const WakelockService();

  Future<void> keepScreenOn(bool on) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } catch (_) {
      // Sem suporte na plataforma: a tela apenas segue a regra do sistema.
    }
  }
}
