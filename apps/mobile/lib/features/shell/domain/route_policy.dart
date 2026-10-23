import 'package:daily_muslim/features/shell/domain/app_route.dart';

/// Validates every location before navigation (REQ-SEC-010, §15 D76).
///
/// * A `dailymuslim://` link names a [AppRoute.linkable] route, written
///   `dailymuslim://app/<path>` (the host `app` keeps the path intact
///   whether or not the platform drops the host) or `dailymuslim:///<path>`.
/// * A location without a scheme (in-app navigation, or a link whose scheme
///   the platform stripped) names any route; none of them changes state.
/// * Anything else — another scheme or host, an unknown path, a malformed
///   Calculation ID, a query or fragment — is rejected (`null`).
abstract final class RoutePolicy {
  /// The custom scheme (§7.1; HTTPS links are deferred to V1).
  static const scheme = 'dailymuslim';

  /// The host of a canonical link.
  static const host = 'app';

  /// The route [uri] names, or `null` when it must not be opened.
  static AppRoute? parse(Uri uri) {
    if (uri.hasQuery || uri.hasFragment) return null;
    final external = uri.scheme.isNotEmpty;
    if (external) {
      if (uri.scheme != scheme) return null;
      if (uri.host.isNotEmpty && uri.host != host) return null;
    } else if (uri.hasAuthority) {
      return null;
    }
    final route = _route(uri.pathSegments.where((s) => s.isNotEmpty).toList());
    if (route == null || (external && !route.linkable)) return null;
    return route;
  }

  static AppRoute? _route(List<String> segments) => switch (segments) {
    [] => const HomeRoute(),
    ['settings'] => const SettingsRoute(),
    ['settings', 'attributions'] => const AttributionsRoute(),
    ['timeline'] => const TimelineRoute(),
    ['place'] => const PlaceRoute(),
    ['health'] => const HealthRoute(),
    ['qibla'] => const QiblaRoute(),
    ['calc', final id] when CalculationRoute.idPattern.hasMatch(id) =>
      CalculationRoute(id),
    _ => null,
  };
}
