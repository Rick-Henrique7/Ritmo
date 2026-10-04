# 0008 — Casca do app (`shell/`) fora do `core/`

- **Status:** Aceito
- **Data:** 2026-10-01

## Contexto
A regra do `core/` é "qualquer feature pode importar; ele não importa
nenhuma" ([ADR 0002](0002-providers-em-core.md)). Na revisão da etapa 3,
**5 arquivos** de `core/widgets/` quebravam a regra:
- `AppShell` e `AnimatedBackground` liam as configurações (`settings`);
- `GlassNavBar`, `GlassInputField` e `AppUndoSnackBar` liam o
  `accentColorProvider` de `settings` só para pegar a cor de destaque.

## Decisão
- `AppShell` e `AnimatedBackground` saem de `core/` para **`lib/shell/`** — a
  casca do app (fundo, barra de navegação, área das telas). Ela compõe
  features, como `routing/`, e por isso pode depender delas.
- Os widgets que só queriam o acento passam a ler
  `Theme.of(context).colorScheme.primary` — o tema já é montado com a cor de
  destaque do usuário. `AppUndoSnackBar.show` deixou de receber `ref`.
- O mesmo vale para as telas: `context.accent` e `context.foreground`
  (extensão em `app_colors.dart`) substituem `accentColorProvider` e
  `textColorProvider` fora de `settings/` — 10 arquivos de 5 features
  deixaram de importar as configurações só por causa de uma cor.
- A regra "core não importa features" passa a ser verificada no CI.

## Alternativas consideradas
- **Passar o acento por parâmetro em todo lugar** — funciona, mas espalha um
  dado que o `Theme` já distribui.
- **Uma "porta" como `FeedbackPreferences`** — boa para serviços; para cor,
  o tema já é essa porta.

## Consequências
- `grep "features/" lib/core` não encontra nenhum import, e o CI falha se
  algum aparecer.
- Camadas de composição ficam explícitas: `main.dart` → `app.dart` →
  `routing/` + `shell/` → `features/` → `core/`.
