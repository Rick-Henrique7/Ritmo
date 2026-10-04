# 0009 — Notificações locais reagendadas a partir do estado

- **Status:** Aceito
- **Data:** 2026-10-04

## Contexto
O usuário pediu avisos de tarefas e hábitos pendentes, com botões para
concluir e adiar direto na notificação (RF-NT-01 a 08). O app é offline e sem
conta, então os avisos não podem vir de um servidor. Logo antes, um bug
mostrou o risco de estado desatualizado: o app amanhecia achando que ainda
era o dia anterior. Notificação desatualizada ("faltam 2 tarefas" quando já
foram feitas) seria o mesmo erro, só que fora do app.

## Decisão
- **Notificações locais** com `flutter_local_notifications`, agendadas no
  próprio aparelho.
- **Planejador puro** (`ReminderPlanner`): recebe tarefas, hábitos,
  configurações, adiamentos e o horário atual, e devolve a lista de avisos dos
  próximos 7 dias. Não sabe nada de Android, e é testado com datas fixas.
- **Reagendar tudo a cada mudança.** Em vez de criar e cancelar avisos item a
  item, o app recalcula o plano inteiro e substitui os avisos pendentes
  sempre que tarefas, hábitos, configurações ou o dia mudam. É simples e não
  deixa aviso órfão.
- **Ações em segundo plano.** Concluir e Adiar rodam num isolate separado,
  sem abrir o app: leem o armazenamento, gravam a mudança, reagendam e
  avisam o app, se ele estiver aberto, para recarregar os dados.
- **Horário aproximado.** Usa o agendamento inexato do Android, que não
  precisa da permissão de alarme exato. Desde o Android 14 essa permissão é
  restrita a despertadores e agendas. Um aviso pode chegar alguns minutos
  depois da hora.

## Alternativas consideradas
- **Agendar e cancelar por item** — menos trabalho por mudança, mas cada
  caminho de edição precisaria lembrar de atualizar o aviso certo. Esquecer
  um deles deixa aviso fantasma.
- **Push por servidor** — exigiria backend e conta; contraria a proposta.
- **Alarme exato** — pontualidade ao segundo, mas a Play Store questiona a
  permissão para apps que não são despertador.
- **Ações que abrem o app** — mais simples (sem isolate), mas o pedido era
  concluir sem abrir.

## Consequências
- Os textos do resumo e das pendências são calculados na hora do
  agendamento. Por isso o reagendamento a cada mudança é obrigatório, e não
  só uma otimização.
- Duas cópias do app podem escrever os dados (o app e o isolate da ação). Ao
  receber o sinal da ação, ou ao voltar do segundo plano, o app relê o
  armazenamento antes de continuar.
- Adiamentos são guardados (`daily_flow.reminder_snoozes`) para sobreviver
  ao reagendamento.
