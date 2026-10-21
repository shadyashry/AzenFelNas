# Generated from schemas/bench_failure.v1.schema.json by datamodel-code-generator 0.86.0.
# Do not edit: run lab/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6).

from typing import Annotated, Literal

from dm_lab.schema.base import WireModel
from pydantic import ConfigDict, Field, StrictStr


class Failure(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    code: Literal[
        "LOC_PERMISSION_DENIED",
        "LOC_SERVICES_OFF",
        "LOC_UNAVAILABLE",
        "LOC_STALE",
        "TZ_UNRESOLVED",
        "COUNTRY_UNRESOLVED",
        "PROFILE_NOT_FOUND",
        "PROFILE_OVERLAP",
        "PROFILE_INVALID",
        "ENGINE_ORDERING",
        "ENGINE_UNSUPPORTED_POLICY",
        "HIJRI_UNKNOWN_MONTH",
        "PKG_SIG_INVALID",
        "PKG_HASH_MISMATCH",
        "PKG_INCOMPATIBLE",
        "PKG_SEQUENCE_REGRESSION",
        "PKG_EXPIRED_WARNING",
        "PKG_NETWORK",
        "PKG_STORAGE",
        "PLAN_WRITE_FAILED",
        "PLAN_SCHEMA_UNSUPPORTED",
        "ALARM_PERMISSION_MISSING",
        "ALARM_SCHEDULE_FAILED",
        "AUDIO_ASSET_MISSING",
        "CLOCK_SKEW",
        "DB_MIGRATION_FAILED",
        "DIAG_EXPORT_FAILED",
    ]
    """
    Appendix J failure code.
    """
    detail: Annotated[StrictStr | None, Field(min_length=1)] = None
    """
    Human-readable detail, e.g. the EngineFailure payload; never coordinates (REQ-PRIV-001).
    """


class BenchFailureV1(WireModel):
    """
    The stdout line the engine bench writes when a bench_request.v1 line yields a typed failure instead of a DayResult (DESIGN.md §6.1, §6.2 EngineFailure, Appendix J). It answers the request line at the same position.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    schema_version: Annotated[Literal[1], Field(alias="schemaVersion")]
    failure: Failure
