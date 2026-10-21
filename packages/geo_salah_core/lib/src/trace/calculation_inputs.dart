import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/model/hijri_confidence.dart';
import 'package:geo_salah_core/src/model/hijri_date.dart';
import 'package:geo_salah_core/src/model/hijri_state.dart';
import 'package:geo_salah_core/src/model/observer.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';
import 'package:geo_salah_core/src/model/reference_mode.dart';
import 'package:geo_salah_core/src/model/reference_point.dart';
import 'package:geo_salah_core/src/trace/canonical_json.dart';
import 'package:meta/meta.dart';

/// The inputs a Calculation ID covers (§6.4 ¶11): coordinates rounded to 6
/// decimals, zone, day, profile identity and the Hijri state.
///
/// The coordinates are where the engine calculates: the observer's, or,
/// under `authorityReferencePoint` with the one reference point the
/// resolver left for the observer's area, that point's (ADR-006, §15 D53).
/// The engine calculates at the **rounded** coordinates, so equal
/// [inputsHash]es give equal raw instants (REQ-DOM-004, §15 D38). [toJson]
/// is exactly the `inputs` object of `calculation_trace.v1`. Immutable and
/// deterministic.
@immutable
final class CalculationInputs {
  /// The inputs of calculating [day] for [observer] with [profile] and
  /// [hijri].
  factory of({
    required Observer observer,
    required PrayerProfile profile,
    required CivilDate day,
    required HijriState hijri,
  }) {
    final (latitudeDeg, longitudeDeg) = switch ((
      profile.referenceMode,
      profile.referencePoints,
    )) {
      (ReferenceMode.authorityReferencePoint, [final ReferencePoint point]) => (
        point.lat,
        point.lon,
      ),
      (
        ReferenceMode.authorityReferencePoint || ReferenceMode.exactCoordinate,
        _,
      ) =>
        (observer.latitudeDeg, observer.longitudeDeg),
    };
    return CalculationInputs._(
      latitudeDeg: round6(latitudeDeg),
      longitudeDeg: round6(longitudeDeg),
      zoneId: observer.zoneId,
      day: day,
      profileId: profile.profileId,
      profileVersion: profile.version,
      hijri: hijri,
    );
  }

  const new _({
    required this.latitudeDeg,
    required this.longitudeDeg,
    required this.zoneId,
    required this.day,
    required this.profileId,
    required this.profileVersion,
    required this.hijri,
  });

  /// [degrees] rounded half away from zero to 6 decimals (≈ 0.1 m).
  static double round6(double degrees) => (degrees * 1e6).round() / 1e6;

  /// Latitude rounded to 6 decimals.
  final double latitudeDeg;

  /// Longitude rounded to 6 decimals.
  final double longitudeDeg;

  /// IANA zone of the observer.
  final String zoneId;

  /// The prayer day.
  final CivilDate day;

  /// Prayer profile id.
  final String profileId;

  /// Prayer profile version.
  final String profileVersion;

  /// Hijri state of the day.
  final HijriState hijri;

  /// The `calculation_trace.v1` `inputs` object.
  Map<String, Object?> toJson() => {
    'lat': latitudeDeg,
    'lon': longitudeDeg,
    'zoneId': zoneId,
    'day': day.toJson(),
    'profileId': profileId,
    'profileVersion': profileVersion,
    'hijri': {
      'dateAtDawn': _date(hijri.dateAtDawn),
      'dateAtNight': _date(hijri.dateAtNight),
      'confidence': switch (hijri.confidence) {
        HijriConfidence.confirmed => 'CONFIRMED',
        HijriConfidence.expected => 'EXPECTED',
        HijriConfidence.userOverride => 'USER_OVERRIDE',
      },
    },
  };

  /// `sha256(canonicalJson(inputs))` as lowercase hex (§6.4 ¶11, RFC 8785).
  String get inputsHash =>
      sha256.convert(utf8.encode(CanonicalJson.encode(toJson()))).toString();

  static Map<String, Object?> _date(HijriDate date) => {
    'year': date.year,
    'month': date.month,
    'day': date.day,
  };

  @override
  bool operator ==(Object other) =>
      other is CalculationInputs &&
      other.latitudeDeg == latitudeDeg &&
      other.longitudeDeg == longitudeDeg &&
      other.zoneId == zoneId &&
      other.day == day &&
      other.profileId == profileId &&
      other.profileVersion == profileVersion &&
      other.hijri == hijri;

  @override
  int get hashCode => Object.hash(
    latitudeDeg,
    longitudeDeg,
    zoneId,
    day,
    profileId,
    profileVersion,
    hijri,
  );
}
