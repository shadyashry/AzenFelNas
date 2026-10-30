import 'dart:io';

import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// [style]'s size, line height and weight as written in §15 D109.
(double, double, int) _spec(TextStyle style) => (
  style.fontSize ?? 0,
  ((style.fontSize ?? 0) * (style.height ?? 0)).roundToDouble(),
  style.fontWeight?.value ?? 0,
);

void main() {
  group('Bundled fonts (§15 D109)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final (family, file, licence) in [
      ('Inter', 'Inter-Variable.ttf', 'OFL-Inter.txt'),
      (
        'Noto Sans Arabic',
        'NotoSansArabic-Variable.ttf',
        'OFL-NotoSansArabic.txt',
      ),
      ('Lora', 'Lora-Variable.ttf', 'OFL-Lora.txt'),
      (
        'Noto Naskh Arabic',
        'NotoNaskhArabic-Variable.ttf',
        'OFL-NotoNaskhArabic.txt',
      ),
    ]) {
      test('$family ships offline with its licence, declared at the weights '
          'the type scale asks for', () {
        expect(File('fonts/$file').lengthSync(), greaterThan(100000));
        expect(
          File('fonts/$licence').readAsStringSync(),
          contains('SIL OPEN FONT LICENSE'),
        );
        expect(pubspec, contains('- family: $family'));
        for (final weight in [400, 500, 600, 700]) {
          expect(
            pubspec,
            contains('asset: fonts/$file\n          weight: $weight'),
          );
        }
      });
    }
  });

  group('The Horizon type scale (§15 D109)', () {
    test('English: Lora for display, Inter for interface, sizes / line '
        'heights / weights as specified', () {
      final t = DmType.en;
      expect(t.location.fontFamily, DmTheme.displayLatinFamily);
      expect(t.countdown.fontFamily, DmTheme.latinFamily);
      expect(_spec(t.location), (20.0, 28.0, 500));
      expect(_spec(t.nextName), (40.0, 52.0, 600));
      expect(_spec(t.nextTime), (56.0, 66.0, 500));
      expect(_spec(t.nextPeriod), (18.0, 26.0, 500));
      expect(_spec(t.countdown), (17.0, 26.0, 400));
      expect(_spec(t.arcLabel), (13.0, 20.0, 500));
      expect(_spec(t.sectionHeading), (22.0, 30.0, 600));
      expect(_spec(t.rowName), (14.0, 22.0, 500));
      expect(_spec(t.rowTime), (20.0, 28.0, 500));
      expect(_spec(t.rowPeriod), (12.0, 18.0, 500));
      expect(_spec(t.quranLabel), (14.0, 22.0, 500));
      expect(_spec(t.quranTitle), (20.0, 30.0, 600));
      expect(_spec(t.offline), (12.0, 18.0, 400));
      expect(_spec(t.resume), (14.0, 22.0, 600));
      expect(_spec(t.navLabel), (12.0, 18.0, 500));
      expect(_spec(t.supporting), (14.0, 22.0, 400));
    });

    test('Arabic: Noto Naskh Arabic for display, Noto Sans Arabic for '
        'interface, with the taller Arabic line heights', () {
      final t = DmType.ar;
      expect(t.location.fontFamily, DmTheme.naskhFamily);
      expect(t.countdown.fontFamily, DmTheme.arabicFamily);
      expect(_spec(t.location), (22.0, 34.0, 600));
      expect(_spec(t.nextName), (42.0, 63.0, 600));
      expect(_spec(t.nextTime), (60.0, 80.0, 600));
      expect(_spec(t.nextPeriod), (18.0, 28.0, 500));
      expect(_spec(t.countdown), (17.0, 29.0, 400));
      expect(_spec(t.arcLabel), (15.0, 25.0, 500));
      expect(_spec(t.sectionHeading), (24.0, 36.0, 600));
      expect(_spec(t.rowName), (16.0, 27.0, 500));
      expect(_spec(t.rowTime), (22.0, 32.0, 600));
      expect(_spec(t.rowPeriod), (12.0, 21.0, 500));
      expect(_spec(t.quranLabel), (14.0, 24.0, 500));
      expect(_spec(t.quranTitle), (22.0, 35.0, 600));
      expect(_spec(t.offline), (12.0, 21.0, 400));
      expect(_spec(t.resume), (14.0, 24.0, 600));
      expect(_spec(t.navLabel), (12.0, 21.0, 500));
      expect(_spec(t.supporting), (14.0, 24.0, 400));
    });

    for (final t in [DmType.en, DmType.ar]) {
      test('every role draws its weight on the font axis, upright, with no '
          'letter spacing; changing digits are tabular', () {
        for (final style in [
          t.location,
          t.nextName,
          t.nextTime,
          t.nextPeriod,
          t.countdown,
          t.arcLabel,
          t.sectionHeading,
          t.rowName,
          t.rowTime,
          t.rowPeriod,
          t.quranLabel,
          t.quranTitle,
          t.offline,
          t.resume,
          t.navLabel,
          t.supporting,
        ]) {
          expect(style.letterSpacing, 0);
          expect(style.fontStyle, FontStyle.normal);
          expect(style.fontVariations, [
            FontVariation.weight(style.fontWeight!.value.toDouble()),
          ]);
        }
        for (final digits in [t.nextTime, t.rowTime, t.countdown]) {
          expect(
            digits.fontFeatures,
            contains(const FontFeature.tabularFigures()),
          );
        }
      });
    }
  });
}
