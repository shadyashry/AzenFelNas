import 'package:daily_muslim/features/athan/domain/pre_reminder.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// The user's Athan choices that shape a plan (US-10, Appendix K): which
/// events alert, the Athan sound, the Fajr sound, the pre-reminder and the
/// plan locale.
///
/// Nothing here is a religious value (§0.2 rule 1): every field is the
/// user's own choice, and an empty [enabled] set yields a plan that holds
/// only its horizon warning.
@immutable
final class AthanPreferences {
  /// Preferences with [enabled] events alerting with [soundId], Fajr with
  /// [fajrSoundId].
  const new({
    required this.enabled,
    required this.soundId,
    required this.fajrSoundId,
    required this.preReminder,
    required this.locale,
  });

  /// The preferences of the stored settings (Appendix K), with the §15 D94
  /// defaults for what the user has not chosen yet:
  /// - [enabled] (`athanEnabled{event: bool}`, keyed by the event's Dart name):
  ///   the five prayers when the user never chose, else the events set true;
  /// - [soundId]: the chosen sound while it is on the phone ([sounds]: the
  ///   bundled sounds, then the downloaded standard voices); until the user
  ///   chooses, the first of [sounds]; else [deviceAlarmSoundId] (no file,
  ///   so the host plays the device alarm tone, §15 D79). A chosen sound
  ///   that is gone falls back to the device tone, never to another
  ///   recording, and the Athan page says so (§15 D111, REQ-ALM-053);
  /// - [fajrSoundId]: the chosen Fajr sound while it is on the phone
  ///   ([fajrSounds]: [sounds] and the downloaded Fajr voices), else the
  ///   Athan sound above (REQ-ALM-052);
  /// - [preReminderMinutes]: off unless it is an allowed value.
  factory ofSettings({
    required Map<String, bool> enabled,
    required String? soundId,
    required List<String> sounds,
    required int preReminderMinutes,
    required PlanLocale locale,
    String? fajrSoundId,
    List<String> fajrSounds = const [],
  }) {
    final athan = effectiveSound(soundId, sounds);
    return AthanPreferences(
      enabled: enabledOf(enabled),
      soundId: athan,
      fajrSoundId: effectiveFajrSound(
        fajrSoundId,
        [...sounds, ...fajrSounds],
        athan: athan,
      ),
      preReminder: PreReminder.ofMinutes(preReminderMinutes) ?? PreReminder.off,
      locale: locale,
    );
  }

  /// The Athan sound that plays for the stored [chosen] id when [sounds] are
  /// on the phone (see [AthanPreferences.ofSettings]).
  static String effectiveSound(String? chosen, List<String> sounds) =>
      switch (chosen) {
        null => sounds.firstOrNull ?? deviceAlarmSoundId,
        deviceAlarmSoundId => deviceAlarmSoundId,
        final String id when sounds.contains(id) => id,
        _ => deviceAlarmSoundId,
      };

  /// The Fajr sound that plays for the stored [chosen] id when [sounds] are
  /// on the phone: the chosen one, else the Athan sound [athan].
  static String effectiveFajrSound(
    String? chosen,
    List<String> sounds, {
    required String athan,
  }) => switch (chosen) {
    deviceAlarmSoundId => deviceAlarmSoundId,
    final String id when sounds.contains(id) => id,
    _ => athan,
  };

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

  /// Sound of `ATHAN` entries but Fajr's (`^[a-z0-9_]+$`, the audio
  /// manifest or voice catalog id).
  final String soundId;

  /// Sound of the Fajr `ATHAN` entry.
  final String fajrSoundId;

  /// The global pre-reminder (REQ-ALM-042).
  final PreReminder preReminder;

  /// The locale native code renders first (falls back to `en`).
  final PlanLocale locale;
}
