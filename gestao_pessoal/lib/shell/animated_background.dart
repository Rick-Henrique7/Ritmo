import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/color_hex.dart';
import '../features/settings/data/settings_controller.dart';
import '../features/settings/domain/app_settings.dart';

/// Fundo de todas as telas. Muda conforme o [AppStyle]:
///
/// - **Editorial**: papel creme com composição geométrica (círculos
///   cheios no accent, aro fino e um círculo hachurado em zigue-zague).
///   A composição se rearranja suavemente a cada aba — [routeIndex]
///   escolhe o layout.
/// - **Liquid Glass**: blobs de gradiente em loop (ou cor sólida), por
///   trás dos cartões de vidro.
class AnimatedBackground extends ConsumerStatefulWidget {
  const AnimatedBackground({
    super.key,
    required this.child,
    this.routeIndex = 0,
  });

  final Widget child;
  final int routeIndex;

  @override
  ConsumerState<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends ConsumerState<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Posição das manchas, atualizada ~12 vezes por segundo. O movimento é
  /// tão lento (uma volta a cada 22 s) que a diferença para 60 quadros não
  /// se vê — mas cada quadro a menos poupa o desfoque de todos os cartões
  /// de vidro por cima do fundo, que é o custo real do Liquid Glass.
  final _frame = ValueNotifier<double>(0);
  static const _framesPerLoop = 22 * 12;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..addListener(() {
        final t = (_controller.value * _framesPerLoop).floorToDouble() /
            _framesPerLoop;
        if (t != _frame.value) _frame.value = t;
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _frame.dispose();
    super.dispose();
  }


  /// Liga o ticker só quando há algo animando (glass + modo animado).
  void _syncTicker(bool shouldAnimate) {
    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accent = context.accent;
    final glass = settings.style.isGlass;
    final animated = glass && settings.wallpaperMode == WallpaperMode.animated;
    _syncTicker(animated);

    final Widget backdrop;
    if (!glass) {
      backdrop = _EditorialBackdrop(
        accent: accent,
        layout: _EditorialLayout.forRoute(widget.routeIndex),
      );
    } else if (!animated) {
      backdrop = ColoredBox(color: colorFromHex(settings.wallpaperSolidColor));
    } else {
      backdrop = _buildBlobs(settings);
    }

    return Stack(
      children: [
        Positioned.fill(child: RepaintBoundary(child: backdrop)),
        RepaintBoundary(child: widget.child),
      ],
    );
  }

  Widget _buildBlobs(AppSettings settings) {
    final seed = colorFromHex(settings.wallpaperSeed);
    final intensity = settings.blobIntensity;
    final hsv = HSVColor.fromColor(seed);

    // Cores análogas (±35°) em vez de complementares: o resultado fica
    // harmonioso, sem virar arco-íris borrado.
    Color shift(double deg, double value) => hsv
        .withHue((hsv.hue + deg) % 360)
        .withSaturation(math.min(1, hsv.saturation * 0.9 + 0.1))
        .withValue(value)
        .toColor();

    final blobColors = <Color>[
      seed.withValues(alpha: intensity),
      shift(35, 0.95).withValues(alpha: intensity * 0.8),
      shift(-35, 0.85).withValues(alpha: intensity * 0.7),
    ];

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: context.palette.background)),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _frame,
            builder: (context, _) => CustomPaint(
              painter: _BlobsPainter(
                t: _frame.value,
                blobColors: blobColors,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Editorial
// ---------------------------------------------------------------------------

/// Posições das formas decorativas, em frações da tela.
/// `x`/`y` são frações de largura/altura; `r` é fração da largura.
@immutable
class _EditorialLayout {
  const _EditorialLayout(this.values);

  /// [sunX, sunY, sunR, sun2X, sun2Y, sun2R, ringX, ringY, ringR,
  ///  hatchX, hatchY, hatchR]
  final List<double> values;

  static const _layouts = <List<double>>[
    // 0 — Hoje
    [1.02, 0.07, 0.42, -0.06, 0.97, 0.30, 0.80, 0.19, 0.34, 0.16, 0.86, 0.17],
    // 1 — Hábitos
    [-0.10, 0.10, 0.30, 1.05, 0.62, 0.36, 0.90, 0.10, 0.22, 0.86, 0.90, 0.15],
    // 2 — Tarefas
    [1.10, 0.30, 0.38, -0.02, 1.00, 0.24, 0.92, 0.42, 0.30, 0.82, 0.07, 0.13],
    // 3 — Foco
    [1.06, 0.62, 0.30, -0.08, 0.06, 0.24, 0.50, 0.37, 0.47, 0.88, 0.10, 0.12],
    // 4 — Stats
    [0.08, 0.22, 0.34, 1.06, 0.95, 0.30, 0.20, 0.30, 0.42, 0.88, 0.12, 0.15],
    // 5 — Configurações
    [1.00, 0.02, 0.30, -0.08, 0.70, 0.26, 0.88, 0.10, 0.26, 0.90, 0.94, 0.12],
  ];

  static _EditorialLayout forRoute(int index) =>
      _EditorialLayout(_layouts[index.clamp(0, _layouts.length - 1)]);

  _EditorialLayout lerpTo(_EditorialLayout other, double t) => _EditorialLayout([
        for (var i = 0; i < values.length; i++)
          ui.lerpDouble(values[i], other.values[i], t)!,
      ]);
}

class _LayoutTween extends Tween<_EditorialLayout> {
  _LayoutTween({required super.begin, required super.end});

  @override
  _EditorialLayout lerp(double t) => begin!.lerpTo(end!, t);
}

class _EditorialBackdrop extends StatelessWidget {
  const _EditorialBackdrop({required this.accent, required this.layout});

  final Color accent;
  final _EditorialLayout layout;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.palette.background,
      child: TweenAnimationBuilder<_EditorialLayout>(
        tween: _LayoutTween(begin: layout, end: layout),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
        builder: (context, value, _) => CustomPaint(
          painter: _EditorialPainter(
            layout: value,
            accent: accent,
            ink: context.palette.decoration,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _EditorialPainter extends CustomPainter {
  _EditorialPainter({
    required this.layout,
    required this.accent,
    required this.ink,
  });

  final _EditorialLayout layout;
  final Color accent;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final v = layout.values;
    Offset at(int i) => Offset(v[i] * w, v[i + 1] * h);
    double r(int i) => v[i + 2] * w;

    final sun = Paint()..color = accent;
    final sunSoft = Paint()..color = accent.withValues(alpha: 0.85);
    final ring = Paint()
      ..color = ink.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    canvas.drawCircle(at(0), r(0), sun);
    canvas.drawCircle(at(3), r(3), sunSoft);
    canvas.drawCircle(at(6), r(6), ring);
    // Segundo aro concêntrico, mais apertado — detalhe de "órbita".
    canvas.drawCircle(at(6), r(6) * 0.62, ring..color = ink.withValues(alpha: 0.25));

    _drawHatch(canvas, at(9), r(9));
  }

  /// Círculo preenchido com linhas em zigue-zague (textura gráfica).
  void _drawHatch(Canvas canvas, Offset c, double radius) {
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeJoin = StrokeJoin.miter;

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: radius)));
    const step = 6.0;
    const amp = 2.4;
    const period = 7.0;
    for (var y = c.dy - radius; y <= c.dy + radius; y += step) {
      final path = Path()..moveTo(c.dx - radius, y);
      var up = true;
      for (var x = c.dx - radius; x <= c.dx + radius + period; x += period / 2) {
        path.lineTo(x, y + (up ? -amp : amp));
        up = !up;
      }
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EditorialPainter old) =>
      old.layout != layout || old.accent != accent || old.ink != ink;
}

// ---------------------------------------------------------------------------
// Liquid Glass
// ---------------------------------------------------------------------------

class _BlobsPainter extends CustomPainter {
  _BlobsPainter({required this.t, required this.blobColors});

  final double t;
  final List<Color> blobColors;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const twoPi = 2 * math.pi;
    final big = math.max(w, h);

    final blobs = <(Offset, double, Color)>[
      (
        Offset((0.25 + 0.10 * math.sin(t * twoPi)) * w,
            (0.28 + 0.08 * math.cos(t * twoPi)) * h),
        big * 0.55,
        blobColors[0],
      ),
      (
        Offset((0.82 + 0.12 * math.cos(t * twoPi + 1.5)) * w,
            (0.72 + 0.10 * math.sin(t * twoPi + 1.5)) * h),
        big * 0.50,
        blobColors[1],
      ),
      (
        Offset((0.55 + 0.14 * math.sin(t * twoPi + 3.0)) * w,
            (0.08 + 0.12 * math.cos(t * twoPi + 3.0)) * h),
        big * 0.42,
        blobColors[2],
      ),
    ];

    for (final (center, radius, color) in blobs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobsPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.blobColors != blobColors;
}
