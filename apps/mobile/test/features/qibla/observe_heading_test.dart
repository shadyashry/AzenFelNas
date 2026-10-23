import 'package:daily_muslim/features/qibla/application/observe_heading.dart';
import 'package:daily_muslim/features/qibla/domain/heading_event.dart';
import 'package:daily_muslim/features/qibla/domain/qibla_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import 'support/fake_heading_source.dart';

final _cairo = Observer(
  latitudeDeg: 30.04,
  longitudeDeg: 31.24,
  zoneId: 'Africa/Cairo',
  source: ObserverSource.manual,
);

Future<List<QiblaState>> _states(List<HeadingEvent> events) => ObserveHeading(
  FakeHeadingSource(events),
)(_cairo).take(events.length + 1).toList();

void main() {
  group('ObserveHeading (§6.6, §18.4)', () {
    test('REQ-DOM-030 every state carries the true-north bearing', () async {
      final states = await _states([
        const HeadingReading(trueHeadingDeg: 100, accuracyDeg: 5),
        const HeadingReading(trueHeadingDeg: 100, accuracyDeg: 40),
        const HeadingUnavailable(),
      ]);
      expect(states, hasLength(4));
      for (final s in states) {
        expect(s.qibla, const CalculateQibla()(_cairo));
      }
      expect(states[0], isA<QiblaNoHeading>());
      expect(states[1], isA<QiblaReady>());
      expect(states[2], isA<QiblaCalibrating>());
      expect(states[3], isA<QiblaNumericOnly>());
    });

    test('the arrow needs true north and accuracy within 15°', () async {
      final states = await _states([
        const HeadingReading(trueHeadingDeg: 100, accuracyDeg: 15),
        const HeadingReading(trueHeadingDeg: 100, accuracyDeg: 15.5),
        const HeadingReading(trueHeadingDeg: 100, accuracyDeg: null),
        const HeadingReading(trueHeadingDeg: null, accuracyDeg: 3),
      ]);
      expect(states[1], isA<QiblaReady>());
      expect(states[2], isA<QiblaCalibrating>());
      expect((states[3] as QiblaCalibrating).accuracyDeg, isNull);
      expect(states[4], isA<QiblaCalibrating>());
    });

    test('the turn is the signed shortest rotation to the bearing', () {
      final q = const CalculateQibla()(_cairo);
      QiblaReady at(double h) => QiblaReady(q, headingDeg: h, accuracyDeg: 5);
      expect(at(q.bearingDeg).turnDeg, closeTo(0, 1e-9));
      expect(at(q.bearingDeg - 30).turnDeg, closeTo(30, 1e-9));
      expect(at((q.bearingDeg + 200) % 360).turnDeg, closeTo(160, 1e-9));
    });
  });
}
