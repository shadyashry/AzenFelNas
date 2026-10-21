import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/policy/ordering_guard.dart';
import 'package:test/test.dart';

const OrderingGuard _guard = OrderingGuard();
const HighLatitudeMethod _method = HighLatitudeMethod.seventhOfNight();

PrayerTime _at(
  PrayerEvent event,
  int displayedUtcMs, {
  EventOrigin origin = const EventOrigin.primary(),
  Set<ResultFlag> flags = const {},
}) => PrayerTime.timed(
  event: event,
  rawUtcMs: displayedUtcMs,
  displayedUtcMs: displayedUtcMs,
  dayOffset: 0,
  origin: origin,
  confidence: const ConfidenceLabel.calculated(),
  flags: flags,
);

PrayerTime _none(PrayerEvent event) => PrayerTime.noEvent(
  event: event,
  reason: NoEventReason.polarNight,
  confidence: const ConfidenceLabel.unknown(reasonCode: 'POLAR_NIGHT'),
);

void main() {
  group('OrderingGuard (§6.4 ¶10, REQ-DOM-001)', () {
    test('accepts strictly increasing displayed instants', () {
      expect(
        _guard.firstViolation([
          for (final (i, event) in PrayerEvent.values.indexed)
            _at(event, 1000 + i * 60000),
        ]),
        isNull,
      );
    });

    test('allows Imsak to tie with Fajr', () {
      expect(
        _guard.firstViolation([
          _at(PrayerEvent.imsak, 1000),
          _at(PrayerEvent.fajr, 1000),
          _at(PrayerEvent.sunrise, 61000),
        ]),
        isNull,
      );
    });

    test('reports the first tie or inversion of any other pair', () {
      final dhuhr = _at(PrayerEvent.dhuhr, 5000);
      final asr = _at(PrayerEvent.asr, 5000);
      expect(
        _guard.firstViolation([_at(PrayerEvent.sunrise, 1000), dhuhr, asr]),
        (dhuhr, asr),
      );
      final fajr = _at(PrayerEvent.fajr, 9000);
      final sunrise = _at(PrayerEvent.sunrise, 1000);
      expect(_guard.firstViolation([fajr, sunrise]), (fajr, sunrise));
    });

    test('skips events without an instant and compares their neighbours', () {
      final fajr = _at(PrayerEvent.fajr, 9000);
      final dhuhr = _at(PrayerEvent.dhuhr, 1000);
      expect(
        _guard.firstViolation([fajr, _none(PrayerEvent.sunrise), dhuhr]),
        (fajr, dhuhr),
      );
      expect(
        _guard.firstViolation([
          _at(PrayerEvent.fajr, 1000),
          _none(PrayerEvent.sunrise),
          _at(PrayerEvent.dhuhr, 9000),
        ]),
        isNull,
      );
    });

    test('allows a tie between two flagged high-latitude fallbacks only', () {
      PrayerTime fallback(PrayerEvent event, {required bool flagged}) => _at(
        event,
        7000,
        origin: const EventOrigin.fallback(_method),
        flags: {if (flagged) ResultFlag.highLatitudeFallback},
      );
      expect(
        _guard.firstViolation([
          fallback(PrayerEvent.maghrib, flagged: true),
          fallback(PrayerEvent.isha, flagged: true),
        ]),
        isNull,
      );
      expect(
        _guard.firstViolation([
          fallback(PrayerEvent.maghrib, flagged: true),
          fallback(PrayerEvent.isha, flagged: false),
        ]),
        isNotNull,
      );
      expect(
        _guard.firstViolation([
          _at(PrayerEvent.maghrib, 7000),
          fallback(PrayerEvent.isha, flagged: true),
        ]),
        isNotNull,
      );
    });
  });
}
