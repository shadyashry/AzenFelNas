import 'package:daily_muslim/features/shell/domain/app_route.dart';

/// Validates every location before navigation (REQ-SEC-010, §15 D76).
///
/// * A `azenfelnas://` link names a [AppRoute.linkable] route, written
///   `azenfelnas://app/<path>` (the host `app` keeps the path intact
///   whether or not the platform drops the host) or `azenfelnas:///<path>`.
/// * A location without a scheme (in-app navigation, or a link whose scheme
///   the platform stripped) names any route; none of them changes state.
/// * Only a Calculation route takes extras (§6.4 ¶11, §15 D78): a fragment
///   naming one event (`<calcId>#fajr`, or the in-app `/calc/<id>/fajr`) and
///   a query of exactly one `i` parameter (unpadded base64url, ≤ 2048
///   characters) carrying a shared link's inputs.
/// * Anything else — another scheme or host, an unknown path, a malformed
///   Calculation ID, any other query or fragment — is rejected (`null`).
abstract final class RoutePolicy {
  /// The custom scheme (§7.1; HTTPS links are deferred to V1).
  static const scheme = 'azenfelnas';

  /// The host of a canonical link.
  static const host = 'app';

  /// The route [uri] names, or `null` when it must not be opened.
  static AppRoute? parse(Uri uri) {
    final external = uri.scheme.isNotEmpty;
    if (external) {
      if (uri.scheme != scheme) return null;
      if (uri.host.isNotEmpty && uri.host != host) return null;
    } else if (uri.hasAuthority) {
      return null;
    }
    final route = _route(uri.pathSegments.where((s) => s.isNotEmpty).toList());
    if (route == null || (external && !route.linkable)) return null;
    if (!uri.hasQuery && !uri.hasFragment) return route;
    return switch (route) {
      CalculationRoute() => _withExtras(route, uri),
      _ => null,
    };
  }

  static CalculationRoute? _withExtras(CalculationRoute route, Uri uri) {
    var event = route.event;
    if (uri.hasFragment) {
      if (event != null) return null;
      event = CalculationRoute.eventOf(uri.fragment);
      if (event == null) return null;
    }
    String? inputs;
    if (uri.hasQuery) {
      final all = uri.queryParametersAll;
      final values = all['i'];
      if (all.length != 1 || values == null || values.length != 1) {
        return null;
      }
      inputs = values.single;
      if (!CalculationRoute.inputsPattern.hasMatch(inputs)) return null;
    }
    return CalculationRoute(route.calculationId, event: event, inputs: inputs);
  }

  static AppRoute? _route(List<String> segments) => switch (segments) {
    [] => const HomeRoute(),
    ['settings'] => const SettingsRoute(),
    ['settings', 'attributions'] => const AttributionsRoute(),
    ['settings', 'diagnostics'] => const DiagnosticsRoute(),
    ['timeline'] => const TimelineRoute(),
    ['place'] => const PlaceRoute(),
    ['health'] => const HealthRoute(),
    ['qibla'] => const QiblaRoute(),
    ['quran'] => const QuranRoute(),
    ['quran', 'search'] => const QuranSearchRoute(),
    ['quran', 'notes'] => const QuranNotesRoute(),
    ['quran', 'storage'] => const QuranStorageRoute(),
    ['calc', final id] when CalculationRoute.idPattern.hasMatch(id) =>
      CalculationRoute(id),
    ['calc', final id, final code]
        when CalculationRoute.idPattern.hasMatch(id) &&
            CalculationRoute.eventOf(code) != null =>
      CalculationRoute(id, event: CalculationRoute.eventOf(code)),
    _ => null,
  };
}
