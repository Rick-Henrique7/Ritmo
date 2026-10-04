// generate_trident_icon.js
//
// Gera o conjunto completo de assets de ícone para o Ritmo a partir
// do tridente de referência em `C:\Users\henri\Downloads\icono-tridente.avif`.
//
// Saída:
//   - `assets/icons/ritmo_icon.png`      (1024×1024 master — web/PWA)
//   - `assets/icons/trident_foreground.png`   (1024×1024 fg transparente p/ adaptive icon)
//
// Pipeline aplicado:
//   1) Carrega AVIF 996×996
//   2) Crop bottom 25% → mantém só os 3 prongs + ornamento + parte do cabo
//   3) Threshold 200 → elimina marca d'água "Magnific" (cinzas → preto/branco puro)
//   4) Trim do bounding box do tridente (recorta espaço vazio ao redor)
//   5) Redimensiona p/ ~68% do canvas (deixa espaço p/ safe-zone do adaptive icon)
//   6) Compõe no canvas 1024×1024 com fundo:
//      - master (web/PWA): branco puro #FFFFFF
//      - foreground (Android adaptive icon): transparente
//
// Adaptive icons no Android esperam:
//   - Foreground 108×108 dp (com tridente centralizado em safe-zone 72dp)
//   - Background 108×108 dp (sólido)
// → O tridente preenche a safe-zone inteira sem precisar de inset extra
//   do sistema, fazendo o ícone PARECER MAIOR no launcher (resolve o
//   "ícone pequeno em relação aos outros apps").

const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const SRC = 'C:\\Users\\henri\\Downloads\\icono-tridente.avif';
const OUT_MASTER = path.join(ROOT, 'assets/icons/ritmo_icon.png');
const OUT_FOREGROUND = path.join(ROOT, 'assets/icons/trident_foreground.png');

// === Pipeline ===
async function generate() {
  // 1) Ler o source.
  const srcMeta = await sharp(SRC).metadata();
  console.log(`source: ${srcMeta.width}×${srcMeta.height} (${srcMeta.format})`);

  // 2) Cortar o terço inferior: ficar do topo até 75% da altura.
  const cropHeight = Math.round(srcMeta.height * 0.75);
  const cropped = await sharp(SRC)
    .extract({
      left: 0,
      top: 0,
      width: srcMeta.width,
      height: cropHeight,
    })
    // Threshold agressivo para eliminar marca d'água
    .threshold(200)
    .png()
    .toBuffer();

  // 3) Calcular bounding box do tridente (remove padding transparente
  //    inútil ao redor). O threshold gera pixels pretos no tridente
  //    e brancos no fundo — `trim` recorta até o primeiro pixel não-
  //    branco nas bordas.
  const trimmed = await sharp(cropped)
    .trim({ background: '#FFFFFF', threshold: 10 })
    .png()
    .toBuffer();

  const trimmedMeta = await sharp(trimmed).metadata();
  console.log(`trimmed trident: ${trimmedMeta.width}×${trimmedMeta.height}`);

  // 4) Redimensionar o tridente p/ ~68% da área do canvas. Esse é o
  //    "tamanho visível final" — o resto é padding p/ safe-zone do
  //    adaptive icon (18 dp de inset deixa ~32 dp de respiro nos lados).
  const canvasSize = 1024;
  const targetWidth = Math.round(canvasSize * 0.68);
  const targetHeight = Math.round(
    (trimmedMeta.height / trimmedMeta.width) * targetWidth,
  );
  const resized = await sharp(trimmed)
    .resize(targetWidth, targetHeight, {
      fit: 'contain',
      background: { r: 0, g: 0, b: 0, alpha: 0 }, // transparente p/ fg
    })
    .png()
    .toBuffer();

  const offsetTop = Math.round((canvasSize - targetHeight) / 2);
  const offsetLeft = Math.round((canvasSize - targetWidth) / 2);
  console.log(
    `resized: ${targetWidth}×${targetHeight}, offset (${offsetLeft}, ${offsetTop})`,
  );

  // === 5a) MASTER: canvas branco + tridente (web/PWA e legacy mipmap) ===
  await sharp({
    create: {
      width: canvasSize,
      height: canvasSize,
      channels: 4,
      background: { r: 255, g: 255, b: 255, alpha: 1 },
    },
  })
    .composite([{ input: resized, top: offsetTop, left: offsetLeft }])
    .png()
    .toFile(OUT_MASTER);
  console.log(`✓ Master: ${OUT_MASTER}`);

  // === 5b) FOREGROUND: canvas transparente + tridente (Android adaptive) ===
  await sharp({
    create: {
      width: canvasSize,
      height: canvasSize,
      channels: 4,
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    },
  })
    .composite([{ input: resized, top: offsetTop, left: offsetLeft }])
    .png()
    .toFile(OUT_FOREGROUND);
  console.log(`✓ Foreground: ${OUT_FOREGROUND}`);
}

generate().catch((e) => {
  console.error(e);
  process.exit(1);
});
