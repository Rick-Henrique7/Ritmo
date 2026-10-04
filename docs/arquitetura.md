# Arquitetura — Daily Flow

> Como o código está organizado **hoje**, por quê, e as regras que mantêm
> essa organização. As decisões estão registradas em [`adr/`](adr/README.md).
> Histórico das mudanças: [refatoração](refatoracao/README.md) (etapas 1 a 3).

![Arquitetura em camadas](assets/arquitetura-camadas.svg)

## 1. Visão geral

O Daily Flow é um app **Flutter offline-first**: tudo roda no aparelho, sem
servidor. A organização combina duas ideias:

- **Por feature (vertical):** cada funcionalidade — hábitos, tarefas, foco,
  estatísticas, configurações, Hoje — vive na sua pasta em `lib/features/`.
- **Em camadas (horizontal):** dentro de cada feature, o código se divide em
  `presentation/`, `data/` e `domain/`, com dependência sempre "para dentro".

| Camada | O que tem | Pode depender de | Não pode depender de |
| --- | --- | --- | --- |
| `presentation/` | Telas, widgets, diálogos | `data/`, `domain/`, `core/` | — |
| `data/` | Controllers (Riverpod `Notifier`) e implementações de repositório | `domain/`, `core/` | `presentation/` |
| `domain/` | Modelos imutáveis, regras puras, contratos de repositório | `core/utils` | `data/`, `presentation/`, Riverpod, armazenamento |
| `core/` | Providers de infraestrutura, serviços, tema, widgets e utilitários compartilhados | — | qualquer feature |

## 2. Estrutura de pastas

```text
lib/
├── main.dart              # composition root: abre o armazenamento e liga as dependências
├── app.dart               # MaterialApp + tema por estilo visual
├── routing/app_router.dart
├── shell/                 # casca do app: AppShell, fundo, virada do dia, sincronização externa
├── core/
│   ├── constants/         # AppPalette (ThemeExtension), AppStyle, AppTheme, espaçamentos
│   ├── database/          # PrefsStore (wrapper do SharedPreferences) + chaves
│   ├── providers/         # prefsStore, today, clock, haptics, sound, wakelock, FeedbackPreferences
│   ├── services/          # HapticsService, SoundService, WakelockService
│   ├── utils/             # date_only, date_formatters, json_coders, color_hex
│   └── widgets/           # nav bar, cards, cabeçalho, seletor de dias, diálogo de exclusão
└── features/
    ├── habits/            # domain: HabitModel, HabitStreak, HabitCalendar, HabitsRepository
    ├── tasks/             # domain: TaskModel, TaskSchedule, TasksRepository
    ├── pomodoro/          # domain: PomodoroSessionModel, PomodoroCycle, PomodoroSessionsRepository
    ├── settings/          # domain: AppSettings, SettingsRepository
    ├── stats/             # domain: StatsCalculator  (feature agregadora)
    ├── reminders/         # domain: ReminderPlanner  (agregadora: avisos de tarefas e hábitos)
    └── dashboard/         # tela Hoje                 (feature agregadora)
```

## 3. Dependências entre features

Features **de domínio** (hábitos, tarefas, foco, configurações) não importam
umas às outras. Duas features são **agregadoras** e podem *ler* as outras,
porque existem justamente para juntar dados: a tela **Hoje** e as
**Estatísticas** ([ADR 0002](adr/0002-providers-em-core.md)).

```mermaid
flowchart LR
  subgraph agregadoras
    dashboard[dashboard · Hoje]
    stats[stats · Estatísticas]
  end
  subgraph dominio[features de domínio]
    habits[habits]
    tasks[tasks]
    pomodoro[pomodoro]
    settings[settings]
  end
  core[(core)]

  dashboard --> habits
  dashboard --> tasks
  stats --> habits
  stats --> tasks
  stats --> pomodoro
  pomodoro -. "lista de tarefas<br/>para vincular" .-> tasks
  pomodoro -. "cores do anel<br/>por modo" .-> settings
  shell[shell · casca do app] --> settings
  shell --> core
  habits --> core
  tasks --> core
  pomodoro --> core
  settings --> core
  dashboard --> core
  stats --> core
```

Duas leituras pontuais entre features de domínio, ambas de dados que
pertencem à outra: o Foco lista as tarefas para vincular uma sessão e lê as
cores do anel configuradas pelo usuário. A cor de destaque **não** conta: as
telas leem `context.accent` (do tema), não as configurações
([ADR 0008](adr/0008-shell-fora-do-core.md)).

> Antes da etapa 1 havia um ciclo `settings → habits → settings` e três
> features importavam `habits` só para acessar o armazenamento. Ver o
> [antes e depois](refatoracao/etapa-1-fundacao.md#1-dependências).

## 4. Fluxo de dados (exemplo: concluir uma tarefa)

O estado vive em `Notifier`s do Riverpod. A tela nunca grava nada direto: ela
chama o controller, que atualiza o estado em memória (a UI reage na hora) e
persiste pelo **contrato** do repositório.

```mermaid
sequenceDiagram
  actor U as Usuário
  participant T as TasksScreen
  participant C as TasksNotifier
  participant S as TaskSchedule
  participant R as TasksRepository
  participant P as SharedPreferences

  U->>T: toca no círculo da tarefa
  T->>C: toggleCompleted(task)
  C->>C: recorrente? marca o dia em completedDates<br/>pontual? alterna isCompleted
  C-->>T: novo estado (lista de tarefas)
  T->>S: filter(tarefas, aba, hoje)
  S-->>T: itens da aba atual
  C->>R: saveAll(tarefas)
  R->>P: grava JSON
  C->>C: vibração + som (se ativados)
```

## 5. Composition root e injeção de dependência

`main.dart` é o único lugar que conhece as implementações concretas:

```dart
ProviderScope(
  overrides: [
    prefsStoreProvider.overrideWithValue(store),          // armazenamento aberto
    feedbackPreferencesProvider.overrideWith((ref) {      // core ← configurações
      final s = ref.watch(settingsProvider);
      return FeedbackPreferences(haptics: s.hapticsEnabled, sound: s.soundEnabled);
    }),
  ],
  child: const DailyFlowApp(),
)
```

Cada feature expõe o repositório por um provider tipado com a **interface**
(`Provider<TasksRepository>`). Nos testes, ele é trocado por um repositório em
memória sem mudar uma linha do controller.

## 6. Persistência

| Chave (`SharedPreferences`) | Conteúdo | Repositório |
| --- | --- | --- |
| `daily_flow.habits` | lista JSON de `HabitModel` | `PrefsHabitsRepository` |
| `daily_flow.tasks` | lista JSON de `TaskModel` | `PrefsTasksRepository` |
| `daily_flow.pomodoro_sessions` | lista JSON de `PomodoroSessionModel` | `PrefsPomodoroSessionsRepository` |
| `daily_flow.settings` | objeto JSON de `AppSettings` | `PrefsSettingsRepository` |

- Leitura síncrona: o `PrefsStore` é aberto antes do `runApp`, então os dados
  já estão em memória ([ADR 0003](adr/0003-repositorios.md)).
- Registros corrompidos são descartados um a um (`JsonCoders.decodeList`), sem
  derrubar o app.
- Migrações de formato ficam no `fromJson` de cada modelo (ex.: tarefas
  recorrentes antigas → `completedDates`).

## 7. Regras de negócio no domínio

| Regra | Onde | Testes |
| --- | --- | --- |
| O que é "de hoje", o que está feito, conteúdo das abas | `tasks/domain/task_schedule.dart` | `test/features/tasks/task_schedule_test.dart` |
| Sequência (streak) de hábitos | `habits/domain/habit_rules.dart` (`HabitStreak`) | `test/features/habits/habit_rules_test.dart` |
| Dias incompletos do calendário | `habits/domain/habit_rules.dart` (`HabitCalendar`) | idem |
| Agregações das estatísticas | `stats/domain/stats_calculator.dart` | `test/features/stats/stats_calculator_test.dart` |
| Ciclo do foco (durações, próximo modo, tempo restante) | `pomodoro/domain/pomodoro_cycle.dart` | `test/features/pomodoro/` |

São funções puras: recebem dados e a data de hoje, devolvem resultados. "Hoje"
vem do `todayProvider` (recalculado à meia-noite), nunca de `DateTime.now()`
espalhado pelo código ([ADR 0004](adr/0004-regras-de-dominio-puras.md)).
Quem precisa da hora exata — o timer de foco — lê o `clockProvider` e guarda
o **horário de término**, não um contador
([ADR 0007](adr/0007-timer-pelo-horario-de-termino.md)).

## 8. Interface e estilos visuais

Dois estilos selecionáveis em Configurações — **Editorial** (padrão) e
**Liquid Glass** — com tema em `AppTheme.build` e paleta em `AppPalette`, uma
`ThemeExtension` lida com `context.palette`
([ADR 0005](adr/0005-dois-estilos-visuais.md), [ADR 0006](adr/0006-paleta-como-theme-extension.md)).
Componentes que só precisam da cor de destaque leem
`Theme.of(context).colorScheme.primary` — assim o `core/` não depende das
configurações ([ADR 0008](adr/0008-shell-fora-do-core.md)). Detalhes visuais em
[`design.md`](design.md).

## 9. Notificações

Os avisos são calculados por uma função pura, `ReminderPlanner`, a partir de
tarefas, hábitos e configurações, e **reagendados inteiros a cada mudança**
pelo `reminderSyncProvider` ([ADR 0009](adr/0009-notificacoes-locais.md)).
Os botões Concluir e Adiar rodam num isolate separado e avisam o app aberto
por uma porta (`ExternalChangesSync`), que relê o armazenamento.

```mermaid
sequenceDiagram
  participant A as App (isolate principal)
  participant P as ReminderPlanner
  participant S as Android
  participant B as Isolate da ação
  A->>P: tarefas, hábitos, configurações mudaram
  P-->>A: avisos dos próximos 7 dias
  A->>S: substitui os avisos pendentes
  S-->>B: usuário toca "Concluir"
  B->>B: grava a conclusão e reagenda
  B-->>A: "dados mudaram" (porta)
  A->>A: relê o armazenamento
```

## 10. Dívidas conhecidas (próximas etapas)

Resolvidas na [etapa 3](refatoracao/etapa-3-clean-code.md): paleta global,
telas grandes, timer que atrasava, `core/` importando features e
dependências não usadas.

- Timer de foco em andamento se perde se o sistema **encerrar** o app;
  persistir `endsAt` resolve.
- `habit_form_dialog.dart` (≈570 linhas) e `dashboard_screen.dart` (≈510)
  são os próximos candidatos a divisão.
- Testes de widget para Hábitos e Foco; testes de integração no emulador.
- Verificação automática das regras de dependência (ex.: falhar o CI se
  `lib/core` importar `features/`).
