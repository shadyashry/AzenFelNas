import 'package:daily_muslim/features/settings/presentation/attributions_page.dart';
import 'package:daily_muslim/features/settings/presentation/settings_page.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/domain/route_policy.dart';
import 'package:daily_muslim/features/shell/presentation/placeholder_page.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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
        builder: (context, state) => const _Home(),
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
            path: 'health',
            builder: (context, state) => PlaceholderPage(
              title: AppLocalizations.of(context).healthTitle,
            ),
          ),
          GoRoute(
            path: 'qibla',
            builder: (context, state) => PlaceholderPage(
              title: AppLocalizations.of(context).qiblaTitle,
            ),
          ),
          GoRoute(
            path: 'calc/:id',
            builder: (context, state) => PlaceholderPage(
              title: AppLocalizations.of(context).passportTitle,
            ),
          ),
        ],
      ),
    ],
  );

  /// The location to go to instead of [uri], or `null` to proceed.
  static String? redirect(Uri uri) {
    final route = RoutePolicy.parse(uri);
    if (route == null) return const HomeRoute().location;
    return route.location == uri.toString() ? null : route.location;
  }
}

/// Home until S17 builds it.
final class _Home extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PlaceholderPage(
      title: l.homeTitle,
      actions: [
        IconButton(
          tooltip: l.settingsTitle,
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(const SettingsRoute().location),
        ),
      ],
    );
  }
}
