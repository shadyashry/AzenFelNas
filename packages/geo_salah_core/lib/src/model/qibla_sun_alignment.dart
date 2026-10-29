import 'package:geo_salah_core/src/model/qibla_sun_alignment_kind.dart';
import 'package:meta/meta.dart';

/// A moment when the Sun lines up with the Qibla, so a shadow shows the
/// Qibla without any device sensor (§6.6, REQ-DOM-031).
///
/// At [utcMs] the Sun's topocentric azimuth equals the Qibla bearing
/// ([QiblaSunAlignmentKind.sunTowardQibla]) or its reciprocal
/// ([QiblaSunAlignmentKind.sunAwayFromQibla]), and the Sun is above the
/// geometric horizon. Between [windowStartUtcMs] and [windowEndUtcMs] the
/// azimuth stays within the tolerance the caller asked for and the Sun stays
/// up; the window is conservative to 1 s and always contains [utcMs].
/// Immutable value type.
@immutable
final class QiblaSunAlignment {
  /// Creates an alignment.
  const new({
    required this.kind,
    required this.utcMs,
    required this.windowStartUtcMs,
    required this.windowEndUtcMs,
    required this.sunAltitudeDeg,
  });

  /// Whether the Sun stands at the Qibla or opposite it.
  final QiblaSunAlignmentKind kind;

  /// The exact alignment, epoch ms UTC, truncated to 1 ms.
  final int utcMs;

  /// First instant of the tolerance window, epoch ms UTC.
  final int windowStartUtcMs;

  /// Last instant of the tolerance window, epoch ms UTC.
  final int windowEndUtcMs;

  /// The Sun's geometric topocentric altitude at [utcMs], degrees (no
  /// refraction, ADR-003). A high Sun casts short shadows: the shadow of a
  /// vertical object of height `h` is `h / tan(altitude)` long.
  final double sunAltitudeDeg;

  @override
  bool operator ==(Object other) =>
      other is QiblaSunAlignment &&
      other.kind == kind &&
      other.utcMs == utcMs &&
      other.windowStartUtcMs == windowStartUtcMs &&
      other.windowEndUtcMs == windowEndUtcMs &&
      other.sunAltitudeDeg == sunAltitudeDeg;

  @override
  int get hashCode => Object.hash(
    kind,
    utcMs,
    windowStartUtcMs,
    windowEndUtcMs,
    sunAltitudeDeg,
  );
}
