// generate_icons.js
//
// Gera todas as variantes do ícone do app a partir de:
//   - `assets/icons/ritmo_icon.png`      (master "Órbita", fundo creme — web/PWA)
//   - `assets/icons/orbit_foreground.png`     (foreground transparente — Android)
//
// Saídas:
//   Android (em `android/app/src/main/res/`):
//     - mipmap-{m,h,xh,xxh,xxxh}dpi/ic_launcher.png        (legacy + adaptive)
//     - mipmap-{m,h,xh,xxh,xxxh}dpi/ic_launcher_round.png
//     - mipmap-{m,h,xh,xxh,xxxh}dpi/ic_launcher_foreground.png (apenas adaptive)
//     - drawable/ic_launcher_background.xml               (cor sólida branca)
//     - mipmap-anydpi-v26/ic_launcher.xml                  (adaptive icon config)
//     - mipmap-anydpi-v26/ic_launcher_round.xml
//   Web (em `web/icons/`):
//     - Icon-{192,512,1024}.png                           (regular)
//     - Icon-maskable-{192,512,1024}.png                  (PWA com safe-area)
//     - favicon.png (256×256)
//
// Por que adaptive icons:
//   Sem `mipmap-anydpi-v26/ic_launcher.xml`, o launcher aplica um inset
//   maior no ícone legacy → ele PARECE pequeno em relação aos outros
//   apps no Android (que usam adaptive icons desde a API 26).
//   Com adaptive icons configurados, o background creme preenche a
//   área total do ícone e a única folga fica na safe-zone interna do
//   foreground (~72dp dos 108dp).

const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const SRC_MASTER = path.join(ROOT, 'assets/icons/ritmo_icon.png');
const SRC_FOREGROUND = path.join(ROOT, 'assets/icons/orbit_foreground.png');

// Tamanhos Android (mdpi=48, hdpi=72, xhdpi=96, xxhdpi=144, xxxhdpi=192)
// Para adaptive icons, o sistema renderiza o foreground em 108dp = 432px no
// xxxhdpi. Geramos nessa escala pra cobrir o foreground adequadamente.
const ANDROID_DENSITIES = {
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

// Escala do foreground (108dp = 432px no xxxhdpi).
const ADAPTIVE_FG_SIZE = {
  'mipmap-mdpi': 108,
  'mipmap-hdpi': 162,
  'mipmap-xhdpi': 216,
  'mipmap-xxhdpi': 324,
  'mipmap-xxxhdpi': 432,
};

const WEB_SIZES = [192, 512, 1024];

async function generate() {
  if (!fs.existsSync(SRC_MASTER) || !fs.existsSync(SRC_FOREGROUND)) {
    console.error(
      `Assets de ícone não encontrados. Rode antes: node scripts/generate_trident_icon.js`,
    );
    process.exit(1);
  }
  const master = sharp(SRC_MASTER);
  const foreground = sharp(SRC_FOREGROUND);

  // === Android (legacy mipmap + adaptive foreground) ===
  for (const [dir, size] of Object.entries(ANDROID_DENSITIES)) {
    const outDir = path.join(ROOT, `android/app/src/main/res/${dir}`);
    fs.mkdirSync(outDir, { recursive: true });

    // ic_launcher.png (ícone padrão — Android pre-O cai nele).
    await master
      .clone()
      .resize(size, size)
      .png()
      .toFile(path.join(outDir, 'ic_launcher.png'));
    console.log(`✓ ${dir}/ic_launcher.png (${size}×${size})`);

    // ic_launcher_round.png (ícone circular).
    await master
      .clone()
      .resize(size, size)
      .png()
      .toFile(path.join(outDir, 'ic_launcher_round.png'));
    console.log(`✓ ${dir}/ic_launcher_round.png (${size}×${size})`);

    // ic_launcher_foreground.png (apenas adaptive icon API 26+).
    // 108dp visível — geramos no tamanho exato por densidade.
    const fgSize = ADAPTIVE_FG_SIZE[dir];
    await foreground
      .clone()
      .resize(fgSize, fgSize, {
        fit: 'contain',
        background: { r: 0, g: 0, b: 0, alpha: 0 }, // mantém transparente
      })
      .png()
      .toFile(path.join(outDir, 'ic_launcher_foreground.png'));
    console.log(`✓ ${dir}/ic_launcher_foreground.png (${fgSize}×${fgSize})`);

    // ic_launcher_round_foreground.png (referenciado pelo adaptive
    // icon circular — sistema exige essa referência explícita quando
    // mipmap-anydpi-v26/ic_launcher_round.xml existe).
    await foreground
      .clone()
      .resize(fgSize, fgSize, {
        fit: 'contain',
        background: { r: 0, g: 0, b: 0, alpha: 0 },
      })
      .png()
      .toFile(path.join(outDir, 'ic_launcher_round_foreground.png'));
    console.log(`✓ ${dir}/ic_launcher_round_foreground.png (${fgSize}×${fgSize})`);
  }

  // === drawable: background branco sólido ===
  // Define a cor de fundo do adaptive icon (camada visível atrás do
  // foreground). Usado por mipmap-anydpi-v26/ic_launcher.xml.
  const drawableDir = path.join(ROOT, 'android/app/src/main/res/drawable');
  fs.mkdirSync(drawableDir, { recursive: true });
  const backgroundXml = `<?xml version="1.0" encoding="utf-8"?>
<!--
  Background sólido do adaptive icon do Ritmo.
  Creme editorial (#EDE5D8) — mesma cor do master p/ coerência visual
  entre o ícone legacy e o adaptive no Android 8+ (API 26+).
-->
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="#EDE5D8" />
</shape>
`;
  fs.writeFileSync(
    path.join(drawableDir, 'ic_launcher_background.xml'),
    backgroundXml,
    'utf-8',
  );
  console.log('✓ drawable/ic_launcher_background.xml (creme #EDE5D8)');

  // === Adaptive icon config (Android 8.0 / API 26+) ===
  // Sem este XML, o sistema cai no legacy mipmap e o launcher aplica
  // inset maior → o ícone PARECE PEQUENO em relação aos outros apps.
  const anydpiDir = path.join(
    ROOT,
    'android/app/src/main/res/mipmap-anydpi-v26',
  );
  fs.mkdirSync(anydpiDir, { recursive: true });

  const adaptiveXml = (roundFlag) => {
    const fgName = roundFlag ? 'ic_launcher_round_foreground' : 'ic_launcher_foreground';
    return `<?xml version="1.0" encoding="utf-8"?>
<!--
  Adaptive icon configuration for Ritmo.
  Refs:
    - foreground: "Órbita" 108×108dp (${fgName}.png)
                  área visível segura: 72×72dp centralizado
    - background: creme editorial (#EDE5D8) via drawable/ic_launcher_background.xml

  Sistema aplica máscara (círculo/squircle/teardrop) na área 108×108dp
  inteira → o background creme preenche o ícone completo, dando a
  sensação de "ícone grande" no launcher (vs legacy inset).
-->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@mipmap/${fgName}" />
</adaptive-icon>
`;
  };
  fs.writeFileSync(
    path.join(anydpiDir, 'ic_launcher.xml'),
    adaptiveXml(false),
    'utf-8',
  );
  fs.writeFileSync(
    path.join(anydpiDir, 'ic_launcher_round.xml'),
    adaptiveXml(true),
    'utf-8',
  );
  console.log('✓ mipmap-anydpi-v26/ic_launcher.xml');
  console.log('✓ mipmap-anydpi-v26/ic_launcher_round.xml');

  // === Web (PWA) ===
  const webDir = path.join(ROOT, 'web/icons');
  fs.mkdirSync(webDir, { recursive: true });
  for (const size of WEB_SIZES) {
    await master
      .clone()
      .resize(size, size)
      .png()
      .toFile(path.join(webDir, `Icon-${size}.png`));
    console.log(`✓ web/icons/Icon-${size}.png`);

    // Maskable (com padding extra nas bordas pra safe area).
    const pad = Math.round(size * 0.18);
    const innerSize = size - pad * 2;
    await sharp(SRC_MASTER)
      .resize(innerSize, innerSize)
      .extend({
        top: pad,
        bottom: pad,
        left: pad,
        right: pad,
        background: { r: 237, g: 229, b: 216, alpha: 1 }, // #EDE5D8
      })
      .png()
      .toFile(path.join(webDir, `Icon-maskable-${size}.png`));
    console.log(`✓ web/icons/Icon-maskable-${size}.png (com safe-area)`);
  }

  // === favicon (256 — Retina/HiDPI friendly) ===
  await master
    .clone()
    .resize(256, 256)
    .png()
    .toFile(path.join(ROOT, 'web/favicon.png'));
  console.log('✓ web/favicon.png (256×256)');

  console.log('\n🎉 Todos os ícones gerados com sucesso!');
}

generate().catch((e) => {
  console.error(e);
  process.exit(1);
});
