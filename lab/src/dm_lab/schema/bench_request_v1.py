# Generated from schemas/bench_request.v1.schema.json by datamodel-code-generator 0.86.0.
# Do not edit: run lab/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6).

from typing import Annotated, Literal

from dm_lab.schema.base import WireModel
from pydantic import ConfigDict, Field, StrictInt, StrictStr


class ElevationSample(WireModel):
    """
    ElevationSample of §6.2; provenance only (ADR-003).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    value_m: Annotated[float, Field(alias="valueM")]
    datum: Literal["WGS84_ELLIPSOID", "EGM2008", "UNKNOWN"]
    source: Literal["GNSS", "MANUAL"]
    vertical_accuracy_m: Annotated[float | None, Field(alias="verticalAccuracyM", ge=0.0)] = None
    dataset_version: Annotated[StrictStr | None, Field(alias="datasetVersion", min_length=1)] = None
    observed_utc_ms: Annotated[StrictInt, Field(alias="observedUtcMs", ge=0)]


class HijriDate(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    year: Annotated[StrictInt, Field(ge=1)]
    month: Annotated[StrictInt, Field(ge=1, le=12)]
    day: Annotated[StrictInt, Field(ge=1, le=30)]


class Hijri(WireModel):
    """
    dateAtDawn = Hijri date of `day` (governs Imsak/Fajr); dateAtNight = Hijri date of the following day (governs Isha), §6.2.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    date_at_dawn: Annotated[HijriDate, Field(alias="dateAtDawn")]
    date_at_night: Annotated[HijriDate, Field(alias="dateAtNight")]
    confidence: Literal["CONFIRMED", "EXPECTED", "USER_OVERRIDE"]


class Observer(WireModel):
    """
    Observer of §6.2.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    latitude_deg: Annotated[float, Field(alias="latitudeDeg", ge=-90.0, le=90.0)]
    longitude_deg: Annotated[float, Field(alias="longitudeDeg", ge=-180.0, le=180.0)]
    horizontal_accuracy_m: Annotated[float | None, Field(alias="horizontalAccuracyM", ge=0.0)] = (
        None
    )
    elevation: ElevationSample | None = None
    zone_id: Annotated[
        StrictStr, Field(alias="zoneId", max_length=64, pattern="^[A-Za-z_]+(/[A-Za-z0-9_+-]+)*$")
    ]
    source: Literal["DEVICE", "PINNED", "MANUAL", "MOSQUE", "BENCHMARK"]


class BenchRequestV1(WireModel):
    """
    One stdin line of the engine bench `dart run geo_salah_core:bench` (DESIGN.md §6.1, §9.4): {observer, profileId, day, hijri}. The bench answers every request line, in order, with exactly one stdout line: a calculation_trace.v1 document or a bench_failure.v1 document (§15 D29).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    schema_version: Annotated[Literal[1], Field(alias="schemaVersion")]
    observer: Observer
    profile_id: Annotated[
        StrictStr,
        Field(alias="profileId", pattern="^[a-z]{2}\\.[a-z0-9_]+\\.[a-z0-9_]+$|^engine\\.default$"),
    ]
    day: Annotated[StrictStr, Field(pattern="^\\d{4}-\\d{2}-\\d{2}$")]
    """
    CivilDate interpreted in observer.zoneId (§6.2).
    """
    hijri: Hijri
    """
    HijriState of §6.2 for `day`, echoed as calculation_trace.v1 inputs.hijri. Until the hijri package exists the lab sends the ADR-016 tabular state with confidence EXPECTED (§15 D29).
    """
