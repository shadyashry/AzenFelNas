import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/model/sky_phase.dart';

part 'solar_state.freezed.dart';

/// The Sun as seen by an observer at one instant (§6.2), the input of
/// `SkyTheme.fromSolarState` (ADR-018).
@freezed
abstract class SolarState with _$SolarState {
  /// Creates a [SolarState].
  const factory({
    /// Geometric topocentric altitude, degrees, no refraction (§6.4 ¶3).
    required double altitudeDeg,

    /// Topocentric azimuth, degrees east of north, `[0, 360)`.
    required double azimuthDeg,

    /// Whether the Sun is east of the meridian (before upper culmination).
    required bool rising,

    /// The Appendix G phase of [altitudeDeg] and [rising].
    required SkyPhase phase,

    /// Progress through [phase]'s band, `[0, 1]` (`SkyPhase.progressAt`).
    required double phaseProgress,
  }) = _SolarState;
}
