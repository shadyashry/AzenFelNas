import 'dart:ui';

import 'package:dm_ui/dm_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

void main() {
  group('SkyTheme (ADR-018, §15 D75)', () {
    test('REQ-UX-010 on-surface is the candidate with the higher midpoint '
        'contrast wherever one reaches 4.5:1', () {
      for (final phase in SkyPhase.values) {
        final t = SkyTokens.of(phase);
        final mid = WcagContrast.midpoint(t.top, t.bottom);
        final ratios = {
          for (final c in SkyTokens.onSurfaceCandidates)
            c: WcagContrast.ratio(c, mid),
        };
        final best = ratios.entries.reduce(
          (a, b) => a.value >= b.value ? a : b,
        );
        if (best.value >= WcagContrast.textMinimum) {
          expect(t.onSurface, best.key, reason: phase.name);
        }
      }
    });

    test('REQ-UX-010 only civil dawn and civil dusk need a scrim, and every '
        'phase reaches 4.5:1 text and 3:1 accent through it', () {
      final scrimmed = <SkyPhase>[];
      for (final phase in SkyPhase.values) {
        final sky = SkyTheme.forPhase(phase);
        if (sky.scrimAlpha > 0) scrimmed.add(phase);
        expect(sky.scrimAlpha, lessThanOrEqualTo(0.5), reason: phase.name);
        expect(sky.scrim, isNot(sky.onSurface));
        for (final stop in sky.stops) {
          final under = sky.underText(stop);
          expect(
            WcagContrast.ratio(sky.onSurface, under),
            greaterThanOrEqualTo(WcagContrast.textMinimum),
            reason: phase.name,
          );
          expect(
            WcagContrast.ratio(sky.accent, under),
            greaterThanOrEqualTo(WcagContrast.nonTextMinimum),
            reason: phase.name,
          );
        }
      }
      expect(scrimmed, [SkyPhase.civilDawn, SkyPhase.civilDusk]);
    });

    test('REQ-UX-010 fromSolarState follows the state phase', () {
      const state = SolarState(
        altitudeDeg: -3,
        azimuthDeg: 80,
        rising: true,
        phase: SkyPhase.civilDawn,
        phaseProgress: 0.5,
      );
      expect(SkyTheme.fromSolarState(state).phase, SkyPhase.civilDawn);
    });

    test('REQ-UX-010 WCAG arithmetic matches the reference values', () {
      expect(
        WcagContrast.ratio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21, 1e-9),
      );
      expect(
        WcagContrast.ratio(const Color(0xFF777777), const Color(0xFFFFFFFF)),
        closeTo(4.48, 0.01),
      );
    });

    test(
      'REQ-UX-010 static content roles: text roles 4.5:1, secondary 3:1',
      () {
        for (final p in [StaticPalette.light, StaticPalette.dark]) {
          for (final c in [p.onSurface, p.primary, p.error]) {
            expect(
              WcagContrast.ratio(c, p.surface),
              greaterThanOrEqualTo(WcagContrast.textMinimum),
            );
          }
          expect(
            WcagContrast.ratio(p.secondary, p.surface),
            greaterThanOrEqualTo(WcagContrast.nonTextMinimum),
          );
        }
      },
    );
  });
}
