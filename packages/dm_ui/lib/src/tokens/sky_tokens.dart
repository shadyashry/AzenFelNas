import 'dart:ui';

import 'package:dm_ui/src/tokens/sky_phase_tokens.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The sky phase colours of Appendix G, mirrored from
/// `tokens/sky.v1.json` (a sync test keeps the two equal).
abstract final class SkyTokens {
  /// The two on-surface candidates, dark then light (Appendix G).
  static const List<Color> onSurfaceCandidates = [
    Color(0xFF0F1B2D),
    Color(0xFFF3F4F8),
  ];

  /// The tokens of [phase].
  static SkyPhaseTokens of(SkyPhase phase) => switch (phase) {
    SkyPhase.night => const SkyPhaseTokens(
      top: Color(0xFF0B1026),
      bottom: Color(0xFF1B2140),
      accent: Color(0xFFF4D58D),
      onSurface: Color(0xFFF3F4F8),
    ),
    SkyPhase.astronomicalDawn => const SkyPhaseTokens(
      top: Color(0xFF14183A),
      bottom: Color(0xFF3B2A5E),
      accent: Color(0xFFE9B98A),
      onSurface: Color(0xFFF3F4F8),
    ),
    SkyPhase.nauticalDawn => const SkyPhaseTokens(
      top: Color(0xFF3B2A5E),
      bottom: Color(0xFF7A4B7A),
      accent: Color(0xFFFFC9A3),
      onSurface: Color(0xFFF3F4F8),
    ),
    SkyPhase.civilDawn => const SkyPhaseTokens(
      top: Color(0xFF7A4B7A),
      bottom: Color(0xFFE08A6A),
      accent: Color(0xFFFFE3B0),
      onSurface: Color(0xFFF3F4F8),
    ),
    SkyPhase.goldenMorning => const SkyPhaseTokens(
      top: Color(0xFFE08A6A),
      bottom: Color(0xFFF6C177),
      accent: Color(0xFF2B2140),
      onSurface: Color(0xFF0F1B2D),
    ),
    SkyPhase.day => const SkyPhaseTokens(
      top: Color(0xFF5FA8E6),
      bottom: Color(0xFFCFE8FA),
      accent: Color(0xFF1F4F7A),
      onSurface: Color(0xFF0F1B2D),
    ),
    SkyPhase.goldenEvening => const SkyPhaseTokens(
      top: Color(0xFFF2A65A),
      bottom: Color(0xFFE26D5A),
      accent: Color(0xFF2B2140),
      onSurface: Color(0xFF0F1B2D),
    ),
    SkyPhase.civilDusk => const SkyPhaseTokens(
      top: Color(0xFFD96C7A),
      bottom: Color(0xFF6E4A8E),
      accent: Color(0xFFFFE3B0),
      onSurface: Color(0xFFF3F4F8),
    ),
    SkyPhase.nauticalDusk => const SkyPhaseTokens(
      top: Color(0xFF4A3A7A),
      bottom: Color(0xFF262B57),
      accent: Color(0xFFE9B98A),
      onSurface: Color(0xFFF3F4F8),
    ),
    SkyPhase.astronomicalDusk => const SkyPhaseTokens(
      top: Color(0xFF1B2140),
      bottom: Color(0xFF0F1430),
      accent: Color(0xFFF4D58D),
      onSurface: Color(0xFFF3F4F8),
    ),
  };
}
