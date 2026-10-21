import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:geo_salah_core/src/astro/sun_sample.dart';

/// Memoised [ExactSun.sampleAt] for the days of one `calculateRange` call
/// (§6.3, §6.4 ¶2, REQ-PERF-001).
///
/// A day's model samples the Sun 12 h apart around its solar-noon guess, and
/// the guesses of consecutive days are 24 h apart, so three of a day's five
/// samples are the next day's first three. A sample is geocentric (it does
/// not depend on the site) and a pure function of its instant, so a cached
/// value is bit-identical to a fresh one: the cache changes speed, never a
/// result (REQ-DOM-004). Keys are exact instants; an instant that differs in
/// its last bit is a miss, never a wrong hit.
///
/// One cache serves one ΔT model and one call; it is not shared between
/// calls and holds no static state (§17.2).
final class SunSampleCache {
  /// An empty cache.
  new();

  final Map<double, SunSample> _byUtcMs = {};

  /// The sample of [exact] at [utcMs], computed once.
  SunSample sampleAt(ExactSun exact, double utcMs) =>
      _byUtcMs.putIfAbsent(utcMs, () => exact.sampleAt(utcMs));

  /// Number of distinct instants sampled so far.
  int get length => _byUtcMs.length;
}
