import 'dart:ui';

import 'package:meta/meta.dart';

/// The Appendix G colours of one sky phase.
@immutable
final class SkyPhaseTokens {
  /// Creates the tokens of one phase.
  const new({
    required this.top,
    required this.bottom,
    required this.accent,
    required this.onSurface,
  });

  /// Gradient top stop.
  final Color top;

  /// Gradient bottom stop.
  final Color bottom;

  /// Accent for icons and non-text marks.
  final Color accent;

  /// Text and icons on the sky, one of `SkyTokens.onSurfaceCandidates`.
  final Color onSurface;
}
