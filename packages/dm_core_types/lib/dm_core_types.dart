/// Types shared by every Azen Fel Nas package (DESIGN.md §5.2, §6.2):
/// `Result`, `Failure`, `Clock`, `CivilDate`, the RFC 8785 `CanonicalJson`
/// and the Appendix J `FailureCode` and `EventCode` enums.
///
/// Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the
/// platform. Every API here is deterministic except `SystemClock`, which
/// reads the device clock and is the only place allowed to.
library;

export 'package:dm_core_types/src/canonical_json.dart';
export 'package:dm_core_types/src/civil_date.dart';
export 'package:dm_core_types/src/clock.dart';
export 'package:dm_core_types/src/codes/event_code.dart';
export 'package:dm_core_types/src/codes/failure_code.dart';
export 'package:dm_core_types/src/failure.dart';
export 'package:dm_core_types/src/fixed_clock.dart';
export 'package:dm_core_types/src/result.dart';
export 'package:dm_core_types/src/system_clock.dart';
