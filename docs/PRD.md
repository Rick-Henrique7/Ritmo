# Visão de produto — Ritmo

> Por que o app existe, para quem, e como saber se está dando certo. Os
> requisitos detalhados, com status e critérios de aceite, estão em
> [`requisitos/`](requisitos/README.md).

## 1. Problema

Quem tenta organizar a rotina costuma espalhar o dia em vários apps: um para
hábitos, outro para tarefas, outro para o timer. Cada troca de app custa
atenção, e a visão do dia nunca fica num lugar só. Muitos desses apps também
pedem conta, mostram anúncios ou mandam dados para a nuvem, o que é excessivo
para uma lista pessoal.

## 2. Proposta

Um app único, **offline e sem conta**, que responde em uma tela "o que eu
preciso fazer hoje e quanto já fiz", e que seja agradável o bastante para
ser aberto todo dia.

## 3. Público

- **Primário:** o próprio autor, que usa o app diariamente e originou os
  requisitos.
- **Secundário:** pessoas que querem acompanhar hábitos e tarefas sem
  cadastro e sem coleta de dados, usuárias da Play Store.

## 4. Objetivos

| Objetivo | Como se mede |
| --- | --- |
| Ver o dia em uma tela | Tela Hoje mostra hábitos e tarefas do dia e o progresso (RF-DB-01) |
| Registrar em um toque | Concluir qualquer item sem trocar de tela (RF-DB-02) |
| Criar constância | Sequência de hábitos e mapa de consistência (RF-HB-03, RF-ST-03) |
| Proteger a atenção | Timer de foco confiável mesmo em segundo plano (RF-PO-06) |
| Respeitar a privacidade | Nenhum dado sai do aparelho (RNF-02) |
| Ser bonito de usar | Dois estilos visuais e personalização de cores (RF-CF-01 a 05) |

## 5. Funcionalidades

| Área | O que faz | Detalhe |
| --- | --- | --- |
| **Hoje** | Saudação, progresso do dia e lista "Hoje no radar" com conclusão em um toque | [spec](dashboard.md) |
| **Hábitos** | Calendário mensal, hábitos por dia da semana, sequência, dias incompletos | [spec](habitos.md) |
| **Tarefas** | Pontuais ou recorrentes, prioridade, abas Todas/Hoje/Próximas/Concluídas | [spec](to-do.md) |
| **Foco** | Pomodoro 25/5/15, ciclo automático, vínculo com tarefa, tela acesa | [spec](pomodoro.md) |
| **Estatísticas** | Conclusões, minutos de foco, gráfico por período, mapa de 8 semanas | [spec](estatistica.md) |
| **Configurações** | Estilo Editorial ou Liquid Glass, cores, fundo, vibração e som | [design](design.md) |

> Os documentos *spec* de cada área registram a **visão original** de
> interface. Onde a implementação divergiu, por decisão ou por estar no
> backlog, vale o que está em [`requisitos/funcionais.md`](requisitos/funcionais.md).

## 6. Fora do escopo

Conta e login, sincronização em nuvem, uso por várias pessoas, anúncios,
analytics e versão iOS publicada.

## 7. Tecnologia

| Necessidade | Escolha | Por quê |
| --- | --- | --- |
| App | Flutter (Dart 3) | Uma base de código, UI própria e boa performance |
| Estado | Riverpod 2 (`Notifier`) | Reativo e fácil de testar com overrides |
| Navegação | go_router | Rotas declarativas com a barra inferior como *shell* |
| Dados | SharedPreferences (JSON) | Volume pequeno, leitura síncrona na abertura ([ADR 0003](adr/0003-repositorios.md)) |
| Calendário | Syncfusion Flutter Calendar | Visão mensal pronta |
| Gráficos | Widgets próprios | Controle visual total, sem dependência |
| Som / tela acesa | audioplayers · wakelock_plus | Feedback de conclusão e modo foco |

Arquitetura completa: [`arquitetura.md`](arquitetura.md).

## 8. Modelo de dados

| Entidade | Campos principais |
| --- | --- |
| `HabitModel` | título, categoria, ícone, cor, `frequencyDays` (1 = seg … 7 = dom), meta e unidade, duração, lembrete, `completedDates` |
| `TaskModel` | título, prioridade, categoria, data e hora, `repeatDays`, `completedDates` (recorrentes), `isCompleted` / `completedAt` (pontuais), subtarefas |
| `PomodoroSessionModel` | tipo (foco, pausa curta, pausa longa), início, duração, tarefa vinculada |
| `AppSettings` | estilo, cores, fundo, vibração, som, cores do timer |

A sequência de hábitos **não é gravada**: é calculada a partir de
`completedDates` ([ADR 0004](adr/0004-regras-de-dominio-puras.md)).

## 9. Marcos

| Versão | Conteúdo | Situação |
| --- | --- | --- |
| v0.1 | Funcionalidades das 6 áreas, dois estilos, arquitetura refatorada, 55 testes, CI | atual |
| v0.2 | `applicationId` definitivo e fontes embutidas (feitos); assinatura do release, backup, notificações e criação rápida ([backlog](requisitos/README.md#3-backlog)) | próxima |
| v1.0 | Publicação na Play Store (teste fechado → produção) | — |
