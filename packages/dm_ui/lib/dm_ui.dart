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
export 'package:dm_ui/src/sky/sky_theme.dart';
export 'package:dm_ui/src/theme/dm_theme.dart';
export 'package:dm_ui/src/tokens/dm_scales.dart';
export 'package:dm_ui/src/tokens/sky_phase_tokens.dart';
export 'package:dm_ui/src/tokens/sky_tokens.dart';
export 'package:dm_ui/src/tokens/static_palette.dart';
