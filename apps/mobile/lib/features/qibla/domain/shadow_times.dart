import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// The sensor-free Qibla of a place: the local day's moments when a
/// vertical object's shadow lies on the Qibla line (§6.6, REQ-DOM-031,
/// §15 D91).
sealed class ShadowTimes {
  const new();
}

/// Within 1 km of the Kaaba the bearing carries no meaning: no Sun method.
final class ShadowTimesNearKaaba extends ShadowTimes {
  const new();
}

/// The Sun does not reach the Qibla bearing or its reciprocal in daylight
/// on any of the searched days (polar night, or a bearing the Sun never
/// crosses in this season).
final class ShadowTimesNone extends ShadowTimes {
  const new();
}

/// The alignments of [date], the first searched local day that has any.
final class ShadowTimesFound extends ShadowTimes {
  /// The alignments of [date]; [isToday] when it is the current local day.
  const new({required this.date, required this.isToday, required this.times});

  /// The local day the [times] fall on.
  final CivilDate date;

  /// Whether [date] is today in the place's zone.
  final bool isToday;

  /// The alignments in time order, never empty.
  final List<ShadowTime> times;
}

/// One alignment in local wall time (pinned TZDB, REQ-TIME-020).
@immutable
final class ShadowTime {
  /// Creates a [ShadowTime].
  const new({
    required this.kind,
    required this.localTime,
    required this.windowStart,
    required this.windowEnd,
    required this.hardToUse,
    required this.passed,
  });

  /// Whether the Sun stands at the Qibla or opposite it, which decides
  /// which end of the shadow points to the Qibla.
  final QiblaSunAlignmentKind kind;

  /// `HH:mm` of the exact alignment.
  final String localTime;

  /// `HH:mm` from which the shadow is within the tolerance.
  final String windowStart;

  /// `HH:mm` until which the shadow is within the tolerance.
  final String windowEnd;

  /// Why the moment is hard to use, or `null`: flagged, never hidden.
  final ShadowDifficulty? hardToUse;

  /// Whether the window has already closed.
  final bool passed;
}

/// Why a [ShadowTime] is hard to use (§15 D91).
enum ShadowDifficulty {
  /// The Sun is so high that the shadow is shorter than about a quarter of
  /// the object's height.
  highSun,

  /// The window lasts less than two minutes.
  briefWindow,
}
