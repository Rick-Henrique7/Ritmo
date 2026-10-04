# Etapa 4 — Documentação de produto

- **Branch:** `docs/etapa-4-produto`
- **Objetivo:** fazer a documentação de produto descrever o app **que existe**,
  com critérios para verificar cada requisito e o caminho de cada um até o
  código e os testes.

## 1. Ponto de partida

O PRD e as specs por tela foram escritos **antes** do código, como visão. Ao
compará-los com o app, apareceram três tipos de divergência:

| Tipo | Exemplos |
| --- | --- |
| Tecnologia que mudou | Isar/Hive → SharedPreferences; `fl_chart` → gráficos próprios; "Dark Mode padrão" → Editorial claro como padrão |
| Funcionalidade prometida e não feita | lembretes por notificação, reordenar tarefas, gráfico de rosca, subtarefas na interface |
| Funcionalidade feita e não documentada | tarefas recorrentes com conclusão por dia, Desfazer exclusão, dias incompletos no calendário, dois estilos visuais |

Um documento de requisitos que promete o que o app não faz é pior do que
nenhum: quem lê (recrutador, revisor, o próprio autor daqui a seis meses)
perde a confiança no resto.

## 2. O que entrou

| Documento | Conteúdo |
| --- | --- |
| [`requisitos/README.md`](../requisitos/README.md) | Escopo, convenções (IDs, MoSCoW, status), resumo e **backlog priorizado** |
| [`requisitos/funcionais.md`](../requisitos/funcionais.md) | 38 requisitos com critérios **Dado / Quando / Então**; partes não feitas marcadas item a item |
| [`requisitos/nao-funcionais.md`](../requisitos/nao-funcionais.md) | 10 requisitos, cada um com forma de verificar |
| [`requisitos/casos-de-uso.md`](../requisitos/casos-de-uso.md) | 7 casos de uso com fluxos alternativos |
| [`requisitos/rastreabilidade.md`](../requisitos/rastreabilidade.md) | Requisito → código → teste → caso de uso, mais as lacunas de teste |
| [`PRD.md`](../PRD.md) | Reescrito como visão: problema, público, objetivos mensuráveis, marcos |
| [`design.md`](../design.md) | Reescrito com os dois estilos e os tokens reais da `AppPalette` |
| `README.md` | Vitrine: o app, os destaques de engenharia, como rodar |

As specs originais por tela foram mantidas, com um aviso de que registram a
visão inicial: o histórico de como o produto foi pensado também tem valor.

## 3. Achados

O levantamento revelou dois pontos que **bloqueiam a publicação** e foram
para o topo do backlog:

1. **`applicationId` do template** (`com.gestao.pessoal.gestao_pessoal`).
   Depois de publicado, não pode mudar.
2. **Fonte do Liquid Glass baixada da internet.** Sem conexão, a DM Sans não
   carrega e o estilo cai na fonte padrão. Além disso, o manifesto principal
   não declara a permissão `INTERNET`, então no build de release o download
   pode nunca acontecer (falta confirmar no aparelho). Embutir a fonte
   resolve os dois casos e elimina uma requisição de rede, o que importa para
   a declaração de privacidade.

Os dois foram resolvidos em seguida, na branch `fix/publicacao-android`: o ID
passou a ser `com.aevumtech.ritmo` e a DM Sans foi embutida, com a remoção
do `google_fonts`.

Situação ao fim da etapa: **25 de 38** requisitos funcionais completos, 6
parciais e 7 no backlog. Depois, o uso real gerou o RF-TD-09 (tarefas
atrasadas e virada do dia).
