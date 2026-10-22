import 'package:dm_ui/dm_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

const List<ConfidenceLabel> _labels = [
  ConfidenceLabel.calculated(),
  ConfidenceLabel.authorityAligned(benchmarkReportId: 'bench-1'),
  ConfidenceLabel.verified(sourceRef: 'src', freshUntilUtcMs: 0),
  ConfidenceLabel.estimated(rangeMinutes: 7),
  ConfidenceLabel.observed(count: 12, lastSeenUtcMs: 0),
  ConfidenceLabel.unknown(reasonCode: 'TZ_UNRESOLVED'),
];

const StatusDetails _full = StatusDetails(
  authorityName: 'Authority',
  sourceName: 'Source',
  date: '2026-10-22',
  reason: 'no time zone',
);

/// Every chip and line of [label] in [locale], with and without details.
List<String> _copies(ConfidenceLabel label, StatusLocale locale) => [
  StatusCopy.chip(label, locale),
  StatusCopy.chip(label, locale, digits: DigitStyle.arabicIndic),
  StatusCopy.line(label, locale),
  StatusCopy.line(label, locale, details: _full),
];

final RegExp _anyDigit = RegExp('[0-9٠-٩۰-۹]');

/// §18.5 "never co-occurs with", per locale.
List<String> _prohibited(ConfidenceLabel label, StatusLocale locale) =>
    switch ((label, locale)) {
      (Calculated(), StatusLocale.en) => ['verified', 'official'],
      (Calculated(), StatusLocale.ar) => ['موثّق', 'موثق', 'رسمي'],
      (Observed(), StatusLocale.en) => ['verified'],
      (Observed(), StatusLocale.ar) => ['موثّق', 'موثق'],
      _ => const [],
    };

void main() {
  group('StatusCopy (§18.5)', () {
    for (final locale in StatusLocale.values) {
      test('REQ-UX-040 ${locale.name} copy avoids every prohibited word', () {
        for (final label in _labels) {
          for (final copy in _copies(label, locale)) {
            for (final word in _prohibited(label, locale)) {
              expect(copy.toLowerCase(), isNot(contains(word)), reason: copy);
            }
          }
        }
      });

      test('REQ-UX-040 ${locale.name} Unknown never shows a number', () {
        const unknown = ConfidenceLabel.unknown(reasonCode: 'X');
        for (final copy in _copies(unknown, locale)) {
          expect(copy, isNot(contains(_anyDigit)), reason: copy);
        }
        expect(
          () => StatusCopy.line(
            unknown,
            locale,
            details: const StatusDetails(reason: 'error 42'),
          ),
          throwsArgumentError,
        );
      });

      test('REQ-UX-001 ${locale.name} Estimated shows its range and Observed '
          'its count', () {
        for (final copy in _copies(_labels[3], locale)) {
          expect(copy, matches(RegExp('±[7٧]')), reason: copy);
        }
        for (final copy in _copies(_labels[4], locale)) {
          expect(copy, matches(RegExp('12|١٢')), reason: copy);
        }
      });

      test('REQ-UX-040 ${locale.name} Expected never says confirmed', () {
        final copy = StatusCopy.expectedHijri(locale);
        expect(copy.toLowerCase(), isNot(contains('confirmed')));
        expect(copy, isNot(contains('مؤكد')));
      });
    }

    test('REQ-UX-040 the §18.5 English lines are exact', () {
      const en = StatusLocale.en;
      expect(
        StatusCopy.line(_labels[0], en),
        'Calculated for your location',
      );
      expect(
        StatusCopy.line(_labels[1], en, details: _full),
        'Matches Authority within 1 min',
      );
      expect(
        StatusCopy.line(_labels[2], en, details: _full),
        'Verified · Source · updated 2026-10-22',
      );
      expect(StatusCopy.line(_labels[3], en), 'Estimated · ±7 min');
      expect(
        StatusCopy.line(_labels[4], en, details: _full),
        'Reported by 12 users · 2026-10-22',
      );
      expect(
        StatusCopy.line(_labels[5], en, details: _full),
        'Not available · no time zone',
      );
    });

    test('REQ-UX-040 Arabic-Indic digits replace every western digit', () {
      expect(DigitStyle.arabicIndic.apply('12:04'), '١٢:٠٤');
      expect(DigitStyle.western.apply('12:04'), '12:04');
    });
  });
}
