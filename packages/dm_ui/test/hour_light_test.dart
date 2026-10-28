import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

void main() {
  group('HourLight (§15 D89)', () {
    for (final light in HourLight.values) {
      test('REQ-UX-010 ivory text meets 4.5:1 on both ${light.name} field '
          'stops', () {
        for (final stop in [light.top, light.bottom]) {
          expect(
            WcagContrast.ratio(RawdahPalette.ivory, stop),
            greaterThanOrEqualTo(WcagContrast.textMinimum),
          );
        }
      });

      test('REQ-UX-010 the large niche time meets 3:1 on the glow-lit '
          '${light.name} centre', () {
        final middle = Color.lerp(light.top, light.bottom, 0.5) ?? light.top;
        final lit = Color.alphaBlend(
          light.glow.withValues(alpha: 0.30),
          middle,
        );
        expect(
          WcagContrast.ratio(RawdahPalette.ivory, lit),
          greaterThanOrEqualTo(3),
        );
      });
    }

    test('follows the awaited prayer: night before Fajr, honey before '
        'Maghrib, rose before Isha', () {
      expect(HourLight.before(PrayerEvent.fajr), HourLight.night);
      expect(HourLight.before(PrayerEvent.imsak), HourLight.night);
      expect(HourLight.before(PrayerEvent.sunrise), HourLight.dawn);
      expect(HourLight.before(PrayerEvent.dhuhr), HourLight.day);
      expect(HourLight.before(PrayerEvent.asr), HourLight.day);
      expect(HourLight.before(PrayerEvent.maghrib), HourLight.afternoon);
      expect(HourLight.before(PrayerEvent.isha), HourLight.dusk);
      expect(HourLight.before(null), HourLight.day);
    });
  });
}
