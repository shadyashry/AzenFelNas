import 'package:daily_muslim/features/passport/domain/calculation_link.dart';
import 'package:daily_muslim/features/passport/presentation/passport_page.dart';
import 'package:daily_muslim/features/schedule/domain/runtime_data.dart';
import 'package:daily_muslim/features/schedule/domain/schedule.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/domain/route_policy.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/runtime_fixtures.dart';
import '../../support/state_harness.dart';
import 'passport_support.dart';

/// S18 done-test (DESIGN.md §13): `<calcId>#event` resolves; a shared link
/// is recomputed on the receiving device, and a link it does not reproduce
/// shows the import-mismatch message.
void main() {
  final data = bundledRuntimeData();
  final schedule = cairoSchedule();
  final day = schedule.days[1];

  Future<void> open(
    WidgetTester tester,
    String link, {
    Schedule? local,
  }) async {
    final route = RoutePolicy.parse(Uri.parse(link));
    expect(route, isA<CalculationRoute>(), reason: link);
    await tester.pumpWidget(
      localizedApp(
        PassportPage(_as<CalculationRoute>(route)),
        overrides: [
          scheduleProvider.overrideWith(
            (ref) async => local == null
                ? const Err<LoadedSchedule, Failure>(
                    PackageFailure.storage('no context on this device'),
                  )
                : Ok<LoadedSchedule, Failure>((schedule: local, data: data)),
          ),
          runtimeDataProvider.overrideWith(
            (ref) async => Ok<RuntimeData, Failure>(data),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  String shared(String id) {
    final link = CalculationLink.of(
      calculationId: id,
      inputs: schedule.inputs[1],
      event: PrayerEvent.asr,
    );
    return link.toString();
  }

  testWidgets('REQ-DOM-004 <calcId>#asr resolves to the Passport entry with '
      'raw and shown time, rounding, flags and the sensitivity line', (
    tester,
  ) async {
    await open(
      tester,
      'dailymuslim://app/calc/${day.calculationId}#asr',
      local: schedule,
    );
    expect(find.text(day.calculationId), findsOneWidget);
    expect(find.text('Asr'), findsOneWidget);
    expect(find.textContaining('Calculated instant'), findsWidgets);
    expect(find.textContaining('Shown as'), findsWidgets);
    expect(find.textContaining('Rounded'), findsWidgets);
    expect(find.textContaining('±1 km changes this by ≤'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text(day.provenance.inputsHash),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Africa/Cairo'), findsOneWidget);
    expect(find.text(EngineVersion.current), findsOneWidget);
  });

  testWidgets('REQ-DOM-004 a shared link recomputes on a device without that '
      'schedule and matches', (tester) async {
    await open(tester, shared(day.calculationId));
    expect(find.text(day.calculationId), findsOneWidget);
    expect(
      find.text('Recomputed on this device: the result matches the link.'),
      findsOneWidget,
    );
  });

  testWidgets('REQ-DOM-004 a link this device does not reproduce shows the '
      'import mismatch message', (tester) async {
    await open(tester, shared('GS-AAAAAAAAAAAAAAAA'));
    expect(find.text('Computed differently on this device'), findsOneWidget);
    expect(
      find.text(
        'This time was computed with a different engine, profile or '
        'time-zone data version.',
      ),
      findsOneWidget,
    );
    expect(find.text('In the link: GS-AAAAAAAAAAAAAAAA'), findsOneWidget);
    expect(find.text('On this device: ${day.calculationId}'), findsOneWidget);
  });

  testWidgets('an ID with neither a local day nor inputs is not found', (
    tester,
  ) async {
    await open(tester, '/calc/GS-AAAAAAAAAAAAAAAA', local: schedule);
    expect(find.text('This calculation is not on this device'), findsOneWidget);
  });
}

/// [value] as [T]; fails the test otherwise.
T _as<T>(Object? value) =>
    value is T ? value : throw StateError('not $T: $value');
