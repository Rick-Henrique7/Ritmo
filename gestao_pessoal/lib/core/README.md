# `lib/core/` — Infraestrutura compartilhada

Tudo aqui é **horizontal**: pode ser importado por qualquer feature,
mas não importa de feature nenhuma. Se algo aqui precisar de algo de
`features/`, é sinal de que deve ser movido.

## Estrutura

```
core/
├── constants/    # AppPalette (ThemeExtension), estilo visual, tema, espaçamentos
│   ├── app_colors.dart
│   ├── app_style.dart
│   └── app_theme.dart
├── database/     # Persistência local (SharedPreferences wrapper)
│   ├── prefs_keys.dart
│   └── prefs_store.dart
├── providers/    # Providers de infraestrutura (armazenamento, hoje, relógio, vibração, som, tela acesa)
│   └── core_providers.dart
├── services/     # Wrappers de plataforma
│   ├── haptics_service.dart
│   ├── sound_service.dart
│   └── wakelock_service.dart
├── utils/        # Funções puras, sem estado
│   ├── color_hex.dart
│   ├── date_formatters.dart
│   ├── date_only.dart
│   └── json_coders.dart
└── widgets/      # Widgets reutilizáveis entre features
    ├── app_snackbar.dart
    ├── confirm_delete_dialog.dart
    ├── glass_input_field.dart
    ├── glass_nav_bar.dart
    ├── liquid_glass_card.dart
    ├── screen_header.dart
    ├── swipe_delete_background.dart
    └── weekday_chip.dart
```

A casca do app (`AppShell`, fundo animado) fica em `lib/shell/`, fora do
core, porque lê as configurações ([ADR 0008](../../../docs/adr/0008-shell-fora-do-core.md)).

Cores: `context.palette` (paleta do estilo, uma `ThemeExtension`),
`context.accent` e `context.foreground` (do tema). Nada de cor global
estática ([ADR 0006](../../../docs/adr/0006-paleta-como-theme-extension.md)).

## Quando criar algo em `core/`

- **`constants/`**: tokens estáticos que mais de uma feature usa
  (cor primária, espaçamentos, tokens de design).
- **`database/`**: acesso de baixo nível ao `SharedPreferences`. Quem
  serializa modelos são os repositórios em `features/<x>/data/`.
- **`providers/`**: providers usados por várias features. O core não
  conhece features: quando precisa de algo delas (ex.: preferências de
  vibração/som), declara uma "porta" (`FeedbackPreferences`) que o
  `main.dart` liga com um override.
- **`services/`**: APIs de plataforma (vibração, som, geolocalização,
  câmera, etc.) encapsuladas em uma classe Dart com interface limpa.
- **`utils/`**: funções puras e formatters sem dependência de framework.
- **`widgets/`**: widgets que aparecem em mais de uma feature. Se
  só uma feature usa, deixe dentro dela.

## Quando **NÃO** criar em `core/`

- Lógica de negócio específica → `features/<x>/data/`
- Modelos → `features/<x>/domain/`
- Telas → `features/<x>/presentation/`
- Constantes usadas em uma única feature → dentro dela mesma
