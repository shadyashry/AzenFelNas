import 'package:flutter/painting.dart';

/// The elevation tokens (§15 D102): soft, green-tinted shadows instead of
/// Material's grey, so depth stays subtle on cream.
abstract final class DmElevation {
  /// Cards and tiles on cream.
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x14062E25), offset: Offset(0, 4), blurRadius: 14),
  ];

  /// The schedule card lifted over the Home hero.
  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x29062E25), offset: Offset(0, 10), blurRadius: 28),
  ];

  /// The navigation bar.
  static const List<BoxShadow> bar = [
    BoxShadow(color: Color(0x33062E25), offset: Offset(0, -2), blurRadius: 18),
  ];
}
