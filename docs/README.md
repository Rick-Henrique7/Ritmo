# Documentação do Ritmo

![Ciclo de vida de desenvolvimento](assets/ciclo-de-vida.svg)

## Produto
- [Visão de produto](PRD.md) — problema, público, objetivos, marcos
- [Requisitos](requisitos/README.md) — [funcionais](requisitos/funcionais.md) ·
  [não funcionais](requisitos/nao-funcionais.md) ·
  [casos de uso](requisitos/casos-de-uso.md) ·
  [rastreabilidade](requisitos/rastreabilidade.md) · backlog
- [Design visual](design.md) — os dois estilos e seus tokens
- Specs originais de interface: [Hoje](dashboard.md) · [Hábitos](habitos.md) ·
  [Tarefas](to-do.md) · [Foco](pomodoro.md) · [Estatísticas](estatistica.md)

## Engenharia
- [Arquitetura](arquitetura.md) — camadas, dependências, fluxo de dados, persistência
- [Decisões de arquitetura (ADRs)](adr/README.md)
- [Estratégia de testes](qualidade/testes.md)

## Processo
- [Ciclo de vida de desenvolvimento](processo/ciclo-de-vida.md) — modelo,
  branches, commits, versionamento, critérios de pronto, release
- [Refatoração por etapas](refatoracao/README.md) —
  [revisão de arquitetura](refatoracao/revisao-de-arquitetura.md) ·
  [etapa 1](refatoracao/etapa-1-fundacao.md) ·
  [etapa 2](refatoracao/etapa-2-qualidade.md) ·
  [etapa 3](refatoracao/etapa-3-clean-code.md) ·
  [etapa 4](refatoracao/etapa-4-produto.md)

## Imagens
Os diagramas em `assets/` são SVG gerados a partir de código, no estilo
editorial do app. Diagramas em Mermaid ficam dentro dos próprios documentos
e são renderizados pelo GitHub.
