import 'dart:ui';

import 'package:meta/meta.dart';

/// The static content-surface roles of Appendix G, for one brightness.
/// Content surfaces use them, never the sky (§7.9, readability first).
@immutable
final class StaticPalette {
  /// Creates a palette.
  const new({
    required this.surface,
    required this.onSurface,
    required this.primary,
    required this.secondary,
    required this.error,
  });

  /// The light palette.
  static const StaticPalette light = StaticPalette(
    surface: Color(0xFFFAF9F6),
    onSurface: Color(0xFF1C1B1F),
    primary: Color(0xFF1F6F5F),
    secondary: Color(0xFFB8862E),
    error: Color(0xFFB3261E),
  );

  /// The dark palette.
  static const StaticPalette dark = StaticPalette(
    surface: Color(0xFF121318),
    onSurface: Color(0xFFE6E1E5),
    primary: Color(0xFF7FC8B8),
    secondary: Color(0xFFE3B661),
    error: Color(0xFFF2B8B5),
  );

  /// Content surface.
  final Color surface;

  /// Text on [surface].
  final Color onSurface;

  /// Primary role; text-safe on [surface].
  final Color primary;

  /// Secondary role; non-text marks only in light (3.07:1, §15 D75).
  final Color secondary;

  /// Error role; text-safe on [surface].
  final Color error;
}
