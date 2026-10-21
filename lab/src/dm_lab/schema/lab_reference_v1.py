# Generated from schemas/lab_reference.v1.schema.json by datamodel-code-generator 0.86.0.
# Do not edit: run lab/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6).

from typing import Annotated, Literal

from dm_lab.schema.base import WireModel
from pydantic import ConfigDict, Field, RootModel, StrictInt, StrictStr


class EventPRIMARY(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["PRIMARY"]
    event: Literal["SUNRISE", "TRANSIT", "SUNSET"]
    """
    Astronomical event: SUNRISE/SUNSET = Sun's centre at the ADR-003 horizon altitude in the ascending/descending half of the segment; TRANSIT = upper meridian transit.
    """
    reference_utc_ms: Annotated[StrictInt, Field(alias="referenceUtcMs", ge=0)]
    """
    Event instant, truncated to 1 ms.
    """
    tolerance_ms: Annotated[StrictInt, Field(alias="toleranceMs", ge=200, le=60000)]
    """
    ADR-019 clamp(0.001° / |rate|, 0.2 s, 60 s), rounded up to 1 ms.
    """
    rate_deg_per_s: Annotated[float, Field(alias="rateDegPerS")]
    """
    Rate of the event's defining angle at the event: altitude for SUNRISE/SUNSET, local hour angle for TRANSIT (°/s).
    """


class EventNOEVENT(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["NO_EVENT"]
    event: Literal["SUNRISE", "TRANSIT", "SUNSET"]
    """
    Astronomical event: SUNRISE/SUNSET = Sun's centre at the ADR-003 horizon altitude in the ascending/descending half of the segment; TRANSIT = upper meridian transit.
    """
    reason: Literal["POLAR_DAY", "POLAR_NIGHT"]


class CandidatesUtcM(RootModel[StrictInt]):
    root: Annotated[StrictInt, Field(ge=0)]


class EventAMBIGUOUS(WireModel):
    """
    The half segment does not hold exactly one crossing in the event's direction: the reference lists every crossing and picks none (unknown beats invented, §0.2 rule 10).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    kind: Literal["AMBIGUOUS"]
    event: Literal["SUNRISE", "TRANSIT", "SUNSET"]
    """
    Astronomical event: SUNRISE/SUNSET = Sun's centre at the ADR-003 horizon altitude in the ascending/descending half of the segment; TRANSIT = upper meridian transit.
    """
    candidates_utc_ms: Annotated[list[CandidatesUtcM], Field(alias="candidatesUtcMs", min_length=1)]


class LabReferenceDayV1(WireModel):
    """
    One line of the Accuracy Lab reference JSONL (DESIGN.md §9.4, ADR-019): Skyfield + JPL de440s.bsp instants of the astronomical events of one benchmark city on one prayer day (ADR-004 culmination segment), with the ADR-019 time tolerance of each.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    schema_version: Annotated[Literal[1], Field(alias="schemaVersion")]
    case_id: Annotated[
        StrictStr, Field(alias="caseId", pattern="^[a-z][a-z0-9_]*/\\d{4}-\\d{2}-\\d{2}$")
    ]
    """
    <cityId>/<day>.
    """
    city_id: Annotated[StrictStr, Field(alias="cityId", max_length=32, pattern="^[a-z][a-z0-9_]*$")]
    latitude_deg: Annotated[float, Field(alias="latitudeDeg", ge=-90.0, le=90.0)]
    longitude_deg: Annotated[float, Field(alias="longitudeDeg", ge=-180.0, le=180.0)]
    zone_id: Annotated[
        StrictStr, Field(alias="zoneId", max_length=64, pattern="^[A-Za-z_]+(/[A-Za-z0-9_+-]+)*$")
    ]
    day: Annotated[StrictStr, Field(pattern="^\\d{4}-\\d{2}-\\d{2}$")]
    """
    Prayer day: the civil date in zoneId of the upper transit (ADR-004).
    """
    tags: Annotated[
        list[
            Literal[
                "MARCH_EQUINOX",
                "JUNE_SOLSTICE",
                "SEPTEMBER_EQUINOX",
                "DECEMBER_SOLSTICE",
                "DAY_OF_MONTH",
                "DST_WINDOW",
                "RAMADAN_FIRST_DAY",
                "RAMADAN_LAST_DAY",
            ]
        ],
        Field(min_length=1),
    ]
    """
    Why the day is in the Appendix H date set.
    """
    events: Annotated[list[EventPRIMARY | EventNOEVENT | EventAMBIGUOUS], Field(min_length=1)]
