import 'package:dm_ui/src/sky/sky_theme.dart';
import 'package:dm_ui/src/tokens/dm_scales.dart';
import 'package:flutter/material.dart';

/// The Home sky surface (§7.9): the [SkyTheme] gradient with [title] and
/// [subtitle] on its scrim. The gradient cross-fades over the standard
/// motion, or instantly when the platform disables animations or
/// [reducedMotion] is set (Appendix K `reducedMotionOverride`, REQ-UX-020).
final class SkyHeader extends StatelessWidget {
  /// Creates a header.
  const new({
    required this.sky,
    required this.title,
    required this.subtitle,
    this.reducedMotion = false,
    super.key,
  });

  /// The sky colours.
  final SkyTheme sky;

  /// Primary line, e.g. the next prayer.
  final String title;

  /// Secondary line, e.g. its time.
  final String subtitle;

  /// The user's reduced-motion override.
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final still = reducedMotion || MediaQuery.disableAnimationsOf(context);
    final text = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: still ? DmScales.motionReduced : DmScales.motionStandard,
      padding: EdgeInsetsDirectional.all(DmScales.space[4]),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sky.gradientTop, sky.gradientBottom],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: sky.scrim.withValues(alpha: sky.scrimAlpha),
          borderRadius: BorderRadius.circular(DmScales.radius[1]),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.all(DmScales.space[3]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: text.headlineMedium?.copyWith(color: sky.onSurface),
                ),
              ),
              Text(
                subtitle,
                style: text.titleLarge?.copyWith(color: sky.onSurface),
              ),
              SizedBox(height: DmScales.space[1]),
              Icon(Icons.wb_twilight, color: sky.accent),
            ],
          ),
        ),
      ),
    );
  }
}
