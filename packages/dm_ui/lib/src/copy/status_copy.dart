import 'package:dm_ui/src/copy/digit_style.dart';
import 'package:dm_ui/src/copy/status_details.dart';
import 'package:dm_ui/src/copy/status_locale.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The only source of status copy (§18.5, REQ-UX-040): a [ConfidenceLabel]
/// in, a string out. Prohibited-word tests guard every line; nothing else
/// in the app may spell a status.
abstract final class StatusCopy {
  /// The short chip text of [label] (REQ-UX-001: `Estimated` and
  /// `Observed` always carry their range or count).
  static String chip(
    ConfidenceLabel label,
    StatusLocale locale, {
    DigitStyle digits = DigitStyle.western,
  }) => digits.apply(switch ((label, locale)) {
    (Calculated(), StatusLocale.en) => 'Calculated',
    (Calculated(), StatusLocale.ar) => 'محسوب',
    (AuthorityAligned(), StatusLocale.en) => 'Authority aligned',
    (AuthorityAligned(), StatusLocale.ar) => 'متوافق مع الجهة',
    (Verified(), StatusLocale.en) => 'Verified',
    (Verified(), StatusLocale.ar) => 'موثّق',
    (Estimated(:final rangeMinutes), StatusLocale.en) =>
      'Estimated · ±$rangeMinutes min',
    (Estimated(:final rangeMinutes), StatusLocale.ar) =>
      'تقديري · ±$rangeMinutes دقيقة',
    (Observed(:final count), StatusLocale.en) => 'Reported by $count users',
    (Observed(:final count), StatusLocale.ar) => 'ملاحظات المستخدمين · $count',
    (Unknown(), StatusLocale.en) => 'Not available',
    (Unknown(), StatusLocale.ar) => 'غير متاح',
  });

  /// The full status line of [label] (§18.5), with [details] filled in.
  ///
  /// Throws [ArgumentError] when an `Unknown` reason contains a digit
  /// ("Unknown" never co-occurs with a number).
  static String line(
    ConfidenceLabel label,
    StatusLocale locale, {
    StatusDetails details = const StatusDetails(),
    DigitStyle digits = DigitStyle.western,
  }) {
    if (label is Unknown && (details.reason?.contains(_digit) ?? false)) {
      throw ArgumentError.value(details.reason, 'reason', 'has a digit');
    }
    final parts = switch ((label, locale)) {
      (Calculated(), StatusLocale.en) => ['Calculated for your location'],
      (Calculated(), StatusLocale.ar) => ['محسوب لموقعك'],
      (AuthorityAligned(), _) when details.authorityName == null => [
        chip(label, locale),
      ],
      (AuthorityAligned(), StatusLocale.en) => [
        'Matches ${details.authorityName} within 1 min',
      ],
      (AuthorityAligned(), StatusLocale.ar) => [
        'متوافق مع ${details.authorityName}',
      ],
      (Verified(), _) => [
        chip(label, locale),
        ?details.sourceName,
        if (details.date case final d?)
          switch (locale) {
            StatusLocale.en => 'updated $d',
            StatusLocale.ar => 'حُدّث $d',
          },
      ],
      (Observed(), _) => [chip(label, locale), ?details.date],
      (Estimated(), _) => [chip(label, locale)],
      (Unknown(), _) => [chip(label, locale), ?details.reason],
    };
    return digits.apply(parts.join(' · '));
  }

  /// "Expected — not yet announced" for a Hijri date (§18.5).
  static String expectedHijri(StatusLocale locale) => switch (locale) {
    StatusLocale.en => 'Expected — not yet announced',
    StatusLocale.ar => 'متوقع — لم يُعلن بعد',
  };

  static final RegExp _digit = RegExp('[0-9٠-٩۰-۹]');
}
