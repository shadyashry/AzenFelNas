import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:test/test.dart';

import '../support/engine_fixtures.dart';
import '../support/sites.dart';

/// 2026-06-21T00:00Z.
const int _solsticeUtcMs = 1782000000000;
const int _minuteMs = 60000;

void main() {
  final cairo = testCities.firstWhere((c) => c.zoneId == 'Africa/Cairo');
  final observer = observerOf(cairo);
  const solarState = ComputeSolarState();

  group('ComputeSolarState (§6.3, ADR-018)', () {
    test('REQ-DOM-020 equal arguments give equal states', () {
      expect(
        solarState(observer: observer, utcMs: _solsticeUtcMs),
        solarState(observer: observer, utcMs: _solsticeUtcMs),
      );
    });

    test('REQ-UX-010 altitude is the exact SPA topocentric altitude', () {
      final exact = ExactSun(cairo.site);
      for (var h = 0; h < 24; h++) {
        final t = _solsticeUtcMs + h * 3600000;
        expect(
          solarState(observer: observer, utcMs: t).altitudeDeg,
          closeTo(exact.altitudeDeg(t.toDouble()), 1e-9),
        );
      }
    });

    test('REQ-UX-010 the solstice culmination is 90° − |φ − δ| and '
        'direction flips there', () {
      var best = solarState(observer: observer, utcMs: _solsticeUtcMs);
      var bestT = _solsticeUtcMs;
      for (
        var t = _solsticeUtcMs;
        t < _solsticeUtcMs + 86400000;
        t += _minuteMs
      ) {
        final s = solarState(observer: observer, utcMs: t);
        if (s.altitudeDeg > best.altitudeDeg) (best, bestT) = (s, t);
      }
      expect(best.altitudeDeg, closeTo(90 - (30.04 - 23.44), 0.05));
      expect(best.phase, SkyPhase.day);
      expect(
        solarState(observer: observer, utcMs: bestT - 10 * _minuteMs).rising,
        isTrue,
      );
      expect(
        solarState(observer: observer, utcMs: bestT + 10 * _minuteMs).rising,
        isFalse,
      );
    });

    test('REQ-UX-010 a mid-latitude day passes all ten phases in order', () {
      final seen = <SkyPhase>[];
      for (
        var t = _solsticeUtcMs;
        t < _solsticeUtcMs + 86400000;
        t += _minuteMs
      ) {
        final phase = solarState(observer: observer, utcMs: t).phase;
        if (seen.isEmpty || seen.last != phase) seen.add(phase);
      }
      // Cairo midnight UTC is night: the day starts and ends there.
      expect(seen, [
        SkyPhase.night,
        SkyPhase.astronomicalDawn,
        SkyPhase.nauticalDawn,
        SkyPhase.civilDawn,
        SkyPhase.goldenMorning,
        SkyPhase.day,
        SkyPhase.goldenEvening,
        SkyPhase.civilDusk,
        SkyPhase.nauticalDusk,
        SkyPhase.astronomicalDusk,
        SkyPhase.night,
      ]);
    });
  });

  group('SkyPhase.classify (Appendix G bands)', () {
    test('REQ-UX-010 band edges follow the direction', () {
      SkyPhase c(double a, {required bool rising}) =>
          SkyPhase.classify(altitudeDeg: a, rising: rising);
      expect(c(-18.0001, rising: true), SkyPhase.night);
      expect(c(-18, rising: true), SkyPhase.astronomicalDawn);
      expect(c(-18, rising: false), SkyPhase.night);
      expect(c(-17.999, rising: false), SkyPhase.astronomicalDusk);
      expect(c(-12, rising: true), SkyPhase.nauticalDawn);
      expect(c(-12, rising: false), SkyPhase.astronomicalDusk);
      expect(c(-6, rising: true), SkyPhase.civilDawn);
      expect(c(-6, rising: false), SkyPhase.nauticalDusk);
      expect(c(-0.833, rising: true), SkyPhase.goldenMorning);
      expect(c(-0.833, rising: false), SkyPhase.civilDusk);
      expect(c(6, rising: true), SkyPhase.day);
      expect(c(6, rising: false), SkyPhase.goldenEvening);
      expect(c(6.0001, rising: false), SkyPhase.day);
      expect(c(-90, rising: false), SkyPhase.night);
      expect(c(90, rising: true), SkyPhase.day);
    });

    test('REQ-UX-010 progress runs 0 → 1 in the direction of travel', () {
      expect(SkyPhase.civilDawn.progressAt(-6), 0);
      expect(SkyPhase.civilDawn.progressAt(-0.833), 1);
      expect(SkyPhase.civilDusk.progressAt(-0.833), 0);
      expect(SkyPhase.civilDusk.progressAt(-6), 1);
      expect(SkyPhase.night.progressAt(-40), 0);
      expect(SkyPhase.day.progressAt(40), 0);
    });
  });
}
