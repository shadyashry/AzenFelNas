import 'dart:io';

import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// [style]'s size, line height and weight as written in §15 D126.
(double, double, int) _spec(TextStyle style) => (
  style.fontSize ?? 0,
  ((style.fontSize ?? 0) * (style.height ?? 0) * 2).roundToDouble() / 2,
  style.fontWeight?.value ?? 0,
);

void main() {
  group('Welcome faces ship offline (§15 D126)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final (family, file, licence, weights) in [
      ('DM Sans', 'DMSans-Variable.ttf', 'OFL-DMSans.txt', [400, 500]),
      ('Gelasio', 'Gelasio-Variable.ttf', 'OFL-Gelasio.txt', [400]),
      ('Amiri', 'Amiri-Regular.ttf', 'OFL-Amiri.txt', [400]),
    ]) {
      test('$family is bundled with its OFL licence at the weights the '
          'welcome screen uses', () {
        expect(File('fonts/$file').lengthSync(), greaterThan(100000));
        expect(
          File('fonts/$licence').readAsStringSync(),
          contains('SIL OPEN FONT LICENSE'),
        );
        expect(FontLicences.files[family], licence);
        expect(pubspec, contains('- family: $family'));
        expect(pubspec, contains('- fonts/$licence'));
        for (final weight in weights) {
          expect(
            pubspec,
            contains('asset: fonts/$file\n          weight: $weight'),
          );
        }
      });
    }
  });

  group('The Emerald horizon type scale (§15 D126)', () {
    test('English: Gelasio headline 32/38.5 at −0.8, heading 22/31; DM Sans '
        'paragraph 15/25.5 and actions 16 medium', () {
      final t = WelcomeType.en;
      expect(t.headline.fontFamily, WelcomeType.serifFamily);
      expect(_spec(t.headline), (32.0, 38.5, 400));
      expect(t.headline.letterSpacing, -0.8);
      expect(_spec(t.heading), (22.0, 31.0, 400));
      expect(t.paragraph.fontFamily, WelcomeType.sansFamily);
      expect(_spec(t.paragraph), (15.0, 25.5, 400));
      expect(t.action.fontSize, 16);
      expect(t.action.fontWeight, FontWeight.w500);
      expect(t.welcome.fontSize, 13);
      expect(t.privacy.fontSize, 12);
    });

    test('compact English: headline 30, actions 15', () {
      final t = WelcomeType.of(StatusLocale.en, compact: true);
      expect(t.headline.fontSize, 30);
      expect(t.action.fontSize, 15);
    });

    test('Arabic: Amiri headline 35/47, Noto Sans Arabic heading 20/32 and '
        'paragraph 15/28.5, never letter-spaced', () {
      final t = WelcomeType.ar;
      expect(t.headline.fontFamily, WelcomeType.arabicDisplayFamily);
      expect(_spec(t.headline), (35.0, 47.0, 400));
      expect(t.heading.fontFamily, DmTheme.arabicFamily);
      expect(_spec(t.heading), (20.0, 32.0, 400));
      expect(_spec(t.paragraph), (15.0, 28.5, 400));
      for (final style in [t.headline, t.heading, t.paragraph, t.action]) {
        expect(style.letterSpacing, 0);
      }
    });

    test('each language name is set in its own script', () {
      expect(
        WelcomeType.languageLabel(StatusLocale.en).fontFamily,
        WelcomeType.sansFamily,
      );
      expect(
        WelcomeType.languageLabel(StatusLocale.ar).fontFamily,
        DmTheme.arabicFamily,
      );
    });
  });
}
