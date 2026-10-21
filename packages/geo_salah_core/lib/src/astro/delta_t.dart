import 'package:meta/meta.dart';

/// ΔT = TT − UT from the Espenak–Meeus (2006) polynomial expressions
/// (ADR-019; recorded in provenance as [modelId]).
///
/// The polynomials take a decimal year `y`. Espenak–Meeus evaluate them at
/// the middle of a month; this model uses the continuous
/// `y = 2000 + (t − 2000-01-01T00:00Z) / 365.2425 d`, so that ΔT, and with it
/// the solar position, has no monthly steps inside a solver bracket
/// (§15 D32). Its only discontinuities are the model's own, at the ends of the
/// polynomial intervals (each ≤ 0.26 s). UT1 − UTC is ignored.
///
/// Pure and deterministic.
@immutable
final class EspenakMeeusDeltaT {
  /// The model.
  const new();

  /// The provenance id of this model (`Provenance.deltaTModel`).
  static const String modelId = 'espenak-meeus-2006';

  static const double _y2000UtcMs = 946684800000;
  static const double _msPerGregorianYear = 365.2425 * 86400000;

  /// ΔT in seconds at [utcMs] (UTC epoch milliseconds).
  double secondsAt(double utcMs) =>
      secondsForYear(2000 + (utcMs - _y2000UtcMs) / _msPerGregorianYear);

  /// ΔT in seconds at decimal year [y].
  double secondsForYear(double y) {
    if (y < -500) return _longTerm(y);
    if (y < 500) {
      return _poly(y / 100, const [
        10583.6,
        -1014.41,
        33.78311,
        -5.952053,
        -0.1798452,
        0.022174192,
        0.0090316521,
      ]);
    }
    if (y < 1600) {
      return _poly((y - 1000) / 100, const [
        1574.2,
        -556.01,
        71.23472,
        0.319781,
        -0.8503463,
        -0.005050998,
        0.0083572073,
      ]);
    }
    if (y < 1700) {
      return _poly(y - 1600, const [120, -0.9808, -0.01532, 1 / 7129]);
    }
    if (y < 1800) {
      return _poly(y - 1700, const [
        8.83,
        0.1603,
        -0.0059285,
        0.00013336,
        -1 / 1174000,
      ]);
    }
    if (y < 1860) {
      return _poly(y - 1800, const [
        13.72,
        -0.332447,
        0.0068612,
        0.0041116,
        -0.00037436,
        0.0000121272,
        -0.0000001699,
        0.000000000875,
      ]);
    }
    if (y < 1900) {
      return _poly(y - 1860, const [
        7.62,
        0.5737,
        -0.251754,
        0.01680668,
        -0.0004473624,
        1 / 233174,
      ]);
    }
    if (y < 1920) {
      return _poly(y - 1900, const [
        -2.79,
        1.494119,
        -0.0598939,
        0.0061966,
        -0.000197,
      ]);
    }
    if (y < 1941) {
      return _poly(y - 1920, const [21.20, 0.84493, -0.076100, 0.0020936]);
    }
    if (y < 1961) {
      return _poly(y - 1950, const [29.07, 0.407, -1 / 233, 1 / 2547]);
    }
    if (y < 1986) {
      return _poly(y - 1975, const [45.45, 1.067, -1 / 260, -1 / 718]);
    }
    if (y < 2005) {
      return _poly(y - 2000, const [
        63.86,
        0.3345,
        -0.060374,
        0.0017275,
        0.000651814,
        0.00002373599,
      ]);
    }
    if (y < 2050) {
      return _poly(y - 2000, const [62.92, 0.32217, 0.005589]);
    }
    if (y < 2150) return _longTerm(y) - 0.5628 * (2150 - y);
    return _longTerm(y);
  }

  /// `−20 + 32·u²`, `u = (y − 1820) / 100`.
  static double _longTerm(double y) {
    final u = (y - 1820) / 100;
    return -20 + 32 * u * u;
  }

  /// `c0 + c1·t + c2·t² + …` (Horner).
  static double _poly(double t, List<double> coefficients) {
    var total = 0.0;
    for (var k = coefficients.length - 1; k >= 0; k--) {
      total = total * t + coefficients[k];
    }
    return total;
  }
}
