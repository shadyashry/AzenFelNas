/// Parses and validates prayer profiles and resolves point + date to a profile
/// (DESIGN.md §6.5, ADR-007).
///
/// Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the
/// platform. Holds the `prayer_profile.v1` wire model since S02; parsing,
/// validation and the resolver arrive in S07.
library;

export 'package:geo_salah_profiles/src/document/accuracy_approval_document.dart';
export 'package:geo_salah_profiles/src/document/adjustments_document.dart';
export 'package:geo_salah_profiles/src/document/approvals_document.dart';
export 'package:geo_salah_profiles/src/document/authority_document.dart';
export 'package:geo_salah_profiles/src/document/authority_type_code.dart';
export 'package:geo_salah_profiles/src/document/compatibility_document.dart';
export 'package:geo_salah_profiles/src/document/elevation_policy_code.dart';
export 'package:geo_salah_profiles/src/document/evidence_document.dart';
export 'package:geo_salah_profiles/src/document/evidence_source_document.dart';
export 'package:geo_salah_profiles/src/document/high_latitude_document.dart';
export 'package:geo_salah_profiles/src/document/horizon_document.dart';
export 'package:geo_salah_profiles/src/document/interval_base_code.dart';
export 'package:geo_salah_profiles/src/document/prayer_profile_document.dart';
export 'package:geo_salah_profiles/src/document/profile_scope_document.dart';
export 'package:geo_salah_profiles/src/document/profile_status_code.dart';
export 'package:geo_salah_profiles/src/document/reference_mode_code.dart';
export 'package:geo_salah_profiles/src/document/reference_point_document.dart';
export 'package:geo_salah_profiles/src/document/religious_approval_document.dart';
export 'package:geo_salah_profiles/src/document/rounding_mode_code.dart';
export 'package:geo_salah_profiles/src/document/rule_document.dart';
export 'package:geo_salah_profiles/src/document/rules_document.dart';
