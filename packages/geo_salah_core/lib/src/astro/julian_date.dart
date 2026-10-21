import 'package:meta/meta.dart';

/// The time arguments of the SPA (Reda & Andreas 2008, §3.1) for one instant.
///
/// Built from UTC epoch milliseconds rather than a calendar date, so it is
/// proleptic Gregorian throughout; the paper's calendar formula (eq. 4) gives
/// the same Julian Day for every Gregorian date. UT1 − UTC is ignored
/// (ADR-019): UT here is UTC.
///
/// Days are counted from J2000.0 (JD 2451545.0) so that a double keeps
/// sub-microsecond resolution. Pure and deterministic.
@immutable
final class JulianDate {
  /// The time arguments of [utcMs] (UTC epoch milliseconds, fractional
  /// allowed) with ΔT = TT − UT of [deltaTSeconds].
  factory fromUtcMs(double utcMs, {required double deltaTSeconds}) {
    final daysUt = (utcMs - _j2000UtcMs) / _msPerDay;
    return JulianDate._(daysUt, daysUt + deltaTSeconds / 86400);
  }

  const new _(this.daysSinceJ2000, this.ephemerisDaysSinceJ2000);

  /// UTC epoch milliseconds of JD 2451545.0 (2000-01-01T12:00:00Z).
  static const double _j2000UtcMs = 946728000000;
  static const double _msPerDay = 86400000;

  /// `JD − 2451545` (UT), in days.
  final double daysSinceJ2000;

  /// `JDE − 2451545` (TT), in days (eq. 5).
  final double ephemerisDaysSinceJ2000;

  /// The Julian Day `JD` (UT). Use [daysSinceJ2000] in arithmetic; this sum
  /// loses about 40 µs of resolution.
  double get julianDay => 2451545 + daysSinceJ2000;

  /// The Julian century `JC` (eq. 6).
  double get julianCentury => daysSinceJ2000 / 36525;

  /// The Julian ephemeris century `JCE` (eq. 7).
  double get julianEphemerisCentury => ephemerisDaysSinceJ2000 / 36525;

  /// The Julian ephemeris millennium `JME` (eq. 8).
  double get julianEphemerisMillennium => julianEphemerisCentury / 10;
}
