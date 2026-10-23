import 'package:daily_muslim/features/qibla/domain/qibla_state.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_page.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/state_harness.dart';

final QiblaResult _qibla = const CalculateQibla()(
  Observer(
    latitudeDeg: 30.04,
    longitudeDeg: 31.24,
    zoneId: 'Africa/Cairo',
    source: ObserverSource.manual,
  ),
);

Future<void> _pump(WidgetTester tester, QiblaState? state) async {
  await tester.pumpWidget(
    localizedApp(
      const QiblaPage(),
      overrides: [
        qiblaStateProvider.overrideWith((ref) => Stream.value(state)),
      ],
    ),
  );
  await tester.pump();
}

void main() {
  group('Qibla UiState (§18.4) — every variant renders', () {
    testWidgets('REQ-DOM-030 noHeading shows the bearing from true north', (
      tester,
    ) async {
      await _pump(tester, QiblaNoHeading(_qibla));
      expect(find.text('Qibla: 136.0° from true north'), findsOneWidget);
      expect(find.text('Waiting for the compass…'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('calibrating guides the user and shows no arrow', (
      tester,
    ) async {
      await _pump(tester, QiblaCalibrating(_qibla, 40));
      expect(find.textContaining('figure-eight'), findsOneWidget);
      expect(find.text('Compass accuracy ±40°'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Turn')), findsNothing);
    });

    testWidgets('REQ-UX-020 ready shows the arrow with a turn label', (
      tester,
    ) async {
      await _pump(
        tester,
        QiblaReady(_qibla, headingDeg: _qibla.bearingDeg - 12, accuracyDeg: 6),
      );
      expect(find.bySemanticsLabel('Turn 12° right'), findsWidgets);
      expect(find.text('Turn 12° right'), findsOneWidget);
      expect(find.text('Compass accuracy ±6°'), findsOneWidget);
    });

    testWidgets('numericOnly explains and keeps the number', (tester) async {
      await _pump(tester, QiblaNumericOnly(_qibla));
      expect(find.textContaining('no usable compass'), findsOneWidget);
      expect(find.text('Qibla: 136.0° from true north'), findsOneWidget);
    });

    testWidgets('without a place it asks for one', (tester) async {
      await _pump(tester, null);
      expect(find.text('Choose a place to see the Qibla.'), findsOneWidget);
    });
  });
}
