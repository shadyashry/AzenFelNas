import 'dart:async';
import 'dart:math' as math;

import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The opening moment (§15 D100, D101, D106), over the whole screen. The
/// native launch screen shows the approved logo at [launchSide] on its own
/// green; the intro's first frame is that same picture, held back until the
/// logo is decoded, so nothing blinks or jumps. The logo then settles to
/// [side] while one warm glow rises over the lantern and the sunrise and
/// fades, and rests, still, until the app is [ready]; then the intro fades
/// into it. If the app is still loading [loadingAfter] after the logo
/// settled, a thin gold line says so; after [longestHold] the intro leaves
/// anyway for the app's own loading and recovery states. The app starts
/// underneath at once and keeps its place in the tree, so deep links and
/// notification taps land while the intro plays. A tap skips it; it is
/// hidden from screen readers. With reduced motion the logo stays still and
/// the intro fades when the app is ready. It plays once per process: a
/// resume does not replay it.
final class BrandIntro extends StatefulWidget {
  /// The intro over [child], leaving once [ready].
  const new({required this.child, this.ready = true, super.key});

  /// The app.
  final Widget child;

  /// Whether the first screen has its content.
  final bool ready;

  /// The logo's side once settled, in logical pixels.
  static const side = 180.0;

  /// The logo's side on the native launch screens (97 % of [side]); the
  /// launch images are made at this size by `tool/brand`.
  static const launchSide = 175.0;

  /// The settle and the glow.
  static const motionDuration = Duration(milliseconds: 900);

  /// The fade into the app.
  static const exitDuration = Duration(milliseconds: 300);

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
              // Light status bar icons over the green (§15 D101).
              child: AnnotatedRegion(
                value: DmTheme.statusBarOn(Brightness.dark),
                child: FadeTransition(
                  opacity: ReverseAnimation(
                    CurvedAnimation(parent: _exit, curve: Curves.easeOut),
                  ),
                  child: AnimatedBuilder(
                    animation: _motion,
                    builder: (context, _) =>
                        _Stage(t: _motion.value, loading: _loading),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The whole-screen stage at motion [t] (0 → 1); [loading] once the app
/// has kept the settled logo waiting.
final class _Stage extends StatelessWidget {
  const new({required this.t, required this.loading});

  final double t;
  final bool loading;

  /// 0 before [from], 1 after [to], linear between.
  static double _span(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Centred on the whole screen, as the launch screens are; smaller only
    // where a screen could not hold it.
    final side = math.min(BrandIntro.side, size.shortestSide * 0.6);
    final settle = Curves.easeOutCubic.transform(_span(t, 0, 0.78));
    const from = BrandIntro.launchSide / BrandIntro.side;
    // One warm glow: up by 0.55, gone by the end, the logo still and crisp.
    final glow = t < 0.55
        ? Curves.easeOut.transform(_span(t, 0.15, 0.55))
        : 1 - Curves.easeInOut.transform(_span(t, 0.55, 1));
    return ColoredBox(
      color: RawdahPalette.logoGround,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Transform.scale(
              scale: from + (1 - from) * settle,
              child: SizedBox.square(
                dimension: side,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      BrandIntro.asset,
                      width: side,
                      height: side,
                      gaplessPlayback: true,
                    ),
                    if (glow > 0)
                      IgnorePointer(
                        child: CustomPaint(painter: _GlowPainter(glow)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Transform.translate(
              offset: Offset(0, side / 2 + 40),
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

/// Warm light over the logo's lantern and sunrise at [strength] (0 → 1),
/// screened onto the picture so it only brightens; both pools sit well
/// inside the logo's square, clear of its edge and mostly of the letters.
final class _GlowPainter extends CustomPainter {
  new(this.strength);

  final double strength;

  /// Where the lantern and the sunrise sit in the logo, as fractions of it.
  static const _lantern = Offset(0.5, 0.23);
  static const _sunrise = Offset(0.5, 0.845);

  @override
  void paint(Canvas canvas, Size size) {
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
            ..blendMode = BlendMode.screen
            ..shader = RadialGradient(
              colors: [
                RawdahPalette.goldLight.withValues(alpha: alpha * strength),
                RawdahPalette.goldLight.withValues(alpha: 0),
              ],
            ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
        )
        ..restore();
    }

    pool(_lantern, 0.15, 1, 0.32);
    pool(_sunrise, 0.16, 0.45, 0.28);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.strength != strength;
}
