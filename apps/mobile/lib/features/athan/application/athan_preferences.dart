import 'package:daily_muslim/features/athan/domain/pre_reminder.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// The user's Athan choices that shape a plan (US-10, Appendix K): which
/// events alert, the Athan sound, the pre-reminder and the plan locale.
///
/// Nothing here is a religious value (§0.2 rule 1): every field is the
/// user's own choice, and an empty [enabled] set yields a plan that holds
/// only its horizon warning.
@immutable
final class AthanPreferences {
  /// Preferences with [enabled] events alerting with [soundId].
  const new({
    required this.enabled,
    required this.soundId,
    required this.preReminder,
    required this.locale,
  });

  /// The preferences of the stored settings (Appendix K), with the §15 D94
  /// defaults for what the user has not chosen yet:
  /// - [enabled] (`athanEnabled{event: bool}`, keyed by the event's Dart name):
  ///   the five prayers when the user never chose, else the events set true;
  /// - [soundId]: the chosen sound when it is still bundled, else the first
  ///   bundled sound of [sounds], else [deviceAlarmSoundId] (no file, so the
  ///   host plays the device alarm tone, §15 D79);
  /// - [preReminderMinutes]: off unless it is an allowed value.
  factory ofSettings({
    required Map<String, bool> enabled,
    required String? soundId,
    required List<String> sounds,
    required int preReminderMinutes,
    required PlanLocale locale,
  }) => AthanPreferences(
    enabled: enabledOf(enabled),
    soundId: switch (soundId) {
      final String id when sounds.contains(id) => id,
      _ => sounds.isEmpty ? deviceAlarmSoundId : sounds.first,
    },
    preReminder: PreReminder.ofMinutes(preReminderMinutes) ?? PreReminder.off,
    locale: locale,
  );

  /// The events that alert under the stored `athanEnabled` map: the five
  /// prayers until the user chooses, then only the events set true.
  static Set<PrayerEvent> enabledOf(Map<String, bool> stored) => stored.isEmpty
      ? defaultEvents
      : {
          for (final event in PrayerEvent.values)
            if (stored[event.name] ?? false) event,
        };

  /// The `athanEnabled` map to store after the user turns [event] [on]: the
  /// current choice made explicit for every event, with [event] changed, so
  /// turning the last one off stays off (§15 D95).
  static Map<String, bool> toggled(
    Map<String, bool> stored,
    PrayerEvent event, {
    required bool on,
  }) {
    final current = enabledOf(stored);
    return {
      for (final e in PrayerEvent.values)
        e.name: e == event ? on : current.contains(e),
    };
  }

  /// The events that alert until the user chooses: the five prayers.
  static const Set<PrayerEvent> defaultEvents = {
    PrayerEvent.fajr,
    PrayerEvent.dhuhr,
    PrayerEvent.asr,
    PrayerEvent.maghrib,
    PrayerEvent.isha,
  };

  /// The sound id when no sound is bundled: the host finds no file for it
  /// and plays the device alarm tone.
  static const String deviceAlarmSoundId = 'device_alarm';

  /// Events that alert. Fajr…Isha give `ATHAN` entries, Imsak gives an
  /// `IMSAK` entry; Sunrise has no plan kind and is ignored (§15 D80).
  final Set<PrayerEvent> enabled;

  /// Sound of `ATHAN` entries (`^[a-z0-9_]+$`, the audio manifest id).
  final String soundId;

  /// The global pre-reminder (REQ-ALM-042).
  final PreReminder preReminder;

  /// The locale native code renders first (falls back to `en`).
  final PlanLocale locale;
}
