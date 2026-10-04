# UI & Feature Spec — Tela de Gerenciador de Tarefas (To-Do)

> **Visão original de interface.** O que está implementado hoje, com status e
> critérios de aceite, está em [requisitos funcionais](requisitos/funcionais.md).
> Itens desta spec que não aparecem lá como ✅ estão no backlog ou foram
> descartados.

> **Objetivo:** Oferecer uma gestão visual, intuitiva e eficiente de afazeres
> diários e pontuais, com suporte a priorização, categorização, datas de
> entrega e ordenação interativa.

---

## 1. Componentes da Interface (UI/UX)

### 1.1 Barra Superior de Busca e Filtros Rápidos

- **Campo de Busca (Search Bar):** Para filtragem em tempo real pelo título da tarefa.
- **Filtros por Abas (Tabs/Chips):** Alternância rápida entre Todas, Hoje, Próximas e Concluídas.
- **Seletor de Categoria:** Filtro suspenso ou chips para visualizar tarefas por projeto/área (ex: Trabalho, Estudos, Pessoal).

### 1.2 Lista Interativa de Tarefas (Drag & Drop + Swipe)

- **Agrupamento Inteligente:** As tarefas são divididas por seções dinâmicas (ex: Atrasadas, Hoje, Esta Semana, Sem Data).
- **Drag & Drop (Reordenamento):** Segurar e arrastar o card para reordenar a prioridade de execução do dia.
- **Ações por Gestos (Swipe Actions):**
  - **Deslizar para a direita:** Marcar como concluída rapidamente (com animação verde + som/haptic).
  - **Deslizar para a esquerda:** Deletar ou adiar para o dia seguinte.

### 1.3 Card da Tarefa

- **Checkbox Personalizado:** Animação suave ao selecionar.
- **Indicador Visual de Prioridade:** Borda lateral ou tag colorida destacando o nível:
  - 🔴 **Alta:** Vermelho / Urgente
  - 🟡 **Média:** Amarelo / Normal
  - 🔵 **Baixa:** Azul / Opcional
- **Meta-informações:** Ícones pequenos indicando data/hora limite, tags de categoria e sub-tarefas (ex: "2/4 concluídas").

### 1.4 Botão de Ação Rápida (FAB & Quick Add Bar)

- Além do botão flutuante, a tela permite abrir um campo de texto rápido no rodapé para adicionar uma tarefa digitando e pressionando `Enter` (com tags automáticas por hashtag, ex: `#Trabalho Relatório amanhã`).

---

## 2. Fluxo de Criação e Detalhes da Tarefa (Modal / Sheet)

Ao clicar para adicionar com detalhes ou editar uma tarefa existente:

- **Título e Descrição:** Texto principal com suporte a notas explicativas ou links.
- **Nível de Prioridade:** Seletor de 3 estados (Baixa, Média, Alta).
- **Data e Hora de Lembrete:** Seletor de data (`DatePicker`) e hora para notificação local.
- **Checklist de Sub-tarefas:** Adição de micro-passos dentro da tarefa principal para acompanhamento do progresso.
- **Categoria/Projeto:** Associação do afazer a uma pasta ou contexto específico.

---

## 3. Especificação de Requisitos Técnicos

### 3.1 Requisitos Funcionais (RF)

- **RF-TD-01:** Permitir a criação, edição, visualização e exclusão (CRUD) de tarefas e sub-tarefas.
- **RF-TD-02:** Suportar reordenamento manual de tarefas na lista via arrastar e soltar (Drag and Drop).
- **RF-TD-03:** Oferecer filtros por estado de conclusão, categoria, prioridade e intervalo de datas.
- **RF-TD-04:** Permitir concluir ou adiar tarefas através de gestos de deslizamento (Swipe to Dismiss / Complete).
- **RF-TD-05:** Agendar alertas e notificações push locais para tarefas que possuírem data/hora de vencimento configuradas.

### 3.2 Requisitos Não-Funcionais e UI (RNF)

- **RNF-TD-01:** A interface deve atualizar em tempo real sem engasgos durante a reordenação (suporte a 60fps).
- **RNF-TD-02:** As alterações de status (conclusão/deletar) devem refletir instantaneamente no banco de dados local (Isar/Hive).

### 3.3 Estrutura de Dados Esperada (Modelo Isar/Hive)

- **`TaskModel`:**
  - `id`: String/Int
  - `title`: String
  - `description`: String?
  - `priority`: Enum (`low`, `medium`, `high`)
  - `category`: String
  - `dueDate`: DateTime?
  - `isCompleted`: bool
  - `completedAt`: DateTime?
  - `subtasks`: List\<SubtaskModel\> (id, title, isCompleted)
  - `orderIndex`: int
