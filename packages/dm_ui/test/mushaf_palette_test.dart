import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MushafPalette (§15 D123)', () {
    for (final (name, p) in [
      ('light', MushafPalette.light),
      ('deep green', MushafPalette.dark),
    ]) {
      test('REQ-UX-010 $name Quran ink stands at least 7:1 on the surface', () {
        expect(WcagContrast.ratio(p.ink, p.surface), greaterThanOrEqualTo(7));
      });

      test('REQ-UX-010 $name interface text meets 4.5:1 on the surface and '
          'the bars', () {
        for (final (text, background) in [
          (p.text, p.surface),
          (p.textMuted, p.surface),
          (p.onBar, p.bar),
          (p.onBarMuted, p.bar),
        ]) {
          expect(
            WcagContrast.ratio(text, background),
            greaterThanOrEqualTo(WcagContrast.textMinimum),
          );
        }
      });

      test('REQ-UX-010 $name gold meets 3:1 on the bars', () {
        expect(WcagContrast.ratio(p.gold, p.bar), greaterThanOrEqualTo(3));
      });
    }

    test("the owner's tokens are kept", () {
      expect(MushafPalette.light.surface, const Color(0xFFFBF8EE));
      expect(MushafPalette.light.green, const Color(0xFF143F33));
      expect(MushafPalette.light.text, const Color(0xFF25372E));
      expect(MushafPalette.light.textMuted, const Color(0xFF657566));
      expect(MushafPalette.light.gold, const Color(0xFFC3A66B));
      expect(MushafPalette.dark.surface, const Color(0xFF083B2D));
      expect(MushafPalette.dark.bar, const Color(0xFF164A38));
      expect(MushafPalette.dark.text, const Color(0xFFE6DFCF));
      expect(MushafPalette.dark.textMuted, const Color(0xFFBCC7B3));
      expect(MushafPalette.dark.gold, const Color(0xFFBEA36E));
    });

    testWidgets('follows the theme brightness', (tester) async {
      late MushafPalette seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              seen = MushafPalette.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(seen, same(MushafPalette.dark));
    });
  });
}
