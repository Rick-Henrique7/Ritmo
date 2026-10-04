# Registros de decisão de arquitetura (ADRs)

Cada ADR registra **uma** decisão: o contexto, o que foi decidido, as
alternativas consideradas e as consequências. ADRs não são editados depois de
aceitos — se a decisão mudar, um novo ADR o substitui.

| Nº | Decisão | Status |
| --- | --- | --- |
| [0001](0001-arquitetura-por-feature.md) | Organização por feature com camadas presentation / data / domain | Aceito |
| [0002](0002-providers-em-core.md) | Providers de infraestrutura em `core/` e features agregadoras | Aceito |
| [0003](0003-repositorios.md) | Repositórios com interface no domínio, SharedPreferences na implementação | Aceito |
| [0004](0004-regras-de-dominio-puras.md) | Regras de negócio como funções puras e `todayProvider` | Aceito |
| [0005](0005-dois-estilos-visuais.md) | Dois estilos visuais (Editorial e Liquid Glass) | Aceito — dívida resolvida pelo 0006 |
| [0006](0006-paleta-como-theme-extension.md) | Paleta como `ThemeExtension` lida por `context.palette` | Aceito |
| [0007](0007-timer-pelo-horario-de-termino.md) | Timer de foco pelo horário de término e relógio injetável | Aceito |
| [0008](0008-shell-fora-do-core.md) | Casca do app (`shell/`) fora do `core/` | Aceito |
| [0009](0009-notificacoes-locais.md) | Notificações locais reagendadas a partir do estado | Aceito |

Modelo: [`template.md`](template.md).
