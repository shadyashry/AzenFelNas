import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/timeline_page.dart';
import 'package:daily_muslim/features/home/presentation/timeline_state.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/state_harness.dart';

DayView _day(int day) => DayView(
  date: CivilDate(2026, 10, day),
  calculationId: 'GS-ABCDEFGHIJKLMNO$day',
  rows: [
    for (final event in [PrayerEvent.fajr, PrayerEvent.dhuhr])
      TimeRowView(
        event: event,
        localTime: '05:42',
        dayOffset: 0,
        confidence: const ConfidenceLabel.calculated(),
        displayedUtcMs: 0,
      ),
  ],
);

Future<void> _pump(WidgetTester tester, TimelineState state) async {
  await tester.pumpWidget(
    localizedApp(
      const TimelinePage(),
      overrides: [timelineStateProvider.overrideWithValue(state)],
    ),
  );
  await tester.pump();
}

void main() {
  group('Day timeline UiState (§18.4) — every variant renders', () {
    testWidgets('loading shows progress', (tester) async {
      await _pump(tester, const TimelineLoading());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('REQ-UX-001 ready lists every day with labelled rows', (
      tester,
    ) async {
      await _pump(tester, TimelineReady([_day(22), _day(23)]));
      expect(find.byType(TimeRow), findsNWidgets(4));
      expect(find.text('Calculated'), findsNWidgets(4));
      expect(find.textContaining('October 22'), findsOneWidget);
    });

    testWidgets('REQ-ERR-002 error names the failure code', (tester) async {
      await _pump(
        tester,
        const TimelineError(PackageFailure.storage('no tzdata')),
      );
      expect(find.byTooltip('Code PKG_STORAGE'), findsOneWidget);
    });
  });
}
