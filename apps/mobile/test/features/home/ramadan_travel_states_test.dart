import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:daily_muslim/features/home/domain/fasting_day.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/fasting_card.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:daily_muslim/features/travel/domain/travel_check.dart';
import 'package:daily_muslim/features/travel/presentation/travel_banner.dart';
import 'package:daily_muslim/features/travel/presentation/travel_providers.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/app_harness.dart';
import '../../support/fake_location_access.dart';
import '../../support/state_harness.dart';
import '../contexts/support/fake_device_locator.dart';

TimeRowView _row(PrayerEvent event, String time) => TimeRowView(
  event: event,
  localTime: time,
  dayOffset: 0,
  confidence: const ConfidenceLabel.calculated(),
  displayedUtcMs: harnessNowUtcMs,
);

const _suggestion = TravelSuggestion(
  contextId: 3,
  fromLabel: 'Cairo',
  fromZoneId: 'Africa/Cairo',
  toZoneId: 'Europe/Oslo',
  toCountry: 'NO',
);

Widget _card(FastingDay day) => localizedApp(
  const Scaffold(body: FastingCard()),
  overrides: [
    fastingDayProvider.overrideWithValue(day),
    hijriOverrideSettingProvider.overrideWith((ref) => Stream.value(0)),
  ],
);

void main() {
  group('REQ-RAM-001 Ramadan card states', () {
    testWidgets('a window shows Fajr to Maghrib, Imsak and Expected', (
      tester,
    ) async {
      await tester.pumpWidget(
        _card(
          FastingWindow(
            ramadan: const RamadanDate(
              day: 12,
              confidence: HijriConfidence.expected,
            ),
            begins: _row(PrayerEvent.fajr, '04:48'),
            ends: _row(PrayerEvent.maghrib, '17:51'),
            imsak: _row(PrayerEvent.imsak, '04:38'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ramadan 12'), findsOneWidget);
      expect(find.text('Fast from 4:48 AM to 5:51 PM'), findsOneWidget);
      expect(find.text('Imsak 4:38 AM'), findsOneWidget);
      expect(find.text('Expected — not yet announced'), findsOneWidget);
      expect(find.text('Hijri day'), findsOneWidget);
    });

    testWidgets('a polar Ramadan day says Unknown; outside Ramadan nothing '
        'shows', (tester) async {
      await tester.pumpWidget(
        _card(
          const FastingUnknown(
            RamadanDate(day: 3, confidence: HijriConfidence.confirmed),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('has no time here today'), findsOneWidget);
      expect(find.textContaining('Expected'), findsNothing);

      await tester.pumpWidget(_card(const NotFasting()));
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNothing);
    });
  });

  group('REQ-TRV-001 Travel banner', () {
    testWidgets('a suggestion asks to switch; Not now hides it for the '
        'session', (tester) async {
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(body: TravelBanner()),
          overrides: [
            travelCheckProvider.overrideWith(
              (ref) async => const TravelSuggested(_suggestion),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('You seem to be in Oslo. Switch schedule?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.textContaining('You seem to be in'), findsNothing);
    });

    testWidgets('an Arabic reader gets the zone city in Arabic (§15 D101)', (
      tester,
    ) async {
      final db = PlacesDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final oslo = GazetteerHit(
        id: 3143244,
        name: 'Oslo',
        matchedName: 'Oslo',
        exact: false,
        country: 'NO',
        admin1: '12',
        point: GeoPointE6(59913330, 10738890),
        population: 580000,
        zoneId: 'Europe/Oslo',
        arabicName: 'أوسلو',
      );
      final useCases = fakeContextUseCases(
        db: db,
        places: const _NoSearch(),
        access: FakeLocationAccess(),
        locator: FakeDeviceLocator(),
        around: FakePlacesAround(zone: 'Europe/Oslo', inZone: [oslo]),
      );
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(body: TravelBanner()),
          locale: const Locale('ar'),
          overrides: [
            travelCheckProvider.overrideWith(
              (ref) async => const TravelSuggested(_suggestion),
            ),
            contextUseCasesProvider.overrideWith(
              (ref) async => Ok(useCases),
            ),
          ],
        ),
      );
      await pumpUntil(tester, find.textContaining('أوسلو'));
      expect(find.text('شكلك في أوسلو. نغيّر المواعيد؟'), findsOneWidget);
    });

    testWidgets('no suggestion shows nothing', (tester) async {
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(body: TravelBanner()),
          overrides: [
            travelCheckProvider.overrideWith(
              (ref) async => const TravelNoChange(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MaterialBanner), findsNothing);
    });
  });
}

final class _NoSearch implements FindGazetteerPlaces {
  const new();

  @override
  Future<Result<List<GazetteerHit>, GazetteerFailure>> findByPrefix(
    SearchKey prefix, {
    required int limit,
  }) async => const Ok([]);
}
