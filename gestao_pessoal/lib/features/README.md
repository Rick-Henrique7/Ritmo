# `lib/features/` — Arquitetura por feature

Cada pasta é uma **funcionalidade vertical** do Ritmo. Visão completa em
[`docs/arquitetura.md`](../../../docs/arquitetura.md) e decisões em
[`docs/adr/`](../../../docs/adr/README.md).

## Estrutura padrão

```
features/<nome>/
├── domain/        # Modelos imutáveis, regras puras e contratos (interfaces)
│   ├── <nome>_model.dart
│   ├── <nome>_repository.dart      # abstract interface class
│   └── <regras>.dart               # funções puras (ex.: task_schedule.dart)
├── data/          # Estado (Riverpod Notifier) e implementações dos contratos
│   ├── <nome>_controller.dart
│   └── prefs_<nome>_repository.dart
└── presentation/  # Telas, widgets e diálogos
    ├── <nome>_screen.dart           # composição e navegação
    ├── <nome>_form_dialog.dart      # formulário de criar/editar
    └── widgets/                     # blocos visuais com nome próprio
```

Uma tela que passa de ~400 linhas é sinal de que algum bloco merece um
widget próprio em `widgets/`.

| Feature | domain | data | presentation |
| --- | --- | --- | --- |
| `habits` | `HabitModel`, `HabitStreak`, `HabitCalendar`, `HabitsRepository` | `HabitsNotifier`, `PrefsHabitsRepository` | `HabitsScreen`, `HabitFormDialog`, `widgets/` |
| `tasks` | `TaskModel`, `TaskSchedule`, `TasksRepository` | `TasksNotifier`, `PrefsTasksRepository` | `TasksScreen`, `TaskFormDialog`, `widgets/` |
| `pomodoro` | `PomodoroSessionModel`, `PomodoroCycle`, `PomodoroSessionsRepository` | `PomodoroTimerNotifier` (horário de término), `PomodoroHistoryNotifier` | `PomodoroScreen`, `PomodoroTimerView` |
| `settings` | `AppSettings`, `SettingsRepository` | `SettingsNotifier` | `SettingsScreen`, `widgets/` |
| `stats` | `StatsCalculator` | `stats_providers.dart` | `StatsScreen` |
| `dashboard` | — | — | `DashboardScreen` (tela Hoje) |
| `reminders` | `ReminderPlanner`, `ReminderPayload`, `ReminderSnooze` | `reminderSyncProvider`, ações da notificação | — (configuração em `settings`) |

## Regras de dependência

```
presentation/  ──►  data/  ──►  domain/
       └──────────────┴────────────┴──►  core/
```

- `domain/` não importa `data/`, `presentation/`, Riverpod nem armazenamento.
- `data/` não importa `presentation/`.
- Features **de domínio** (`habits`, `tasks`, `pomodoro`, `settings`) não
  importam umas às outras.
- Features **agregadoras** (`dashboard`, `stats`) podem ler os controllers de
  outras features — juntar dados é o propósito delas. Exceção pontual: o Foco
  lê a lista de tarefas para vincular uma sessão e as cores do anel nas
  configurações. ([ADR 0002](../../../docs/adr/0002-providers-em-core.md))
- Cor de destaque e de texto vêm do tema (`context.accent`,
  `context.foreground`), não de `settings`
  ([ADR 0008](../../../docs/adr/0008-shell-fora-do-core.md)).
- Infraestrutura (armazenamento, "hoje", relógio, vibração, som, tela acesa) vem de
  `core/providers/core_providers.dart`, nunca de outra feature.

## Adicionando uma feature

1. `domain/`: modelo imutável (`copyWith`, `toJson`, `fromJson`) e o contrato
   do repositório.
2. `data/`: implementação `Prefs<Nome>Repository` + provider tipado com a
   interface; controller `Notifier` que depende só da interface.
3. Regras de negócio como funções puras em `domain/`, com testes em
   `test/features/<nome>/`.
4. `presentation/`: tela que lê providers e chama o controller.
5. Rota em `routing/app_router.dart`.
