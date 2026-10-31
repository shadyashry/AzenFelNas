import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:meta/meta.dart';

/// The station list as last refreshed (§15 D122): kept on the phone so it
/// shows at once and can be browsed offline. Live audio still needs the
/// internet; the list is never offered as offline radio.
@immutable
final class RadioCatalog {
  /// [stations], featured first, refreshed at [refreshedUtcMs].
  const new({required this.stations, required this.refreshedUtcMs});

  /// The cache file's schema version; a file of another version is ignored
  /// and the list fetched again.
  static const int schemaVersion = 1;

  /// How long a refreshed list stays fresh before a background refresh.
  static const Duration maxAge = Duration(hours: 24);

  /// The stations: the featured ones in their set order, then the rest in
  /// the provider's order.
  final List<RadioStation> stations;

  /// When the list was last fetched successfully (UTC epoch ms).
  final int refreshedUtcMs;

  /// Whether the list is older than [maxAge] at [nowUtcMs], or dated in the
  /// future (a clock that moved back).
  bool isStale(int nowUtcMs, {Duration maxAge = RadioCatalog.maxAge}) =>
      nowUtcMs < refreshedUtcMs ||
      nowUtcMs - refreshedUtcMs >= maxAge.inMilliseconds;

  /// The station with [id], or `null`.
  RadioStation? byId(RadioStationId id) {
    for (final station in stations) {
      if (station.id == id) return station;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is RadioCatalog &&
      other.refreshedUtcMs == refreshedUtcMs &&
      _sameStations(other.stations, stations);

  @override
  int get hashCode => Object.hash(refreshedUtcMs, Object.hashAll(stations));

  static bool _sameStations(List<RadioStation> a, List<RadioStation> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
