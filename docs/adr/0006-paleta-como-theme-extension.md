# 0006 — Paleta como `ThemeExtension`

- **Status:** Aceito (substitui a parte de cores do [ADR 0005](0005-dois-estilos-visuais.md))
- **Data:** 2026-10-01

## Contexto
O [ADR 0005](0005-dois-estilos-visuais.md) deixou uma dívida: a paleta do
estilo ativo ficava em um campo **estático** de `AppColors`, trocado por
`AppColors.use(style)`. Era estado global mutável: os widgets não sabiam
quando a cor mudava, então o `AppShell` recriava a árvore inteira com uma
`KeyedSubtree` a cada troca de estilo, e um widget testado fora do app lia a
paleta errada (ou a do teste anterior).

## Decisão
`AppPalette` passa a ser uma `ThemeExtension<AppPalette>` publicada no
`ThemeData` de cada estilo (`AppTheme.build`). Widgets leem com
`context.palette` — um atalho para `Theme.of(context).extension<AppPalette>()`.
`AppColors` fica só com o que **não** depende do estilo: espaçamentos, raios e
`onColor()` (contraste sobre uma cor sólida).

## Alternativas consideradas
- **Manter o campo estático** — funciona, mas é exatamente o que o Clean Code
  e o SOLID desaconselham: dependência escondida e estado global.
- **Provider Riverpod com a paleta** — reativo, mas obriga todo widget de cor a
  virar `ConsumerWidget` e duplica o que o `Theme` do Flutter já resolve.
- **Só `ColorScheme`** — não tem papéis como `panel`, `onPanelMuted`,
  `decoration`; seria preciso forçar cores em campos com outro significado.

## Consequências
- Trocar de estilo reconstrói só quem depende do tema; o `AppShell` virou
  `StatelessWidget` sem `KeyedSubtree`.
- `lerp` implementado: a transição entre Editorial e Liquid Glass é animada
  pelo `AnimatedTheme` do `MaterialApp`.
- Fora de um tema do app, `AppPalette.of` cai no editorial em vez de quebrar.
- Custo: 226 leituras `AppColors.x` reescritas para `context.palette.x`
  (mecanicamente, em um commit só). Em funções sem `BuildContext` a cor passa
  a ser parâmetro — ex.: `TaskPriority.colorAt(accent, muted: ...)`.
