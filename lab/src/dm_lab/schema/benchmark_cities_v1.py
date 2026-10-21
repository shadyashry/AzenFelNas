# Generated from schemas/benchmark_cities.v1.schema.json by datamodel-code-generator 0.86.0.
# Do not edit: run lab/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6).

from typing import Annotated, Literal

from dm_lab.schema.base import WireModel
from pydantic import ConfigDict, Field, StrictInt, StrictStr


class City(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    city_id: Annotated[StrictStr, Field(alias="cityId", max_length=32, pattern="^[a-z][a-z0-9_]*$")]
    name: Annotated[StrictStr, Field(min_length=1)]
    latitude_deg: Annotated[float, Field(alias="latitudeDeg", ge=-90.0, le=90.0)]
    longitude_deg: Annotated[float, Field(alias="longitudeDeg", ge=-180.0, le=180.0)]
    zone_id: Annotated[
        StrictStr, Field(alias="zoneId", max_length=64, pattern="^[A-Za-z_]+(/[A-Za-z0-9_+-]+)*$")
    ]
    """
    IANA zone of the city.
    """
    country: Annotated[StrictStr, Field(pattern="^[A-Z]{2}$")]
    """
    ISO 3166-1 alpha-2.
    """


class RamadanMonth(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    hijri_year: Annotated[StrictInt, Field(alias="hijriYear", ge=1)]
    first_day: Annotated[StrictStr, Field(alias="firstDay", pattern="^\\d{4}-\\d{2}-\\d{2}$")]
    last_day: Annotated[StrictStr, Field(alias="lastDay", pattern="^\\d{4}-\\d{2}-\\d{2}$")]
    confidence: Literal["CONFIRMED", "EXPECTED"]
    source: Annotated[StrictStr, Field(min_length=1)]


class DateSet(WireModel):
    """
    Appendix H: both solstices, both equinoxes, the 15th of each month, every DST transition ±7 days, Ramadan start/end 1447–1449.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    seasons: list[
        Literal["MARCH_EQUINOX", "JUNE_SOLSTICE", "SEPTEMBER_EQUINOX", "DECEMBER_SOLSTICE"]
    ]
    """
    Season instants; each selects the civil date of the instant in the city's zone.
    """
    day_of_month: Annotated[StrictInt, Field(alias="dayOfMonth", ge=1, le=28)]
    dst_window_days: Annotated[StrictInt, Field(alias="dstWindowDays", ge=0, le=31)]
    """
    Each UTC-offset transition day of the city's zone selects the days from −n to +n around it.
    """
    ramadan: list[RamadanMonth]


class BenchmarkCitiesV1(WireModel):
    """
    The Accuracy Lab benchmark city file lab/benchmarks/cities.v1.json (DESIGN.md Appendix H, §9.4): the cities and the rule that selects their benchmark dates. Civil and astronomical data only; no religious parameter (§0.2 rule 1).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    schema_version: Annotated[Literal[1], Field(alias="schemaVersion")]
    source: Annotated[StrictStr, Field(min_length=1)]
    """
    Where the city list comes from.
    """
    date_set: Annotated[DateSet, Field(alias="dateSet")]
    cities: Annotated[list[City], Field(min_length=1)]
