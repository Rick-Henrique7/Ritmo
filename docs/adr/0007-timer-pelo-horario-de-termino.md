# 0007 — Timer de foco pelo horário de término e relógio injetável

- **Status:** Aceito
- **Data:** 2026-10-01

## Contexto
O timer de foco descontava 1 segundo a cada disparo de um `Timer.periodic`.
No celular, quando o app vai para segundo plano (ou a tela apaga), o Android
pausa o processo e os disparos param; ao voltar, o mostrador continuava de
onde parou — uma sessão de 25 minutos podia levar 40. Além disso:
- "Parar" só pausava, apesar do comentário dizer que zerava;
- a configuração "Som de conclusão" prometia tocar ao fim de uma sessão de
  foco, mas o timer não tocava nada;
- `wakelock_plus` estava no `pubspec.yaml` sem uso;
- a lógica do ciclo (durações, próximo modo) estava misturada com o `Timer`,
  sem como testar sem esperar 25 minutos.

## Decisão
- Ao iniciar, o estado guarda **`endsAt`** (horário de término). O restante é
  sempre `endsAt − agora`, recalculado a cada tique de 250 ms. Pausar congela
  o restante e apaga `endsAt`; retomar grava um novo `endsAt`.
- "Agora" vem de um **`clockProvider`** em `core/` (padrão `DateTime.now`).
  Os testes trocam por um `FakeClock` e avançam o tempo na hora.
- Regras do ciclo viram funções puras em `PomodoroCycle` (como no
  [ADR 0004](0004-regras-de-dominio-puras.md)).
- Efeitos ao concluir: grava a sessão **no horário em que de fato terminou**,
  vibra e toca o som (respeitando as configurações).
- Tela acesa enquanto o timer roda, por um `WakelockService` em `core/`
  (wrapper do plugin, trocado por um fake nos testes).

## Alternativas consideradas
- **Serviço em primeiro plano / notificação persistente** — mantém o processo
  vivo, mas exige permissões, notificação fixa e código nativo; desproporcional
  para um timer de 25 minutos.
- **Agendar uma notificação para o término** (`flutter_local_notifications`)
  — útil para avisar com o app fechado; fica para quando houver lembretes. Por
  ora a dependência foi removida.
- **Continuar contando tiques e corrigir no `resume`** — duas fontes da
  verdade; o horário de término resolve com uma só.

## Consequências
- O tempo fica certo depois de minimizar, trocar de app ou apagar a tela.
- Se o sistema **encerrar** o processo, o timer em andamento se perde (o
  estado é só em memória). Persistir `endsAt` resolve; registrado como
  próximo passo.
- 16 testes novos cobrem ciclo, segundo plano, pausa, conclusão única e tela
  acesa, sem nenhuma espera real.
