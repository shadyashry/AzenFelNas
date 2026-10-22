import 'package:meta/meta.dart';

/// A type ramp entry of Appendix G: font size and line height, logical px.
@immutable
final class TypeStep {
  /// Creates a step.
  const new(this.size, this.lineHeight);

  /// Font size.
  final double size;

  /// Line height for Latin text; Arabic adds `DmScales.arabicExtraLine`.
  final double lineHeight;
}

/// The space, radius, type and motion scales of Appendix G.
abstract final class DmScales {
  /// Space scale on the 4-pt grid.
  static const List<double> space = [4, 8, 12, 16, 24, 32, 48];

  /// Corner radii.
  static const List<double> radius = [8, 12, 16, 24];

  /// Display text.
  static const TypeStep display = TypeStep(40, 48);

  /// Headline text.
  static const TypeStep headline = TypeStep(28, 36);

  /// Title text.
  static const TypeStep title = TypeStep(20, 28);

  /// Body text.
  static const TypeStep body = TypeStep(16, 24);

  /// Label text.
  static const TypeStep label = TypeStep(13, 18);

  /// Extra line height for Arabic text.
  static const double arabicExtraLine = 2;

  /// Standard motion.
  static const Duration motionStandard = Duration(milliseconds: 200);

  /// Motion when the platform or the user asks for reduced motion.
  static const Duration motionReduced = Duration.zero;

  /// The sky gradient re-renders at most this often.
  static const Duration skyMinRepaint = Duration(minutes: 1);

  /// Minimum interactive target (§7.9, REQ-UX-020).
  static const double minTarget = 44;
}
