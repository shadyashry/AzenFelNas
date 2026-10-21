import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// Why a profile or a profile set cannot be used (REQ-ERR-001). Each variant
/// carries its Appendix J [code] (REQ-ERR-002).
@immutable
sealed class ProfileFailure implements Failure {
  const new();

  /// A profile is malformed or breaks a validation rule, for [reason].
  const factory invalid(String reason) = ProfileInvalid;

  /// Profiles [first] and [second] both cover [country] on a common day
  /// (ADR-007 non-overlap).
  const factory overlap({
    required String first,
    required String second,
    required String country,
  }) = ProfileOverlap;

  /// No profile, not even `engine.default`, covers [day].
  const factory notFound(CivilDate day) = ProfileNotFound;

  /// A one-line description for logs; never coordinates (REQ-PRIV-001).
  String get detail;
}

/// [ProfileFailure.invalid]: `PROFILE_INVALID`.
final class ProfileInvalid extends ProfileFailure {
  /// Wraps [reason].
  const new(this.reason);

  /// What makes the profile unusable.
  final String reason;

  @override
  FailureCode get code => FailureCode.profileInvalid;

  @override
  String get detail => reason;

  @override
  bool operator ==(Object other) =>
      other is ProfileInvalid && other.reason == reason;

  @override
  int get hashCode => Object.hash(ProfileInvalid, reason);

  @override
  String toString() => 'ProfileInvalid($reason)';
}

/// [ProfileFailure.overlap]: `PROFILE_OVERLAP`.
final class ProfileOverlap extends ProfileFailure {
  /// [first] and [second] overlap in [country].
  const new({required this.first, required this.second, required this.country});

  /// `profileId@version` of the earlier profile in the set.
  final String first;

  /// `profileId@version` of the later profile in the set.
  final String second;

  /// The shared country, or `*`.
  final String country;

  @override
  FailureCode get code => FailureCode.profileOverlap;

  @override
  String get detail => '$first and $second both cover $country';

  @override
  bool operator ==(Object other) =>
      other is ProfileOverlap &&
      other.first == first &&
      other.second == second &&
      other.country == country;

  @override
  int get hashCode => Object.hash(ProfileOverlap, first, second, country);

  @override
  String toString() => 'ProfileOverlap($detail)';
}

/// [ProfileFailure.notFound]: `PROFILE_NOT_FOUND`.
final class ProfileNotFound extends ProfileFailure {
  /// No profile for [day].
  const new(this.day);

  /// The day nothing covers.
  final CivilDate day;

  @override
  FailureCode get code => FailureCode.profileNotFound;

  @override
  String get detail => 'no profile covers $day';

  @override
  bool operator ==(Object other) =>
      other is ProfileNotFound && other.day == day;

  @override
  int get hashCode => Object.hash(ProfileNotFound, day);

  @override
  String toString() => 'ProfileNotFound($day)';
}
