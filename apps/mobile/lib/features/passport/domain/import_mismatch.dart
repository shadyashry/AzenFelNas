import 'package:meta/meta.dart';

/// Why a shared link's Calculation ID was not reproduced on this device.
enum MismatchReason {
  /// The inputs recomputed to a different ID: the sender used another
  /// engine, ΔT model or TZDB version (§6.4 ¶11).
  differentVersions,

  /// The link names a profile version this device does not hold.
  profileUnavailable,

  /// The link names a zone this device's TZDB does not hold.
  zoneUnavailable,
}

/// The `importMismatch(details)` of the Passport (§18.4): what differs, with
/// this device's versions so the user can compare. Never shows the sender's
/// values as if they were true (§6.4 ¶11: the receiver trusts only its own
/// recomputation).
@immutable
final class ImportMismatch {
  /// Creates an [ImportMismatch].
  const new({
    required this.linkId,
    required this.reason,
    required this.profileId,
    required this.profileVersion,
    required this.engineVersion,
    required this.tzdbVersion,
    this.deltaTModel,
    this.localId,
  });

  /// The Calculation ID in the link.
  final String linkId;

  /// The ID this device computed from the same inputs, when it could.
  final String? localId;

  /// Why they differ.
  final MismatchReason reason;

  /// The profile the link names.
  final String profileId;

  /// The profile version the link names.
  final String profileVersion;

  /// This device's engine version.
  final String engineVersion;

  /// This device's ΔT model, when it computed the day.
  final String? deltaTModel;

  /// This device's TZDB release.
  final String tzdbVersion;
}
