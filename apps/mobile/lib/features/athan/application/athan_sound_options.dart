import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:meta/meta.dart';

/// Which sounds may play for the Athan and for Fajr, and which play now
/// (§15 D94, D111): the bundled sounds and the downloaded voices, a Fajr
/// voice for Fajr only (REQ-ALM-052).
@immutable
final class AthanSoundOptions {
  /// The options of [bundled] sounds and the [installed] ids of [catalog].
  factory of({
    required List<String> bundled,
    required List<AthanVoice> catalog,
    required Set<String> installed,
  }) {
    final downloaded = [
      for (final v in catalog)
        if (installed.contains(v.soundId)) v,
    ];
    return AthanSoundOptions._(
      athan: [
        ...bundled,
        for (final v in downloaded)
          if (!v.fajrOnly) v.soundId,
      ],
      fajrOnly: [
        for (final v in downloaded)
          if (v.fajrOnly) v.soundId,
      ],
    );
  }

  const new _({required this.athan, required this.fajrOnly});

  /// Sounds on the phone that may play for every prayer.
  final List<String> athan;

  /// Downloaded voices that may play for Fajr only.
  final List<String> fajrOnly;

  /// The Athan sound that plays for the stored choice [chosen].
  String athanSound(String? chosen) =>
      AthanPreferences.effectiveSound(chosen, athan);

  /// The Fajr sound that plays for the stored choices.
  String fajrSound(String? chosenFajr, String? chosenAthan) =>
      AthanPreferences.effectiveFajrSound(chosenFajr, [
        ...athan,
        ...fajrOnly,
      ], athan: athanSound(chosenAthan));

  /// Whether the stored [chosen] Athan sound is gone and the device tone
  /// plays instead (REQ-ALM-053).
  bool athanFellBack(String? chosen) =>
      chosen != null && athanSound(chosen) != chosen;

  /// Whether the stored [chosen] Fajr sound is gone and the Athan sound
  /// plays instead (REQ-ALM-053).
  bool fajrFellBack(String? chosen, String? chosenAthan) =>
      chosen != null && fajrSound(chosen, chosenAthan) != chosen;
}
