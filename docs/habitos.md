# UI & Feature Spec — Tela de Gestão de Hábitos

> **Visão original de interface.** O que está implementado hoje, com status e
> critérios de aceite, está em [requisitos funcionais](requisitos/funcionais.md).
> Itens desta spec que não aparecem lá como ✅ estão no backlog ou foram
> descartados.

> **Objetivo:** Permitir a criação, acompanhamento diário e visualização de
> consistência de hábitos recorrentes através de um design limpo, interativo
> e motivacional.

---

## 1. Componentes da Interface (UI/UX)

### 1.1 Header com Seletor de Dias (Fita Semanal / Calendar Strip)

- Exibe os dias da semana atual em formato carrossel horizontal (ex: Seg, Ter, Qua...).
- O dia selecionado ganha destaque visual (Background com cor primária e texto em negrito).
- Permite navegar rapidamente para dias passados para marcar um hábito esquecido ou visualizar o histórico.

### 1.2 Visão de Consistência (Heatmap / Streak Counter)

- **Mini Heatmap:** Uma grade no topo (estilo contribuições do GitHub) indicando os dias em que todos os hábitos foram cumpridos.
- **Streak Card:** Card destacado mostrando a maior sequência de dias consecutivos (Streak) atual.

### 1.3 Lista Card de Hábitos

- **Visual dos Cards:** Cada hábito possui uma cor própria configurável e um ícone identificador (ex: 💧 para água, 🏃 para corrida, 📚 para leitura).
- **Meta e Progresso Visível:** Exibe o progresso diário dentro do card (ex: "3/5 copos" ou "0/1 concluído").
- **Ação de Toque:** Unidade com Haptic Feedback (vibração suave ao completar).
- **Micro-interação de Conclusão:** Ao segurar ou clicar para concluir, uma barra de progresso se preenche de forma fluida e surge um indicador check animado (`flutter_animate`).

### 1.4 Filtros por Categoria

- Chips deslizantes para filtrar a lista por áreas da vida (ex: Saúde, Produtividade, Mente, Finanças).

---

## 2. Fluxo de Criação de Hábito (Modal / Bottom Sheet)

Ao clicar no botão de criar novo hábito, é exibido um formulário suspenso (Bottom Sheet) com as seguintes etapas:

- **Nome do Hábito:** Input simples (ex: "Beber 2L de Água").
- **Frequência:** Opções para Diário, Dias da Semana específicos ou X vezes por semana.
- **Meta Diária:** Definição de quantidade (ex: 1 vez, 30 minutos, 2000 ml).
- **Notificação/Lembrete:** Horário do alerta com acionamento do alarme local do dispositivo.
- **Personalização Visual:** Seletor de Cor + Seletor de Ícone.

---

## 3. Especificação de Requisitos Técnicos

### 3.1 Requisitos Funcionais (RF)

- **RF-HB-01:** Exibir os hábitos do usuário filtrados pelo dia selecionado na fita de calendário semanal.
- **RF-HB-02:** Permitir registrar a conclusão (parcial ou total) de um hábito com persistência offline instantânea.
- **RF-HB-03:** Calcular dinamicamente o número de dias seguidos (Streak) de cada hábito.
- **RF-HB-04:** Permitir criar, editar e deletar hábitos com parâmetros de nome, frequência, meta, ícone, cor e lembrete.
- **RF-HB-05:** Agendar notificações locais usando `flutter_local_notifications` baseando-se no horário do lembrete do hábito.

### 3.2 Requisitos Não-Funcionais e UI (RNF)

- **RNF-HB-01:** Executar animações de progresso e haptic feedback ao concluir qualquer hábito em tempo de resposta < 100ms.
- **RNF-HB-02:** O estado da lista deve reagir instantaneamente via Riverpod Notifier sem necessidade de dar "refresh" na página.

### 3.3 Estrutura de Dados Esperada (Modelo Isar/Hive)

- **`HabitModel`:**
  - `id`: String/Int
  - `title`: String
  - `category`: String
  - `icon`: String (ou codePoint)
  - `colorHex`: String
  - `frequency`: List\<int\> (dias da semana: 1-7)
  - `targetValue`: int
  - `unit`: String (ex: "ml", "min", "vezes")
  - `completedDates`: List\<DateTime\>
  - `streakCount`: int
