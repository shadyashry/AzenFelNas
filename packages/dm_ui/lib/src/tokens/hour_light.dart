import 'package:flutter/painting.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The light of the current prayer interval (§7.9, §15 D89): the Home field
/// and the active navigation tab take it, so the screen follows the
/// prayer hours. Content below the field stays pearl.
///
/// Each value holds the field's two gradient stops, the glow around the
/// niche and whether stars show. Ivory text keeps at least 4.5:1 against
/// both stops and 3:1 against the glow-lit centre (REQ-UX-010, pinned by
/// `hour_light_test.dart`).
enum HourLight {
  /// After Isha and before Fajr: night lapis with stars.
  night(Color(0xFF10233F), Color(0xFF1D4E63), Color(0xFF8FC7D9), stars: true),

  /// Fajr to sunrise: lapis turning to teal under first light.
  dawn(Color(0xFF173A5A), Color(0xFF2F5F63), Color(0xFFF2D4A0), stars: false),

  /// Sunrise to Asr: luminous Rawdah emerald.
  day(Color(0xFF1C7550), Color(0xFF124A34), Color(0xFFFFF1C2), stars: false),

  /// Asr to Maghrib: emerald warmed into honey gold.
  afternoon(
    Color(0xFF2A6744),
    Color(0xFF465624),
    Color(0xFFF1C878),
    stars: false,
  ),

  /// Maghrib to Isha: rose amber over dark green, stars returning.
  dusk(Color(0xFF1E3E36), Color(0xFF6A3931), Color(0xFFF0AE8C), stars: true);

  new(this.top, this.bottom, this.glow, {required this.stars});

  /// The light before [next], the prayer the user is waiting for; with no
  /// next prayer (a polar day without one) the day light.
  static HourLight before(PrayerEvent? next) => switch (next) {
    PrayerEvent.imsak || PrayerEvent.fajr => night,
    PrayerEvent.sunrise => dawn,
    PrayerEvent.dhuhr || PrayerEvent.asr || null => day,
    PrayerEvent.maghrib => afternoon,
    PrayerEvent.isha => dusk,
  };

  /// Field colour at the top.
  final Color top;

  /// Field colour at the bottom.
  final Color bottom;

  /// The light around the niche and on the active tab.
  final Color glow;

  /// Whether the field shows stars.
  final bool stars;

  /// The swatch of [event]'s own light in the prayer list.
  static Color swatchOf(PrayerEvent event) => switch (event) {
    PrayerEvent.imsak => const Color(0xFF3E5E8E),
    PrayerEvent.fajr => const Color(0xFF3E6E9E),
    PrayerEvent.sunrise => const Color(0xFFE7B979),
    PrayerEvent.dhuhr => const Color(0xFFF4E7B8),
    PrayerEvent.asr => const Color(0xFFD9A548),
    PrayerEvent.maghrib => const Color(0xFFD7826A),
    PrayerEvent.isha => const Color(0xFF2B3F6B),
  };
}
