import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import 'support/home_sample.dart';

/// S15 done-test (§13): contrast ≥ 4.5:1 for 10 phases × 2 modes × 2
/// directions, measured on the rendered text colours, with one golden image
/// per combination.
void main() {
  Color textColour(WidgetTester tester, Finder paragraph) {
    final span = tester.renderObject<RenderParagraph>(paragraph).text;
    return span.style?.color ?? const Color(0xFF000000);
  }

  for (final phase in SkyPhase.values) {
    for (final brightness in Brightness.values) {
      for (final direction in TextDirection.values) {
        final name = '${phase.name}_${brightness.name}_${direction.name}';
        testWidgets('REQ-UX-010 REQ-UX-030 $name meets 4.5:1', (tester) async {
          tester.view.physicalSize = const Size(360, 420);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            HomeSample(
              phase: phase,
              brightness: brightness,
              direction: direction,
            ),
          );
          final sky = SkyTheme.forPhase(phase);
          final header = find.descendant(
            of: find.descendant(
              of: find.byType(SkyHeader),
              matching: find.byType(Text),
            ),
            matching: find.byType(RichText),
          );
          expect(header, findsNWidgets(2));
          for (final e in header.evaluate()) {
            final colour = textColour(tester, find.byWidget(e.widget));
            expect(colour, sky.onSurface);
          }
          final icon = tester.widget<Icon>(
            find.descendant(
              of: find.byType(SkyHeader),
              matching: find.byType(Icon),
            ),
          );
          expect(icon.color, sky.accent);
          expect(
            sky.minTextContrast,
            greaterThanOrEqualTo(WcagContrast.textMinimum),
          );
          final surface = Theme.of(
            tester.element(find.byType(Scaffold)),
          ).scaffoldBackgroundColor;
          final rows = find.descendant(
            of: find.descendant(
              of: find.byType(TimeRow),
              matching: find.byType(Text),
            ),
            matching: find.byType(RichText),
          );
          expect(rows, findsNWidgets(6));
          for (final e in rows.evaluate()) {
            final colour = textColour(tester, find.byWidget(e.widget));
            expect(
              WcagContrast.ratio(colour, surface),
              greaterThanOrEqualTo(WcagContrast.textMinimum),
            );
          }
          expect(
            Directionality.of(tester.element(find.byType(TimeRow).first)),
            direction,
          );
          await expectLater(
            find.byType(Scaffold),
            matchesGoldenFile('goldens/$name.png'),
          );
        });
      }
    }
  }
}
