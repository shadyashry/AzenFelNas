import 'package:daily_muslim/app/app_router.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/domain/route_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

void main() {
  const id = 'GS-ABCDEFGHIJKLMNOP';

  AppRoute? parse(String s) => RoutePolicy.parse(Uri.parse(s));

  group('deep links are allow-listed (REQ-SEC-010)', () {
    test('the three linkable routes open, in both link forms', () {
      for (final prefix in ['azenfelnas://app', 'azenfelnas://']) {
        expect(parse('$prefix/calc/$id'), const CalculationRoute(id));
        expect(parse('$prefix/health'), isA<HealthRoute>());
        expect(parse('$prefix/qibla'), isA<QiblaRoute>());
      }
    });

    test('a link cannot name an in-app-only route', () {
      expect(parse('azenfelnas://app/settings'), isNull);
      expect(parse('azenfelnas://app/settings/attributions'), isNull);
      expect(parse('azenfelnas://app/'), isNull);
    });

    test('other schemes and hosts are refused', () {
      expect(parse('https://azenfelnas.app/calc/$id'), isNull);
      expect(parse('http://app/health'), isNull);
      expect(parse('azenfelnas://evil/health'), isNull);
      expect(parse('//app/health'), isNull);
    });

    test('a malformed Calculation ID is refused', () {
      for (final bad in [
        'GS-abcdefghijklmnop',
        'GS-ABCDEFGHIJKLMNO',
        'GS-ABCDEFGHIJKLMNOPQ',
        'GS-ABCDEFGHIJKLMN01',
        'XX-ABCDEFGHIJKLMNOP',
      ]) {
        expect(parse('azenfelnas://app/calc/$bad'), isNull, reason: bad);
        expect(parse('/calc/$bad'), isNull, reason: bad);
      }
    });

    test(
      'unknown paths, extra segments, queries and fragments are refused',
      () {
        for (final bad in [
          'azenfelnas://app/settings/locale',
          'azenfelnas://app/health/x',
          'azenfelnas://app/calc',
          'azenfelnas://app/health?set=1',
          'azenfelnas://app/qibla#x',
          '/athan/test',
          '/health?x=1',
        ]) {
          expect(parse(bad), isNull, reason: bad);
        }
      },
    );
  });

  group('Calculation links carry an event and inputs (§6.4 ¶11)', () {
    test('REQ-SEC-010 <calcId>#<event> and ?i= open the Passport', () {
      expect(
        parse('azenfelnas://app/calc/$id#asr'),
        const CalculationRoute(id, event: PrayerEvent.asr),
      );
      expect(
        parse('azenfelnas://app/calc/$id?i=eyJhIjoxfQ#fajr'),
        const CalculationRoute(
          id,
          event: PrayerEvent.fajr,
          inputs: 'eyJhIjoxfQ',
        ),
      );
      expect(
        parse('/calc/$id/isha?i=abc-_9'),
        const CalculationRoute(id, event: PrayerEvent.isha, inputs: 'abc-_9'),
      );
    });

    test('REQ-SEC-010 any other query or fragment on a Calculation link is '
        'refused', () {
      for (final bad in [
        'azenfelnas://app/calc/$id#noon',
        'azenfelnas://app/calc/$id?x=1',
        'azenfelnas://app/calc/$id?i=a&i=b',
        'azenfelnas://app/calc/$id?i=a&x=b',
        'azenfelnas://app/calc/$id?i=a+b',
        'azenfelnas://app/calc/$id?i=${'A' * 2049}',
        'azenfelnas://app/calc/$id/asr#fajr',
        'azenfelnas://app/calc/$id/noon',
      ]) {
        expect(parse(bad), isNull, reason: bad);
      }
    });

    test('a link with a fragment is rewritten to the in-app event path', () {
      expect(
        AppRouter.redirect(Uri.parse('azenfelnas://app/calc/$id#dhuhr')),
        '/calc/$id/dhuhr',
      );
    });
  });

  test('in-app locations name every route', () {
    expect(parse('/'), isA<HomeRoute>());
    expect(parse('/settings'), isA<SettingsRoute>());
    expect(parse('/settings/attributions'), isA<AttributionsRoute>());
    expect(parse('/calc/$id'), const CalculationRoute(id));
  });

  test('REQ-SEC-010 the timeline and manual place are in-app only', () {
    expect(parse('/timeline'), isA<TimelineRoute>());
    expect(parse('/place'), isA<PlaceRoute>());
    expect(parse('azenfelnas://app/timeline'), isNull);
    expect(parse('azenfelnas://app/place'), isNull);
  });

  test('REQ-SEC-010 REQ-PRIV-005 the diagnostic report is in-app only', () {
    expect(parse('/settings/diagnostics'), isA<DiagnosticsRoute>());
    expect(parse('azenfelnas://app/settings/diagnostics'), isNull);
  });

  test('every route parses back from its own location', () {
    for (final route in const <AppRoute>[
      HomeRoute(),
      SettingsRoute(),
      AttributionsRoute(),
      DiagnosticsRoute(),
      TimelineRoute(),
      PlaceRoute(),
      HealthRoute(),
      QiblaRoute(),
      CalculationRoute(id),
      CalculationRoute(id, event: PrayerEvent.maghrib),
      CalculationRoute(id, inputs: 'abc'),
      CalculationRoute(id, event: PrayerEvent.imsak, inputs: 'abc'),
    ]) {
      expect(parse(route.location), route, reason: route.location);
    }
  });

  group('AppRouter.redirect (REQ-SEC-010)', () {
    test('a valid in-app location proceeds', () {
      expect(AppRouter.redirect(Uri.parse('/settings')), isNull);
    });

    test('a valid link is rewritten to its in-app location', () {
      expect(
        AppRouter.redirect(Uri.parse('azenfelnas://app/calc/$id')),
        '/calc/$id',
      );
    });

    test('anything refused lands on Home', () {
      expect(AppRouter.redirect(Uri.parse('/calc/nope')), '/');
      expect(AppRouter.redirect(Uri.parse('https://x.example/health')), '/');
    });
  });
}
