import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RawdahScheme (§15 D89)', () {
    for (final (name, r) in [
      ('pearl', RawdahScheme.light),
      ('Nabawi Night', RawdahScheme.night),
    ]) {
      test('REQ-UX-010 $name text roles meet 4.5:1 on panel, ground and the '
          'row wash', () {
        for (final background in [r.panel, r.ground, r.raised]) {
          for (final text in [
            r.ink,
            r.inkMuted,
            r.caption,
            r.primary,
            r.error,
          ]) {
            expect(
              WcagContrast.ratio(text, background),
              greaterThanOrEqualTo(WcagContrast.textMinimum),
            );
          }
        }
        // The next prayer's name and time sit on the wash.
        expect(
          WcagContrast.ratio(r.primary, r.wash),
          greaterThanOrEqualTo(WcagContrast.textMinimum),
        );
      });

      test('REQ-UX-010 $name gold marks meet 3:1 on the panel', () {
        expect(WcagContrast.ratio(r.accent, r.panel), greaterThanOrEqualTo(3));
      });

      test('REQ-UX-010 $name the selected prayer reads on its tile', () {
        for (final text in [r.ink, r.inkMuted]) {
          expect(
            WcagContrast.ratio(text, r.selection),
            greaterThanOrEqualTo(WcagContrast.textMinimum),
          );
        }
      });
    }

    testWidgets('the theme carries the scheme of its brightness', (
      tester,
    ) async {
      late RawdahScheme light;
      late RawdahScheme dark;
      await tester.pumpWidget(
        MaterialApp(
          theme: DmTheme.of(Brightness.light, StatusLocale.ar),
          home: Builder(
            builder: (context) {
              light = RawdahScheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: DmTheme.of(Brightness.dark, StatusLocale.ar),
          home: Builder(
            builder: (context) {
              dark = RawdahScheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      // MaterialApp animates between themes; read the settled one.
      await tester.pumpAndSettle();
      expect(light.ground, RawdahScheme.light.ground);
      expect(dark.ground, RawdahScheme.night.ground);
      expect(dark.ink, RawdahScheme.night.ink);
    });
  });

  group('Switched on is green (§15 D100)', () {
    for (final brightness in Brightness.values) {
      test('REQ-UX-010 a switch, a box and a segment that are on are green '
          'with ivory on top (${brightness.name})', () {
        final theme = DmTheme.of(brightness, StatusLocale.en);
        final green = theme.extension<RawdahScheme>()!.switchedOn;
        const on = {WidgetState.selected};
        expect(theme.switchTheme.trackColor?.resolve(on), green);
        expect(theme.checkboxTheme.fillColor?.resolve(on), green);
        expect(
          theme.segmentedButtonTheme.style?.backgroundColor?.resolve(on),
          RawdahPalette.enabled,
        );
        expect(
          WcagContrast.ratio(RawdahPalette.ivory, RawdahPalette.enabled),
          greaterThanOrEqualTo(WcagContrast.textMinimum),
        );
      });
    }

    test('REQ-UX-010 the green stands 3:1 off both grounds', () {
      for (final r in [RawdahScheme.light, RawdahScheme.night]) {
        expect(
          WcagContrast.ratio(r.switchedOn, r.panel),
          greaterThanOrEqualTo(3),
        );
      }
    });
  });

  test('the status bar icons read on their ground (§15 D101)', () {
    expect(
      DmTheme.statusBarOn(Brightness.light).statusBarIconBrightness,
      Brightness.dark,
    );
    expect(
      DmTheme.statusBarOn(Brightness.dark).statusBarIconBrightness,
      Brightness.light,
    );
    expect(
      DmTheme.of(
        Brightness.light,
        StatusLocale.en,
      ).appBarTheme.systemOverlayStyle?.statusBarIconBrightness,
      Brightness.dark,
    );
  });

  test('REQ-UX-010 Horizon Dark uses the owner tokens (§15 D119)', () {
    const r = RawdahScheme.night;
    expect(
      [
        r.ground,
        r.panel,
        r.raised,
        r.navBar,
        r.ink,
        r.inkMuted,
        r.caption,
        r.accent,
        r.selection,
        r.hairline,
      ].map((c) => c.toARGB32()),
      [
        0xFF061A15,
        0xFF0C2720,
        0xFF12382D,
        0xFF071F18,
        0xFFF0EDDF,
        0xFFB6C4B8,
        0xFFA3B5A8,
        0xFFD2B373,
        0xFF2D3625,
        0xFF29463B,
      ],
    );
  });
}
