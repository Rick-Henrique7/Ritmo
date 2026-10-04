# Requisitos funcionais

> O que o app faz, área por área, com **critérios de aceite** verificáveis.
> Convenções (IDs, prioridade, status) em [README](README.md). Onde cada
> requisito está no código e qual teste o cobre:
> [rastreabilidade](rastreabilidade.md).

Os critérios seguem o formato **Dado / Quando / Então**: o estado inicial, a
ação do usuário e o resultado observável. Um requisito só é ✅ quando todos os
critérios dele passam.

---

## 1. Hoje (`DB`)

Tela inicial: o que o dia pede e o quanto já foi feito.

| ID | Requisito | Prioridade | Status |
| --- | --- | --- | --- |
| RF-DB-01 | Mostrar o progresso do dia somando hábitos e tarefas previstos para hoje | Must | ✅ |
| RF-DB-02 | Concluir ou reabrir um item direto da lista "Hoje no radar" | Must | ✅ |
| RF-DB-03 | Botão **+** abre a criação rápida de hábito ou tarefa | Should | 🟡 |
| RF-DB-04 | Saudação conforme a hora do dia e data por extenso | Could | ✅ |
| RF-DB-05 | Estado vazio com convite para criar o primeiro item | Should | ✅ |

**RF-DB-01 — Progresso do dia**
- Dado 2 itens previstos para hoje e nenhum feito, quando abro a tela Hoje,
  então vejo "00 / 02" e o total de pendentes.
- Dado que concluo 1 dos 2, então o contador passa a "01 / 02" e a barra de
  progresso avança, sem recarregar a tela.
- Uma tarefa recorrente feita hoje continua contando no total do dia (não
  some do progresso ao ser concluída).

**RF-DB-02 — Concluir pela tela Hoje**
- Dado um hábito ou tarefa pendente na lista, quando toco na linha, então ele
  fica marcado como feito e o progresso atualiza.
- Quando toco de novo, então ele volta a pendente.

**RF-DB-03 — Criação rápida** 🟡
- ✅ Quando toco em **+**, então aparece uma folha com "Novo hábito" e
  "Nova tarefa".
- ⬜ Quando escolho uma opção, então o formulário correspondente abre
  direto. *Hoje a opção só navega para a tela; é preciso tocar no + de lá.*

**RF-DB-04 — Saudação**
- Das 5h às 11h59 a saudação é "Bom dia"; das 12h às 17h59, "Boa tarde"; no
  restante, "Boa noite".
- A data aparece por extenso em português (ex.: "quinta-feira, 1 de outubro").

**RF-DB-05 — Estado vazio**
- Dado que não há nada previsto para hoje, então vejo a mensagem de dia livre
  e um atalho para criar um hábito.

---

## 2. Hábitos (`HB`)

Rotinas que se repetem em dias da semana escolhidos.

| ID | Requisito | Prioridade | Status |
| --- | --- | --- | --- |
| RF-HB-01 | Calendário mensal; a lista mostra os hábitos previstos para o dia selecionado | Must | ✅ |
| RF-HB-02 | Marcar e desmarcar a conclusão de um hábito em um dia, com vibração e som | Must | ✅ |
| RF-HB-03 | Calcular a sequência (streak) de dias previstos cumpridos | Must | 🟡 |
| RF-HB-04 | Criar, editar e excluir hábitos | Must | ✅ |
| RF-HB-05 | Lembrete por notificação no horário configurado | Should | ⬜ |
| RF-HB-06 | Destacar no calendário os dias com hábito previsto e não feito | Could | ✅ |

**RF-HB-01 — Hábitos do dia**
- Dado um hábito com frequência seg/qua/sex, quando seleciono uma quarta no
  calendário, então ele aparece na lista; numa terça, não aparece.
- Os dias com conclusão mostram um marcador colorido no calendário.

**RF-HB-02 — Concluir hábito**
- Dado um hábito pendente no dia selecionado, quando toco no botão de check,
  então ele fica concluído naquele dia, o aparelho vibra (se ativado) e toca
  o som de conclusão (se ativado).
- Quando toco de novo, então a conclusão daquele dia é removida, sem som.
- A conclusão fica gravada e continua lá depois de fechar e abrir o app.

**RF-HB-03 — Sequência** 🟡
- ✅ A sequência conta só os dias **previstos** na frequência: dias fora dela
  não quebram a contagem.
- ✅ Um dia previsto que passou sem conclusão zera a sequência; hoje ainda
  não feito não zera.
- ✅ A tela mostra a **maior** sequência atual entre todos os hábitos.
- ⬜ Cada cartão mostra a sequência do próprio hábito.

**RF-HB-04 — Gerenciar hábitos**
- Quando crio um hábito, informo: nome (obrigatório), categoria, ícone, cor,
  dias da semana, meta e unidade, duração estimada e horário de lembrete.
- Sem nome, o botão de salvar não cria o hábito.
- Quando toco num cartão, então o formulário abre preenchido para edição.
- Quando excluo (pelo formulário ou deslizando o cartão para a esquerda),
  então o app pede confirmação e, depois de excluir, oferece **Desfazer**
  por alguns segundos.

**RF-HB-05 — Lembretes** ⬜
- Dado um hábito com lembrete às 7h em dias previstos, então às 7h desses
  dias chega uma notificação, mesmo com o app fechado.
- *O horário já é salvo no hábito; falta agendar a notificação.*

**RF-HB-06 — Dias incompletos**
- Dado um dia passado, dos últimos 90, com hábito previsto e não feito,
  então o calendário marca esse dia em tom neutro.

---

## 3. Tarefas (`TD`)

Afazeres pontuais (com data) ou recorrentes (em dias da semana).

| ID | Requisito | Prioridade | Status |
| --- | --- | --- | --- |
| RF-TD-01 | Criar, editar e excluir tarefas; subtarefas | Must | 🟡 |
| RF-TD-02 | Reordenar tarefas arrastando | Won't (v0.x) | ⬜ |
| RF-TD-03 | Abas Todas · Hoje · Próximas · Concluídas | Must | ✅ |
| RF-TD-04 | Excluir deslizando, com confirmação e Desfazer | Should | ✅ |
| RF-TD-05 | Notificação no horário da tarefa | Should | ⬜ |
| RF-TD-06 | Tarefa recorrente com conclusão **por dia** | Must | ✅ |
| RF-TD-07 | Prioridade, categoria, data e hora | Must | ✅ |
| RF-TD-08 | Filtros por categoria e prioridade, e busca | Could | ⬜ |
| RF-TD-09 | Tarefa atrasada continua em Hoje, marcada, até ser feita; concluída some no dia seguinte | Must | ✅ |

**RF-TD-01 — Gerenciar tarefas** 🟡
- ✅ Quando crio uma tarefa, informo título, prioridade, categoria, data, hora
  e, opcionalmente, dias de repetição. Sem título, ela não é criada.
- ✅ Quando toco num cartão, então o formulário abre para edição.
- ✅ O cartão mostra o progresso das subtarefas ("Sub-tarefas: 1/3").
- ⬜ Adicionar, marcar e remover subtarefas pela interface. *O modelo e o
  controller já suportam; falta a tela.*
- ⬜ Campo de descrição no formulário.

**RF-TD-02 — Reordenar** ⬜
- Fora do escopo atual: a lista é ordenada por data e hora, que é o que o uso
  diário pediu. Reavaliar se surgir demanda.

**RF-TD-03 — Abas**
- **Hoje:** tarefas do dia ainda não feitas: pontuais com data de hoje,
  recorrentes previstas para o dia da semana, avulsas (sem data e sem
  repetição) e **atrasadas** (RF-TD-09).
- **Próximas:** abertas com data futura, em ordem de data.
- **Concluídas:** pontuais concluídas e recorrentes feitas hoje, mais
  recentes primeiro.
- **Todas:** abertas (inclusive atrasadas), recorrentes e concluídas de hoje
  em diante; concluídas de dias passados ficam só em "Concluídas".
- Cada aba vazia mostra uma mensagem própria.

**RF-TD-04 — Excluir deslizando**
- Quando deslizo um cartão para a esquerda, então o app pede confirmação; se
  a tarefa é recorrente, o aviso diz que todas as ocorrências serão
  excluídas.
- Depois de excluir, aparece **Desfazer**; ao tocar, a tarefa volta igual.

**RF-TD-05 — Notificações** ⬜
- Dado uma tarefa com data e hora, então no horário chega uma notificação,
  mesmo com o app fechado.

**RF-TD-06 — Recorrência**
- Dado uma tarefa que repete ter/qua/qui/sex, quando a concluo na terça,
  então na quarta ela volta a aparecer pendente em "Hoje".
- Desmarcar remove só a conclusão daquele dia.
- Tarefas recorrentes salvas no formato antigo (um único "concluída") são
  migradas sem perder dados.

**RF-TD-09 — Atrasadas e virada do dia**
- Dado uma tarefa do dia 10 não feita, quando chega o dia 11, então ela
  continua em "Hoje" (aba e tela inicial) com a marca **Atrasada**, até ser
  concluída.
- Dado uma tarefa do dia 10 concluída, quando chega o dia 11, então ela não
  aparece mais em "Hoje"; fica só em "Concluídas" e nas Estatísticas.
- Uma tarefa com data futura só entra em "Hoje" no próprio dia; antes disso,
  fica em "Próximas".
- Recorrentes nunca ficam atrasadas: o dia perdido não passa para o seguinte.
- A virada é percebida ao voltar o app do segundo plano, sem precisar
  fechá-lo.
- Nada é apagado: o histórico de concluídas alimenta as Estatísticas.

**RF-TD-07 — Atributos**
- A prioridade (baixa, média, alta) aparece como uma barra colorida no
  cartão.
- O cabeçalho mostra quantas tarefas estão pendentes ou "Tudo em dia".

---

## 4. Foco (`PO`)

Timer Pomodoro: blocos de foco intercalados com pausas.

| ID | Requisito | Prioridade | Status |
| --- | --- | --- | --- |
| RF-PO-01 | Timer regressivo com os modos Foco (25), Pausa curta (5) e Pausa longa (15) | Must | ✅ |
| RF-PO-02 | Ao terminar, passar sozinho para o próximo modo do ciclo | Must | ✅ |
| RF-PO-03 | Vincular a sessão a uma tarefa | Should | 🟡 |
| RF-PO-04 | Avisar o fim da sessão com som e vibração | Must | 🟡 |
| RF-PO-05 | Manter a tela acesa enquanto o timer roda | Should | ✅ |
| RF-PO-06 | Tempo correto mesmo com o app em segundo plano | Must | ✅ |
| RF-PO-07 | Iniciar, pausar, parar e pular | Must | ✅ |
| RF-PO-08 | Durações configuráveis pelo usuário | Could | ⬜ |

**RF-PO-01 — Modos**
- O app abre em Foco com 25:00. Ao escolher Pausa curta ou Pausa longa, o
  mostrador vai para 05:00 ou 15:00.
- O mostrador nunca mostra 00:00 antes do tempo acabar de fato.

**RF-PO-02 — Ciclo**
- Focos 1, 2 e 3 levam à pausa curta; o 4º foco leva à pausa longa; qualquer
  pausa leva de volta ao foco.
- O próximo modo fica pronto, mas só começa quando o usuário inicia.
- Cada foco concluído é gravado no histórico (aparece em Estatísticas).

**RF-PO-03 — Vincular tarefa** 🟡
- ✅ Posso escolher uma tarefa pendente para a sessão; a sessão gravada guarda
  a tarefa.
- ⬜ A tarefa mostra quanto tempo de foco já recebeu.

**RF-PO-04 — Aviso de fim** 🟡
- ✅ Com o app aberto, ao terminar a sessão o aparelho vibra e toca o som
  (respeitando as configurações).
- ⬜ Com o app em segundo plano, chega uma notificação no horário do término.
  *Hoje a sessão é concluída e registrada corretamente, mas o aviso só
  acontece ao voltar para o app.*

**RF-PO-05 — Tela acesa**
- Enquanto o timer roda, a tela não apaga sozinha; ao pausar ou parar, volta
  a seguir a regra do sistema.

**RF-PO-06 — Segundo plano**
- Dado um foco iniciado às 9h00, se o app fica minimizado até 9h24 e eu volto,
  então o mostrador mostra 01:00.
- Se eu volto depois das 9h25, a sessão aparece como concluída **uma única
  vez**, registrada como iniciada às 9h00.

**RF-PO-07 — Controles**
- **Pausar** congela o tempo; o tempo pausado não conta. **Iniciar** retoma de
  onde parou.
- **Parar** volta ao tempo cheio do modo atual, sem gravar sessão.
- **Pular** avança Foco → Pausa curta → Pausa longa → Foco, sem gravar sessão.

---

## 5. Estatísticas (`ST`)

| ID | Requisito | Prioridade | Status |
| --- | --- | --- | --- |
| RF-ST-01 | Indicadores: tarefas concluídas, minutos de foco e maior sequência, com filtro Semana · Mês · Ano | Must | 🟡 |
| RF-ST-02 | Gráfico de barras de conclusões no período | Must | ✅ |
| RF-ST-03 | Mapa de consistência dos hábitos (últimas 8 semanas) | Should | ✅ |
| RF-ST-04 | Distribuição por categoria (gráfico de rosca) | Could | ⬜ |

**RF-ST-01 — Indicadores** 🟡
- ✅ Vejo o total de tarefas concluídas, os minutos de foco e a maior sequência.
- ✅ Uma tarefa recorrente conta uma vez por dia em que foi feita.
- ✅ Minutos de foco somam só sessões de **foco** concluídas (pausas não
  contam).
- ⬜ Os indicadores respeitam o período escolhido. *Hoje o filtro muda só o
  gráfico; os indicadores são do histórico todo.*

**RF-ST-02 — Gráfico de barras**
- Semana: 7 barras terminando hoje. Mês: 30 barras. Ano: 12 barras, cada uma
  com o **mês inteiro**.

**RF-ST-03 — Mapa de consistência**
- Cada um dos últimos 56 dias aparece preenchido se ao menos um hábito foi
  concluído nele.

---

## 6. Configurações (`CF`)

| ID | Requisito | Prioridade | Status |
| --- | --- | --- | --- |
| RF-CF-01 | Escolher o estilo visual: Editorial ou Liquid Glass | Must | ✅ |
| RF-CF-02 | Cor de destaque personalizável, com restaurar padrão | Should | ✅ |
| RF-CF-03 | Fundo do Liquid Glass: gradiente animado ou cor sólida; cor e intensidade | Could | ✅ |
| RF-CF-04 | Ligar e desligar vibração e som de conclusão | Must | ✅ |
| RF-CF-05 | Cor do anel do timer para cada modo | Could | ✅ |
| RF-CF-06 | Restaurar as configurações padrão sem apagar dados | Should | ✅ |
| RF-CF-07 | Exportar e importar backup dos dados | Should | ⬜ |

**RF-CF-01 — Estilo visual**
- Quando escolho um estilo, então o app inteiro muda na hora, com transição
  animada, e a escolha continua depois de reabrir o app.

**RF-CF-04 — Vibração e som**
- Com a vibração desligada, nenhuma ação vibra. Com o som desligado, nenhuma
  conclusão toca som (tarefa, hábito ou foco).

**RF-CF-06 — Restaurar padrões**
- Quando toco em "Restaurar padrões", então cores, fundo e feedback voltam ao
  padrão; hábitos, tarefas e histórico de foco continuam intactos.

**RF-CF-07 — Backup** ⬜
- Posso exportar um arquivo com todos os dados e importá-lo em outro aparelho.
  *Importante por ser um app sem conta e sem nuvem: trocar de celular hoje
  perde os dados.*

---

## Limitações conhecidas

- É possível marcar hábitos em dias **futuros** pelo calendário.
- A opção de saturação do fundo existe nas configurações salvas, mas não tem
  controle na tela.
