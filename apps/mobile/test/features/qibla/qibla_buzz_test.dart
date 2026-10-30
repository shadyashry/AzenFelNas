import 'package:daily_muslim/features/qibla/domain/qibla_state.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_page.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

final QiblaResult _qibla = const CalculateQibla()(
  Observer(
    latitudeDeg: 30.04,
    longitudeDeg: 31.24,
    zoneId: 'Africa/Cairo',
    source: ObserverSource.manual,
  ),
);

/// A sample [turn] degrees away from the Qibla.
QiblaReady _off(double turn) => QiblaReady(
  _qibla,
  headingDeg: _qibla.bearingDeg - turn,
  accuracyDeg: 5,
);

void main() {
  test('REQ-UX-041 lining up vibrates once for one second; wavering at the '
      'edge of the green line does not vibrate again', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final armed = c.read(qiblaBuzzArmedProvider.notifier);

    final fired = [
      for (final turn in [20.0, 2.0, 1.0, 4.0, 2.5, 5.0, 0.5])
        armed.next(_off(turn)),
    ];

    expect(fired, [false, true, false, false, false, false, false]);
    expect(QiblaPage.lineUpBuzz, const Duration(seconds: 1));
  });

  test('REQ-UX-041 turning clearly away and back lines up again with a new '
      'vibration', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final armed = c.read(qiblaBuzzArmedProvider.notifier);

    expect(armed.next(_off(1)), isTrue);
    expect(armed.next(_off(QiblaBuzzArmed.rearmDeg + 1)), isFalse);
    expect(armed.next(_off(1)), isTrue);
    expect(armed.next(null), isFalse);
    expect(armed.next(_off(0)), isTrue);
  });
}
