import 'package:geo_salah_core/src/solver/crossing_direction.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';

/// Picks an altitude-defined event's crossing in its half of the prayer day
/// (ADR-004, §15 D37).
///
/// A rising event is searched in the ascending half `[A₋, T₀]`, a setting
/// one in the descending half `[T₀, A₊]`. If the half has several crossings
/// in the event's direction (possible only near a grazing crossing), the one
/// nearest the daylight around `T₀` is taken: the **last** rising crossing
/// before `T₀`, the **first** setting one after it. Shared by the horizon,
/// altitude and shadow-factor rules. Pure and deterministic.
abstract final class HalfSegmentCrossing {
  /// The crossing of [targetDeg] (geometric degrees) in [direction] on the
  /// day of [segments], UTC epoch ms truncated to 1 ms; `null` when the Sun
  /// stays on one side of the target throughout the half.
  static int? find(
    CulminationSegments segments, {
    required CrossingDirection direction,
    required double targetDeg,
  }) {
    final half = switch (direction) {
      CrossingDirection.rising => segments.ascending,
      CrossingDirection.setting => segments.descending,
    };
    final inDirection = [
      for (final crossing in half.crossings(targetDeg))
        if (crossing.direction == direction) crossing,
    ];
    if (inDirection.isEmpty) return null;
    return switch (direction) {
      CrossingDirection.rising => inDirection.last.utcMs,
      CrossingDirection.setting => inDirection.first.utcMs,
    };
  }

  /// The interpolated altitude at `T₀`, degrees: which side of a target the
  /// Sun stays on when [find] returns `null`.
  static double upperAltitudeDeg(
    CulminationSegments segments, {
    required CrossingDirection direction,
  }) => switch (direction) {
    CrossingDirection.rising => segments.ascending,
    CrossingDirection.setting => segments.descending,
  }.source.altitudeDeg(segments.upperUtcMs);
}
