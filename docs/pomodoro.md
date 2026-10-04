# UI & Feature Spec — Tela de Timer de Foco (Pomodoro)

> **Visão original de interface.** O que está implementado hoje, com status e
> critérios de aceite, está em [requisitos funcionais](requisitos/funcionais.md).
> Itens desta spec que não aparecem lá como ✅ estão no backlog ou foram
> descartados.

> **Objetivo:** Proporcionar um ambiente imersivo e livre de distrações para a
> execução das tarefas, utilizando a técnica Pomodoro (ciclos de trabalho
> focados seguidos de pausas) com um design minimalista e agradável.

---

## 1. Componentes da Interface (UI/UX)

### 1.1 Timer Circular Animado (O Coração da Tela)

- **Visual:** Um grande círculo minimalista no centro da tela. A borda do círculo atua como uma barra de progresso que vai esvaziando (ou preenchendo) suavemente conforme os segundos passam.
- **Tipografia:** Tempo restante (ex: `24:59`) exibido no centro do círculo com uma fonte limpa, grande e monoespaçada (para os números não "pularem" ao mudar).

### 1.2 Card de Tarefa Atual

- Um componente elegante logo abaixo ou acima do timer, indicando qual tarefa do Gerenciador de Tarefas está sendo executada no momento.
- Permite tocar para trocar a tarefa em foco sem precisar sair da tela.

### 1.3 Controles de Reprodução (Play/Pause/Stop)

- Botões flutuantes ou integrados de forma minimalista.
- **Ações:** Iniciar (Play), Pausar (Pause), Parar/Cancelar (Stop) e Pular para o Intervalo (Skip).
- **Micro-interações:** O botão de "Play" pode se transformar fluidamente em um botão de "Pause" (usando `AnimatedIcon` no Flutter).

### 1.4 Indicador de Sessões (Marcador de Ciclos)

- Pequenos pontos ou ícones de "tomates" na parte inferior que indicam quantos ciclos de foco já foram concluídos na sessão atual. (Ex: 3 bolinhas preenchidas e 1 vazia para o 4º ciclo).

### 1.5 Modo Zen / Foco Profundo

- **Tela Ativa:** Opção para manter a tela do celular sempre ligada (Wakelock) enquanto o timer estiver rodando, exibindo apenas o relógio em um fundo escuro (OLED Dark Mode) para economizar bateria.
- **Sons Ambientes (Opcional):** Um botão discreto para ativar ruído branco, chuva ou sons de cafeteria (Lo-Fi).

---

## 2. Fluxos do Timer (Regras de Negócio)

- **Ciclo Padrão:** 25 minutos de Foco → 5 minutos de Pausa Curta. A cada 4 ciclos de Foco → 15 minutos de Pausa Longa.
- **Transições:** Ao zerar o cronômetro, o app deve emitir um alerta sonoro e vibrar (mesmo em segundo plano), alternando a interface automaticamente para o modo de "Pausa" (mudando a paleta de cores, por exemplo, de vermelho/laranja para azul/verde relaxante).

---

## 3. Especificação de Requisitos Técnicos

### 3.1 Requisitos Funcionais (RF)

- **RF-PO-01:** Implementar cronômetro regressivo com tempos configuráveis para Foco, Pausa Curta e Pausa Longa.
- **RF-PO-02:** Alternar estado do ciclo automaticamente (Foco ↔ Pausa) ao término do tempo.
- **RF-PO-03:** Permitir vincular a sessão de foco a uma tarefa específica (`TaskModel`) e atualizar o tempo investido nela.
- **RF-PO-04:** Disparar notificações locais e som de alarme quando o timer zerar, mesmo se o app estiver em background (usando `flutter_local_notifications` e isolados se necessário).
- **RF-PO-05:** Suportar manter a tela ativa durante o foco usando o pacote `wakelock_plus`.

### 3.2 Requisitos Não-Funcionais e UI (RNF)

- **RNF-PO-01:** A animação circular do timer não deve consumir processamento excessivo (usar `CustomPaint` otimizado ou `TweenAnimationBuilder`).
- **RNF-PO-02:** A transição visual entre o modo "Foco" e "Pausa" deve envolver uma mudança na paleta de cores da tela de forma fluida.

### 3.3 Estrutura de Dados Esperada (Modelo Isar/Hive)

- **`PomodoroSessionModel`:**
  - `id`: String/Int
  - `taskId`: String? (opcional)
  - `startTime`: DateTime
  - `durationMinutes`: int
  - `isCompleted`: bool
  - `type`: Enum (`focus`, `shortBreak`, `longBreak`)
