import 'package:freezed_annotation/freezed_annotation.dart';

part 'hijri_date.freezed.dart';

/// A Hijri calendar date (§6.2). Produced by `dm_hijri`; the engine only
/// carries it into the calculation inputs.
@freezed
abstract class HijriDate with _$HijriDate {
  /// Creates a [HijriDate].
  const factory({
    /// Hijri year, ≥ 1.
    required int year,

    /// Month, 1–12.
    required int month,

    /// Day of month, 1–30.
    required int day,
  }) = _HijriDate;
}
