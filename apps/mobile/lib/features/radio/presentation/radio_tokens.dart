import 'package:flutter/material.dart';

/// The Radio screen's colours in Horizon light and Horizon Dark (the
/// owner's tokens, §15 D122). Dark is its own set of values, never an
/// inversion. Text roles meet 4.5:1 on [background], [surface] and
/// [selected], and [goldIcon] 3:1 (pinned by `radio_tokens_test`). Two
/// light values move from the owner's palette for that: secondary text
/// #65756A → #5F6F64 (4.21:1 → 4.59:1 on the chosen row), and gold icons
/// that act use [goldIcon] #8A6A2E, since #C4A56A is 2.3:1 on cream; gold
/// stays #C4A56A where it only decorates.
@immutable
final class RadioTokens {
  /// A set of tokens.
  const new({
    required this.background,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.green,
    required this.header,
    required this.headerDeep,
    required this.gold,
    required this.goldIcon,
    required this.selected,
    required this.onGreen,
    required this.tile,
    required this.tileIcon,
  });

  /// Horizon light.
  static const RadioTokens light = RadioTokens(
    background: Color(0xFFF7F5EE),
    surface: Color(0xFFFFFCF5),
    text: Color(0xFF233D32),
    textMuted: Color(0xFF5F6F64),
    border: Color(0xFFDEDFCE),
    green: Color(0xFF174D3C),
    header: Color(0xFF153F34),
    headerDeep: Color(0xFF1F5A45),
    gold: Color(0xFFC4A56A),
    goldIcon: Color(0xFF8A6A2E),
    selected: Color(0xFFEAF0E7),
    onGreen: Color(0xFFF7F1E1),
    tile: Color(0xFFEAF0E7),
    tileIcon: Color(0xFF174D3C),
  );

  /// Horizon Dark.
  static const RadioTokens dark = RadioTokens(
    background: Color(0xFF10221A),
    surface: Color(0xFF192E23),
    text: Color(0xFFEEF0E3),
    textMuted: Color(0xFFB2C1B4),
    border: Color(0xFF36503B),
    green: Color(0xFF1F5A45),
    header: Color(0xFF0B281F),
    headerDeep: Color(0xFF2A5A41),
    gold: Color(0xFFD0B67B),
    goldIcon: Color(0xFFD0B67B),
    selected: Color(0xFF263F2D),
    onGreen: Color(0xFFF2EEDD),
    tile: Color(0xFF263F2D),
    tileIcon: Color(0xFFB2C1B4),
  );

  /// The tokens for [context]'s brightness.
  static RadioTokens of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// The page.
  final Color background;

  /// The player card and the search field.
  final Color surface;

  /// Primary text.
  final Color text;

  /// Secondary text and inactive icons.
  final Color textMuted;

  /// Fine borders and separators.
  final Color border;

  /// The arch artwork, the selected tile and the Play button.
  final Color green;

  /// The header's base green.
  final Color header;

  /// The header gradient's lighter end.
  final Color headerDeep;

  /// Restrained gold for decoration: outlines, the arch, the tab marker.
  final Color gold;

  /// Gold for icons that act or show a state: the favorite heart, the
  /// chosen sleep time.
  final Color goldIcon;

  /// The chosen station's row.
  final Color selected;

  /// Text and icons on [green] and on the header.
  final Color onGreen;

  /// A station's small arch tile.
  final Color tile;

  /// The icon on [tile].
  final Color tileIcon;
}

/// The mini player keeps its deep green in both appearances (§15 D122):
/// warm light text, a restrained gold border and a pale Play button.
abstract final class RadioMiniTokens {
  /// The player's surface.
  static const Color surface = Color(0xFF153F34);

  /// Its surface on the dark page, a step lighter so it stands off it.
  static const Color surfaceOnDark = Color(0xFF1B4638);

  /// The title.
  static const Color text = Color(0xFFF7F1E1);

  /// The status line.
  static const Color textMuted = Color(0xFFCBD6C8);

  /// The border.
  static const Color border = Color(0x99C4A56A);

  /// The Play and Pause disc.
  static const Color control = Color(0xFFF3E9CF);

  /// The icon on [control].
  static const Color onControl = Color(0xFF153F34);

  /// The live dot.
  static const Color live = Color(0xFF8FC79A);
}
