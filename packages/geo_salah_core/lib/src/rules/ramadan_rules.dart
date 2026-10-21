import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/model/engine_failure.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/hijri_state.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';

/// The rules in force on one prayer day and the events whose rule Ramadan
/// replaced.
typedef RamadanSelection = ({
  Map<PrayerEvent, EventRule> rules,
  Set<PrayerEvent> replaced,
});

/// Ramadan rule replacement at the rule step (§6.4 ¶6).
///
/// When the governing flag of the Hijri state is true — `ramadanAtNight`
/// for Isha, `ramadanAtDawn` for Imsak and Fajr — the event's rule in
/// `profile.ramadanRules` **replaces** its rule, or defines it when the profile
/// has none (an Imsak kept for Ramadan, US-07). The rules and the flags are
/// data (profile and Hijri state); nothing religious is decided here (§0.2
/// rule 1). A Ramadan rule for any other event is
/// `EngineFailure.invalidProfile` (the parser refuses it too, §15 D52).
/// Pure and deterministic.
final class RamadanRules {
  /// The step.
  const new();

  /// The rules of [profile] in force on a day with Hijri state [hijri].
  Result<RamadanSelection, EngineFailure> select(
    PrayerProfile profile,
    HijriState hijri,
  ) {
    if (profile.ramadanRules.isEmpty) {
      return Result.ok((rules: profile.rules, replaced: const {}));
    }
    final rules = {...profile.rules};
    final replaced = <PrayerEvent>{};
    for (final MapEntry(key: event, value: rule)
        in profile.ramadanRules.entries) {
      final governs = switch (event) {
        PrayerEvent.imsak || PrayerEvent.fajr => hijri.ramadanAtDawn,
        PrayerEvent.isha => hijri.ramadanAtNight,
        PrayerEvent.sunrise ||
        PrayerEvent.dhuhr ||
        PrayerEvent.asr ||
        PrayerEvent.maghrib => null,
      };
      switch (governs) {
        case null:
          return Result.err(
            EngineFailure.invalidProfile(
              'adjustments.ramadan: no Ramadan rule for ${event.name} '
              '(§6.4 ¶6)',
            ),
          );
        case true:
          rules[event] = rule;
          replaced.add(event);
        case false:
          continue;
      }
    }
    return Result.ok((
      rules: Map.unmodifiable(rules),
      replaced: Set.unmodifiable(replaced),
    ));
  }
}
