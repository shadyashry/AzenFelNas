import 'package:daily_muslim/features/qibla/domain/qibla_state.dart';
import 'package:daily_muslim/features/qibla/domain/shadow_times.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_page.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_ui/dm_ui.dart';
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

Future<void> _pump(
  WidgetTester tester,
  QiblaState? state, {
  ShadowTimes? shadows,
}) async {
  await tester.pumpWidget(
    localizedApp(
      const QiblaPage(),
      overrides: [
        qiblaStateProvider.overrideWith((ref) => Stream.value(state)),
        shadowTimesProvider.overrideWith((ref) async => shadows),
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
      await tester.scrollUntilVisible(find.text('Compass accuracy ±40°'), 100);
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

    testWidgets('within 3° of the bearing the user is told they face the '
        'Qibla and the dial lights its green line (§15 D98)', (tester) async {
      await _pump(
        tester,
        QiblaReady(
          _qibla,
          headingDeg: _qibla.bearingDeg - 2.5,
          accuracyDeg: 10,
        ),
      );
      expect(find.text('You are facing the Qibla.'), findsOneWidget);
      expect(tester.widget<QiblaDial>(find.byType(QiblaDial)).aligned, isTrue);
    });

    testWidgets('beyond 3° the user is told which way to turn and the dial '
        'stays unlit', (tester) async {
      await _pump(
        tester,
        QiblaReady(_qibla, headingDeg: _qibla.bearingDeg - 4, accuracyDeg: 10),
      );
      expect(find.text('Turn 4° right'), findsOneWidget);
      expect(tester.widget<QiblaDial>(find.byType(QiblaDial)).aligned, isFalse);
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

  group('Qibla shadow times (§15 D91)', () {
    const toward = ShadowTime(
      kind: QiblaSunAlignmentKind.sunTowardQibla,
      localTime: '10:17',
      windowStart: '10:13',
      windowEnd: '10:20',
      hardToUse: null,
      passed: true,
    );
    const away = ShadowTime(
      kind: QiblaSunAlignmentKind.sunAwayFromQibla,
      localTime: '20:19',
      windowStart: '20:14',
      windowEnd: '20:24',
      hardToUse: ShadowDifficulty.highSun,
      passed: false,
    );

    Future<void> pumpShadows(WidgetTester tester, ShadowTimes shadows) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await _pump(tester, QiblaNumericOnly(_qibla), shadows: shadows);
      await tester.scrollUntilVisible(
        find.text('20:19'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }

    testWidgets('REQ-DOM-031 lists each time with the shadow rule for its '
        'kind, its window and a passed mark', (tester) async {
      await pumpShadows(
        tester,
        ShadowTimesFound(
          date: CivilDate(2026, 5, 27),
          isToday: true,
          times: const [toward, away],
        ),
      );
      expect(find.text("Qibla by the Sun's shadow"), findsOneWidget);
      expect(find.text('10:17'), findsOneWidget);
      expect(find.textContaining('Face the Sun'), findsOneWidget);
      expect(find.textContaining('The Sun is behind you'), findsOneWidget);
      expect(find.text('Within 1° from 10:13 to 10:20'), findsOneWidget);
      expect(find.text('Passed'), findsOneWidget);
    });

    testWidgets('REQ-DOM-031 flags a hard-to-use time instead of hiding it', (
      tester,
    ) async {
      await pumpShadows(
        tester,
        ShadowTimesFound(
          date: CivilDate(2026, 5, 27),
          isToday: true,
          times: const [toward, away],
        ),
      );
      expect(find.textContaining('the Sun is high'), findsOneWidget);
      expect(find.text('20:19'), findsOneWidget);
    });

    testWidgets('REQ-DOM-031 names the later day when today has none', (
      tester,
    ) async {
      await pumpShadows(
        tester,
        ShadowTimesFound(
          date: CivilDate(2027, 1, 28),
          isToday: false,
          times: const [away],
        ),
      );
      expect(find.textContaining('None today. Next:'), findsOneWidget);
    });

    testWidgets('REQ-DOM-031 says so when no day has an alignment', (
      tester,
    ) async {
      await _pump(
        tester,
        QiblaNumericOnly(_qibla),
        shadows: const ShadowTimesNone(),
      );
      await tester.scrollUntilVisible(
        find.textContaining('does not line up'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('does not line up'), findsOneWidget);
    });

    testWidgets('REQ-DOM-031 shows no section near the Kaaba', (tester) async {
      await _pump(
        tester,
        QiblaNumericOnly(_qibla),
        shadows: const ShadowTimesNearKaaba(),
      );
      expect(
        find.text("Qibla by the Sun's shadow", skipOffstage: false),
        findsNothing,
      );
    });
  });
}
