# Refatoração guiada por princípios

Plano para levar o código de "organizado por pastas" a "arquitetura que se
sustenta", em etapas pequenas, cada uma numa branch própria e com um commit
por mudança.

| Etapa | Foco | Status |
| --- | --- | --- |
| [1 — Fundação](etapa-1-fundacao.md) | Dependências, repositórios, regras no domínio, primeiros testes | ✅ concluída |
| [2 — Qualidade](etapa-2-qualidade.md) | Testes de widget, lints mais rígidos, CI no GitHub Actions | ✅ concluída |
| [3 — Clean Code](etapa-3-clean-code.md) | Timer de foco por horário de término, quebrar telas grandes, `ThemeExtension`, `core/` independente, dependências não usadas | ✅ concluída |
| [4 — Documentação de produto](etapa-4-produto.md) | Requisitos com critérios de aceite, rastreabilidade, casos de uso, README de vitrine | ✅ concluída |

Diagnóstico que originou o plano: [revisão de arquitetura](revisao-de-arquitetura.md).
