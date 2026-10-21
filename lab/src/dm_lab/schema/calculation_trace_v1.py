# Generated from schemas/calculation_trace.v1.schema.json by datamodel-code-generator 0.86.0.
# Do not edit: run lab/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6).

from typing import Annotated, Literal

from dm_lab.schema.base import WireModel
from pydantic import ConfigDict, Field, StrictInt, StrictStr


class HijriDate(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    year: Annotated[StrictInt, Field(ge=1)]
    month: Annotated[StrictInt, Field(ge=1, le=12)]
    day: Annotated[StrictInt, Field(ge=1, le=30)]


class Hijri(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    date_at_dawn: Annotated[HijriDate, Field(alias="dateAtDawn")]
    date_at_night: Annotated[HijriDate, Field(alias="dateAtNight")]
    confidence: Literal["CONFIRMED", "EXPECTED", "USER_OVERRIDE"]


class Inputs(WireModel):
    """
    Hashed as JCS canonical JSON into provenance.inputsHash; lat/lon rounded to 6 decimals (§6.4 ¶11).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    lat: Annotated[float, Field(ge=-90.0, le=90.0)]
    lon: Annotated[float, Field(ge=-180.0, le=180.0)]
    zone_id: Annotated[
        StrictStr, Field(alias="zoneId", max_length=64, pattern="^[A-Za-z_]+(/[A-Za-z0-9_+-]+)*$")
    ]
    day: Annotated[StrictStr, Field(pattern="^\\d{4}-\\d{2}-\\d{2}$")]
    profile_id: Annotated[
        StrictStr,
        Field(alias="profileId", pattern="^[a-z]{2}\\.[a-z0-9_]+\\.[a-z0-9_]+$|^engine\\.default$"),
    ]
    profile_version: Annotated[
        StrictStr, Field(alias="profileVersion", pattern="^\\d{4}\\.\\d{1,2}\\.\\d+$")
    ]
    hijri: Hijri


class Provenance(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    engine_version: Annotated[
        StrictStr, Field(alias="engineVersion", pattern="^\\d+\\.\\d+\\.\\d+$")
    ]
    delta_t_model: Annotated[StrictStr, Field(alias="deltaTModel", pattern="^[a-z0-9-]+$")]
    profile_id: Annotated[
        StrictStr,
        Field(alias="profileId", pattern="^[a-z]{2}\\.[a-z0-9_]+\\.[a-z0-9_]+$|^engine\\.default$"),
    ]
    profile_version: Annotated[
        StrictStr, Field(alias="profileVersion", pattern="^\\d{4}\\.\\d{1,2}\\.\\d+$")
    ]
    tzdb_version: Annotated[StrictStr, Field(alias="tzdbVersion", pattern="^\\d{4}[a-z]$")]
    inputs_hash: Annotated[StrictStr, Field(alias="inputsHash", pattern="^[a-f0-9]{64}$")]
    hijri_confidence: Annotated[
        Literal["CONFIRMED", "EXPECTED", "USER_OVERRIDE"], Field(alias="hijriConfidence")
    ]


class NearestLatitude(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    lat_deg: Annotated[float, Field(alias="latDeg", ge=40.0, le=60.0)]


class HlMethod1(WireModel):
    """
    Same shape as prayer_profile.v1 highLatitude.chain items.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    nearest_latitude: Annotated[NearestLatitude, Field(alias="nearestLatitude")]


class NearestValidDay(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    max_days: Annotated[StrictInt, Field(alias="maxDays", ge=1, le=60)]


class HlMethod2(WireModel):
    """
    Same shape as prayer_profile.v1 highLatitude.chain items.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    nearest_valid_day: Annotated[NearestValidDay, Field(alias="nearestValidDay")]


class OriginPRIMARY(WireModel):
    """
    EventOrigin (REQ-DOM-002).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["PRIMARY"]


class OriginFALLBACK(WireModel):
    """
    EventOrigin (REQ-DOM-002).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["FALLBACK"]
    method: Literal["anglePortion", "middleOfNight", "seventhOfNight"] | HlMethod1 | HlMethod2
    """
    Same shape as prayer_profile.v1 highLatitude.chain items.
    """


class OriginNOEVENT(WireModel):
    """
    EventOrigin (REQ-DOM-002).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["NO_EVENT"]
    reason: Literal[
        "POLAR_DAY", "POLAR_NIGHT", "TWILIGHT_ABSENT", "ASR_UNDEFINED", "CHAIN_EXHAUSTED"
    ]


class ConfidenceCALCULATED(WireModel):
    """
    ConfidenceLabel (REQ-DOM-010, REQ-DOM-050); Estimated/Observed always carry a range or count (REQ-UX-001).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["CALCULATED"]


class ConfidenceAUTHORITYALIGNED(WireModel):
    """
    ConfidenceLabel (REQ-DOM-010, REQ-DOM-050); Estimated/Observed always carry a range or count (REQ-UX-001).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["AUTHORITY_ALIGNED"]
    benchmark_report_id: Annotated[StrictStr, Field(alias="benchmarkReportId", min_length=1)]


class ConfidenceVERIFIED(WireModel):
    """
    ConfidenceLabel (REQ-DOM-010, REQ-DOM-050); Estimated/Observed always carry a range or count (REQ-UX-001).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["VERIFIED"]
    source_ref: Annotated[StrictStr, Field(alias="sourceRef", min_length=1)]
    fresh_until_utc_ms: Annotated[StrictInt, Field(alias="freshUntilUtcMs", ge=0)]


class ConfidenceESTIMATED(WireModel):
    """
    ConfidenceLabel (REQ-DOM-010, REQ-DOM-050); Estimated/Observed always carry a range or count (REQ-UX-001).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["ESTIMATED"]
    range_minutes: Annotated[StrictInt, Field(alias="rangeMinutes", ge=1)]


class ConfidenceOBSERVED(WireModel):
    """
    ConfidenceLabel (REQ-DOM-010, REQ-DOM-050); Estimated/Observed always carry a range or count (REQ-UX-001).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["OBSERVED"]
    count: Annotated[StrictInt, Field(ge=1)]
    last_seen_utc_ms: Annotated[StrictInt, Field(alias="lastSeenUtcMs", ge=0)]


class ConfidenceUNKNOWN(WireModel):
    """
    ConfidenceLabel (REQ-DOM-010, REQ-DOM-050); Estimated/Observed always carry a range or count (REQ-UX-001).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["UNKNOWN"]
    reason_code: Annotated[StrictStr, Field(alias="reasonCode", pattern="^[A-Z0-9_]+$")]


class AdjustmentStep(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    event: Literal["IMSAK", "FAJR", "SUNRISE", "DHUHR", "ASR", "MAGHRIB", "ISHA"]
    kind: Literal[
        "PER_EVENT_OFFSET", "RAMADAN_RULE_REPLACEMENT", "HIGH_LATITUDE_FALLBACK", "ROUNDING"
    ]
    delta_ms: Annotated[StrictInt, Field(alias="deltaMs")]
    reason: Annotated[StrictStr, Field(min_length=1)]
    evidence_id: Annotated[StrictStr | None, Field(alias="evidenceId", min_length=1)] = None


class Time(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    event: Literal["IMSAK", "FAJR", "SUNRISE", "DHUHR", "ASR", "MAGHRIB", "ISHA"]
    raw_utc_ms: Annotated[StrictInt | None, Field(alias="rawUtcMs", ge=0)] = None
    """
    Truncated to 1 ms (REQ-DOM-004).
    """
    displayed_utc_ms: Annotated[StrictInt | None, Field(alias="displayedUtcMs", ge=0)] = None
    """
    After rounding, applied once and last (REQ-DOM-003).
    """
    day_offset: Annotated[StrictInt | None, Field(alias="dayOffset", ge=-1, le=1)] = None
    origin: OriginPRIMARY | OriginFALLBACK | OriginNOEVENT
    """
    EventOrigin (REQ-DOM-002).
    """
    confidence: (
        ConfidenceCALCULATED
        | ConfidenceAUTHORITYALIGNED
        | ConfidenceVERIFIED
        | ConfidenceESTIMATED
        | ConfidenceOBSERVED
        | ConfidenceUNKNOWN
    )
    """
    ConfidenceLabel (REQ-DOM-010, REQ-DOM-050); Estimated/Observed always carry a range or count (REQ-UX-001).
    """
    flags: list[
        Literal[
            "NEAR_ROUNDING_BOUNDARY",
            "HIGH_LATITUDE_FALLBACK",
            "LOW_LOCATION_ACCURACY",
            "DST_TRANSITION_DAY",
            "STALE_TZDB",
            "HIJRI_EXPECTED",
            "REFERENCE_MODE_AUTHORITY_POINT",
            "MANUAL_COORDINATE_RESOLUTION",
            "ZONE_BOUNDARY_PROXIMITY",
            "NO_LOCAL_PROFILE",
        ]
    ]
    adjustment_trace: Annotated[list[AdjustmentStep], Field(alias="adjustmentTrace")]


class CalculationTraceV1(WireModel):
    """
    Serialised DayResult + Provenance with per-event detail and the inputs object of §6.4 ¶11; used by the Passport renderer, the deep-link import and lab discrepancy reports (DESIGN.md Appendix M). Provenance's adjustment trace is carried per event (times[].adjustmentTrace).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    schema_version: Annotated[Literal[1], Field(alias="schemaVersion")]
    calculation_id: Annotated[StrictStr, Field(alias="calculationId", pattern="^GS-[A-Z2-7]{16}$")]
    """
    'GS-' + RFC 4648 base32 (upper, no padding) of the first 10 bytes of sha256(inputsHash|engineVersion|deltaTModel|tzdbVersion) (§6.4 ¶11).
    """
    day: Annotated[StrictStr, Field(pattern="^\\d{4}-\\d{2}-\\d{2}$")]
    inputs: Inputs
    provenance: Provenance
    times: Annotated[list[Time], Field(min_length=1)]
