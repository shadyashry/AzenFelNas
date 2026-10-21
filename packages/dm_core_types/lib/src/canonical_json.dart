/// JSON Canonicalization Scheme (RFC 8785), shared by the engine's
/// Calculation ID (§6.4 ¶11, §15 D38) and the TUF-lite signatures of the
/// package client (Appendix C, REQ-DIST-004).
///
/// Supported values: `null`, `bool`, `int`, finite `double`, `String`,
/// `List` of supported values and `Map` with `String` keys. Object members
/// are sorted by their UTF-16 code units; numbers use the ECMAScript form
/// (no `.0` on integral values, `-0` as `0`, exponent beyond 1e21 and below
/// 1e-6); strings escape exactly `"`, `\` and the C0 controls (`\b \f \n \r
/// \t` short forms, the rest as lowercase `\u00xx`). No whitespace. Pure and
/// deterministic.
abstract final class CanonicalJson {
  /// The canonical form of [value].
  ///
  /// Throws [ArgumentError] for an unsupported value, a non-finite number or
  /// a non-`String` key.
  static String encode(Object? value) {
    final out = StringBuffer();
    _write(out, value);
    return out.toString();
  }

  static void _write(StringBuffer out, Object? value) {
    switch (value) {
      case null:
        out.write('null');
      case final bool flag:
        out.write(flag ? 'true' : 'false');
      case final int number:
        out.write(_integer(number));
      case final double number:
        out.write(_number(number));
      case final String text:
        _string(out, text);
      case final List<Object?> items:
        out.write('[');
        for (var i = 0; i < items.length; i++) {
          if (i > 0) out.write(',');
          _write(out, items[i]);
        }
        out.write(']');
      case final Map<Object?, Object?> members:
        _object(out, members);
      default:
        throw ArgumentError.value(value, 'value', 'not a JSON value');
    }
  }

  static void _object(StringBuffer out, Map<Object?, Object?> members) {
    final keys = [
      for (final key in members.keys)
        switch (key) {
          final String name => name,
          _ => throw ArgumentError.value(key, 'key', 'not a string'),
        },
    ]..sort();
    out.write('{');
    for (var i = 0; i < keys.length; i++) {
      if (i > 0) out.write(',');
      _string(out, keys[i]);
      out.write(':');
      _write(out, members[keys[i]]);
    }
    out.write('}');
  }

  /// 2^53 − 1: every integer up to it is exactly one IEEE 754 double.
  static const int _maxSafeInteger = 9007199254740991;

  /// An integer beyond ±(2^53 − 1) is written as the double nearest to it,
  /// as ECMAScript would read it (RFC 8785 §3.2.2.3).
  static String _integer(int value) => value.abs() <= _maxSafeInteger
      ? value.toString()
      : _number(value.toDouble());

  /// Dart's `double.toString` is ECMAScript's shortest round-trip form
  /// (decimal from 1e-6 to 1e21, exponent outside it) except for the `.0`
  /// it appends to integral values, which is dropped; `-0.0` is `0`.
  static String _number(double value) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'not a finite number');
    }
    if (value == 0) return '0';
    final text = value.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  static void _string(StringBuffer out, String text) {
    out.write('"');
    for (final unit in text.codeUnits) {
      switch (unit) {
        case 0x22:
          out.write(r'\"');
        case 0x5C:
          out.write(r'\\');
        case 0x08:
          out.write(r'\b');
        case 0x0C:
          out.write(r'\f');
        case 0x0A:
          out.write(r'\n');
        case 0x0D:
          out.write(r'\r');
        case 0x09:
          out.write(r'\t');
        case < 0x20:
          out.write(r'\u' + unit.toRadixString(16).padLeft(4, '0'));
        default:
          out.writeCharCode(unit);
      }
    }
    out.write('"');
  }
}
