import 'dart:math' as math;

/// The inverse geodesic problem on an ellipsoid (§6.6): a Dart port of the
/// core of GeographicLib's `Geodesic` (C. F. F. Karney, "Algorithms for
/// geodesics", J. Geodesy 87, 43–55, 2013; GeographicLib 2.0, MIT/X11
/// licence, copyright Charles Karney 2011–2022).
///
/// Only what the Qibla needs is ported: the initial azimuth and the
/// distance, with the series of order 6, the astroid start for nearly
/// antipodal points and the Newton/bisection solution of the hybrid problem.
/// Area (`C4`) and the direct problem are left out. Accurate to round-off
/// (about 15 nm) for every pair of points, antipodes included. Pure.
final class Geodesic {
  /// The geodesic on the ellipsoid of equatorial radius [a] (metres) and
  /// flattening [f].
  new({required this.a, required this.f})
    : _f1 = 1 - f,
      _ep2 = f * (2 - f) / ((1 - f) * (1 - f)),
      _n = f / (2 - f),
      _b = a * (1 - f),
      _etol2 =
          0.1 *
          _tol2 /
          math.sqrt(math.max(0.001, f.abs()) * math.min(1.0, 1 - f / 2) / 2) {
    _a3Coefficients();
    _c3Coefficients();
  }

  /// WGS84 (a = 6 378 137 m, f = 1/298.257223563).
  static final Geodesic wgs84 = Geodesic(a: 6378137, f: 1 / 298.257223563);

  /// Equatorial radius in metres.
  final double a;

  /// Flattening.
  final double f;

  final double _f1;
  final double _ep2;
  final double _n;
  final double _b;
  final double _etol2;
  final List<double> _a3x = List<double>.filled(_nA3, 0);
  final List<double> _c3x = List<double>.filled(_nC3x, 0);

  static const int _order = 6;
  static const int _nA3 = _order;
  static const int _nC1 = _order;
  static const int _nC2 = _order;
  static const int _nC3 = _order;
  static const int _nC3x = _nC3 * (_nC3 - 1) ~/ 2;
  static const int _maxit1 = 20;
  static const int _maxit2 = _maxit1 + 53 + 10;
  static final double _tiny = math.sqrt(2.2250738585072014e-308);
  static const double _tol0 = 2.220446049250313e-16;
  static const double _tol1 = 200 * _tol0;
  static final double _tol2 = math.sqrt(_tol0);
  static final double _tolb = _tol0 * _tol2;
  static final double _xthresh = 1000 * _tol2;

  /// The initial azimuth (degrees clockwise from true north, `(-180, 180]`)
  /// and length (metres) of the shortest geodesic from (`lat1`, `lon1`) to
  /// (`lat2`, `lon2`), all in degrees. Latitudes outside `[-90, 90]` give NaN.
  ({double azimuth1Deg, double distanceM}) inverse(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final c1a = List<double>.filled(_nC1 + 1, 0);
    final c2a = List<double>.filled(_nC2 + 1, 0);
    final c3a = List<double>.filled(_nC3, 0);

    var (lon12, lon12s) = _angDiff(lon1, lon2);
    var lonsign = _copysign(1, lon12);
    lon12 = lonsign * lon12;
    lon12s = lonsign * lon12s;
    final lam12 = _radians(lon12);
    final (slam12, clam12) = _sincosde(lon12, lon12s);
    lon12s = (180 - lon12) - lon12s;

    var la1 = _angRound(_latFix(lat1));
    var la2 = _angRound(_latFix(lat2));
    final swapp = (la1.abs() < la2.abs() || la2.isNaN) ? -1.0 : 1.0;
    if (swapp < 0) {
      lonsign *= -1;
      final t = la2;
      la2 = la1;
      la1 = t;
    }
    final latsign = _copysign(1, -la1);
    la1 *= latsign;
    la2 *= latsign;

    var (sbet1, cbet1) = _sincosd(la1);
    (sbet1, cbet1) = _norm(sbet1 * _f1, cbet1);
    cbet1 = math.max(_tiny, cbet1);
    var (sbet2, cbet2) = _sincosd(la2);
    (sbet2, cbet2) = _norm(sbet2 * _f1, cbet2);
    cbet2 = math.max(_tiny, cbet2);
    if (cbet1 < -sbet1) {
      if (cbet2 == cbet1) sbet2 = _copysign(sbet1, sbet2);
    } else if (sbet2.abs() == -sbet1) {
      cbet2 = cbet1;
    }
    final dn1 = math.sqrt(1 + _ep2 * sbet1 * sbet1);
    final dn2 = math.sqrt(1 + _ep2 * sbet2 * sbet2);

    var salp1 = 0.0;
    var calp1 = 0.0;
    var salp2 = 0.0;
    var calp2 = 0.0;
    var s12x = double.nan;

    var meridian = la1 == -90 || slam12 == 0;
    if (meridian) {
      calp1 = clam12;
      salp1 = slam12;
      calp2 = 1.0;
      salp2 = 0.0;
      final ssig1 = sbet1;
      final csig1 = calp1 * cbet1;
      final ssig2 = sbet2;
      final csig2 = calp2 * cbet2;
      var sig12 = math.atan2(
        math.max(0, csig1 * ssig2 - ssig1 * csig2) + 0.0,
        csig1 * csig2 + ssig1 * ssig2,
      );
      final lengths = _lengths(
        _n,
        sig12,
        ssig1,
        csig1,
        dn1,
        ssig2,
        csig2,
        dn2,
        c1a,
        c2a,
      );
      var m12x = lengths.m12b;
      s12x = lengths.s12b;
      if (sig12 < 1 || m12x >= 0) {
        if (sig12 < 3 * _tiny || (sig12 < _tol0 && (s12x < 0 || m12x < 0))) {
          sig12 = m12x = s12x = 0.0;
        }
        s12x *= _b;
      } else {
        meridian = false;
      }
    }

    if (!meridian && sbet1 == 0 && (f <= 0 || lon12s >= f * 180)) {
      calp1 = calp2 = 0.0;
      salp1 = salp2 = 1.0;
      s12x = a * lam12;
    } else if (!meridian) {
      final start = _inverseStart(
        sbet1,
        cbet1,
        dn1,
        sbet2,
        cbet2,
        dn2,
        lam12,
        slam12,
        clam12,
      );
      salp1 = start.salp1;
      calp1 = start.calp1;
      if (start.sig12 >= 0) {
        salp2 = start.salp2;
        calp2 = start.calp2;
        s12x = start.sig12 * _b * start.dnm;
      } else {
        var numit = 0;
        var tripn = false;
        var tripb = false;
        var salp1a = _tiny;
        var calp1a = 1.0;
        var salp1b = _tiny;
        var calp1b = -1.0;
        late _Lambda12 l;
        while (numit < _maxit2) {
          l = _lambda12(
            sbet1,
            cbet1,
            dn1,
            sbet2,
            cbet2,
            dn2,
            salp1,
            calp1,
            slam12,
            clam12,
            diffp: numit < _maxit1,
            c1a: c1a,
            c2a: c2a,
            c3a: c3a,
          );
          final v = l.lam12;
          if (tripb || !(v.abs() >= (tripn ? 8 : 1) * _tol0)) break;
          if (v > 0 && (numit > _maxit1 || calp1 / salp1 > calp1b / salp1b)) {
            salp1b = salp1;
            calp1b = calp1;
          } else if (v < 0 &&
              (numit > _maxit1 || calp1 / salp1 < calp1a / salp1a)) {
            salp1a = salp1;
            calp1a = calp1;
          }
          numit += 1;
          if (numit < _maxit1 && l.dlam12 > 0) {
            final dalp1 = -v / l.dlam12;
            final sdalp1 = math.sin(dalp1);
            final cdalp1 = math.cos(dalp1);
            final nsalp1 = salp1 * cdalp1 + calp1 * sdalp1;
            if (nsalp1 > 0 && dalp1.abs() < math.pi) {
              calp1 = calp1 * cdalp1 - salp1 * sdalp1;
              salp1 = nsalp1;
              (salp1, calp1) = _norm(salp1, calp1);
              tripn = v.abs() <= 16 * _tol0;
              continue;
            }
          }
          salp1 = (salp1a + salp1b) / 2;
          calp1 = (calp1a + calp1b) / 2;
          (salp1, calp1) = _norm(salp1, calp1);
          tripn = false;
          tripb =
              (salp1a - salp1).abs() + (calp1a - calp1) < _tolb ||
              (salp1 - salp1b).abs() + (calp1 - calp1b) < _tolb;
        }
        salp2 = l.salp2;
        calp2 = l.calp2;
        s12x =
            _lengths(
              l.eps,
              l.sig12,
              l.ssig1,
              l.csig1,
              dn1,
              l.ssig2,
              l.csig2,
              dn2,
              c1a,
              c2a,
            ).s12b *
            _b;
      }
    }

    if (swapp < 0) {
      // The points were swapped: the wanted start azimuth is the far one.
      salp1 = salp2;
      calp1 = calp2;
    }
    salp1 *= swapp * lonsign;
    calp1 *= swapp * latsign;
    return (azimuth1Deg: _atan2d(salp1, calp1), distanceM: 0.0 + s12x);
  }

  /// `(salp2, calp2)` at the end point of the geodesic leaving point 1 with
  /// azimuth `(salp1, calp1)` (Clairaut: `cbet · sin α` is constant).
  (double, double) _farAzimuth(
    double sbet1,
    double cbet1,
    double sbet2,
    double cbet2,
    double salp1,
    double calp1,
  ) {
    final salp2 = cbet2 != cbet1 ? salp1 * cbet1 / cbet2 : salp1;
    final calp2 = (cbet2 != cbet1 || sbet2.abs() != -sbet1)
        ? math.sqrt(
                calp1 * cbet1 * calp1 * cbet1 +
                    (cbet1 < -sbet1
                        ? (cbet2 - cbet1) * (cbet1 + cbet2)
                        : (sbet1 - sbet2) * (sbet1 + sbet2)),
              ) /
              cbet2
        : calp1.abs();
    return (salp2, calp2);
  }

  ({double s12b, double m12b}) _lengths(
    double eps,
    double sig12,
    double ssig1,
    double csig1,
    double dn1,
    double ssig2,
    double csig2,
    double dn2,
    List<double> c1a,
    List<double> c2a,
  ) {
    var a1 = _a1m1f(eps);
    _c1f(eps, c1a);
    var a2 = _a2m1f(eps);
    _c2f(eps, c2a);
    final m0x = a1 - a2;
    a2 = 1 + a2;
    a1 = 1 + a1;
    final b1 =
        _sinCosSeries(true, ssig2, csig2, c1a) -
        _sinCosSeries(true, ssig1, csig1, c1a);
    final s12b = a1 * (sig12 + b1);
    final b2 =
        _sinCosSeries(true, ssig2, csig2, c2a) -
        _sinCosSeries(true, ssig1, csig1, c2a);
    final j12 = m0x * sig12 + (a1 * b1 - a2 * b2);
    final m12b =
        dn2 * (csig1 * ssig2) - dn1 * (ssig1 * csig2) - csig1 * csig2 * j12;
    return (s12b: s12b, m12b: m12b);
  }

  ({
    double sig12,
    double salp1,
    double calp1,
    double salp2,
    double calp2,
    double dnm,
  })
  _inverseStart(
    double sbet1,
    double cbet1,
    double dn1,
    double sbet2,
    double cbet2,
    double dn2,
    double lam12,
    double slam12,
    double clam12,
  ) {
    var sig12 = -1.0;
    var dnm = double.nan;
    var salp2 = double.nan;
    var calp2 = double.nan;
    final sbet12 = sbet2 * cbet1 - cbet2 * sbet1;
    final cbet12 = cbet2 * cbet1 + sbet2 * sbet1;
    final sbet12a = sbet2 * cbet1 + cbet2 * sbet1;
    final shortline = cbet12 >= 0 && sbet12 < 0.5 && cbet2 * lam12 < 0.5;
    double somg12;
    double comg12;
    if (shortline) {
      var sbetm2 = (sbet1 + sbet2) * (sbet1 + sbet2);
      sbetm2 /= sbetm2 + (cbet1 + cbet2) * (cbet1 + cbet2);
      dnm = math.sqrt(1 + _ep2 * sbetm2);
      final omg12 = lam12 / (_f1 * dnm);
      somg12 = math.sin(omg12);
      comg12 = math.cos(omg12);
    } else {
      somg12 = slam12;
      comg12 = clam12;
    }
    var salp1 = cbet2 * somg12;
    var calp1 = comg12 >= 0
        ? sbet12 + cbet2 * sbet1 * somg12 * somg12 / (1 + comg12)
        : sbet12a - cbet2 * sbet1 * somg12 * somg12 / (1 - comg12);
    final ssig12 = _hypot(salp1, calp1);
    final csig12 = sbet1 * sbet2 + cbet1 * cbet2 * comg12;
    if (shortline && ssig12 < _etol2) {
      (salp2, calp2) = _norm(
        cbet1 * somg12,
        sbet12 -
            cbet1 *
                sbet2 *
                (comg12 >= 0 ? somg12 * somg12 / (1 + comg12) : 1 - comg12),
      );
      sig12 = math.atan2(ssig12, csig12);
    } else if (_n.abs() >= 0.1 ||
        csig12 >= 0 ||
        ssig12 >= 6 * _n.abs() * math.pi * cbet1 * cbet1) {
      // Zeroth-order spherical approximation is good enough.
    } else {
      // Nearly antipodal: start from the astroid solution (f > 0 branch;
      // WGS84 is oblate).
      final lam12x = math.atan2(-slam12, -clam12);
      final k2 = sbet1 * sbet1 * _ep2;
      final eps = k2 / (2 * (1 + math.sqrt(1 + k2)) + k2);
      final lamscale = f * cbet1 * _a3f(eps) * math.pi;
      final betscale = lamscale * cbet1;
      final x = lam12x / lamscale;
      final y = sbet12a / betscale;
      if (y > -_tol1 && x > -1 - _xthresh) {
        salp1 = math.min(1, -x);
        calp1 = -math.sqrt(1 - salp1 * salp1);
      } else {
        final k = _astroid(x, y);
        final omg12a = lamscale * (-x * k / (1 + k));
        somg12 = math.sin(omg12a);
        comg12 = -math.cos(omg12a);
        salp1 = cbet2 * somg12;
        calp1 = sbet12a - cbet2 * sbet1 * somg12 * somg12 / (1 - comg12);
      }
    }
    if (!(salp1 <= 0)) {
      (salp1, calp1) = _norm(salp1, calp1);
    } else {
      salp1 = 1;
      calp1 = 0;
    }
    return (
      sig12: sig12,
      salp1: salp1,
      calp1: calp1,
      salp2: salp2,
      calp2: calp2,
      dnm: dnm,
    );
  }

  _Lambda12 _lambda12(
    double sbet1,
    double cbet1,
    double dn1,
    double sbet2,
    double cbet2,
    double dn2,
    double salp1,
    double calp1In,
    double slam120,
    double clam120, {
    required bool diffp,
    required List<double> c1a,
    required List<double> c2a,
    required List<double> c3a,
  }) {
    var calp1 = calp1In;
    if (sbet1 == 0 && calp1 == 0) calp1 = -_tiny;
    final salp0 = salp1 * cbet1;
    final calp0 = _hypot(calp1, salp1 * sbet1);
    final somg1 = salp0 * sbet1;
    final comg1 = calp1 * cbet1;
    final (ssig1, csig1) = _norm(sbet1, calp1 * cbet1);
    final (salp2, calp2) = _farAzimuth(
      sbet1,
      cbet1,
      sbet2,
      cbet2,
      salp1,
      calp1,
    );
    final somg2 = salp0 * sbet2;
    final comg2 = calp2 * cbet2;
    final (ssig2, csig2) = _norm(sbet2, calp2 * cbet2);
    final sig12 = math.atan2(
      math.max(0, csig1 * ssig2 - ssig1 * csig2) + 0.0,
      csig1 * csig2 + ssig1 * ssig2,
    );
    final somg12 = math.max(0, comg1 * somg2 - somg1 * comg2) + 0.0;
    final comg12 = comg1 * comg2 + somg1 * somg2;
    final eta = math.atan2(
      somg12 * clam120 - comg12 * slam120,
      comg12 * clam120 + somg12 * slam120,
    );
    final k2 = calp0 * calp0 * _ep2;
    final eps = k2 / (2 * (1 + math.sqrt(1 + k2)) + k2);
    _c3f(eps, c3a);
    final b312 =
        _sinCosSeries(true, ssig2, csig2, c3a) -
        _sinCosSeries(true, ssig1, csig1, c3a);
    final domg12 = -f * _a3f(eps) * salp0 * (sig12 + b312);
    final lam12 = eta + domg12;
    var dlam12 = double.nan;
    if (diffp) {
      if (calp2 == 0) {
        dlam12 = -2 * _f1 * dn1 / sbet1;
      } else {
        dlam12 =
            _lengths(
              eps,
              sig12,
              ssig1,
              csig1,
              dn1,
              ssig2,
              csig2,
              dn2,
              c1a,
              c2a,
            ).m12b *
            _f1 /
            (calp2 * cbet2);
      }
    }
    return _Lambda12(
      lam12: lam12,
      salp2: salp2,
      calp2: calp2,
      sig12: sig12,
      ssig1: ssig1,
      csig1: csig1,
      ssig2: ssig2,
      csig2: csig2,
      eps: eps,
      dlam12: dlam12,
    );
  }

  void _a3Coefficients() {
    const coeff = <double>[
      -3, 128, -2, -3, 64, -1, -3, -1, 16, 3, -1, -2, 8, 1, -1, 2, 1, 1, //
    ];
    var o = 0;
    var k = 0;
    for (var j = _nA3 - 1; j >= 0; j--) {
      final m = math.min(_nA3 - j - 1, j);
      _a3x[k++] = _polyval(m, coeff, o, _n) / coeff[o + m + 1];
      o += m + 2;
    }
  }

  void _c3Coefficients() {
    const coeff = <double>[
      3, 128, 2, 5, 128, -1, 3, 3, 64, -1, 0, 1, 8, -1, 1, 4, //
      5, 256, 1, 3, 128, -3, -2, 3, 64, 1, -3, 2, 32, //
      7, 512, -10, 9, 384, 5, -9, 5, 192, //
      7, 512, -14, 7, 512, //
      21, 2560,
    ];
    var o = 0;
    var k = 0;
    for (var l = 1; l < _nC3; l++) {
      for (var j = _nC3 - 1; j >= l; j--) {
        final m = math.min(_nC3 - j - 1, j);
        _c3x[k++] = _polyval(m, coeff, o, _n) / coeff[o + m + 1];
        o += m + 2;
      }
    }
  }

  double _a3f(double eps) => _polyval(_nA3 - 1, _a3x, 0, eps);

  void _c3f(double eps, List<double> c) {
    var mult = 1.0;
    var o = 0;
    for (var l = 1; l < _nC3; l++) {
      final m = _nC3 - l - 1;
      mult *= eps;
      c[l] = mult * _polyval(m, _c3x, o, eps);
      o += m + 1;
    }
  }

  static double _a1m1f(double eps) {
    const coeff = <double>[1, 4, 64, 0, 256];
    const m = _order ~/ 2;
    final t = _polyval(m, coeff, 0, eps * eps) / coeff[m + 1];
    return (t + eps) / (1 - eps);
  }

  static void _c1f(double eps, List<double> c) {
    const coeff = <double>[
      -1, 6, -16, 32, -9, 64, -128, 2048, 9, -16, 768, 3, -5, 512, //
      -7, 1280, -7, 2048,
    ];
    _series(_nC1, coeff, eps, c);
  }

  static double _a2m1f(double eps) {
    const coeff = <double>[-11, -28, -192, 0, 256];
    const m = _order ~/ 2;
    final t = _polyval(m, coeff, 0, eps * eps) / coeff[m + 1];
    return (t - eps) / (1 + eps);
  }

  static void _c2f(double eps, List<double> c) {
    const coeff = <double>[
      1, 2, 16, 32, 35, 64, 384, 2048, 15, 80, 768, 7, 35, 512, //
      63, 1280, 77, 2048,
    ];
    _series(_nC2, coeff, eps, c);
  }

  static void _series(int n, List<double> coeff, double eps, List<double> c) {
    final eps2 = eps * eps;
    var d = eps;
    var o = 0;
    for (var l = 1; l <= n; l++) {
      final m = (n - l) ~/ 2;
      c[l] = d * _polyval(m, coeff, o, eps2) / coeff[o + m + 1];
      o += m + 2;
      d *= eps;
    }
  }

  static double _sinCosSeries(
    bool sinp,
    double sinx,
    double cosx,
    List<double> c,
  ) {
    var k = c.length;
    var n = k - (sinp ? 1 : 0);
    final ar = 2 * (cosx - sinx) * (cosx + sinx);
    var y1 = 0.0;
    double y0;
    if (n.isOdd) {
      y0 = c[--k];
    } else {
      y0 = 0;
    }
    n ~/= 2;
    while (n-- > 0) {
      y1 = ar * y0 - y1 + c[--k];
      y0 = ar * y1 - y0 + c[--k];
    }
    return sinp ? 2 * sinx * cosx * y0 : cosx * (y0 - y1);
  }

  static double _astroid(double x, double y) {
    final p = x * x;
    final q = y * y;
    final r = (p + q - 1) / 6;
    if (q == 0 && r <= 0) return 0;
    final s = p * q / 4;
    final r2 = r * r;
    final r3 = r * r2;
    final disc = s * (s + 2 * r3);
    var u = r;
    if (disc >= 0) {
      var t3 = s + r3;
      t3 += t3 < 0 ? -math.sqrt(disc) : math.sqrt(disc);
      final t = _cbrt(t3);
      u += t + (t != 0 ? r2 / t : 0);
    } else {
      final ang = math.atan2(math.sqrt(-disc), -(s + r3));
      u += 2 * r * math.cos(ang / 3);
    }
    final v = math.sqrt(u * u + q);
    final uv = u < 0 ? q / (v - u) : u + v;
    final w = (uv - q) / (2 * v);
    return uv / (math.sqrt(uv + w * w) + w);
  }

  static double _polyval(int n, List<double> p, int s, double x) {
    var y = n < 0 ? 0.0 : p[s];
    var i = s;
    for (var k = n; k > 0; k--) {
      y = y * x + p[++i];
    }
    return y;
  }

  static double _copysign(double magnitude, double sign) {
    final m = magnitude.abs();
    return (sign.isNegative) ? -m : m;
  }

  static double _hypot(double x, double y) => math.sqrt(x * x + y * y);

  static double _cbrt(double x) =>
      _copysign(math.pow(x.abs(), 1 / 3.0).toDouble(), x);

  static (double, double) _norm(double x, double y) {
    final r = _hypot(x, y);
    return (x / r, y / r);
  }

  static double _radians(double deg) => deg * math.pi / 180;

  static double _angRound(double x) {
    const z = 1 / 16.0;
    var y = x.abs();
    if (y < z) y = z - (z - y);
    return _copysign(y, x);
  }

  static double _latFix(double x) => x.abs() > 90 ? double.nan : x;

  /// IEEE 754 remainder of [x] / [y] in `[-y/2, y/2]` (exact).
  static double _remainder(double x, double y) {
    if (!x.isFinite) return double.nan;
    var r = x.remainder(y);
    if (r.abs() > y / 2) r -= _copysign(y, r);
    return r;
  }

  static (double, double) _sum(double u, double v) {
    final s = u + v;
    var up = s - v;
    var vpp = s - up;
    up -= u;
    vpp -= v;
    final t = s == 0 ? s : 0.0 - (up + vpp);
    return (s, t);
  }

  static (double, double) _angDiff(double x, double y) {
    var (d, t) = _sum(_remainder(-x, 360), _remainder(y, 360));
    (d, t) = _sum(_remainder(d, 360), t);
    if (d == 0 || d.abs() == 180) {
      d = _copysign(d, t == 0 ? y - x : -t);
    }
    return (d, t);
  }

  static int _roundHalfEven(double x) {
    final r = x.roundToDouble();
    if ((r - x).abs() == 0.5 && r.toInt().isOdd) {
      return (r - _copysign(1, x)).toInt();
    }
    return r.toInt();
  }

  static (double, double) _quadrant(int q, double s, double c, double x) {
    var (sn, cs) = switch (q % 4) {
      1 => (c, -s),
      2 => (-s, -c),
      3 => (-c, s),
      _ => (s, c),
    };
    cs = cs + 0.0;
    if (sn == 0) sn = _copysign(sn, x);
    return (sn, cs);
  }

  static (double, double) _sincosd(double x) {
    var r = x.isFinite ? x.remainder(360) : double.nan;
    final q = r.isNaN ? 0 : _roundHalfEven(r / 90);
    r = _radians(r - 90 * q);
    return _quadrant(q, math.sin(r), math.cos(r), x);
  }

  static (double, double) _sincosde(double x, double t) {
    final q = x.isFinite ? _roundHalfEven(x / 90) : 0;
    final r = _radians(_angRound(x - 90 * q + t));
    return _quadrant(q, math.sin(r), math.cos(r), x);
  }

  static double _atan2d(double y0, double x0) {
    var x = x0;
    var y = y0;
    var q = 0;
    if (y.abs() > x.abs()) {
      q = 2;
      final t = x;
      x = y;
      y = t;
    }
    if (x < 0) {
      q += 1;
      x = -x;
    }
    final ang = math.atan2(y, x) * 180 / math.pi;
    return switch (q) {
      1 => _copysign(180, y) - ang,
      2 => 90 - ang,
      3 => -90 + ang,
      _ => ang,
    };
  }
}

final class _Lambda12 {
  const new({
    required this.lam12,
    required this.salp2,
    required this.calp2,
    required this.sig12,
    required this.ssig1,
    required this.csig1,
    required this.ssig2,
    required this.csig2,
    required this.eps,
    required this.dlam12,
  });

  final double lam12;
  final double salp2;
  final double calp2;
  final double sig12;
  final double ssig1;
  final double csig1;
  final double ssig2;
  final double csig2;
  final double eps;
  final double dlam12;
}
