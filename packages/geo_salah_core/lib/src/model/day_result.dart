import 'package:dm_core_types/dm_core_types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/model/prayer_time.dart';
import 'package:geo_salah_core/src/model/provenance.dart';

part 'day_result.freezed.dart';

/// The calculated prayer day `D` (§6.2).
///
/// [times] holds the profile's events in `PrayerEvent` order. It is empty
/// only for a calendar day the observer's zone skipped, which has no upper
/// transit and so no prayer day (ADR-004, §15 D36). A time is addressed
/// `<calculationId>#<event>`.
@freezed
abstract class DayResult with _$DayResult {
  /// Creates a [DayResult].
  const factory({
    /// The prayer day, a civil date in the observer's zone.
    required CivilDate day,

    /// `GS-` + 16 base32 characters (§6.4 ¶11).
    required String calculationId,

    /// The day's events.
    required List<PrayerTime> times,

    /// How the day was calculated.
    required Provenance provenance,
  }) = _DayResult;
}
