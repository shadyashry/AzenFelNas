import 'dart:math' as math;

import 'package:geo_salah_core/src/model/authority_type.dart';
import 'package:geo_salah_core/src/model/confidence_label.dart';
import 'package:geo_salah_core/src/model/event_origin.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';
import 'package:geo_salah_core/src/model/profile_status.dart';

/// The fixed mapping from an event's origin and its profile's standing to
/// its [ConfidenceLabel] (§6.2, REQ-DOM-050, REQ-DOM-010):
///
/// - `primary`, profile `approved`, authority `government` or
///   `recognizedBody`, `benchmarkReportId ≠ null` →
///   `authorityAligned(benchmarkReportId)`;
/// - `primary` otherwise → `calculated`;
/// - `fallback(method)` →
///   `estimated(rangeMinutes = max(5, perturbationMinutes))`;
/// - `noEvent(reason)` → `unknown(reason)`.
///
/// Nothing else can change a label; `verified` and `observed` come only from
/// V1.5 data types, never from the engine. Pure and deterministic.
final class ConfidenceMapper {
  /// The mapper.
  const new();

  /// The smallest range of an `estimated` label, minutes (§6.2).
  static const int minimumEstimateMinutes = 5;

  /// The label of a time with [origin] under [profile].
  ///
  /// [perturbationMinutes] is the fallback instant's sensitivity in whole
  /// minutes (§6.7, §15 D46), supplied by the high-latitude step (S08); only
  /// the fallback row reads it.
  ConfidenceLabel labelOf(
    EventOrigin origin,
    PrayerProfile profile, {
    required int perturbationMinutes,
  }) => switch (origin) {
    Primary() => switch (profile) {
      PrayerProfile(
        status: ProfileStatus.approved,
        authorityType: AuthorityType.government || AuthorityType.recognizedBody,
        benchmarkReportId: final String reportId,
      ) =>
        ConfidenceLabel.authorityAligned(benchmarkReportId: reportId),
      PrayerProfile() => const ConfidenceLabel.calculated(),
    },
    Fallback() => ConfidenceLabel.estimated(
      rangeMinutes: math.max(minimumEstimateMinutes, perturbationMinutes),
    ),
    NoEvent(:final reason) => ConfidenceLabel.unknown(reasonCode: reason.code),
  };
}
