import 'package:daily_muslim/features/passport/application/measure_sensitivity.dart';
import 'package:daily_muslim/features/passport/domain/calculation_link.dart';
import 'package:daily_muslim/features/passport/domain/import_mismatch.dart';
import 'package:daily_muslim/features/passport/domain/passport_entry.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';

/// The outcome of importing a shared Calculation link.
sealed class ImportOutcome {
  const new();
}

/// Recomputed here to the same ID.
final class ImportMatched extends ImportOutcome {
  /// Creates an [ImportMatched].
  const new(this.entry);

  /// This device's own recomputation.
  final PassportEntry entry;
}

/// Not reproduced here.
final class ImportMismatched extends ImportOutcome {
  /// Creates an [ImportMismatched].
  const new(this.mismatch);

  /// What differs.
  final ImportMismatch mismatch;
}

/// Recomputes a shared link's day on this device and compares IDs (§6.4
/// ¶11, US-09). It never trusts the sender's values: the times shown on a
/// match are this device's own; on a mismatch only the reason and this
/// device's versions are shown.
final class ImportCalculationLink {
  /// The use case over this device's [_tzdb] and [_profiles].
  const new(this._tzdb, this._profiles);

  final PinnedTzDatabase _tzdb;
  final ProfileSet _profiles;

  static const CalculateDay _calculate = CalculateDay();

  /// Imports [inputs] shared as [calculationId], focused on [event]; `null`
  /// when the inputs do not calculate at all.
  ImportOutcome? call(
    String calculationId,
    LinkedInputs inputs, {
    PrayerEvent? event,
  }) {
    ImportMismatch mismatch(MismatchReason reason, {DayResult? day}) =>
        ImportMismatch(
          linkId: calculationId,
          localId: day?.calculationId,
          reason: reason,
          profileId: inputs.profileId,
          profileVersion: inputs.profileVersion,
          engineVersion: EngineVersion.current,
          deltaTModel: day?.provenance.deltaTModel,
          tzdbVersion: _tzdb.version,
        );
    if (!_tzdb.zoneIds.contains(inputs.zoneId)) {
      return ImportMismatched(mismatch(MismatchReason.zoneUnavailable));
    }
    final profile = _profileOf(inputs);
    if (profile == null) {
      return ImportMismatched(mismatch(MismatchReason.profileUnavailable));
    }
    final observer = Observer(
      latitudeDeg: inputs.latitudeDeg,
      longitudeDeg: inputs.longitudeDeg,
      zoneId: inputs.zoneId,
      source: ObserverSource.pinned,
    );
    final result = _calculate(
      observer: observer,
      profile: profile,
      day: inputs.day,
      tzdb: _tzdb,
      hijri: inputs.hijri,
    );
    final DayResult day;
    switch (result) {
      case Err():
        return null;
      case Ok(:final value):
        day = value;
    }
    if (day.calculationId != calculationId) {
      return ImportMismatched(
        mismatch(MismatchReason.differentVersions, day: day),
      );
    }
    return ImportMatched(
      PassportEntry(
        day: day,
        inputs: CalculationInputs.of(
          observer: observer,
          profile: profile,
          day: inputs.day,
          hijri: inputs.hijri,
        ),
        zoneId: inputs.zoneId,
        profile: profile,
        sensitivityMs: MeasureSensitivity(_tzdb)(
          observer: observer,
          profile: profile,
          base: day,
          hijri: inputs.hijri,
        ),
        origin: PassportOrigin.importedMatch,
        focus: event,
      ),
    );
  }

  /// The profile the link names, bound to the reference point at the linked
  /// coordinates when it calculates at authority reference points (the
  /// sender's resolver left exactly that one, ADR-006).
  PrayerProfile? _profileOf(LinkedInputs inputs) {
    for (final profile in _profiles.profiles) {
      if (profile.profileId != inputs.profileId ||
          profile.version != inputs.profileVersion) {
        continue;
      }
      return switch (profile.referenceMode) {
        ReferenceMode.exactCoordinate => profile,
        ReferenceMode.authorityReferencePoint => switch ([
          for (final point in profile.referencePoints)
            if (CalculationInputs.round6(point.lat) == inputs.latitudeDeg &&
                CalculationInputs.round6(point.lon) == inputs.longitudeDeg)
              point,
        ]) {
          [final point, ...] => profile.copyWith(referencePoints: [point]),
          [] => profile,
        },
      };
    }
    return null;
  }
}
