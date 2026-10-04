import '../../../core/utils/date_only.dart';
import 'task_model.dart';

/// Abas da tela de Tarefas.
enum TaskFilter { all, today, upcoming, completed }

/// Regras de agendamento de tarefas — **fonte única da verdade** para
/// "o que é de hoje", "o que está feito" e o que cada aba mostra.
///
/// Funções puras (sem Flutter, sem Riverpod, sem armazenamento): recebem
/// a lista e o dia, devolvem o resultado. Por isso são testadas direto em
/// `test/features/tasks/task_schedule_test.dart`.
///
/// Antes estas regras estavam espalhadas: o controller tinha uma versão
/// e a tela Hoje outra, e as duas discordavam.
abstract final class TaskSchedule {
  /// A tarefa é "do dia" [day] quando:
  /// 1. é pontual com data == [day];
  /// 2. é recorrente e o dia da semana de [day] está em `repeatDays`;
  /// 3. é avulsa (sem data e sem recorrência) — conta como "para hoje".
  static bool isScheduledFor(TaskModel t, DateTime day) {
    final due = t.dueDate;
    if (due != null && isSameDay(due, day)) return true;
    if (t.isRepeating && t.repeatDays.contains(day.weekday)) return true;
    return due == null && !t.isRepeating;
  }

  /// Feita no [day]? (recorrente: conclusão naquele dia; pontual: concluída)
  static bool isDoneOn(TaskModel t, DateTime day) => t.isCompletedOn(day);

  /// Pontual com data **anterior** a [day] e ainda não concluída.
  ///
  /// Tarefa atrasada não some: continua em "Hoje" (com a marca "Atrasada")
  /// até ser feita, porque pode ser algo importante a lembrar. Recorrentes
  /// nunca ficam atrasadas — cada dia previsto é uma ocorrência nova.
  static bool isOverdue(TaskModel t, DateTime day) {
    final due = t.dueDate;
    return !t.isRepeating &&
        !t.isCompleted &&
        due != null &&
        dateOnly(due).isBefore(dateOnly(day));
  }

  /// Tarefas do dia [day] — pendentes, atrasadas **e** as já feitas naquele
  /// dia. Alimenta o painel "Hoje no radar" e o progresso "Feitos hoje".
  ///
  /// Concluída num dia anterior não aparece: o dia seguinte começa limpo.
  static List<TaskModel> forDay(List<TaskModel> tasks, DateTime day) {
    return tasks.where((t) {
      if (isOverdue(t, day)) return true;
      if (!isScheduledFor(t, day)) {
        // Atrasada concluída hoje continua visível (e contando) até o fim do dia.
        final at = t.completedAt;
        final due = t.dueDate;
        return !t.isRepeating &&
            t.isCompleted &&
            due != null &&
            dateOnly(due).isBefore(dateOnly(day)) &&
            at != null &&
            isSameDay(at, day);
      }
      if (t.isRepeating || !t.isCompleted) return true;
      // Pontual concluída: só aparece se era daquele dia ou foi feita nele.
      final due = t.dueDate;
      final at = t.completedAt;
      return (due != null && isSameDay(due, day)) ||
          (at != null && isSameDay(at, day));
    }).toList()
      ..sort(compareBySchedule);
  }

  /// Quantas tarefas ainda pedem ação: pontuais abertas + recorrentes
  /// previstas para hoje e não feitas.
  static int pendingCount(List<TaskModel> tasks, DateTime today) =>
      tasks.where((t) {
        if (t.isRepeating) {
          return isScheduledFor(t, today) && !isDoneOn(t, today);
        }
        return !t.isCompleted;
      }).length;

  /// Conteúdo de cada aba da tela de Tarefas.
  ///
  /// - **Todas**: pontuais abertas (inclusive atrasadas), pontuais
  ///   concluídas de hoje em diante e todas as recorrentes.
  /// - **Hoje**: do dia e ainda não feitas, mais as **atrasadas**.
  /// - **Próximas**: abertas com data futura e recorrentes fora do dia.
  ///   (Atrasadas ficam em Hoje, não aqui.)
  /// - **Concluídas**: pontuais concluídas + recorrentes feitas hoje,
  ///   mais recentes primeiro.
  static List<TaskModel> filter(
    List<TaskModel> tasks,
    TaskFilter filter,
    DateTime today,
  ) {
    final day = dateOnly(today);
    switch (filter) {
      case TaskFilter.all:
        return tasks.where((t) {
          if (t.isRepeating || !t.isCompleted) return true;
          final due = t.dueDate;
          if (due != null) return !dateOnly(due).isBefore(day);
          final at = t.completedAt;
          return at != null && isSameDay(at, day);
        }).toList()
          ..sort(compareBySchedule);

      case TaskFilter.today:
        return tasks
            .where((t) =>
                isOverdue(t, day) ||
                (isScheduledFor(t, day) && !isDoneOn(t, day)))
            .toList()
          ..sort(compareBySchedule);

      case TaskFilter.upcoming:
        return tasks
            .where((t) =>
                !isScheduledFor(t, day) &&
                !isOverdue(t, day) &&
                (t.isRepeating || !t.isCompleted))
            .toList()
          ..sort(compareBySchedule);

      case TaskFilter.completed:
        return tasks
            .where((t) => t.isRepeating ? isDoneOn(t, day) : t.isCompleted)
            .toList()
          ..sort((a, b) {
            final ad = a.completedAt;
            final bd = b.completedAt;
            if (ad == null && bd == null) return 0;
            if (ad == null) return 1;
            if (bd == null) return -1;
            return bd.compareTo(ad); // mais recente primeiro
          });
    }
  }

  /// Ordena por data (asc) e hora (asc); sem data vai para o fim.
  static int compareBySchedule(TaskModel a, TaskModel b) {
    final ad = a.dueDate;
    final bd = b.dueDate;
    if (ad == null && bd == null) {
      return _minutesOf(a).compareTo(_minutesOf(b));
    }
    if (ad == null) return 1;
    if (bd == null) return -1;
    final cmp = dateOnly(ad).compareTo(dateOnly(bd));
    if (cmp != 0) return cmp;
    return _minutesOf(a).compareTo(_minutesOf(b));
  }

  /// Minutos do dia da `dueTime` (00:00 → 0); -1 sem hora.
  static int _minutesOf(TaskModel t) {
    final time = t.dueTime;
    return time == null ? -1 : time.hour * 60 + time.minute;
  }
}
