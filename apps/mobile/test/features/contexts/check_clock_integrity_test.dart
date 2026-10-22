import 'package:daily_muslim/features/contexts/application/check_clock_integrity.dart';
import 'package:daily_muslim/features/contexts/domain/clock_integrity.dart';
import 'package:daily_muslim/features/contexts/domain/time_reference.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

TimeReference _sample(TimeSource source, int skewMs) => TimeReference(
  source: source,
  referenceUtcMs: 1792670400000,
  deviceUtcMs: 1792670400000 + skewMs,
);

void main() {
  const check = CheckClockIntegrity();

  group('REQ-TIME-010 device clock skew versus GNSS/CDN time', () {
    test('skew of exactly 60 s either way is consistent', () {
      expect(
        check([
          _sample(TimeSource.gnssFix, 60000),
          _sample(TimeSource.cdnDate, -60000),
        ]),
        const ClockConsistent(60000),
      );
    });

    test('skew above 60 s needs attention and names the worst sample', () {
      final worst = _sample(TimeSource.cdnDate, -61000);
      final integrity = check([_sample(TimeSource.gnssFix, 2000), worst]);
      expect(integrity, ClockSkewed(worst));
      expect(
        switch (integrity) {
          ClockSkewed(:final code, :final skewMs) => (code, skewMs),
          ClockConsistent() || ClockUnverified() => null,
        },
        (FailureCode.clockSkew, -61000),
      );
    });

    test('no sample leaves the clock unverified, not wrong', () {
      expect(check(const []), const ClockUnverified());
    });
  });
}
