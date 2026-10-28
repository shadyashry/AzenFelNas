/// Design system: tokens, SkyTheme and RTL-aware components (DESIGN.md §7.9,
/// ADR-018).
///
/// Flutter package. Since S15: the Appendix G tokens (`tokens/sky.v1.json`
/// mirrored in Dart), WCAG contrast arithmetic, `SkyTheme`, the static
/// `DmTheme`, the §18.5 `StatusCopy` and the `ConfidenceChip`, `TimeRow`
/// and `SkyHeader` components. No business logic.
library;

export 'package:dm_ui/src/color/wcag_contrast.dart';
export 'package:dm_ui/src/components/confidence_chip.dart';
export 'package:dm_ui/src/components/sky_header.dart';
export 'package:dm_ui/src/components/time_row.dart';
export 'package:dm_ui/src/copy/digit_style.dart';
export 'package:dm_ui/src/copy/status_copy.dart';
export 'package:dm_ui/src/copy/status_details.dart';
export 'package:dm_ui/src/copy/status_locale.dart';
export 'package:dm_ui/src/rawdah/arch_mark.dart';
export 'package:dm_ui/src/rawdah/arch_position.dart';
export 'package:dm_ui/src/rawdah/athan_ring.dart';
export 'package:dm_ui/src/rawdah/cartouche.dart';
export 'package:dm_ui/src/rawdah/girih_backdrop.dart';
export 'package:dm_ui/src/rawdah/gold_divider.dart';
export 'package:dm_ui/src/rawdah/medallion_tone.dart';
export 'package:dm_ui/src/rawdah/mihrab_arch.dart';
export 'package:dm_ui/src/rawdah/moon_phase.dart';
export 'package:dm_ui/src/rawdah/ornament_paths.dart';
export 'package:dm_ui/src/rawdah/qibla_dial.dart';
export 'package:dm_ui/src/rawdah/rawdah_glyph.dart';
export 'package:dm_ui/src/rawdah/rawdah_glyph_kind.dart';
export 'package:dm_ui/src/rawdah/rawdah_nav_bar.dart';
export 'package:dm_ui/src/rawdah/rawdah_section.dart';
export 'package:dm_ui/src/rawdah/rawdah_tab.dart';
export 'package:dm_ui/src/rawdah/rawdah_tab_labels.dart';
export 'package:dm_ui/src/rawdah/readiness_medallion.dart';
export 'package:dm_ui/src/sky/sky_theme.dart';
export 'package:dm_ui/src/theme/dm_theme.dart';
export 'package:dm_ui/src/tokens/dm_scales.dart';
export 'package:dm_ui/src/tokens/hour_light.dart';
export 'package:dm_ui/src/tokens/rawdah_palette.dart';
export 'package:dm_ui/src/tokens/sky_phase_tokens.dart';
export 'package:dm_ui/src/tokens/sky_tokens.dart';
export 'package:dm_ui/src/tokens/static_palette.dart';
