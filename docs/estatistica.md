# UI & Feature Spec — Tela de Estatísticas & Progresso

> **Visão original de interface.** O que está implementado hoje, com status e
> critérios de aceite, está em [requisitos funcionais](requisitos/funcionais.md).
> Itens desta spec que não aparecem lá como ✅ estão no backlog ou foram
> descartados.

> **Objetivo:** Transformar os dados de uso diário em gráficos simples,
> atraentes e motivacionais, permitindo visualizar a evolução pessoal em
> hábitos, tarefas concluídas e horas de foco acumuladas.

---

## 1. Componentes da Interface (UI/UX)

### 1.1 Seletor de Período (Filtro Temporal)

- **Abas de Controle:** Alternância rápida no topo entre Semana, Mês e Ano.
- Permite navegar para semanas ou meses anteriores para comparar o progresso.

### 1.2 Cards de Métricas Principais (KPIs)

- **Taxa de Conclusão:** Porcentagem global de tarefas e hábitos cumpridos no período.
- **Total de Horas em Foco:** Soma do tempo de Pomodoro finalizado com sucesso.
- **Sequência Atual (Streak Geral):** Contagem de dias seguidos cumprindo a meta diária principal.

### 1.3 Gráfico de Barras — Produtividade Semanal/Mensal

- Gráfico de barras estilizado (usando a biblioteca `fl_chart`) comparando tarefas concluídas dia a dia.
- Barras com cantos arredondados, gradiente de cores suaves e destaque na barra do dia com maior produtividade.

### 1.4 Visão de Consistência (Heatmap Grid)

- Grade de consistência inspirada no modelo de contribuições do GitHub.
- Quadrados que escurecem gradativamente de acordo com o volume de hábitos concluídos no dia, dando uma sensação clara de progresso ao longo dos meses.

### 1.5 Distribuição por Categorias (Gráfico de Rosca / Donut Chart)

- Mostra onde o tempo e o esforço foram investidos (ex: 35% Estudos, 25% Trabalho, 20% Saúde, 20% Pessoal).

---

## 2. Especificação de Requisitos Técnicos

### 2.1 Requisitos Funcionais (RF)

- **RF-ST-01:** Calcular e exibir o total de tarefas concluídas, tempo total de Pomodoro e hábitos cumpridos filtrados por período (Semanal, Mensal, Anual).
- **RF-ST-02:** Gerar os dados para o gráfico de barras comparativo de produtividade diária usando a biblioteca `fl_chart`.
- **RF-ST-03:** Renderizar a grade de consistência (Heatmap) cruzando histórico de conclusão dos hábitos salvos localmente.
- **RF-ST-04:** Agrupar e calcular a distribuição percentual de tempo/tarefas por categoria para o gráfico de rosca.

### 2.2 Requisitos Não-Funcionais e UI (RNF)

- **RNF-ST-01:** As consultas no banco de dados local (Isar/Hive) para gerar relatórios devem ser assíncronas e otimizadas para não travar a renderização da tela.
- **RNF-ST-02:** Os gráficos devem possuir animações de entrada (`animate: true`) ao trocar o filtro de período.

### 2.3 Consultas de Dados Requeridas

- **Aggregation Query:** Somatório de `PomodoroSessionModel.durationMinutes` onde `isCompleted == true`.
- **Count Query:** Total de `TaskModel` onde `isCompleted == true` dentro do intervalo de datas.
- **Matrix Query:** Mapeamento de `completedDates` da coleção `HabitModel` para gerar os pontos de calor do Heatmap.
