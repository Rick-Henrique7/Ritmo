# Design visual

> Os dois estilos do Ritmo e os tokens que os sustentam. No código:
> `lib/core/constants/app_colors.dart` (paleta) e `app_theme.dart` (tema).
> Decisões: [ADR 0005](adr/0005-dois-estilos-visuais.md) e
> [ADR 0006](adr/0006-paleta-como-theme-extension.md).

## 1. Dois estilos

| | **Editorial** (padrão) | **Liquid Glass** |
| --- | --- | --- |
| Ideia | Revista impressa: papel creme, tinta grafite, um coral de destaque | Noite azulada com vidro translúcido e brilho |
| Fundo | Creme liso com formas geométricas (círculos, aro fino, hachura em zigue-zague) | Gradiente animado de "blobs" ou cor sólida, à escolha |
| Superfícies | Papel um tom mais claro, borda fina | Vidro com desfoque, reflexo e borda clara (`liquid_glass_widgets`) |
| Painel de destaque | Grafite com texto creme | Vidro mais opaco |
| Tipografia | **Jost** (embutida), títulos em peso leve | **DM Sans**, títulos encorpados para ler sobre o vidro |
| Destaque padrão | Coral `#E4553F` | Lilás `#A78BFA` |
| Tema do sistema | claro | escuro |

O usuário troca de estilo em Configurações. A mudança é animada, porque a
paleta é interpolada pelo `AnimatedTheme`.

## 2. Paleta (`AppPalette`)

Cada estilo é uma instância de `AppPalette`, uma `ThemeExtension` lida com
`context.palette`. Os nomes dos papéis são os mesmos nos dois estilos; os
valores mudam.

| Papel | Uso | Editorial | Liquid Glass |
| --- | --- | --- | --- |
| `background` | fundo da tela | `#EDE5D8` | `#0B0D1A` |
| `surface` | cards | `#F6F0E6` | branco 10% |
| `surface2` | chips, campos, trilhas | `#E3D9CA` | branco 14% |
| `textPrimary` | títulos e números | `#2E2D2B` | `#FFFFFF` |
| `textSecondary` | rótulos | `#6E685F` | `#BFC3DD` |
| `textTertiary` | dicas, desabilitado | `#9C958A` | `#8E93B5` |
| `border` | linhas finas | `#D3C8B8` | branco 20% |
| `panel` / `onPanel` | painel de destaque | `#3B3A39` / `#F2EBE0` | branco 18% / `#FFFFFF` |
| `decoration` | traço das formas do fundo | `#2E2D2B` | `#FFFFFF` |

**Cor de destaque:** escolhida pelo usuário e lida com `context.accent`. Usada
no botão +, números grandes, prioridade alta, conclusões e aba ativa. O texto
sobre ela usa `AppColors.onColor`, que escolhe grafite ou branco pelo
contraste.

**Cores do timer** (padrão, personalizáveis): Foco `#E4553F`, Pausa curta
`#4F8A83`, Pausa longa `#D9A441`.

## 3. Espaçamento e forma

| Token | Valor |
| --- | --- |
| `space1` … `space10` | 4, 8, 12, 16, 20, 24, 32, 40 px (base 4) |
| `radiusSm` · `radiusMd` · `radiusLg` · `radiusXl` | 8 · 16 · 24 · 32 px |
| Botões | pílula (raio total) |

## 4. Princípios

- **Números como protagonistas.** O progresso do dia ("01 / 03") e a
  sequência ocupam o topo, em tamanho de capa.
- **Um destaque só.** A cor de destaque marca o que é ação ou conquista; o
  resto fica na paleta neutra.
- **Estado negativo sem alarme.** Dias perdidos e prioridade baixa usam tons
  neutros, não vermelho.
- **Resistente a fonte grande.** Números grandes usam `FittedBox`, e os
  testes de widget rodam com uma fonte mais larga que a real.
- **Feedback em toda conclusão.** Vibração leve e som, ambos desligáveis.

## 5. Ícone

"Órbita": disco coral, aro grafite e círculo hachurado sobre fundo creme, as
mesmas formas do fundo Editorial. Arquivo:
`gestao_pessoal/assets/icons/ritmo_icon.png`. O ícone adaptativo do
Android usa `orbit_foreground.png`, com margem para a máscara circular.
