package app.azenfelnas.athan.codes

import kotlinx.serialization.Serializable

/**
 * Failure codes of DESIGN.md Appendix J.
 *
 * Mirrors DESIGN.md Appendix J and `dm_core_types` verbatim (REQ-ERR-002); entry names are the wire names.
 */
@Serializable
internal enum class FailureCode {
    LOC_PERMISSION_DENIED,
    LOC_SERVICES_OFF,
    LOC_UNAVAILABLE,
    LOC_STALE,
    TZ_UNRESOLVED,
    COUNTRY_UNRESOLVED,
    PROFILE_NOT_FOUND,
    PROFILE_OVERLAP,
    PROFILE_INVALID,
    ENGINE_ORDERING,
    ENGINE_UNSUPPORTED_POLICY,
    HIJRI_UNKNOWN_MONTH,
    PKG_SIG_INVALID,
    PKG_HASH_MISMATCH,
    PKG_INCOMPATIBLE,
    PKG_SEQUENCE_REGRESSION,
    PKG_EXPIRED_WARNING,
    PKG_NETWORK,
    PKG_STORAGE,
    PLAN_WRITE_FAILED,
    PLAN_SCHEMA_UNSUPPORTED,
    ALARM_PERMISSION_MISSING,
    ALARM_SCHEDULE_FAILED,
    AUDIO_ASSET_MISSING,
    CLOCK_SKEW,
    DB_MIGRATION_FAILED,
    DIAG_EXPORT_FAILED,
}
