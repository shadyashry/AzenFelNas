import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dm_ui/dm_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

Map<String, Object?> _json(Object? v) => switch (v) {
  final Map<String, Object?> m => m,
  _ => throw const FormatException('object expected'),
};

Color _hex(Object? v) => switch (v) {
  final String s when s.length == 7 => Color(
    0xFF000000 | int.parse(s.substring(1), radix: 16),
  ),
  _ => throw FormatException('colour expected: $v'),
};

void main() {
  final tokens = _json(
    jsonDecode(File('tokens/sky.v1.json').readAsStringSync()),
  );

  test('REQ-UX-010 every Appendix G phase in sky.v1.json equals SkyTokens', () {
    final phases = _json(tokens['phases']);
    expect(phases.keys, SkyPhase.values.map((p) => p.name));
    for (final phase in SkyPhase.values) {
      final j = _json(phases[phase.name]);
      final t = SkyTokens.of(phase);
      expect(
        [t.top, t.bottom, t.accent, t.onSurface],
        [j['top'], j['bottom'], j['accent'], j['onSurface']].map(_hex),
        reason: phase.name,
      );
    }
  });

  test('REQ-UX-010 static palettes and scales equal sky.v1.json', () {
    final statics = _json(tokens['static']);
    for (final (name, p) in [
      ('light', StaticPalette.light),
      ('dark', StaticPalette.dark),
    ]) {
      final j = _json(statics[name]);
      expect(
        [p.surface, p.onSurface, p.primary, p.secondary, p.error],
        [
          j['surface'],
          j['onSurface'],
          j['primary'],
          j['secondary'],
          j['error'],
        ].map(_hex),
        reason: name,
      );
    }
    expect(tokens['space'], DmScales.space);
    expect(tokens['radius'], DmScales.radius);
    final type = _json(tokens['type']);
    for (final (name, s) in [
      ('display', DmScales.display),
      ('headline', DmScales.headline),
      ('title', DmScales.title),
      ('body', DmScales.body),
      ('label', DmScales.label),
    ]) {
      expect(type[name], [s.size, s.lineHeight], reason: name);
    }
    expect(tokens['arabicExtraLineHeight'], DmScales.arabicExtraLine);
    final motion = _json(tokens['motion']);
    expect(motion['standardMs'], DmScales.motionStandard.inMilliseconds);
    expect(motion['reducedMs'], DmScales.motionReduced.inMilliseconds);
    expect(motion['skyMinRepaintMs'], DmScales.skyMinRepaint.inMilliseconds);
    expect(
      switch (tokens['onSurfaceCandidates']) {
        final List<Object?> l => l.map(_hex),
        _ => throw const FormatException('list expected'),
      },
      SkyTokens.onSurfaceCandidates,
    );
  });
}
