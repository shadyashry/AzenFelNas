import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The opening moment (§15 D100, D101, D106), over the whole screen. The
/// native launch screen shows the approved logo at [launchSide] on its own
/// green; the intro's first frame is that same picture, held back until the
/// logo is decoded, so nothing blinks or jumps. The logo then opens out to
/// fill the screen ([fullSideIn]) as dawn light spreads from its sunrise:
/// a warm bloom over the whole screen, soft rays rising through the arch, a
/// sheen across the gold and a glow at the lantern and the sunrise, all of
/// it once, never looping. The logo rests, crisp, until the app is
/// [ready]; then it opens towards the reader and fades as the app settles
/// into place beneath. If the app is still loading [loadingAfter] after the
/// logo settled, a thin gold line says so; after [longestHold] the intro
/// leaves anyway for the app's own loading and recovery states. The app
/// starts underneath at once and keeps its place in the tree, so deep links
/// and notification taps land while the intro plays. A tap skips it; it is
/// hidden from screen readers. With reduced motion the logo stays still at
/// the launch size and the intro fades when the app is ready. It plays once
/// per process: a resume does not replay it.
final class BrandIntro extends StatefulWidget {
  /// The intro over [child], leaving once [ready].
  const new({required this.child, this.ready = true, super.key});

  /// The app.
  final Widget child;

  /// Whether the first screen has its content.
  final bool ready;

  /// The logo's side on the native launch screens; the launch images are
  /// made at this size by `tool/brand`.
  static const launchSide = 175.0;

  /// The opening out and the dawn light.
  static const motionDuration = Duration(milliseconds: 1400);

  /// The opening towards the reader and the fade into the app.
  static const exitDuration = Duration(milliseconds: 450);

  /// The fade into the app with reduced motion, or when a tap skips.
  static const quickExitDuration = Duration(milliseconds: 200);

  /// How long the settled logo waits for [ready] before the loading line.
  static const loadingAfter = Duration(seconds: 2);

  /// The longest the settled logo waits for [ready].
  static const longestHold = Duration(seconds: 8);

  /// The longest the first frame waits for the logo to decode, and the
  /// motion for that frame to reach the screen.
  static const decodeWait = Duration(milliseconds: 400);

  /// The intro's logo: the launch screens' picture, its plain edge faded.
  static const asset = 'assets/brand/logo_launch.png';

  /// The settled logo's side on a screen of [size]: the full width in
  /// portrait; in landscape a little short of the height, leaving room for
  /// the loading line.
  static double fullSideIn(Size size) =>
      math.min(size.width, size.height * 0.8);

  @override
  State<BrandIntro> createState() => _BrandIntroState();
}

final class _BrandIntroState extends State<BrandIntro>
    with TickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: BrandIntro.motionDuration,
  );
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: BrandIntro.exitDuration,
  );
  final List<Timer> _timers = [];
  bool _started = false;
  bool _frameDeferred = false;
  bool _settled = false;
  bool _loading = false;
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // The native launch screen stays until the logo can be drawn.
    WidgetsBinding.instance.deferFirstFrame();
    _frameDeferred = true;
    unawaited(
      Future.any([
        precacheImage(const AssetImage(BrandIntro.asset), context),
        Future<void>.delayed(BrandIntro.decodeWait),
      ]).whenComplete(_begin),
    );
  }

  @override
  void didUpdateWidget(BrandIntro old) {
    super.didUpdateWidget(old);
    if (_settled && widget.ready && !old.ready) _leave();
  }

  @override
  void dispose() {
    _allowFirstFrame();
    _cancelTimers();
    _motion.dispose();
    _exit.dispose();
    super.dispose();
  }

  void _allowFirstFrame() {
    if (!_frameDeferred) return;
    _frameDeferred = false;
    WidgetsBinding.instance.allowFirstFrame();
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void _begin() {
    _allowFirstFrame();
    // The motion starts once the first frame, the launch picture, is on
    // screen, so it starts from the launch size rather than part-way; at
    // the latest [BrandIntro.decodeWait] later.
    unawaited(
      Future.any([
        WidgetsBinding.instance.waitUntilFirstFrameRasterized,
        Future<void>.delayed(BrandIntro.decodeWait),
      ]).then((_) {
        if (!mounted || _exit.status != AnimationStatus.dismissed) return;
        if (MediaQuery.disableAnimationsOf(context)) {
          _settle();
          return;
        }
        _motion.forward().whenCompleteOrCancel(() {
          if (mounted && _motion.isCompleted) _settle();
        });
      }),
    );
  }

  void _settle() {
    _settled = true;
    if (widget.ready) {
      _leave();
      return;
    }
    _timers
      ..add(
        Timer(BrandIntro.loadingAfter, () {
          if (mounted) setState(() => _loading = true);
        }),
      )
      ..add(Timer(BrandIntro.longestHold, _leave));
  }

  /// Fades into the app.
  void _leave({bool quick = false}) {
    _cancelTimers();
    if (!mounted || _exit.status != AnimationStatus.dismissed) return;
    if (quick || MediaQuery.disableAnimationsOf(context)) {
      _exit.duration = BrandIntro.quickExitDuration;
    }
    _exit.forward().whenCompleteOrCancel(() {
      if (mounted && _exit.isCompleted) setState(() => _done = true);
    });
  }

  void _skip() {
    _motion.stop();
    _leave(quick: true);
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    // The app keeps its place in the tree when the intro leaves, so none of
    // its state is rebuilt; its transform is the identity once settled.
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _exit,
          builder: (context, app) => Transform.scale(
            scale: still || _done
                ? 1
                : 0.96 + 0.04 * Curves.easeOutCubic.transform(_exit.value),
            child: app,
          ),
          child: widget.child,
        ),
        if (!_done)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _skip,
            child: ExcludeSemantics(
              // Light status bar icons over the green (§15 D101).
              child: AnnotatedRegion(
                value: DmTheme.statusBarOn(Brightness.dark),
                child: FadeTransition(
                  opacity: ReverseAnimation(
                    CurvedAnimation(parent: _exit, curve: Curves.easeIn),
                  ),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_motion, _exit]),
                    builder: (context, _) => _Stage(
                      t: _motion.value,
                      leaving: still ? 0 : _exit.value,
                      loading: _loading,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The whole-screen stage at motion [t] (0 → 1) and exit [leaving]
/// (0 → 1); [loading] once the app has kept the settled logo waiting.
final class _Stage extends StatelessWidget {
  const new({required this.t, required this.leaving, required this.loading});

  final double t;
  final double leaving;
  final bool loading;

  /// 0 before [from], 1 after [to], linear between.
  static double _span(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);

  /// Up over [from]–[peak], down over [peak]–[to], each eased.
  static double _rise(double t, double from, double peak, double to) => t < peak
      ? Curves.easeOut.transform(_span(t, from, peak))
      : 1 - Curves.easeInOut.transform(_span(t, peak, to));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final full = BrandIntro.fullSideIn(size);
    // From the launch picture, centred on the whole screen as the launch
    // screens are, out to the full side; then towards the reader as it
    // leaves.
    final open = Curves.easeInOutCubic.transform(_span(t, 0, 0.55));
    final from = math.min(BrandIntro.launchSide / full, 1);
    final scale =
        (from + (1 - from) * open) *
        (1 + 0.08 * Curves.easeIn.transform(leaving));
    final sunrise = Offset(
      size.width / 2,
      size.height / 2 + (_GlowPainter.sunrise.dy - 0.5) * full * scale,
    );
    return ColoredBox(
      color: RawdahPalette.logoGround,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Transform.scale(
              scale: scale,
              child: SizedBox.square(
                dimension: full,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      BrandIntro.asset,
                      width: full,
                      height: full,
                      gaplessPlayback: true,
                    ),
                    IgnorePointer(
                      child: CustomPaint(
                        painter: _GlowPainter(
                          sheen: Curves.easeInOut.transform(
                            _span(t, 0.45, 0.88),
                          ),
                          glow: _rise(t, 0.5, 0.72, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              painter: _DawnPainter(
                from: sunrise,
                bloom: _rise(t, 0.12, 0.55, 1),
                reach: Curves.easeOutCubic.transform(_span(t, 0.22, 0.78)),
                rays: _rise(t, 0.22, 0.5, 1),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom + 28,
              ),
              child: AnimatedOpacity(
                opacity: loading ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: math.min(size.width * 0.3, 120),
                  child: loading
                      ? LinearProgressIndicator(
                          minHeight: 2,
                          borderRadius: BorderRadius.circular(1),
                          backgroundColor: RawdahPalette.goldDeep.withValues(
                            alpha: 0.35,
                          ),
                          color: RawdahPalette.goldLight,
                        )
                      : const SizedBox(height: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dawn over the whole screen from the logo's sunrise at [from]: a warm
/// [bloom] (0 → 1) and soft rays fanning upward through the arch, reaching
/// [reach] of the screen at strength [rays]. Added, so it only lightens;
/// no blur or blend that reads the screen back, so it stays cheap.
final class _DawnPainter extends CustomPainter {
  new({
    required this.from,
    required this.bloom,
    required this.reach,
    required this.rays,
  });

  final Offset from;
  final double bloom;
  final double reach;
  final double rays;

  static const _rayCount = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final far = size.longestSide;
    if (bloom > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = ui.Gradient.radial(
            from,
            far * 0.85,
            [
              RawdahPalette.goldLight.withValues(alpha: 0.14 * bloom),
              RawdahPalette.gold.withValues(alpha: 0.04 * bloom),
              RawdahPalette.gold.withValues(alpha: 0),
            ],
            const [0, 0.45, 1],
          ),
      );
    }
    if (rays <= 0 || reach <= 0) return;
    final length = far * 0.9 * reach;
    final shader = ui.Gradient.radial(
      from,
      length,
      [
        RawdahPalette.goldLight.withValues(alpha: 0.07 * rays),
        RawdahPalette.goldLight.withValues(alpha: 0.025 * rays),
        RawdahPalette.goldLight.withValues(alpha: 0),
      ],
      const [0, 0.5, 1],
    );
    final paint = Paint()
      ..blendMode = BlendMode.plus
      ..shader = shader;
    // A fan over the upper half-circle; each ray a narrow wedge over a
    // wider, fainter one, so its edges read soft without a blur.
    const spread = math.pi * 0.78;
    final path = Path();
    for (final halfWedge in const [math.pi / 70, math.pi / 160]) {
      for (var i = 0; i < _rayCount; i++) {
        final angle = -math.pi / 2 - spread / 2 + spread * i / (_rayCount - 1);
        path
          ..moveTo(from.dx, from.dy)
          ..lineTo(
            from.dx + length * math.cos(angle - halfWedge),
            from.dy + length * math.sin(angle - halfWedge),
          )
          ..lineTo(
            from.dx + length * math.cos(angle + halfWedge),
            from.dy + length * math.sin(angle + halfWedge),
          )
          ..close();
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DawnPainter old) =>
      old.from != from ||
      old.bloom != bloom ||
      old.reach != reach ||
      old.rays != rays;
}

/// Light on the logo itself, added so it only lightens: a [sheen] (0 → 1,
/// its place across the logo) and warm [glow] (0 → 1) over the lantern and
/// the sunrise; both pools
/// sit well inside the logo's square, clear of its edge and mostly of the
/// letters.
final class _GlowPainter extends CustomPainter {
  new({required this.sheen, required this.glow});

  final double sheen;
  final double glow;

  /// Where the lantern and the sunrise sit in the logo, as fractions of it.
  static const lantern = Offset(0.5, 0.23);
  static const sunrise = Offset(0.5, 0.845);

  @override
  void paint(Canvas canvas, Size size) {
    if (sheen > 0 && sheen < 1) {
      // A soft diagonal band from the upper left to the lower right.
      final across = -0.35 + 1.7 * sheen;
      final centre = Offset(size.width * across, size.height * 0.5);
      const direction = Offset(0.91, 0.41);
      final half = direction * (size.width * 0.16);
      final strength = math.sin(math.pi * sheen);
      canvas
        ..save()
        ..clipRect(Offset.zero & size)
        ..drawRect(
          Offset.zero & size,
          Paint()
            ..blendMode = BlendMode.plus
            ..shader = ui.Gradient.linear(
              centre - half,
              centre + half,
              [
                RawdahPalette.goldLight.withValues(alpha: 0),
                RawdahPalette.goldLight.withValues(alpha: 0.22 * strength),
                RawdahPalette.goldLight.withValues(alpha: 0),
              ],
              const [0, 0.5, 1],
            ),
        )
        ..restore();
    }
    if (glow <= 0) return;

    void pool(Offset at, double radius, double squash, double alpha) {
      final centre = Offset(at.dx * size.width, at.dy * size.height);
      final r = radius * size.width;
      canvas
        ..save()
        ..translate(centre.dx, centre.dy)
        ..scale(1, squash)
        ..drawCircle(
          Offset.zero,
          r,
          Paint()
            ..blendMode = BlendMode.plus
            ..shader = RadialGradient(
              colors: [
                RawdahPalette.goldLight.withValues(alpha: alpha * glow),
                RawdahPalette.goldLight.withValues(alpha: 0),
              ],
            ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
        )
        ..restore();
    }

    pool(lantern, 0.15, 1, 0.26);
    pool(sunrise, 0.16, 0.45, 0.22);
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.sheen != sheen || old.glow != glow;
}
