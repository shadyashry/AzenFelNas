import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// How times and status copy are written for the reader: the status-copy
/// locale and the digit style (`digits` setting, §15 D77). Locale changes
/// presentation only (REQ-DOM-040).
@immutable
final class DisplayStyle {
  /// [locale] with [digits].
  const new({required this.locale, required this.digits});

  /// The style for [context] under the `digits` setting.
  factory of(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode == 'ar'
        ? StatusLocale.ar
        : StatusLocale.en;
    final setting = switch (ref.watch(digitsSettingProvider)) {
      AsyncData(:final value) => value,
      _ => DigitsSetting.locale,
    };
    return DisplayStyle(
      locale: locale,
      digits: switch (setting) {
        DigitsSetting.western => DigitStyle.western,
        DigitsSetting.arabicIndic => DigitStyle.arabicIndic,
        DigitsSetting.locale => switch (locale) {
          StatusLocale.ar => DigitStyle.arabicIndic,
          StatusLocale.en => DigitStyle.western,
        },
      },
    );
  }

  /// The status-copy locale.
  final StatusLocale locale;

  /// The digits times are written with.
  final DigitStyle digits;

  /// The localised name of [event].
  static String eventName(AppLocalizations l, PrayerEvent event) =>
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
