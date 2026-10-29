import 'dart:math' as math;

import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:geo_salah_core/src/astro/topocentric.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/model/qibla_sun_alignment.dart';
import 'package:geo_salah_core/src/model/qibla_sun_alignment_kind.dart';
import 'package:geo_salah_core/src/solver/bracket.dart';
import 'package:geo_salah_core/src/solver/brent.dart';
import 'package:meta/meta.dart';

/// The Sun's direction from a site at one instant.
typedef _SunDirection = ({double azimuthDeg, double altitudeDeg});

/// Finds the instants when the Sun's azimuth equals a Qibla bearing or its
/// reciprocal (§6.6, REQ-DOM-031).
///
/// Both alignments are the roots of `g(t) = sin(A(t) − Q)`, which is
/// continuous through the 0°/360° wrap. `g` is sampled every
/// [_sampleStepMs] of exact SPA; each sign change is solved by Brent to
/// 1 ms. The root's own azimuth says which alignment it is, and a root where
/// the azimuth matches neither within [_continuityDeg] is the 180° jump of a
/// Sun passing through the zenith or nadir, not an alignment, and is
/// dropped. Two roots inside one sample step (the azimuth turning back
/// within two minutes, possible only at a grazing tangency) are not
/// resolved.
///
/// Pure and deterministic.
@immutable
final class QiblaSunSearch {
  /// A search at [site] for the Qibla bearing [qiblaBearingDeg].
  const new(this.site, {required this.qiblaBearingDeg});

  static const double _sampleStepMs = 2 * 60000;
  static const double _windowStepMs = 60000;
  static const double _windowResolutionMs = 1000;
  static const double _maxWindowHalfMs = 12 * 3600000;
  static const double _continuityDeg = 0.5;
  static const BrentSolver _solver = BrentSolver(toleranceMs: 1);

  /// The observing site.
  final TopocentricSite site;

  /// The Qibla bearing, degrees from true north.
  final double qiblaBearingDeg;

  /// The alignments in `[fromUtcMs, toUtcMs)`, in time order, each with its
  /// window for [toleranceDeg].
  List<QiblaSunAlignment> find({
    required int fromUtcMs,
    required int toUtcMs,
    required double toleranceDeg,
  }) {
    final exact = ExactSun(site);
    _SunDirection sun(double utcMs) => _direction(exact, utcMs);
    double offset(double utcMs) => _offset(sun(utcMs));

    final alignments = <QiblaSunAlignment>[];
    var t0 = fromUtcMs.toDouble();
    var s0 = sun(t0);
    while (t0 < toUtcMs) {
      final t1 = math.min(t0 + _sampleStepMs, toUtcMs.toDouble());
      final s1 = sun(t1);
      // Below −1° at both ends the Sun cannot rise above 0° within 2 min.
      if (math.max(s0.altitudeDeg, s1.altitudeDeg) > -1 &&
          _offset(s0) * _offset(s1) <= 0) {
        final bracket = Bracket.tryOf(offset, lowerMs: t0, upperMs: t1);
        final alignment = bracket == null
            ? null
            : _alignmentAt(sun, _solver.solve(offset, bracket), toleranceDeg);
        if (alignment != null &&
            alignment.utcMs >= fromUtcMs &&
            alignment.utcMs < toUtcMs &&
            (alignments.isEmpty || alignments.last.utcMs != alignment.utcMs)) {
          alignments.add(alignment);
        }
      }
      (t0, s0) = (t1, s1);
    }
    return List.unmodifiable(alignments);
  }

  double _offset(_SunDirection s) =>
      math.sin(degToRad(s.azimuthDeg - qiblaBearingDeg));

  QiblaSunAlignment? _alignmentAt(
    _SunDirection Function(double) sun,
    double rootMs,
    double toleranceDeg,
  ) {
    final at = sun(rootMs);
    if (!(at.altitudeDeg > 0)) {
      return null;
    }
    final QiblaSunAlignmentKind kind;
    if (wrapTo180(at.azimuthDeg - qiblaBearingDeg).abs() < _continuityDeg) {
      kind = QiblaSunAlignmentKind.sunTowardQibla;
    } else if (wrapTo180(at.azimuthDeg - qiblaBearingDeg - 180).abs() <
        _continuityDeg) {
      kind = QiblaSunAlignmentKind.sunAwayFromQibla;
    } else {
      return null;
    }
    final targetDeg = switch (kind) {
      QiblaSunAlignmentKind.sunTowardQibla => qiblaBearingDeg,
      QiblaSunAlignmentKind.sunAwayFromQibla => qiblaBearingDeg + 180,
    };
    bool inside(double utcMs) {
      final s = sun(utcMs);
      return s.altitudeDeg > 0 &&
          wrapTo180(s.azimuthDeg - targetDeg).abs() <= toleranceDeg;
    }

    final utcMs = rootMs.floor();
    return QiblaSunAlignment(
      kind: kind,
      utcMs: utcMs,
      windowStartUtcMs: math.min(_edge(inside, rootMs, -1).ceil(), utcMs),
      windowEndUtcMs: math.max(_edge(inside, rootMs, 1).floor(), utcMs),
      sunAltitudeDeg: at.altitudeDeg,
    );
  }

  /// The last instant from [rootMs] in [direction] (±1) at which [inside]
  /// still holds, to [_windowResolutionMs]: minute steps outwards, then
  /// bisection between the last inside and the first outside instant.
  static double _edge(
    bool Function(double) inside,
    double rootMs,
    int direction,
  ) {
    var inner = rootMs;
    var outer = rootMs + direction * _windowStepMs;
    while (inside(outer) && (outer - rootMs).abs() < _maxWindowHalfMs) {
      inner = outer;
      outer += direction * _windowStepMs;
    }
    while ((outer - inner).abs() > _windowResolutionMs) {
      final middle = (inner + outer) / 2;
      if (inside(middle)) {
        inner = middle;
      } else {
        outer = middle;
      }
    }
    return inner;
  }

  static _SunDirection _direction(ExactSun exact, double utcMs) {
    final apparent = exact.apparentAt(utcMs);
    final topocentric = TopocentricSun.observe(
      exact.site,
      declinationDeg: apparent.declinationDeg,
      hourAngleDeg: apparent.hourAngleDeg(exact.site.longitudeDeg),
      radiusAu: apparent.earth.radiusAu,
    );
    return (
      azimuthDeg: topocentric.azimuthDeg,
      altitudeDeg: topocentric.altitudeDeg,
    );
  }
}
