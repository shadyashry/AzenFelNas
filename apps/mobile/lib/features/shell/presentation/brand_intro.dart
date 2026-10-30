import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The opening moment (§15 D100, D101), drawn over the whole screen: the
/// native launch screen's deep emerald continues, a gold mihrab arch draws
/// itself from both pillars up to its apex, the lamp at the apex lights and
/// breathes, stars appear at the springing, the mark rises into the arch
/// and a light sweeps across it, then the intro fades into the app. The app
/// starts underneath at once; the intro holds, lamp lit, until the app is
/// [ready] (at most [longestHold]), so it fades into content rather than a
/// spinner. A tap skips it; it is hidden from screen readers. With reduced
/// motion it is a short still fade.
final class BrandIntro extends StatefulWidget {
  /// The intro over [child], leaving once [ready].
  const new({required this.child, this.ready = true, super.key});

  /// The app.
  final Widget child;

  /// Whether the first screen has its content.
  final bool ready;

  /// The longest the intro waits for [ready] after it has played.
  static const longestHold = Duration(seconds: 8);

  /// How long the intro shows, fade-out included.
  static const duration = Duration(milliseconds: 2600);

  /// With reduced motion: the mark, still, then a fade.
  static const reducedDuration = Duration(milliseconds: 700);

  /// How long the fade takes when a tap skips the intro.
  static const skipDuration = Duration(milliseconds: 250);

  @override
  State<BrandIntro> createState() => _BrandIntroState();
}

final class _BrandIntroState extends State<BrandIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this);
  Timer? _hold;
  bool _done = false;
  bool _started = false;

  /// Played up to the fade, waiting for [BrandIntro.ready].
  bool _waiting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _clock.duration = MediaQuery.disableAnimationsOf(context)
        ? BrandIntro.reducedDuration
        : BrandIntro.duration;
    _clock.addStatusListener((status) {
      // animateTo reports `completed` at the hold too; only the end counts.
      if (status == AnimationStatus.completed && _clock.value >= 1 && mounted) {
        setState(() => _done = true);
      }
    });
    _clock.animateTo(_Timeline.fadeFrom).whenCompleteOrCancel(() {
      if (!mounted || _clock.value < _Timeline.fadeFrom) return;
      setState(() => _waiting = true);
      _hold = Timer(BrandIntro.longestHold, _leave);
      if (widget.ready) _leave();
    });
  }

  @override
  void didUpdateWidget(BrandIntro old) {
    super.didUpdateWidget(old);
    if (_waiting && widget.ready && !old.ready) _leave();
  }

  @override
  void dispose() {
    _hold?.cancel();
    _clock.dispose();
    super.dispose();
  }

  /// Fades into the app.
  void _leave() {
    _hold?.cancel();
    if (_clock.isAnimating && _clock.value >= _Timeline.fadeFrom) return;
    _clock.animateTo(1);
  }

  /// Runs the rest of the intro as a quick fade.
  void _skip() {
    _hold?.cancel();
    _clock.animateTo(1, duration: BrandIntro.skipDuration);
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    // The app keeps its place in the tree when the intro leaves, so none of
    // its state is rebuilt.
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_done)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _skip,
            child: ExcludeSemantics(
              // Light status bar icons over the emerald (§15 D101).
              child: AnnotatedRegion(
                value: DmTheme.statusBarOn(Brightness.dark),
                child: AnimatedBuilder(
                  animation: _clock,
                  builder: (context, _) {
                    final t = still ? 1.0 : _clock.value;
                    final fade = _Timeline.span(
                      _clock.value,
                      _Timeline.fadeFrom,
                      1,
                    );
                    return Opacity(
                      opacity: 1 - Curves.easeIn.transform(fade),
                      child: _Stage(t: t, waiting: _waiting && fade == 0),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Where each part of the intro starts and ends, as fractions of it.
abstract final class _Timeline {
  /// Where the fade into the app starts.
  static const fadeFrom = 0.86;

  /// 0 before [from], 1 after [to], linear between.
  static double span(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);
}

/// The whole-screen stage at [t] (0 → 1); [waiting] while the app loads.
final class _Stage extends StatelessWidget {
  const new({required this.t, required this.waiting});

  final double t;
  final bool waiting;

  @override
  Widget build(BuildContext context) {
    final pattern = Curves.easeOut.transform(_Timeline.span(t, 0, 0.35));
    final rise = Curves.easeOutBack.transform(_Timeline.span(t, 0.3, 0.62));
    final sweep = _Timeline.span(t, 0.58, 0.84);
    final line = Curves.easeInOut.transform(_Timeline.span(t, 0.1, 0.86));
    final size = MediaQuery.sizeOf(context);
    final markWidth = math.min<double>(size.width * 0.58, 300);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.2,
          colors: [Color(0xFF1C6646), RawdahPalette.emeraldDeep],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The girih settles in from a little larger.
          Opacity(
            opacity: 0.55 * pattern,
            child: Transform.scale(
              scale: 1.12 - 0.12 * pattern,
              child: const GirihBackdrop(
                ground: Colors.transparent,
                ink: RawdahPalette.gold,
                child: SizedBox.expand(),
              ),
            ),
          ),
          CustomPaint(painter: _ArchPainter(t)),
          Align(
            alignment: const Alignment(0, 0.12),
            child: Opacity(
              opacity: _Timeline.span(t, 0.3, 0.5),
              child: Transform.translate(
                offset: Offset(0, 40 * (1 - rise)),
                child: Transform.scale(
                  scale: 0.8 + 0.2 * rise,
                  child: _Sweep(
                    at: sweep,
                    child: Image.asset(
                      'assets/brand/logo.png',
                      width: markWidth,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.86),
            child: SizedBox(
              width: math.min(size.width * 0.4, 180),
              child: LinearProgressIndicator(
                // Still loading: the line keeps moving.
                value: waiting ? null : line,
                minHeight: 2,
                borderRadius: BorderRadius.circular(1),
                backgroundColor: RawdahPalette.goldDeep.withValues(alpha: 0.35),
                color: RawdahPalette.goldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A band of light crossing [child] once as [at] runs 0 → 1.
final class _Sweep extends StatelessWidget {
  const new({required this.at, required this.child});

  final double at;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (at <= 0 || at >= 1) return child;
    final centre = -0.4 + 1.8 * at;
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          RawdahPalette.ivory.withValues(alpha: 0.55),
          Colors.transparent,
        ],
        stops: [
          (centre - 0.15).clamp(0.0, 1.0),
          centre.clamp(0.0, 1.0),
          (centre + 0.15).clamp(0.0, 1.0),
        ],
      ).createShader(bounds),
      child: child,
    );
  }
}

/// The full-screen mihrab at [t]: the arch drawn up from both pillars, the
/// lamp lit at its apex, stars at the springing.
final class _ArchPainter extends CustomPainter {
  new(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final draw = Curves.easeInOutCubic.transform(_Timeline.span(t, 0.05, 0.55));
    final glow = _Timeline.span(t, 0.45, 0.6);
    final stars = Curves.easeOutBack.transform(_Timeline.span(t, 0.5, 0.72));

    final margin = size.width * 0.1;
    final left = margin;
    final right = size.width - margin;
    final bottom = size.height * 0.9;
    final spring = size.height * 0.36;
    final apex = Offset(size.width / 2, size.height * 0.1);
    final halfWidth = (right - left) / 2;

    // Each half from its pillar's foot, up the pillar, then the curve to
    // the apex; both are drawn at once and meet at the top.
    Path half(double side) {
      final x = size.width / 2 + side * halfWidth;
      return Path()
        ..moveTo(x, bottom)
        ..lineTo(x, spring)
        ..cubicTo(
          x,
          spring - (spring - apex.dy) * 0.55,
          apex.dx + side * halfWidth * 0.18,
          apex.dy + (spring - apex.dy) * 0.25,
          apex.dx,
          apex.dy,
        );
    }

    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          RawdahPalette.goldLight,
          RawdahPalette.gold,
          RawdahPalette.goldDeep,
        ],
      ).createShader(Offset.zero & size);
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = RawdahPalette.goldLight.withValues(alpha: 0.6);

    for (final side in const [-1.0, 1.0]) {
      canvas.drawPath(_part(half(side), draw), outer);
      final inset = Matrix4.identity()
        ..translateByDouble(size.width / 2, apex.dy, 0, 1)
        ..scaleByDouble(0.93, 0.97, 1, 1)
        ..translateByDouble(-size.width / 2, -apex.dy + 14, 0, 1);
      canvas.drawPath(
        _part(half(side).transform(inset.storage), draw),
        inner,
      );
    }

    // The base line joins the pillars once they stand.
    if (draw > 0) {
      canvas.drawLine(
        Offset(size.width / 2 - halfWidth * draw, bottom),
        Offset(size.width / 2 + halfWidth * draw, bottom),
        outer,
      );
    }

    if (glow > 0) {
      // The lamp hangs from the apex and breathes once lit.
      final breathe = 0.85 + 0.15 * math.sin(t * math.pi * 6);
      final lamp = apex + Offset(0, (spring - apex.dy) * 0.42);
      canvas
        ..drawLine(
          apex,
          lamp - const Offset(0, 10),
          Paint()
            ..color = RawdahPalette.gold.withValues(alpha: glow)
            ..strokeWidth = 1.2,
        )
        ..drawCircle(
          lamp,
          90 * breathe,
          Paint()
            ..shader = ui.Gradient.radial(lamp, 90 * breathe, [
              RawdahPalette.goldLight.withValues(alpha: 0.45 * glow),
              RawdahPalette.goldLight.withValues(alpha: 0),
            ]),
        )
        ..drawCircle(
          lamp,
          9,
          Paint()..color = RawdahPalette.ivory.withValues(alpha: glow),
        );
    }

    if (stars > 0) {
      final star = Paint()..color = RawdahPalette.gold;
      for (final x in [left, right]) {
        canvas.drawPath(
          OrnamentPaths.star(Offset(x, spring), 11 * stars),
          star,
        );
      }
      canvas.drawPath(OrnamentPaths.star(apex, 13 * stars), star);
    }
  }

  /// The first [fraction] of [path], along its length.
  static Path _part(Path path, double fraction) {
    final out = Path();
    for (final metric in path.computeMetrics()) {
      out.addPath(metric.extractPath(0, metric.length * fraction), Offset.zero);
    }
    return out;
  }

  @override
  bool shouldRepaint(_ArchPainter old) => old.t != t;
}
