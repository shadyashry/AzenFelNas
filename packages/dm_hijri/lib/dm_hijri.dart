/// Tabular Hijri calendar, announcements model and HijriState builder
/// (DESIGN.md §5.2, ADR-016).
///
/// Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the
/// platform. Holds the `hijri_package.v1` wire model since S02; since S08 the
/// ADR-016 tabular calendar and the `BuildHijriState` use case that turns a
/// prayer day into the engine's `HijriState` (labelled `expected`).
library;

export 'package:dm_hijri/src/calendar/tabular_hijri_calendar.dart';
export 'package:dm_hijri/src/package/hijri_month_document.dart';
export 'package:dm_hijri/src/package/hijri_month_status_code.dart';
export 'package:dm_hijri/src/package/hijri_package_document.dart';
export 'package:dm_hijri/src/state/build_hijri_state.dart';
