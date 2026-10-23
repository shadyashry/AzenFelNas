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
