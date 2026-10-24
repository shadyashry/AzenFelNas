import 'package:meta/meta.dart';

/// What the Travel Mode check found (§7.2 `travel`, US-22, REQ-TRV-001).
sealed class TravelCheck {
  const new();
}

/// Nothing to ask: the active context follows the device, or the device is
/// still in the context's zone.
final class TravelNoChange extends TravelCheck {
  /// The state.
  const new();
}

/// The device seems to be in another zone than the pinned or manual context;
/// the user decides whether to switch (never automatic, REQ-PRIV-002).
final class TravelSuggested extends TravelCheck {
  /// The suggestion [suggestion].
  const new(this.suggestion);

  /// What to ask.
  final TravelSuggestion suggestion;
}

/// The check cannot tell: no context, no recent cached fix, no permission or
/// a mock location. Nothing is asked.
final class TravelUnknown extends TravelCheck {
  /// The state.
  const new();
}

/// "You seem to be in [toZoneId]. Switch schedule?" (US-22).
@immutable
final class TravelSuggestion {
  /// A suggestion to leave context [contextId] ([fromLabel] in [fromZoneId])
  /// for the device's zone [toZoneId] in [toCountry].
  const new({
    required this.contextId,
    required this.fromLabel,
    required this.fromZoneId,
    required this.toZoneId,
    required this.toCountry,
  });

  /// The active pinned or manual context.
  final int contextId;

  /// Its user-facing name.
  final String fromLabel;

  /// Its zone.
  final String fromZoneId;

  /// The zone the device's cached fix resolves to.
  final String toZoneId;

  /// The country it resolves to; null offshore or outside every country.
  final String? toCountry;

  /// The city part of [toZoneId] for the prompt (`Europe/Oslo` → `Oslo`):
  /// no gazetteer lookup and no coordinates in the copy (REQ-PRIV-001).
  String get toCity => toZoneId.split('/').last.replaceAll('_', ' ');

  @override
  bool operator ==(Object other) =>
      other is TravelSuggestion &&
      other.contextId == contextId &&
      other.fromLabel == fromLabel &&
      other.fromZoneId == fromZoneId &&
      other.toZoneId == toZoneId &&
      other.toCountry == toCountry;

  @override
  int get hashCode =>
      Object.hash(contextId, fromLabel, fromZoneId, toZoneId, toCountry);
}
