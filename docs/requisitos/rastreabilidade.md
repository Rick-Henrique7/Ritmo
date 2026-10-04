# Matriz de rastreabilidade

> Liga cada requisito ao código que o implementa, ao teste que o protege e ao
> caso de uso em que aparece. Serve para responder duas perguntas:
> **"se eu mudar isto, o que quebra?"** e **"este requisito está garantido?"**

Caminhos relativos a `gestao_pessoal/`. Testes: **U** = unitário,
**W** = widget, **M** = só verificação manual.

## Requisitos funcionais

| Requisito | Código principal | Teste | UC | Status |
| --- | --- | --- | --- | --- |
| RF-DB-01 | `TaskSchedule.forDay` · `habitsForDayProvider` · `DashboardScreen` | U `task_schedule_test` (forDay), `tasks_controller_test` · W `app_test` "Hoje: mostra o progresso" | 01 | ✅ |
| RF-DB-02 | `DashboardScreen` (`_RadarRow`) → `toggleCompleted` / `toggleCompletionForDate` | W `app_test` "conclui um item ao tocar" | 01 | ✅ |
| RF-DB-03 | `DashboardScreen._showCreateSheet` | M | 01 | 🟡 |
| RF-DB-04 | `DateFormatters.greetingForHour` | M | 01 | ✅ |
| RF-DB-05 | `DashboardScreen` (estado vazio) | W `app_test` "sem nada agendado" | 01 | ✅ |
| RF-HB-01 | `HabitCalendarCard` · `habitsForDayProvider` · `HabitModel.isScheduledFor` | M | 03 | ✅ |
| RF-HB-02 | `HabitsNotifier.toggleCompletionForDate` · `HabitCard` | M | 03 | ✅ |
| RF-HB-03 | `HabitStreak.current` / `.best` · `StreakPanel` | U `habit_rules_test` (7 testes) | 03 | 🟡 |
| RF-HB-04 | `HabitFormDialog` · `HabitsNotifier.create/update/remove` | M | 02 | ✅ |
| RF-HB-05 | — | — | — | ⬜ |
| RF-HB-06 | `HabitCalendar.incompleteDays` · `incompleteDaysProvider` | U `habit_rules_test` (incompleteDays) | 03 | ✅ |
| RF-TD-01 | `TaskFormDialog` · `TasksNotifier` · `TaskTile` | M | 04 | 🟡 |
| RF-TD-03 | `TaskSchedule.filter` · `TaskFilterTabs` | U `task_schedule_test` (filter) · W `app_test` "abas filtram" | 04 | ✅ |
| RF-TD-04 | `TasksScreen` (`Dismissible`) · `showConfirmDeleteDialog` · `AppUndoSnackBar` | M | 04 | ✅ |
| RF-TD-06 | `TaskModel.isCompletedOn` · `completedDates` · `TasksNotifier.toggleCompleted` | U `task_model_test` (migração), `tasks_controller_test`, `task_schedule_test` | 04 | ✅ |
| RF-TD-09 | `TaskSchedule.isOverdue` · `forDay` · `filter` · `OverdueTag` · `todayProvider` · `DayRollover` | U `task_schedule_test` (isOverdue, forDay, Hoje) · W `app_test` "tarefa atrasada", `day_rollover_test` | 01, 04 | ✅ |
| RF-TD-07 | `TaskModel` · `TaskTile` · `TaskSchedule.pendingCount` | U `task_schedule_test` (pendingCount) | 04 | ✅ |
| RF-PO-01 | `PomodoroCycle.durationOf` · `PomodoroTimerState.idle` | U `pomodoro_controller_test` "começa parado em Foco" | 05 | ✅ |
| RF-PO-02 | `PomodoroCycle.nextAfterCompletion` · `PomodoroTimerNotifier._complete` | U `pomodoro_cycle_test`, `pomodoro_controller_test` "quarto foco" | 05 | ✅ |
| RF-PO-03 | `PomodoroTimerNotifier.selectTask` · `PomodoroSessionModel.taskId` | M | 05 | 🟡 |
| RF-PO-04 | `_complete` → `HapticsService.heavy` + `SoundService.playSuccess` | U `pomodoro_controller_test` "toca o som" | 05 | 🟡 |
| RF-PO-05 | `WakelockService` · `start` / `_stopTicker` | U `pomodoro_controller_test` "tela fica acesa" | 05 | ✅ |
| RF-PO-06 | `endsAt` · `clockProvider` · `PomodoroCycle.secondsLeft` | U `pomodoro_controller_test` "segundo plano", "uma vez só" | 05 | ✅ |
| RF-PO-07 | `start` · `pause` · `stop` · `skip` | U `pomodoro_controller_test` (pausar, parar, pular) | 05 | ✅ |
| RF-ST-01 | `StatsCalculator.summarize` · `statsSummaryProvider` | U `stats_calculator_test` | 06 | 🟡 |
| RF-ST-02 | `StatsCalculator` (séries) · `_CustomBarChart` | U `stats_calculator_test` "semanal", "anual" | 06 | ✅ |
| RF-ST-03 | `StatsCalculator.habitDays` · `_Heatmap` | M | 06 | ✅ |
| RF-CF-01 | `AppTheme.build` · `AppPalette` · `SettingsNotifier.updateStyle` | W `app_test` "dois estilos" | 07 | ✅ |
| RF-CF-02 | `SettingsNotifier.updateAccentColor` · `context.accent` | M | 07 | ✅ |
| RF-CF-03 | `AnimatedBackground` · `WallpaperMode` | M | 07 | ✅ |
| RF-CF-04 | `feedbackPreferencesProvider` (`main.dart`) · `HapticsService` · `SoundService` | M | 07 | ✅ |
| RF-CF-05 | `AppSettings.pomodoro*Color` · `PomodoroTimerView` | M | 07 | ✅ |
| RF-CF-06 | `SettingsNotifier.resetDefaults` | M | 07 | ✅ |

| RF-NT-01/02 | `ReminderPlanner.plan` (resumo e pendências) | U `reminder_planner_test` "resumo e pendências" | — | ⬜ aguarda aparelho |
| RF-NT-03 | `ReminderPlanner.plan` (tarefas) · `LocalNotificationScheduler` | U `reminder_planner_test` "tarefas com horário" | 04 | ⬜ aguarda aparelho |
| RF-NT-04 | `ReminderPlanner.plan` (hábitos) | U `reminder_planner_test` "hábitos" | 03 | ⬜ aguarda aparelho |
| RF-NT-05 | `PomodoroTimerNotifier.start` → `scheduleFocusEnd` | U `pomodoro_controller_test` "aviso de fim do foco" | 05 | ⬜ aguarda aparelho |
| RF-NT-06 | `handleNotificationAction` · `TaskSchedule.markDone` · `ExternalChangesSync` | U `task_schedule_test` (markDone), `reminder_planner_test` (adiar) | 03, 04 | ⬜ aguarda aparelho |
| RF-NT-07 | `NotificationSettings` · `NotificationSettingsCard` · `askNotificationPermissionOnce` | U `notification_settings_test` | 07 | ⬜ aguarda aparelho |
| RF-NT-08 | `reminderSyncProvider` · `syncRemindersFromStore` | U `reminder_planner_test` (concluída não avisa) | — | ⬜ aguarda aparelho |

Requisitos ⬜ sem código ainda (RF-HB-05, RF-TD-02, RF-TD-05, RF-TD-08,
RF-PO-08, RF-ST-04, RF-CF-07) ficam no [backlog](README.md#3-backlog).

## Requisitos não funcionais

| Requisito | Onde é garantido | Teste |
| --- | --- | --- |
| RNF-03 Persistência | `Prefs*Repository.saveAll` chamado a cada alteração nos controllers | U `tasks_controller_test` "persiste no repositório" |
| RNF-04 Dados resilientes | `JsonCoders.decodeList` · `TaskModel.fromJson` (migração) | U `json_coders_test`, `task_model_test` |
| RNF-05 Precisão do timer | `PomodoroCycle.secondsLeft` · `endsAt` | U `pomodoro_cycle_test`, `pomodoro_controller_test` |
| RNF-07 Acessibilidade | `FittedBox` nos números grandes · `tooltip` nos botões | W `app_test` (fonte de teste mais larga que a real) |
| RNF-09 Manutenibilidade | `.github/workflows/ci.yml` · `analysis_options.yaml` | CI a cada push |

## Lacunas de teste

Requisitos ✅ cobertos **só manualmente**. São os próximos candidatos a teste
de widget:

1. **RF-HB-02 / RF-HB-04:** criar um hábito e marcá-lo pelo calendário.
2. **RF-TD-04:** deslizar para excluir e tocar em Desfazer.
3. **RF-CF-04:** com som desligado, concluir não chama o `SoundService` (já
   possível com o `CountingSound` dos fakes).
4. **RF-ST-03:** mapa de consistência com dias preenchidos.
