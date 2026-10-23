import 'package:daily_muslim/features/contexts/presentation/manual_place_page.dart';
import 'package:daily_muslim/features/home/presentation/timeline_page.dart';
import 'package:daily_muslim/features/onboarding/presentation/home_gate.dart';
import 'package:daily_muslim/features/passport/presentation/passport_page.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_page.dart';
import 'package:daily_muslim/features/settings/presentation/attributions_page.dart';
import 'package:daily_muslim/features/settings/presentation/settings_page.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/domain/route_policy.dart';
import 'package:daily_muslim/features/shell/presentation/placeholder_page.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// The router (§7.1): every location passes [RoutePolicy] before a page is
/// built; a rejected one lands on Home (REQ-SEC-010).
abstract final class AppRouter {
  /// A new router starting at [initialLocation].
  static GoRouter create({String initialLocation = '/'}) => GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) => redirect(state.uri),
    onException: (context, state, router) =>
        router.go(const HomeRoute().location),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeGate(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'attributions',
                builder: (context, state) => const AttributionsPage(),
              ),
            ],
          ),
          GoRoute(
            path: 'timeline',
            builder: (context, state) => const TimelinePage(),
          ),
          GoRoute(
            path: 'place',
            builder: (context, state) => const ManualPlacePage(),
          ),
          GoRoute(
            path: 'health',
            builder: (context, state) => PlaceholderPage(
              title: AppLocalizations.of(context).healthTitle,
            ),
          ),
          GoRoute(
            path: 'qibla',
            builder: (context, state) => const QiblaPage(),
          ),
          GoRoute(
            path: 'calc/:id',
            builder: (context, state) => _passport(state.uri),
            routes: [
              GoRoute(
                path: ':event',
                builder: (context, state) => _passport(state.uri),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  /// The location to go to instead of [uri], or `null` to proceed.
  /// The Passport of [uri], which the redirect already validated.
  static Widget _passport(Uri uri) => switch (RoutePolicy.parse(uri)) {
    final CalculationRoute route => PassportPage(route),
    _ => const HomeGate(),
  };

  static String? redirect(Uri uri) {
    final route = RoutePolicy.parse(uri);
    if (route == null) return const HomeRoute().location;
    return route.location == uri.toString() ? null : route.location;
  }
}
