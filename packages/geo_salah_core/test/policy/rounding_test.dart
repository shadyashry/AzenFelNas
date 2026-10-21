import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/policy/rounding.dart';
import 'package:glados/glados.dart';

const PerEventRounding _rounding = PerEventRounding();

/// 2026-03-20T12:34:00Z, on a UTC minute boundary.
const int _minute = 1774010040000;

/// Instants in 2026–2028 and whole-minute or second-granular UTC offsets.
final Generator<int> _instants = any.intInRange(1767225600000, 1861920000000);
final Generator<int> _offsets = any.intInRange(-12 * 3600, 14 * 3600);

int _displayed(int utcMs, RoundingMode mode, {int offsetSeconds = 0}) =>
    _rounding.round(utcMs, mode, offsetSeconds: offsetSeconds).displayedUtcMs;

void main() {
  group('PerEventRounding (ADR-005, §6.4 ¶9)', () {
    test('rounds up with ceil, down with floor and half up with nearest', () {
      expect(_displayed(_minute + 1, RoundingMode.ceil), _minute + 60000);
      expect(_displayed(_minute + 59999, RoundingMode.floor), _minute);
      expect(_displayed(_minute + 29999, RoundingMode.nearest), _minute);
      expect(
        _displayed(_minute + 30000, RoundingMode.nearest),
        _minute + 60000,
      );
    });

    test('keeps an instant already on a minute boundary in every mode', () {
      for (final mode in RoundingMode.values) {
        expect(_displayed(_minute, mode), _minute, reason: '$mode');
      }
    });

    test('rounds to the local minute in a zone whose offset has seconds', () {
      // Monrovia's historical offset, −0:44:30.
      const offsetSeconds = -(44 * 60 + 30);
      final displayed = _displayed(
        _minute + 1000,
        RoundingMode.ceil,
        offsetSeconds: offsetSeconds,
      );
      expect((displayed + offsetSeconds * 1000) % 60000, 0);
      expect(displayed, _minute + 30000);
    });

    test('flags an instant within 500 ms of a minute boundary on either '
        'side (ADR-005)', () {
      bool near(int utcMs) => _rounding
          .round(utcMs, RoundingMode.ceil, offsetSeconds: 0)
          .nearBoundary;
      expect(near(_minute), isTrue);
      expect(near(_minute + 499), isTrue);
      expect(near(_minute + 500), isFalse);
      expect(near(_minute - 500), isFalse);
      expect(near(_minute - 499), isTrue);
      expect(near(_minute + 30000), isFalse);
    });

    Glados2(_instants, _offsets).test(
      'lands on a local minute boundary within the ADR-005 budget: ceil '
      '−0/+60 s, floor −60/+0 s, nearest ±30 s',
      (utcMs, offsetSeconds) {
        for (final mode in RoundingMode.values) {
          final displayed = _displayed(
            utcMs,
            mode,
            offsetSeconds: offsetSeconds,
          );
          expect((displayed + offsetSeconds * 1000) % 60000, 0);
          final delta = displayed - utcMs;
          switch (mode) {
            case RoundingMode.ceil:
              expect(delta, inInclusiveRange(0, 59999));
            case RoundingMode.floor:
              expect(delta, inInclusiveRange(-59999, 0));
            case RoundingMode.nearest:
              expect(delta, inInclusiveRange(-29999, 30000));
          }
        }
      },
    );

    Glados2(_instants, _offsets).test(
      'is idempotent: rounding a displayed instant changes nothing (§6.7)',
      (utcMs, offsetSeconds) {
        for (final mode in RoundingMode.values) {
          final once = _displayed(utcMs, mode, offsetSeconds: offsetSeconds);
          expect(_displayed(once, mode, offsetSeconds: offsetSeconds), once);
        }
      },
    );
  });
}
