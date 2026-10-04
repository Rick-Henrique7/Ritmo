# Changelog

Todas as mudanças notáveis neste projeto serão documentadas aqui.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Corrigido
- Tarefas concluídas no dia anterior continuavam na tela Hoje: o "hoje" do app
  dependia de um timer até a meia-noite que atrasa com o celular dormindo.
  Agora a data é conferida a cada minuto e ao voltar do segundo plano.
- Tarefa recorrente ficava concluída para sempre; agora a conclusão é por dia
  e ela volta a ficar pendente na próxima ocorrência (dados antigos migrados).
- Tarefas não contavam em "Feitos hoje" e a tela Hoje divergia da aba Hoje.
- Sequência de hábitos não zerava ao perder dias; agora é calculada.
- Estatísticas não atualizavam após uma sessão de foco.
- Gráfico "Ano" contava só o mesmo dia de cada mês.
- Um registro corrompido no armazenamento podia fechar o app.
- Timer de foco atrasava ou parava com o app em segundo plano; agora calcula
  o tempo pelo horário de término.
- Botão "Parar" do foco só pausava; agora volta ao tempo cheio do modo.
- Fim de uma sessão de foco não tocava som nem vibrava, apesar da opção
  "Som de conclusão".

### Adicionado
- Tela fica acesa enquanto o timer de foco está rodando.
- Tarefa pontual não feita continua em Hoje nos dias seguintes, com a marca
  "Atrasada", até ser concluída. A aba Próximas passa a mostrar só datas
  futuras. Concluídas somem no dia seguinte (o histórico é mantido para as
  Estatísticas).

### Alterado
- `applicationId` definitivo para a Play Store: `com.aevumtech.dailyflow`.
- Fonte DM Sans (Liquid Glass) embutida no app; removido `google_fonts`. O app
  não faz mais nenhuma requisição de rede e funciona igual offline.

### Performance
- Provider de hábitos do dia criava uma instância nova a cada rebuild (chave
  com segundos) sem liberar; agora chave estável + `autoDispose`.
- Calendário de hábitos e estatísticas memoizados em providers.
- `SoundService` liberado ao ser recriado.

### Arquitetura
- Repositórios com interface no domínio; implementação `SharedPreferences` em `data/`.
- Providers de infraestrutura em `core/`; fim da dependência circular `settings ↔ habits`.
- Regras de negócio puras: `TaskSchedule`, `HabitStreak`, `HabitCalendar`, `StatsCalculator`.
- 35 testes unitários.
- Paleta de cores como `ThemeExtension` (`context.palette`) no lugar de
  estado global; troca de estilo animada e sem recriar a árvore.
- Telas de Hábitos, Tarefas e Configurações divididas em tela, diálogo de
  formulário e widgets menores (de ~1.000 para 180–350 linhas).
- Componentes repetidos unificados em `core/` (seletor de dias, diálogo de
  exclusão, fundo de deslizar, conversão de cor hexadecimal).
- `core/` não depende mais de nenhuma feature; casca do app em `lib/shell/`.
- Regras do ciclo de foco puras em `PomodoroCycle`; relógio injetável.
- Removidas dependências sem uso: `flutter_local_notifications`, `vibration`,
  `flutter_colorpicker`; removido widget morto `DailyProgressRing`.

### Qualidade
- Integração contínua no GitHub Actions: análise estática e testes a cada push e pull request.
- 4 testes de widget do app real (tela Hoje, estado vazio, abas de Tarefas, Configurações).
- 16 testes do timer de foco com relógio falso (55 no total).
- Lints extras no `analysis_options.yaml`.
- Números grandes da tela Hoje e de Hábitos encolhem em telas estreitas ou com fonte aumentada.
- APK removido do controle de versão.

### Documentação
- `docs/`: arquitetura, ADRs 0001–0008, ciclo de vida, estratégia de testes
  e registros das etapas 1 a 4, com diagramas (SVG e Mermaid).
- Requisitos: 38 funcionais e 10 não funcionais com critérios de aceite e
  status, 7 casos de uso, matriz de rastreabilidade e backlog priorizado.
- Visão de produto, design e README reescritos para refletir o app atual.

### Performance
- **Pomodoro (aba Foco)**: removidas chamadas a `GoogleFonts.spaceGrotesk()`
  e `GoogleFonts.inter()` que disparavam download sob demanda de `fonts.gstatic.com`
  na primeira entrada na aba, causando delay visível de 1–3s. Agora todo o texto
  do timer usa DM Sans via `Theme.of(context).textTheme`, já cacheado.
- Removida animação `.fadeIn(400ms).scale()` que adicionava 400ms ao iniciar
  o timer.

### Estrutura
- Adicionados `LICENSE` (Apache 2.0), `.editorconfig`, `lib/features/README.md`.
- Limpeza de logs de build temporários (`.log`, `.iml`).
- Documentada a arquitetura em camadas (data/domain/presentation).

## [0.1.0] — 2026-09-21

### Adicionado
- Pomodoro com ciclo completo Foco → Pausa Curta → Pausa Longa (botão
  "próximo" corrigido para ciclar pelos 3 modos).
- Configurações reativas: cor de texto + cor de destaque (accent) editáveis
  pelo usuário, com botões "Restaurar padrão".
- Wallpaper animado **ou** cor sólida (toggle em Configurações).
- Haptics + som de conclusão em tarefa/hábito (toggles independentes).
- Botão de excluir em diálogo de edição de hábito.
- Tridente minimalista (fundo branco + preto) como ícone do app.
- Build web com `Icon-1024` + `Icon-maskable-1024` para PWA/HiDPI.
- Token `textSecondary` clareado para #B0B0B0 e `textTertiary` para
  #8A8A8A (compliance WCAG AA+).
- Documentação: README institucional, diagrama ASCII de arquitetura,
  tabela de tokens de cor, changelog.

### Corrigido
- Filtro "Todas" esconde concluídas com `dueDate` no passado.
- Filtro "Hoje" inclui tarefas ad-hoc (sem data/recorrência).
- Filtro "Próximas" só com pontuais futuras + atrasadas.

## [0.0.1] — 2026-08-15

### Adicionado
- Build base do Daily Flow: 5 telas (Hoje/Hábitos/Tarefas/Foco/Stats) +
  Configurações, com Riverpod + GoRouter.
- Persistência local via SharedPreferences.
- Liquid Glass 3D (shaders + jelly) via `liquid_glass_widgets`.
- Calendário Syncfusion para hábitos (mês com appointments).
- Tema Dark/Green único, fonte DM Sans, sem glassmorphism no conteúdo.

[Não lançado]: https://github.com/Rick-Henrique7/Daily-Flow/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Rick-Henrique7/Daily-Flow/releases/tag/v0.1.0
[0.0.1]: https://github.com/Rick-Henrique7/Daily-Flow/releases/tag/v0.0.1
