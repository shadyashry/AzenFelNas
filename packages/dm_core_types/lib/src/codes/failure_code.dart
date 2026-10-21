/// Failure codes of DESIGN.md Appendix J, carried by every `Failure`.
///
/// Mirrored verbatim in Kotlin and Swift via `dm_contracts` (REQ-ERR-002);
/// [wire] is the stable cross-language name and never changes for a value.
enum FailureCode {
  /// `LOC_PERMISSION_DENIED`.
  locPermissionDenied('LOC_PERMISSION_DENIED'),

  /// `LOC_SERVICES_OFF`.
  locServicesOff('LOC_SERVICES_OFF'),

  /// `LOC_UNAVAILABLE`.
  locUnavailable('LOC_UNAVAILABLE'),

  /// `LOC_STALE`.
  locStale('LOC_STALE'),

  /// `TZ_UNRESOLVED`.
  tzUnresolved('TZ_UNRESOLVED'),

  /// `COUNTRY_UNRESOLVED`.
  countryUnresolved('COUNTRY_UNRESOLVED'),

  /// `PROFILE_NOT_FOUND`.
  profileNotFound('PROFILE_NOT_FOUND'),

  /// `PROFILE_OVERLAP`.
  profileOverlap('PROFILE_OVERLAP'),

  /// `PROFILE_INVALID`.
  profileInvalid('PROFILE_INVALID'),

  /// `ENGINE_ORDERING`.
  engineOrdering('ENGINE_ORDERING'),

  /// `ENGINE_UNSUPPORTED_POLICY`.
  engineUnsupportedPolicy('ENGINE_UNSUPPORTED_POLICY'),

  /// `HIJRI_UNKNOWN_MONTH`.
  hijriUnknownMonth('HIJRI_UNKNOWN_MONTH'),

  /// `PKG_SIG_INVALID`.
  pkgSigInvalid('PKG_SIG_INVALID'),

  /// `PKG_HASH_MISMATCH`.
  pkgHashMismatch('PKG_HASH_MISMATCH'),

  /// `PKG_INCOMPATIBLE`.
  pkgIncompatible('PKG_INCOMPATIBLE'),

  /// `PKG_SEQUENCE_REGRESSION`.
  pkgSequenceRegression('PKG_SEQUENCE_REGRESSION'),

  /// `PKG_EXPIRED_WARNING`.
  pkgExpiredWarning('PKG_EXPIRED_WARNING'),

  /// `PKG_NETWORK`.
  pkgNetwork('PKG_NETWORK'),

  /// `PKG_STORAGE`.
  pkgStorage('PKG_STORAGE'),

  /// `PLAN_WRITE_FAILED`.
  planWriteFailed('PLAN_WRITE_FAILED'),

  /// `PLAN_SCHEMA_UNSUPPORTED`.
  planSchemaUnsupported('PLAN_SCHEMA_UNSUPPORTED'),

  /// `ALARM_PERMISSION_MISSING`.
  alarmPermissionMissing('ALARM_PERMISSION_MISSING'),

  /// `ALARM_SCHEDULE_FAILED`.
  alarmScheduleFailed('ALARM_SCHEDULE_FAILED'),

  /// `AUDIO_ASSET_MISSING`.
  audioAssetMissing('AUDIO_ASSET_MISSING'),

  /// `CLOCK_SKEW`.
  clockSkew('CLOCK_SKEW'),

  /// `DB_MIGRATION_FAILED`.
  dbMigrationFailed('DB_MIGRATION_FAILED'),

  /// `DIAG_EXPORT_FAILED`.
  diagExportFailed('DIAG_EXPORT_FAILED');

  new(this.wire);

  /// The cross-language name from DESIGN.md Appendix J.
  final String wire;

  /// The code whose [wire] name is [wire], or `null` if none is.
  static FailureCode? fromWire(String wire) => _byWire[wire];

  static final Map<String, FailureCode> _byWire = {
    for (final code in values) code.wire: code,
  };
}
