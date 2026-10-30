import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The opening moment (§15 D113), over the whole screen. The native launch
/// screen is the logo's own green with nothing on it, and so is the intro's
/// first frame. Once the logo is decoded and that frame is on screen, the
/// approved logo fades in while it settles from 97 to 100 % (0–780 ms); a
/// soft warm glow rises and falls at its lantern (300–1250 ms), then at its
/// sunrise (600–1430 ms), and a gold light runs out along its horizon line
/// and fades (650–1450 ms). The light is drawn over the logo, never into
/// it, and kept off the lettering; it plays once and never loops. At
/// [motionDuration] the intro crossfades into the app if it is [ready]
/// ([exitDuration]); otherwise the logo rests, a thin gold line says it is
/// loading after [loadingAfter], and after [longestHold] the intro leaves
/// anyway for the app's own loading and recovery states. The app starts
/// underneath at once and keeps its place in the tree, so deep links and
/// notification taps land while the intro plays. A tap skips it; it is
/// hidden from screen readers. With reduced motion, or when the launch
/// opened a link ([brief]), the logo stays at its size with no light: a
/// [briefFade] in, a short rest, a [briefFade] into the app once it is
/// ready. It plays once per launch: a resume does not replay it.
final class BrandIntro extends StatefulWidget {
  /// The intro over [child], leaving once [ready].
  const new({
    required this.child,
    this.ready = true,
    this.brief = false,
    super.key,
  });

  /// The app.
  final Widget child;

  /// Whether the first screen has its content.
  final bool ready;

  /// Whether to play the still, short intro whatever the motion setting:
  /// the launch opened a link, so its page should come quickly.
  final bool brief;

  /// The logo's fade-in and the light on it.
  static const motionDuration = Duration(milliseconds: 1500);

  /// The crossfade into the app.
  static const exitDuration = Duration(milliseconds: 450);

  /// The still intro's fades in and out, and the fade when a tap skips.
  static const briefFade = Duration(milliseconds: 180);

  /// How long the still intro shows the logo before it may leave.
  static const briefRest = Duration(milliseconds: 400);

  /// How long the resting logo waits for [ready] before the loading line.
  static const loadingAfter = Duration(seconds: 2);

  /// The longest the resting logo waits for [ready].
  static const longestHold = Duration(seconds: 8);

  /// The longest the logo's fade-in waits for the image to decode, and for
  /// the first frame to reach the screen. A busy cold start on the emulator
  /// took over 400 ms to decode, and the logo then popped in mid-fade.
  static const decodeWait = Duration(milliseconds: 1500);

  /// The intro's logo: the approved logo, its plain edge faded.
  static const asset = 'assets/brand/logo_launch.png';

  /// The logo's largest side: the intro asset's 1x size, so it stays crisp.
  static const largestSide = 418.0;

  /// Where the logo rests on a screen of [size] whose system bars take
  /// [safe]: most of the safe width in portrait, short of the safe height
  /// in landscape so the loading line has room, a little above the centre.
  static Rect logoRectIn(Size size, EdgeInsets safe) {
    final area = safe.deflateRect(Offset.zero & size);
    final side = math.min(
      math.min(area.width * 0.86, area.height * 0.62),
      largestSide,
    );
    final centre = area.center.translate(0, -0.12 * (area.height - side) / 2);
    return Rect.fromCenter(center: centre, width: side, height: side);
  }

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
  late final Animation<double> _shown = ReverseAnimation(
    CurvedAnimation(parent: _exit, curve: Curves.easeOut),
  );
  final List<Timer> _timers = [];
  bool _started = false;
  bool _still = false;
  bool _settled = false;
  bool _loading = false;
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _still = widget.brief || MediaQuery.disableAnimationsOf(context);
    if (_still) {
      _motion.duration = BrandIntro.briefFade;
      _exit.duration = BrandIntro.briefFade;
    }
    // The fade-in starts once the logo is decoded and the first frame, the
    // bare ground, is on screen, so none of it is lost to start-up; at the
    // latest [BrandIntro.decodeWait] later.
    unawaited(
      Future.wait([
        _atMost(precacheImage(const AssetImage(BrandIntro.asset), context)),
        _atMost(WidgetsBinding.instance.waitUntilFirstFrameRasterized),
      ]).then((_) => _begin()),
    );
  }

  static Future<void> _atMost(Future<void> wait) =>
      Future.any([wait, Future<void>.delayed(BrandIntro.decodeWait)]);

  @override
  void didUpdateWidget(BrandIntro old) {
    super.didUpdateWidget(old);
    if (_settled && widget.ready && !old.ready) _leave();
  }

  @override
  void dispose() {
    _cancelTimers();
    _motion.dispose();
    _exit.dispose();
    super.dispose();
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void _begin() {
    if (!mounted || _exit.status != AnimationStatus.dismissed) return;
    _motion.forward().whenCompleteOrCancel(() {
      if (!mounted || !_motion.isCompleted) return;
      if (_still) {
        _timers.add(Timer(BrandIntro.briefRest, _settle));
      } else {
        _settle();
      }
    });
  }

  void _settle() {
    if (!mounted) return;
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

  /// Crossfades into the app.
  void _leave({bool quick = false}) {
    _cancelTimers();
    if (!mounted || _exit.status != AnimationStatus.dismissed) return;
    if (quick) _exit.duration = BrandIntro.briefFade;
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
    // its state is rebuilt. Until the crossfade starts it is laid out and
    // read by screen readers but not painted: the opaque stage covers it,
    // and painting it under every frame of the motion is wasted work.
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _exit,
          builder: (context, app) => Opacity(
            opacity: _done || _exit.value > 0 ? 1 : 0,
            alwaysIncludeSemantics: true,
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
                  opacity: _shown,
                  child: AnimatedBuilder(
                    animation: _motion,
                    builder: (context, _) => _Stage(
                      t: _motion.value,
                      still: _still,
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

/// The whole-screen stage at motion [t] (0 → 1 over
/// [BrandIntro.motionDuration], or over [BrandIntro.briefFade] when
/// [still]); [loading] once the app has kept the resting logo waiting.
final class _Stage extends StatelessWidget {
  const new({required this.t, required this.still, required this.loading});

  final double t;
  final bool still;
  final bool loading;

  /// How far through [from]–[to] ms of the motion [t] is, 0 → 1.
  static double _span(double t, int from, int to) {
    final ms = t * BrandIntro.motionDuration.inMilliseconds;
    return ((ms - from) / (to - from)).clamp(0.0, 1.0);
  }

  /// Up over [from]–[peak] ms, back down to nothing by [to] ms.
  static double _swell(double t, int from, int peak, int to) {
    final rising = _span(t, from, peak);
    return rising < 1
        ? Curves.easeOutCubic.transform(rising)
        : 1 - Curves.easeInOutSine.transform(_span(t, peak, to));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logo = BrandIntro.logoRectIn(size, MediaQuery.paddingOf(context));
    final appear = still
        ? Curves.easeOut.transform(t)
        : Curves.easeOutCubic.transform(_span(t, 0, 780));
    return ColoredBox(
      color: RawdahPalette.logoGround,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: CustomPaint(
              painter: _GroundPainter(logo: logo, strength: appear),
            ),
          ),
          Positioned.fromRect(
            rect: logo,
            child: Opacity(
              opacity: appear,
              child: Transform.scale(
                scale: still ? 1 : 0.97 + 0.03 * appear,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      BrandIntro.asset,
                      width: logo.width,
                      height: logo.height,
                      gaplessPlayback: true,
                    ),
                    if (!still)
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _LightPainter(
                            lantern: _swell(t, 300, 700, 1250),
                            sunrise: _swell(t, 600, 1000, 1430),
                            horizon: _swell(t, 650, 1050, 1450),
                            reach: Curves.easeOutCubic.transform(
                              _span(t, 650, 1150),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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

/// The ground at [strength] (0 → 1, from the launch screen's flat green): a
/// restrained emerald lift behind the [logo], whose own green is a little
/// lighter than its outer band, easing to the plain ground by the circle
/// through its corners, then deepening towards the screen's corners. The
/// logo's faded edge so meets a green close to its own and no square shows.
final class _GroundPainter extends CustomPainter {
  new({required this.logo, required this.strength});

  final Rect logo;
  final double strength;

  static final Color _lift =
      Color.lerp(
        RawdahPalette.logoGround,
        RawdahPalette.emerald,
        0.12,
      ) ??
      RawdahPalette.logoGround;
  static final Color _dusk =
      Color.lerp(
        RawdahPalette.logoGround,
        Colors.black,
        0.32,
      ) ??
      RawdahPalette.logoGround;

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0) return;
    final side = logo.width;
    final far = math.max(
      side,
      [
        Offset.zero,
        Offset(size.width, 0),
        Offset(0, size.height),
        Offset(size.width, size.height),
      ].map((corner) => (corner - logo.center).distance).reduce(math.max),
    );
    Color at(Color to) =>
        Color.lerp(RawdahPalette.logoGround, to, strength) ??
        RawdahPalette.logoGround;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.radial(
          logo.center,
          far,
          [at(_lift), at(_lift), RawdahPalette.logoGround, at(_dusk)],
          [0, 0.3 * side / far, side * math.sqrt1_2 / far, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_GroundPainter old) =>
      old.logo != logo || old.strength != strength;
}

/// Light over the logo, each part 0 → 1, added so it only lightens: a warm
/// glow at the [lantern], a low glow at the [sunrise], and light along the
/// [horizon] line, running out from the sunrise to [reach] of it. Every
/// pool sits clear of the lettering; no blur or blend that reads the
/// screen back, so it stays cheap. Places are fractions of the logo's
/// side, measured on `tool/brand/logo_source.png`.
final class _LightPainter extends CustomPainter {
  new({
    required this.lantern,
    required this.sunrise,
    required this.horizon,
    required this.reach,
  });

  final double lantern;
  final double sunrise;
  final double horizon;
  final double reach;

  /// The lantern's body; the nearest letter mark is 0.145 away.
  static const lanternAt = Offset(0.493, 0.232);

  /// The sunrise dome, sitting on the horizon line.
  static const sunriseAt = Offset(0.499, 0.848);

  /// The horizon line from pillar to pillar: a shallow curve through its
  /// top under the sunrise.
  static const horizonFrom = Offset(0.21, 0.8725);
  static const horizonBend = Offset(0.5025, 0.8433);
  static const horizonTo = Offset(0.795, 0.873);

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.width;

    void pool(Offset at, double radius, double squash, double alpha) {
      if (alpha <= 0) return;
      final r = radius * side;
      canvas
        ..save()
        ..translate(at.dx * side, at.dy * side)
        ..scale(1, squash)
        ..drawCircle(
          Offset.zero,
          r,
          Paint()
            ..blendMode = BlendMode.plus
            ..shader = ui.Gradient.radial(
              Offset.zero,
              r,
              [
                RawdahPalette.goldLight.withValues(alpha: alpha),
                RawdahPalette.gold.withValues(alpha: alpha * 0.35),
                RawdahPalette.gold.withValues(alpha: 0),
              ],
              const [0, 0.45, 1],
            ),
        )
        ..restore();
    }

    pool(lanternAt, 0.13, 1, 0.24 * lantern);
    pool(sunriseAt, 0.14, 0.4, 0.22 * sunrise);

    if (horizon <= 0 || reach <= 0) return;
    final from = horizonFrom * side;
    final to = horizonTo * side;
    final line = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(
        horizonBend.dx * side,
        horizonBend.dy * side,
        to.dx,
        to.dy,
      );
    // From the sunrise outward: bright at the middle, nothing past reach;
    // strokes from wide and faint to narrow and bright, so the light reads
    // soft without a blur.
    final half = 0.5 * reach;
    for (final (width, alpha) in const [
      (0.026, 0.08),
      (0.014, 0.14),
      (0.006, 0.34),
    ]) {
      final light = RawdahPalette.goldLight.withValues(alpha: alpha * horizon);
      canvas.drawPath(
        line,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = width * side
          ..blendMode = BlendMode.plus
          ..shader = ui.Gradient.linear(
            Offset(from.dx, 0),
            Offset(to.dx, 0),
            [light.withValues(alpha: 0), light, light.withValues(alpha: 0)],
            [0.5 - half, 0.5, 0.5 + half],
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_LightPainter old) =>
      old.lantern != lantern ||
      old.sunrise != sunrise ||
      old.horizon != horizon ||
      old.reach != reach;
}
