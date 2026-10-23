import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/src/parse_prayer_profile.dart';
import 'package:geo_salah_profiles/src/profile_failure.dart';
import 'package:geo_salah_profiles/src/profile_set.dart';
import 'package:geo_salah_profiles/src/validate_profile_set.dart';

/// Reads a `prayer_profiles` package payload (§15 D60: `profiles.json`, the
/// UTF-8 JSON array of `prayer_profile.v1` documents) into a validated
/// [ProfileSet].
///
/// Each document goes through [ParsePrayerProfile], then the whole list
/// through [ValidateProfileSet]. Bytes that are not UTF-8 JSON, a top level
/// that is not an array, and an empty array are `ProfileFailure.invalid`;
/// a document's own failure is returned as it is. The release channel is
/// not checked here (`CheckProfileChannel` runs where the set is used).
/// Pure and deterministic.
final class ParseProfileSetPayload {
  /// The use case.
  const new();

  static const ParsePrayerProfile _parse = ParsePrayerProfile();
  static const ValidateProfileSet _validate = ValidateProfileSet();

  /// The set [payload] holds, or why it cannot be used.
  Result<ProfileSet, ProfileFailure> call(List<int> payload) {
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(payload));
    } on FormatException catch (error) {
      return Result.err(
        ProfileFailure.invalid('profiles.json: ${error.message}'),
      );
    }
    if (json is! List<Object?> || json.isEmpty) {
      return const Result.err(
        ProfileFailure.invalid('profiles.json: not a non-empty array'),
      );
    }
    final profiles = <PrayerProfile>[];
    for (final document in json) {
      switch (_parse(document)) {
        case Ok(:final value):
          profiles.add(value);
        case Err(:final failure):
          return Result.err(failure);
      }
    }
    return _validate(profiles);
  }
}
