import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The opening moment (§15 D100): the native launch screen's deep emerald
/// continues here, the mihrab mark rises and settles over a gold girih,
/// then the whole intro fades into the app. The app starts underneath at
/// once; the intro never blocks a tap and is hidden from screen readers.
final class BrandIntro extends StatefulWidget {
  /// The intro over [child].
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  /// How long the intro shows, fade-out included.
  static const duration = Duration(milliseconds: 1400);

  /// With reduced motion: a short fade only.
  static const reducedDuration = Duration(milliseconds: 500);

  @override
  State<BrandIntro> createState() => _BrandIntroState();
}

final class _BrandIntroState extends State<BrandIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this);
  bool _done = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _clock.duration = MediaQuery.disableAnimationsOf(context)
        ? BrandIntro.reducedDuration
        : BrandIntro.duration;
    _clock.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _done = true);
      }
    });
    _clock.forward();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
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
          IgnorePointer(
            child: ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _clock,
                builder: (context, _) {
                  final t = _clock.value;
                  // In over the first third, held, out over the last quarter.
                  final fadeOut = Curves.easeIn.transform(
                    ((t - 0.75) / 0.25).clamp(0.0, 1.0),
                  );
                  final rise = still
                      ? 1.0
                      : Curves.easeOutCubic.transform(
                          (t / 0.35).clamp(0.0, 1.0),
                        );
                  return Opacity(
                    opacity: 1 - fadeOut,
                    child: _Stage(rise: rise, progress: t),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// The emerald stage with the mark at [rise] and the gold line at
/// [progress] (both 0 → 1).
final class _Stage extends StatelessWidget {
  const new({required this.rise, required this.progress});

  final double rise;
  final double progress;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        radius: 1.1,
        colors: [Color(0xFF17563C), RawdahPalette.emeraldDeep],
      ),
    ),
    child: GirihBackdrop(
      ground: Colors.transparent,
      ink: RawdahPalette.gold,
      child: Center(
        child: Opacity(
          opacity: rise,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - rise)),
            child: Transform.scale(
              scale: 0.92 + 0.08 * rise,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/brand/logo.png', height: 240),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 160,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      backgroundColor: RawdahPalette.goldDeep.withValues(
                        alpha: 0.35,
                      ),
                      color: RawdahPalette.goldLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
