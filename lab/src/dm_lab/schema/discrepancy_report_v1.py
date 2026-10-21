# Generated from schemas/discrepancy_report.v1.schema.json by datamodel-code-generator 0.86.0.
# Do not edit: run lab/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6).

from typing import Annotated, Literal

from dm_lab.schema.base import WireModel
from pydantic import ConfigDict, Field, StrictInt, StrictStr


class Summary(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    cases: Annotated[StrictInt, Field(ge=0)]
    failed_cases: Annotated[StrictInt, Field(alias="failedCases", ge=0)]
    """
    Cases the engine answered with bench_failure.v1.
    """
    compared_events: Annotated[StrictInt, Field(alias="comparedEvents", ge=0)]
    agreed: Annotated[StrictInt, Field(ge=0)]
    """
    Compared events within tolerance, or without an instant on both sides for the same reason.
    """
    discrepancies: Annotated[StrictInt, Field(ge=0)]
    blocking: Annotated[StrictInt, Field(ge=0)]
    """
    Discrepancies classified UNKNOWN plus failed cases; non-zero blocks promotion (§6.7).
    """
    max_abs_delta_ms: Annotated[StrictInt, Field(alias="maxAbsDeltaMs", ge=0)]
    """
    Largest |residual| = |engineRawUtcMs − referenceUtcMs − expected Dhuhr offset| over PRIMARY reference events the engine answered with a PRIMARY instant.
    """


class Failure(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    case_id: Annotated[
        StrictStr, Field(alias="caseId", pattern="^[a-z][a-z0-9_]*/\\d{4}-\\d{2}-\\d{2}$")
    ]
    code: Annotated[StrictStr, Field(pattern="^[A-Z][A-Z0-9_]*$")]
    """
    bench_failure.v1 failure.code.
    """
    detail: Annotated[StrictStr | None, Field(min_length=1)] = None


class Discrepancy(WireModel):
    """
    §6.7 discrepancy fields. referenceUtcMs / engineRawUtcMs / deltaMs are absent when that side has no instant; decision, owner and linkedChange are written at triage.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    case_id: Annotated[
        StrictStr, Field(alias="caseId", pattern="^[a-z][a-z0-9_]*/\\d{4}-\\d{2}-\\d{2}$")
    ]
    city: Annotated[StrictStr, Field(pattern="^[a-z][a-z0-9_]*$")]
    lat: Annotated[float, Field(ge=-90.0, le=90.0)]
    lon: Annotated[float, Field(ge=-180.0, le=180.0)]
    day: Annotated[StrictStr, Field(pattern="^\\d{4}-\\d{2}-\\d{2}$")]
    event: Literal["IMSAK", "FAJR", "SUNRISE", "DHUHR", "ASR", "MAGHRIB", "ISHA"]
    engine_version: Annotated[
        StrictStr, Field(alias="engineVersion", pattern="^\\d+\\.\\d+\\.\\d+$")
    ]
    profile_id: Annotated[
        StrictStr,
        Field(alias="profileId", pattern="^[a-z]{2}\\.[a-z0-9_]+\\.[a-z0-9_]+$|^engine\\.default$"),
    ]
    profile_version: Annotated[
        StrictStr, Field(alias="profileVersion", pattern="^\\d{4}\\.\\d{1,2}\\.\\d+$")
    ]
    tzdb_version: Annotated[StrictStr, Field(alias="tzdbVersion", pattern="^\\d{4}[a-z]$")]
    reference_utc_ms: Annotated[StrictInt | None, Field(alias="referenceUtcMs", ge=0)] = None
    engine_raw_utc_ms: Annotated[StrictInt | None, Field(alias="engineRawUtcMs", ge=0)] = None
    delta_ms: Annotated[StrictInt | None, Field(alias="deltaMs")] = None
    """
    engineRawUtcMs − referenceUtcMs.
    """
    tolerance_ms: Annotated[StrictInt, Field(alias="toleranceMs", ge=0)]
    check: Literal["INSTANT", "ORIGIN", "DHUHR_OFFSET", "NEAR_TANGENT", "AMBIGUOUS_REFERENCE"]
    """
    INSTANT: residual beyond tolerance; ORIGIN: typed origin or reason differs, or an event is missing; DHUHR_OFFSET: whole-minute Dhuhr offset differs from the expected one; NEAR_TANGENT / AMBIGUOUS_REFERENCE: the reference instant is ill-conditioned or absent (§15 D29).
    """
    classification: Literal[
        "ENGINE_BUG",
        "PROFILE_ERROR",
        "REFERENCE_AMBIGUITY",
        "TOLERANCE_NOISE",
        "CIVIL_TIME",
        "UNKNOWN",
    ]
    decision: Annotated[StrictStr | None, Field(min_length=1)] = None
    owner: Annotated[StrictStr | None, Field(min_length=1)] = None
    linked_change: Annotated[StrictStr | None, Field(alias="linkedChange", min_length=1)] = None


class DiscrepancyReportV1(WireModel):
    """
    Output of `lab benchmark` (DESIGN.md §9.4): the engine's raw instants compared with the lab reference under the ADR-019 tolerance. Entries carry the §6.7 discrepancy fields; an UNKNOWN entry above tolerance blocks promotion.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    schema_version: Annotated[Literal[1], Field(alias="schemaVersion")]
    profile_id: Annotated[
        StrictStr,
        Field(alias="profileId", pattern="^[a-z]{2}\\.[a-z0-9_]+\\.[a-z0-9_]+$|^engine\\.default$"),
    ]
    reference_sha256: Annotated[StrictStr, Field(alias="referenceSha256", pattern="^[a-f0-9]{64}$")]
    """
    sha256 of the reference JSONL compared against.
    """
    summary: Summary
    discrepancies: list[Discrepancy]
    failures: list[Failure]
