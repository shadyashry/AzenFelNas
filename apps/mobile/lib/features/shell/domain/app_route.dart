import 'package:meta/meta.dart';

/// Every screen the router can show: a closed set, so a location that is not
/// one of these never reaches a page (REQ-SEC-010).
sealed class AppRoute {
  const new();

  /// The in-app location, e.g. `/calc/GS-…`.
  String get location;

  /// Whether a `dailymuslim://` link from outside the app may open it
  /// (§7.1 allow-list: `/calc/<id>`, `/health`, `/qibla`).
  bool get linkable;
}

/// Home (S17).
final class HomeRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/';

  @override
  bool get linkable => false;
}

/// Settings (static, §18.4).
final class SettingsRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/settings';

  @override
  bool get linkable => false;
}

/// Data and licence attributions (§10.4).
final class AttributionsRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/settings/attributions';

  @override
  bool get linkable => false;
}

/// Athan Health (S20).
final class HealthRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/health';

  @override
  bool get linkable => true;
}

/// Qibla (S22).
final class QiblaRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/qibla';

  @override
  bool get linkable => true;
}

/// The Accuracy Passport of one Calculation ID (S18).
@immutable
final class CalculationRoute extends AppRoute {
  /// The route for [calculationId], which must match [idPattern].
  const new(this.calculationId);

  /// `calculation_trace.v1` `calculationId` (§6.4 ¶11).
  static final idPattern = RegExp(r'^GS-[A-Z2-7]{16}$');

  /// The Calculation ID.
  final String calculationId;

  @override
  String get location => '/calc/$calculationId';

  @override
  bool get linkable => true;

  @override
  bool operator ==(Object other) =>
      other is CalculationRoute && other.calculationId == calculationId;

  @override
  int get hashCode => Object.hash(CalculationRoute, calculationId);
}
