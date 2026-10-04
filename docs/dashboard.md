# UI & Feature Spec — Tela de Dashboard (Hoje)

> **Visão original de interface.** O que está implementado hoje, com status e
> critérios de aceite, está em [requisitos funcionais](requisitos/funcionais.md).
> Itens desta spec que não aparecem lá como ✅ estão no backlog ou foram
> descartados.

> **Objetivo:** Oferecer um panorama imediato do dia do usuário, combinando
> hábitos, tarefas e estatísticas com foco em alta legibilidade e apelo visual.

---

## 1. Componentes e Regras da Interface (UI/UX)

### 1.1 Header Dinâmico

- Exibe saudação personalizada de acordo com o horário do dia (ex: "Bom dia", "Boa tarde", "Boa noite") acompanhada do nome do usuário.
- Exibe a data atual por extenso e um ícone de perfil/configurações no canto superior direito.

### 1.2 Anel de Progresso Diário (Daily Progress Ring)

- Um gráfico circular animado que mostra a porcentagem global de conclusão do dia (combinação de tarefas concluídas + hábitos cumpridos).
- Subtexto no centro do anel informando o total (ex: "6/10 concluídos").

### 1.3 Card "Próximo Foco"

- Destaque visual em formato de card em alto contraste apontando a próxima tarefa com horário definido ou o hábito pendente mais próximo.
- Botão de ação rápida no próprio card para concluir a tarefa com animação e haptic feedback.

### 1.4 Sessão "Hoje no Radar"

- Lista de tarefas e hábitos programados para o dia atual dispostos em linha do tempo (Timeline).
- Design estilo Checkbox estilizado que ativa micro-interação ao ser marcado.

### 1.5 Barra de Navegação / FAB (Floating Action Button)

- Menu inferior suspenso com efeito translúcido (Glassmorphism).
- Botão central destacado com ícone de `+` que abre uma folha inferior (Bottom Sheet) para criação rápida de Tarefa ou Hábito.

---

## 2. Especificação de Requisitos da Tela

### 2.1 Requisitos Funcionais (RF)

- **RF-DB-01:** Calcular dinamicamente a taxa de progresso diário `((tarefas_concluidas + habitos_concluidos) / total_do_dia * 100)`.
- **RF-DB-02:** Permitir a conclusão rápida de qualquer item (tarefa ou hábito) diretamente pelo Dashboard sem mudar de tela.
- **RF-DB-03:** Exibir modal/bottom-sheet de criação rápida ao clicar no botão flutuante (`+`).
- **RF-DB-04:** Atualizar a saudação do header com base no relógio do dispositivo local.

### 2.2 Especificações do Componente Flutter

- **Layout Base:** `CustomScrollView` com Slivers para rolagem suave do header.
- **Biblioteca de Animações:** `flutter_animate` para entrada suave dos cards.
- **Gerenciamento de Estado:** `NotifierProvider` (Riverpod) escutando as mudanças na lista de tarefas e hábitos do dia.
