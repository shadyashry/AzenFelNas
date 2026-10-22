# Generated from schemas/tz_transition_oracle.v1.schema.json by datamodel-code-generator 0.86.0.
# Do not edit: run data-pipelines/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6).

from typing import Annotated, Literal

from dm_pipelines.schema.base import WireModel
from pydantic import ConfigDict, Field, StrictInt, StrictStr


class Transition(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    utc_ms: Annotated[StrictInt, Field(alias="utcMs")]
    """
    First instant of the new offset.
    """
    offset_before_seconds: Annotated[
        StrictInt, Field(alias="offsetBeforeSeconds", ge=-93600, le=93600)
    ]
    offset_after_seconds: Annotated[
        StrictInt, Field(alias="offsetAfterSeconds", ge=-93600, le=93600)
    ]


class Day(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    day: Annotated[StrictStr, Field(pattern="^\\d{4}-\\d{2}-\\d{2}$")]
    start_of_day_utc_ms: Annotated[StrictInt, Field(alias="startOfDayUtcMs")]
    """
    First instant whose local date is `day`.
    """
    local_hour_utc_ms: Annotated[
        list[StrictInt], Field(alias="localHourUtcMs", max_length=24, min_length=24)
    ]
    """
    UTC instant of local `day` h:00 for h = 0..23, resolved as PEP 495 fold = 0 (overlap: earlier instant; gap: moved forward by the gap).
    """
    hour_offsets_seconds: Annotated[
        list[StrictInt], Field(alias="hourOffsetsSeconds", max_length=24, min_length=24)
    ]
    """
    Offset in effect at localHourUtcMs[h], seconds.
    """


class Zone(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    zone_id: Annotated[
        StrictStr, Field(alias="zoneId", pattern="^[A-Za-z0-9_+-]+(/[A-Za-z0-9_+-]+)*$")
    ]
    offset_at_start_seconds: Annotated[
        StrictInt, Field(alias="offsetAtStartSeconds", ge=-93600, le=93600)
    ]
    """
    Offset at fromYear-01-01T00:00Z.
    """
    transitions: list[Transition]
    days: list[Day]
    """
    Empty when the zone has no transition in the range.
    """


class TzTransitionOracleV1(WireModel):
    """
    Independent reference for the DST transition suite (DESIGN.md §13 S10, §15 D66-D67): for each benchmark-corpus zone, the UTC offset changes in [fromYear-01-01, toYear+1-01-01) and, for every civil day within windowDays of a transition's local date, the conversions CPython zoneinfo computes from the same zic output the tzdata package is encoded from. Written by `dm-pipelines tzdata build`; read by dm_civil_time's tests. Instants are UTC epoch milliseconds; offsets are seconds, local = UTC + offset.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    schema_version: Annotated[Literal[1], Field(alias="schemaVersion")]
    tzdb_version: Annotated[StrictStr, Field(alias="tzdbVersion", pattern="^\\d{4}[a-z]+$")]
    """
    IANA release, e.g. 2026e.
    """
    from_year: Annotated[StrictInt, Field(alias="fromYear", ge=1)]
    to_year: Annotated[StrictInt, Field(alias="toYear", ge=1)]
    window_days: Annotated[StrictInt, Field(alias="windowDays", ge=0, le=31)]
    zones: Annotated[list[Zone], Field(min_length=1)]
