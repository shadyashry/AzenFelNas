import 'package:daily_muslim/app/app_router.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/domain/route_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const id = 'GS-ABCDEFGHIJKLMNOP';

  AppRoute? parse(String s) => RoutePolicy.parse(Uri.parse(s));

  group('deep links are allow-listed (REQ-SEC-010)', () {
    test('the three linkable routes open, in both link forms', () {
      for (final prefix in ['dailymuslim://app', 'dailymuslim://']) {
        expect(parse('$prefix/calc/$id'), const CalculationRoute(id));
        expect(parse('$prefix/health'), isA<HealthRoute>());
        expect(parse('$prefix/qibla'), isA<QiblaRoute>());
      }
    });

    test('a link cannot name an in-app-only route', () {
      expect(parse('dailymuslim://app/settings'), isNull);
      expect(parse('dailymuslim://app/settings/attributions'), isNull);
      expect(parse('dailymuslim://app/'), isNull);
    });

    test('other schemes and hosts are refused', () {
      expect(parse('https://dailymuslim.app/calc/$id'), isNull);
      expect(parse('http://app/health'), isNull);
      expect(parse('dailymuslim://evil/health'), isNull);
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
        expect(parse('dailymuslim://app/calc/$bad'), isNull, reason: bad);
        expect(parse('/calc/$bad'), isNull, reason: bad);
      }
    });

    test(
      'unknown paths, extra segments, queries and fragments are refused',
      () {
        for (final bad in [
          'dailymuslim://app/settings/locale',
          'dailymuslim://app/health/x',
          'dailymuslim://app/calc',
          'dailymuslim://app/health?set=1',
          'dailymuslim://app/qibla#x',
          '/athan/test',
          '/health?x=1',
        ]) {
          expect(parse(bad), isNull, reason: bad);
        }
      },
    );
  });

  test('in-app locations name every route', () {
    expect(parse('/'), isA<HomeRoute>());
    expect(parse('/settings'), isA<SettingsRoute>());
    expect(parse('/settings/attributions'), isA<AttributionsRoute>());
    expect(parse('/calc/$id'), const CalculationRoute(id));
  });

  test('every route parses back from its own location', () {
    for (final route in const <AppRoute>[
      HomeRoute(),
      SettingsRoute(),
      AttributionsRoute(),
      HealthRoute(),
      QiblaRoute(),
      CalculationRoute(id),
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
        AppRouter.redirect(Uri.parse('dailymuslim://app/calc/$id')),
        '/calc/$id',
      );
    });

    test('anything refused lands on Home', () {
      expect(AppRouter.redirect(Uri.parse('/calc/nope')), '/');
      expect(AppRouter.redirect(Uri.parse('https://x.example/health')), '/');
    });
  });
}
