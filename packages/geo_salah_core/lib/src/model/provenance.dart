import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/model/adjustment_step.dart';
import 'package:geo_salah_core/src/model/hijri_confidence.dart';

part 'provenance.freezed.dart';

/// Everything that identifies how a day was calculated (§6.2). Equal
/// `(inputsHash, engineVersion, deltaTModel, tzdbVersion)` give equal raw
/// instants (REQ-DOM-004) and the same Calculation ID (§6.4 ¶11).
@freezed
abstract class Provenance with _$Provenance {
  /// Creates a [Provenance].
  const factory({
    /// Engine version, `MAJOR.MINOR.PATCH`.
    required String engineVersion,

    /// ΔT model id, e.g. `espenak-meeus-2006` (ADR-019).
    required String deltaTModel,

    /// Prayer profile id.
    required String profileId,

    /// Prayer profile version.
    required String profileVersion,

    /// Version of the TZDB the local dates were derived with (REQ-TIME-020).
    required String tzdbVersion,

    /// Lowercase hex SHA-256 of the canonical calculation inputs.
    required String inputsHash,

    /// How the day's Hijri dates were obtained.
    required HijriConfidence hijriConfidence,

    /// Adjustments applied after the rules, in order.
    required List<AdjustmentStep> adjustmentTrace,
  }) = _Provenance;
}
