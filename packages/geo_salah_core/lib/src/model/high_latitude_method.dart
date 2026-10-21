import 'package:freezed_annotation/freezed_annotation.dart';

part 'high_latitude_method.freezed.dart';

/// A high-latitude fallback method of a profile's ordered chain (§6.2,
/// §6.4 ¶7). Parameters are profile data (§0.2 rule 1); the chain is
/// evaluated from S08. `authorityTable` is `[DEFERRED V2]`.
@freezed
sealed class HighLatitudeMethod with _$HighLatitudeMethod {
  /// α/60 of the night.
  const factory anglePortion() = AnglePortion;

  /// Half of the night.
  const factory middleOfNight() = MiddleOfNight;

  /// A seventh of the night.
  const factory seventhOfNight() = SeventhOfNight;

  /// The event as calculated at latitude [latDeg].
  const factory nearestLatitude({required double latDeg}) = NearestLatitude;

  /// The event of the nearest day within [maxDays] that has one.
  const factory nearestValidDay({required int maxDays}) = NearestValidDay;
}
