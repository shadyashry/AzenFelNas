import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// Every screen the router can show: a closed set, so a location that is not
/// one of these never reaches a page (REQ-SEC-010).
sealed class AppRoute {
  const new();

  /// The in-app location, e.g. `/calc/GS-…`.
  String get location;

  /// Whether a `azenfelnas://` link from outside the app may open it
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

/// The redacted diagnostic report (REQ-PRIV-005, §15 D84).
final class DiagnosticsRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/settings/diagnostics';

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

/// The seven-day timeline (S17).
final class TimelineRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/timeline';

  @override
  bool get linkable => false;
}

/// Manual place search and coordinate entry (S17).
final class PlaceRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/place';

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

/// The Quran reader, or its download when the package is not installed
/// (§15 D107).
final class QuranRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/quran';

  @override
  bool get linkable => false;
}

/// Search in the Quran text (offline, §15 D107).
final class QuranSearchRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/quran/search';

  @override
  bool get linkable => false;
}

/// Bookmarks and highlights (§15 D107).
final class QuranNotesRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/quran/notes';

  @override
  bool get linkable => false;
}

/// The Quran download: status, size, check, remove (§15 D107).
final class QuranStorageRoute extends AppRoute {
  /// The route.
  const new();

  @override
  String get location => '/quran/storage';

  @override
  bool get linkable => false;
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
/// The Accuracy Passport of a Calculation ID (§6.4 ¶11, P1), optionally
/// focused on one event (`<calcId>#<event>`) and carrying a shared link's
/// inputs for local recomputation.
@immutable
final class CalculationRoute extends AppRoute {
  /// The Passport of [calculationId], focused on [event] when given, with a
  /// shared link's base64url [inputs] when given.
  const new(this.calculationId, {this.event, this.inputs});

  /// `GS-` + 16 base32 characters.
  static final idPattern = RegExp(r'^GS-[A-Z2-7]{16}$');

  /// A shared link's `i` parameter: unpadded base64url, at most 2048
  /// characters (§15 D78).
  static final inputsPattern = RegExp(r'^[A-Za-z0-9_-]{1,2048}$');

  /// The Calculation ID.
  final String calculationId;

  /// The focused event, or `null` for the whole day.
  final PrayerEvent? event;

  /// A shared link's encoded inputs, or `null` for a local lookup.
  final String? inputs;

  /// The event named by [code] (`PrayerEvent.name`), or `null`.
  static PrayerEvent? eventOf(String code) {
    for (final event in PrayerEvent.values) {
      if (event.name == code) return event;
    }
    return null;
  }

  @override
  String get location {
    final path = event == null
        ? '/calc/$calculationId'
        : '/calc/$calculationId/${event?.name}';
    return inputs == null ? path : '$path?i=$inputs';
  }

  @override
  bool get linkable => true;

  @override
  bool operator ==(Object other) =>
      other is CalculationRoute &&
      other.calculationId == calculationId &&
      other.event == event &&
      other.inputs == inputs;

  @override
  int get hashCode =>
      Object.hash(CalculationRoute, calculationId, event, inputs);
}
