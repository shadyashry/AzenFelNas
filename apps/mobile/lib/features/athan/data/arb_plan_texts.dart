import 'package:daily_muslim/features/athan/domain/plan_text_key.dart';
import 'package:daily_muslim/features/athan/domain/plan_texts.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter/widgets.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// [PlanTexts] from the app's ARB catalogues (§7.11): both `ar` and `en`
/// are rendered whatever the UI locale, so native code can follow
/// `policy.locale` with an `en` fallback (§7.7).
final class ArbPlanTexts implements PlanTexts {
  /// Reads the generated catalogues.
  new()
    : _ar = lookupAppLocalizations(const Locale('ar')),
      _en = lookupAppLocalizations(const Locale('en'));

  final AppLocalizations _ar;
  final AppLocalizations _en;

  @override
  LocalizedText title(PlanTextKey key) => LocalizedText(
    ar: _title(_ar, key),
    en: _title(_en, key),
  );

  @override
  LocalizedText body(PlanTextKey key) =>
      LocalizedText(ar: _body(_ar, key), en: _body(_en, key));

  static String _title(AppLocalizations l, PlanTextKey key) => switch (key) {
    AthanText(:final event) => l.planAthanTitle(_prayer(l, event)),
    ImsakText() => l.planImsakTitle,
    PreReminderText(:final event, :final minutes) => l.planPreReminderTitle(
      _prayer(l, event),
      minutes,
    ),
    HorizonText() => l.planHorizonTitle,
  };

  static String _body(AppLocalizations l, PlanTextKey key) => switch (key) {
    AthanText(:final event) => l.planAthanBody(_prayer(l, event)),
    ImsakText() => l.planImsakBody,
    PreReminderText(:final event, :final minutes) => l.planPreReminderBody(
      _prayer(l, event),
      minutes,
    ),
    HorizonText() => l.planHorizonBody,
  };

  static String _prayer(AppLocalizations l, PrayerEvent event) =>
      switch (event) {
        PrayerEvent.imsak => l.prayerImsak,
        PrayerEvent.fajr => l.prayerFajr,
        PrayerEvent.sunrise => l.prayerSunrise,
        PrayerEvent.dhuhr => l.prayerDhuhr,
        PrayerEvent.asr => l.prayerAsr,
        PrayerEvent.maghrib => l.prayerMaghrib,
        PrayerEvent.isha => l.prayerIsha,
      };
}
