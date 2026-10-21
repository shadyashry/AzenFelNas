import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';

part 'event_rule.freezed.dart';

/// How a profile defines one prayer event (§6.2, Appendix A `rule`).
///
/// A sealed variation point (§17.1 O): the engine switches over it
/// exhaustively. Values come from profile data; the only constants here are
/// the ADR-003 horizon defaults that §6.2 fixes for [HorizonRule] and the
/// zero transit offset of an absent Appendix A `offsetMinutes` (§0.2 rule 1).
@freezed
sealed class EventRule with _$EventRule {
  /// The Sun's centre at geometric altitude `−degrees` (Fajr, Isha):
  /// [degrees] is the depression below the horizon, with no refraction and
  /// no dip (ADR-003).
  const factory solarAltitude({required double degrees}) = SolarAltitudeRule;

  /// The upper transit `T₀` plus [offset] (Dhuhr). An absent Appendix A
  /// `offsetMinutes` is zero.
  const factory transit({@Default(Duration.zero) Duration offset}) =
      TransitRule;

  /// The afternoon instant at which a gnomon's shadow is [k] times its length
  /// plus the noon shadow (Asr, §6.4 ¶6).
  const factory shadowFactor({required int k}) = ShadowFactorRule;

  /// The Sun's centre at geometric altitude
  /// `−(refractionArcmin + semidiameterArcmin)/60 − dip` (sunrise, sunset).
  ///
  /// The defaults 34′ + 16′ = 0.8333° are ADR-003's; the dip follows the
  /// profile's elevation policy and is 0 under `none`. No refraction model
  /// is applied on top of [refractionArcmin].
  const factory horizon({
    @Default(34) double refractionArcmin,
    @Default(16) double semidiameterArcmin,
  }) = HorizonRule;

  /// [duration] after the raw instant of the event [base] (Isha after
  /// Maghrib, Appendix A).
  const factory intervalAfter({
    required PrayerEvent base,
    required Duration duration,
  }) = IntervalAfterRule;

  /// [duration] before the raw instant of the event [base] (Imsak before
  /// Fajr, Appendix A).
  const factory intervalBefore({
    required PrayerEvent base,
    required Duration duration,
  }) = IntervalBeforeRule;
}
