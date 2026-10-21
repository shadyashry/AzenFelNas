import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/model/hijri_confidence.dart';
import 'package:geo_salah_core/src/model/hijri_date.dart';

part 'hijri_state.freezed.dart';

/// The Hijri state of prayer day `D` (§6.2). A Hijri day begins at Maghrib:
/// [dateAtDawn] is `hijri(D)` and governs Imsak/Fajr, [dateAtNight] is
/// `hijri(D + 1)` and governs Isha.
///
/// The engine never derives it; the caller supplies it and it is hashed into
/// the Calculation ID (§6.4 ¶11). Ramadan rule replacement reads it from S08.
@freezed
abstract class HijriState with _$HijriState {
  /// Creates a [HijriState].
  const factory({
    /// Hijri date of `D`.
    required HijriDate dateAtDawn,

    /// Hijri date of `D + 1`.
    required HijriDate dateAtNight,

    /// How the dates were obtained.
    required HijriConfidence confidence,

    /// Version of the `hijri` package the dates came from, when any.
    String? packageVersion,
  }) = _HijriState;
}
