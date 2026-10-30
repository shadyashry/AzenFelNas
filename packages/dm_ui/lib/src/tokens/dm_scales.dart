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

  /// Side gutter of every page (§15 D102).
  static const double gutter = 16;

  /// Horizontal padding of Home's content (§15 D109); [gutter] on a
  /// compact screen, narrower than [compactWidth].
  static const double pagePadding = 20;

  /// Below this width a screen is compact.
  static const double compactWidth = 375;

  /// Gap between major sections.
  static const double sectionGap = 16;

  /// Padding inside a card.
  static const double cardPadding = 16;

  /// Gap between an icon and its text.
  static const double iconGap = 12;

  /// Gap between closely related lines of text.
  static const double lineGap = 4;

  /// Home's horizontal padding for a screen [width] wide.
  static double paddingFor(double width) =>
      width < compactWidth ? gutter : pagePadding;

  /// Radius of controls: fields, menus, chips.
  static const double radiusControl = 14;

  /// Radius of cards and tiles.
  static const double radiusCard = 20;

  /// Radius of sheets, dialogs and the hero's lower edge.
  static const double radiusSheet = 28;

  /// Small icons: chips, inline marks.
  static const double iconSmall = 16;

  /// Icons in list rows and links.
  static const double iconMedium = 20;

  /// Standard icons: app bars, buttons, the navigation bar.
  static const double iconLarge = 24;

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
