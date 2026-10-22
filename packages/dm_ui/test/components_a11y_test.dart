import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  bool disableAnimations = false,
}) => MaterialApp(
  theme: DmTheme.of(Brightness.light, StatusLocale.en),
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(360, 800),
      textScaler: TextScaler.linear(textScale),
      disableAnimations: disableAnimations,
    ),
    child: Directionality(
      textDirection: direction,
      child: Scaffold(body: Column(children: [child])),
    ),
  ),
);

TimeRow _row({VoidCallback? onTap}) => TimeRow(
  eventName: 'Maghrib',
  timeText: '17:52',
  label: const ConfidenceLabel.estimated(rangeMinutes: 3),
  locale: StatusLocale.en,
  onTap: onTap,
);

void main() {
  group('TimeRow and ConfidenceChip (§7.9)', () {
    testWidgets('REQ-UX-020 a row reads event, time and confidence as one '
        'tappable node of at least 44 pt', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(_host(_row(onTap: () => taps++)));
      expect(
        tester.getSemantics(find.byType(TimeRow)),
        matchesSemantics(
          label: 'Maghrib, 17:52, Estimated · ±3 min',
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSize(find.byType(TimeRow)).height,
        greaterThanOrEqualTo(DmScales.minTarget),
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await tester.tap(find.byType(TimeRow));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('REQ-UX-020 200 % text wraps without overflow', (tester) async {
      await tester.pumpWidget(_host(_row(), textScale: 2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        _host(
          SkyHeader(
            sky: SkyTheme.forPhase(SkyPhase.day),
            title: 'Next: Maghrib',
            subtitle: 'in 2 h 10 min',
          ),
          textScale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('REQ-UX-030 the event name sits at the start and the time at '
        'the end in both directions', (tester) async {
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(_host(_row(), direction: direction));
        final name = tester.getCenter(find.text('Maghrib')).dx;
        final time = tester.getCenter(find.text('17:52')).dx;
        expect(
          direction == TextDirection.ltr ? name < time : name > time,
          isTrue,
          reason: direction.name,
        );
      }
    });

    testWidgets('REQ-UX-040 the chip shows StatusCopy and a per-variant icon', (
      tester,
    ) async {
      const labels = [
        ConfidenceLabel.calculated(),
        ConfidenceLabel.authorityAligned(benchmarkReportId: 'b'),
        ConfidenceLabel.verified(sourceRef: 's', freshUntilUtcMs: 0),
        ConfidenceLabel.estimated(rangeMinutes: 2),
        ConfidenceLabel.observed(count: 4, lastSeenUtcMs: 0),
        ConfidenceLabel.unknown(reasonCode: 'r'),
      ];
      expect(labels.map(ConfidenceChip.iconOf).toSet(), hasLength(6));
      for (final label in labels) {
        await tester.pumpWidget(
          _host(ConfidenceChip(label: label, locale: StatusLocale.en)),
        );
        expect(find.text(StatusCopy.chip(label, StatusLocale.en)), findsOne);
        expect(find.byIcon(ConfidenceChip.iconOf(label)), findsOne);
      }
    });
  });

  group('SkyHeader (§7.9)', () {
    Duration duration(WidgetTester tester) => tester
        .widget<AnimatedContainer>(find.byType(AnimatedContainer))
        .duration;

    testWidgets('REQ-UX-020 reduced motion stops the sky animation', (
      tester,
    ) async {
      final sky = SkyTheme.forPhase(SkyPhase.night);
      Widget header({bool reduced = false}) => SkyHeader(
        sky: sky,
        title: 't',
        subtitle: 's',
        reducedMotion: reduced,
      );
      await tester.pumpWidget(_host(header()));
      expect(duration(tester), DmScales.motionStandard);
      await tester.pumpWidget(_host(header(), disableAnimations: true));
      expect(duration(tester), Duration.zero);
      await tester.pumpWidget(_host(header(reduced: true)));
      expect(duration(tester), Duration.zero);
    });

    testWidgets('REQ-UX-020 the title is a semantics header', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          SkyHeader(
            sky: SkyTheme.forPhase(SkyPhase.day),
            title: 'Next: Asr',
            subtitle: '15:20',
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Next: Asr')),
        matchesSemantics(label: 'Next: Asr', isHeader: true),
      );
      handle.dispose();
    });
  });
}
