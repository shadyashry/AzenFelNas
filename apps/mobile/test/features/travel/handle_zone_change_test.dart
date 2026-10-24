import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:daily_muslim/features/travel/application/handle_zone_change.dart';
import 'package:daily_muslim/features/travel/domain/travel_check.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

import '../contexts/support/places_fixtures.dart';
import '../contexts/support/resolver_harness.dart';

void main() {
  late ResolverHarness h;
  late HandleZoneChange check;

  setUp(() {
    h = ResolverHarness();
    check = HandleZoneChange(h.store, h.locator, h.resolvePlace, h.clock);
  });

  Future<void> manualMakkah() => h.store.addChosen(
    ChosenKind.manual,
    makkahPlace,
    ContextSource.gazetteer,
    utcMs: 1,
  );

  group('REQ-TRV-001 Travel Mode on open', () {
    test('a cached fix in another zone suggests switching and changes no '
        'context (REQ-PRIV-002)', () async {
      await manualMakkah();
      final before = h.store.rows;
      h.locator.lastKnown = Ok(fixAt(londonPlace.point, ageMs: 3600000));

      final result = await check();

      expect(
        result,
        isA<TravelSuggested>().having(
          (s) => s.suggestion,
          'suggestion',
          TravelSuggestion(
            contextId: before.single.id,
            fromLabel: makkahPlace.label,
            fromZoneId: 'Asia/Riyadh',
            toZoneId: 'Europe/London',
            toCountry: 'GB',
          ),
        ),
      );
      if (result case TravelSuggested(:final suggestion)) {
        expect(suggestion.toCity, 'London');
      }
      expect(h.store.rows, before);
      expect(h.events.entries, isEmpty);
    });

    test('a cached fix in the same zone asks nothing', () async {
      await manualMakkah();
      h.locator.lastKnown = Ok(fixAt(makkahPlace.point));

      expect(await check(), isA<TravelNoChange>());
    });

    test(
      'a current context follows the device by itself and asks nothing',
      () async {
        await h.store.saveCurrent(cairoPlace, ContextSource.freshFix, utcMs: 1);
        h.locator.lastKnown = Ok(fixAt(londonPlace.point));

        expect(await check(), isA<TravelNoChange>());
      },
    );

    test('no cached fix, a stale one, a mock one or no context tells '
        'nothing', () async {
      expect(await check(), isA<TravelUnknown>());
      await manualMakkah();
      expect(await check(), isA<TravelUnknown>());
      h.locator.lastKnown = Ok(
        fixAt(londonPlace.point, ageMs: HandleZoneChange.maxFixAgeMs + 1),
      );
      expect(await check(), isA<TravelUnknown>());
      h.locator.lastKnown = Ok(fixAt(londonPlace.point, isMock: true));
      expect(await check(), isA<TravelUnknown>());
    });
  });
}
