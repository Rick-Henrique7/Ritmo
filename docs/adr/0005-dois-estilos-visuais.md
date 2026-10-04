# 0005 — Dois estilos visuais (Editorial e Liquid Glass)

- **Status:** Aceito — a dívida de cores foi resolvida pelo [ADR 0006](0006-paleta-como-theme-extension.md)
- **Data:** 2026-10-01

## Contexto
O visual "Dark/Green" foi considerado pouco atraente. O usuário queria um
estilo editorial (papel creme, coral, painéis grafite) sem perder o Liquid
Glass, que agrada em outros momentos.

## Decisão
`AppStyle { editorial, liquidGlass }` persistido nas configurações. Cada
estilo tem uma `AppPalette` e um `ThemeData` (`AppTheme.build`). Widgets
compartilhados (`LiquidGlassCard`, `GlassNavBar`, `AnimatedBackground`)
mudam de forma conforme o estilo. Fonte Jost embutida (sem download).

## Alternativas consideradas
- **Só o editorial** — mais simples, mas o usuário pediu o glass como opção.
- **`ThemeExtension` desde o início** — correto, mas exigia tocar ~200 usos de
  cor de uma vez; adiado para a etapa 3.

## Consequências
- **Dívida:** `AppColors` guarda a paleta em um campo estático trocado por
  `AppColors.use(style)`; o `AppShell` recria a árvore quando o estilo muda.
  Funciona, mas é estado global mutável. Plano: migrar para
  `ThemeExtension<AppPalette>` lida via `Theme.of(context)`.
