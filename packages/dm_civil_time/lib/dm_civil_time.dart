/// TzDatabase over the app's pinned TZDB, plus tz and country polygon indexes
/// (DESIGN.md §5.2, ADR-015).
///
/// S10: `ReadTzfDatabase` turns the `tzdata` package payload into a
/// `PinnedTzDatabase`, the engine's `TzDatabase` port (REQ-TIME-020), with
/// local-time derivation for display and day boundaries (§15 D66, D67).
///
/// Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the
/// platform.
library;

export 'package:dm_civil_time/src/tzdb/local_date_time.dart';
export 'package:dm_civil_time/src/tzdb/pinned_tz_database.dart';
export 'package:dm_civil_time/src/tzdb/read_tzf_database.dart';
export 'package:dm_civil_time/src/tzdb/tzdb_failure.dart';
