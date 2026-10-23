import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// The shared form of a Calculation ID (§6.4 ¶11, US-09):
/// `dailymuslim://app/calc/<calcId>?i=<base64url(inputs JSON)>#<event>`.
///
/// The inputs are the `calculation_trace.v1` `inputs` object as RFC 8785
/// canonical JSON, base64url without padding (§15 D78). They hold only what
/// the ID hashes — rounded coordinates, zone, day, profile and Hijri state —
/// never a raw device fix or an identifier.
abstract final class CalculationLink {
  /// The link that shares [inputs]' day [calculationId], focused on [event].
  static Uri of({
    required String calculationId,
    required CalculationInputs inputs,
    PrayerEvent? event,
  }) => Uri(
    scheme: 'dailymuslim',
    host: 'app',
    path: '/calc/$calculationId',
    query: 'i=${encode(inputs)}',
    fragment: event?.name,
  );

  /// The `i` parameter of [inputs].
  static String encode(CalculationInputs inputs) => encodeJson(inputs.toJson());

  /// The `i` parameter of an `inputs` JSON object.
  static String encodeJson(Map<String, Object?> json) => base64Url
      .encode(utf8.encode(CanonicalJson.encode(json)))
      .replaceAll('=', '');

  /// The inputs in an `i` parameter, or `null` when it is not well formed.
  static LinkedInputs? decode(String encoded) {
    try {
      final padded = encoded.padRight((encoded.length + 3) ~/ 4 * 4, '=');
      final json = jsonDecode(utf8.decode(base64Url.decode(padded)));
      return json is Map<String, Object?> ? LinkedInputs.fromJson(json) : null;
    } on FormatException {
      return null;
    }
  }
}

/// The inputs a shared link carries, read strictly; nothing else from the
/// sender is used.
@immutable
final class LinkedInputs {
  /// Creates [LinkedInputs].
  const new({
    required this.latitudeDeg,
    required this.longitudeDeg,
    required this.zoneId,
    required this.day,
    required this.profileId,
    required this.profileVersion,
    required this.hijri,
  });

  /// Reads the `inputs` object; `null` when a field is missing, has the
  /// wrong type or is out of range, or when there are extra fields.
  static LinkedInputs? fromJson(Map<String, Object?> json) {
    if (json.length != 7) return null;
    final (lat, lon) = (json['lat'], json['lon']);
    final zone = json['zoneId'];
    final day = json['day'];
    final profileId = json['profileId'];
    final profileVersion = json['profileVersion'];
    final hijri = json['hijri'];
    if (lat is! num ||
        lon is! num ||
        zone is! String ||
        day is! String ||
        profileId is! String ||
        profileVersion is! String ||
        hijri is! Map<String, Object?>) {
      return null;
    }
    final civil = CivilDate.tryParse(day);
    final state = _hijri(hijri);
    if (civil == null ||
        state == null ||
        lat.abs() > 90 ||
        lon.abs() > 180 ||
        zone.isEmpty ||
        profileId.isEmpty ||
        profileVersion.isEmpty) {
      return null;
    }
    return LinkedInputs(
      latitudeDeg: lat.toDouble(),
      longitudeDeg: lon.toDouble(),
      zoneId: zone,
      day: civil,
      profileId: profileId,
      profileVersion: profileVersion,
      hijri: state,
    );
  }

  /// Latitude, degrees (already rounded to 6 decimals by the sender).
  final double latitudeDeg;

  /// Longitude, degrees.
  final double longitudeDeg;

  /// IANA zone.
  final String zoneId;

  /// The prayer day.
  final CivilDate day;

  /// Profile id.
  final String profileId;

  /// Profile version.
  final String profileVersion;

  /// Hijri state of the day.
  final HijriState hijri;

  static HijriState? _hijri(Map<String, Object?> json) {
    if (json.length != 3) return null;
    final dawn = _date(json['dateAtDawn']);
    final night = _date(json['dateAtNight']);
    final confidence = switch (json['confidence']) {
      'CONFIRMED' => HijriConfidence.confirmed,
      'EXPECTED' => HijriConfidence.expected,
      'USER_OVERRIDE' => HijriConfidence.userOverride,
      _ => null,
    };
    if (dawn == null || night == null || confidence == null) return null;
    return HijriState(
      dateAtDawn: dawn,
      dateAtNight: night,
      confidence: confidence,
    );
  }

  static HijriDate? _date(Object? json) {
    if (json is! Map<String, Object?> || json.length != 3) return null;
    final (year, month, day) = (json['year'], json['month'], json['day']);
    if (year is! int || month is! int || day is! int) return null;
    if (year < 1 || month < 1 || month > 12 || day < 1 || day > 30) {
      return null;
    }
    return HijriDate(year: year, month: month, day: day);
  }
}
