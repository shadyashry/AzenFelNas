# Generated from schemas/polygon_lookup_oracle.v1.schema.json by datamodel-code-generator 0.86.0.
# Do not edit: run data-pipelines/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6).

from typing import Annotated, Literal

from dm_pipelines.schema.base import WireModel
from pydantic import ConfigDict, Field, StrictInt, StrictStr


class Point(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    lon_e6: Annotated[StrictInt, Field(alias="lonE6", ge=-180000000, le=180000000)]
    lat_e6: Annotated[StrictInt, Field(alias="latE6", ge=-90000000, le=90000000)]
    containing: Annotated[StrictStr | None, Field(min_length=1)]
    """
    Name of the source polygon that contains the point; null when none does.
    """
    nearest: Annotated[StrictStr | None, Field(min_length=1)]
    """
    Name of the nearest source polygon when none contains the point and one lies within distanceLimitM; otherwise null.
    """
    nearest_distance_m: Annotated[float | None, Field(alias="nearestDistanceM", ge=0.0)]
    """
    Distance to `nearest`; null exactly when `nearest` is null.
    """
    other_distance_m: Annotated[float | None, Field(alias="otherDistanceM", ge=0.0)]
    """
    Distance to the nearest source polygon whose name differs from containing (or from nearest when nothing contains the point); null when there is none within distanceLimitM or the point has neither.
    """


class Sample(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    name: Literal["sphere", "land"]
    """
    sphere: uniform on the sphere; land: uniform on the sphere, kept only when a source polygon contains the point.
    """
    points: Annotated[list[Point], Field(min_length=1)]


class PolygonLookupOracleV1(WireModel):
    """
    Independent reference for the S11 done-test (DESIGN.md §13 S11, §15 D70-D71): seeded random points and the answers shapely computes on the unsimplified source geometry of a `tz_polygons` or `country_polygons` payload. Written by `dm-pipelines polygons build`; read by dm_civil_time's tests. Coordinates are integer micro-degrees, the same integers the Dart reader is given. Distances are metres in the local equirectangular projection of §15 D71 on a sphere of radius earthRadiusM, and are given only up to distanceLimitM (null beyond).
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    schema_version: Annotated[Literal[1], Field(alias="schemaVersion")]
    dataset: Literal["tz_polygons", "country_polygons"]
    source_version: Annotated[StrictStr, Field(alias="sourceVersion", min_length=1)]
    """
    Release of the source data, e.g. timezone-boundary-builder 2026e or Natural Earth 5.1.2.
    """
    seed: Annotated[StrictInt, Field(ge=0)]
    earth_radius_m: Annotated[float, Field(alias="earthRadiusM", gt=0.0)]
    distance_limit_m: Annotated[float, Field(alias="distanceLimitM", gt=0.0)]
    samples: Annotated[list[Sample], Field(min_length=1)]
    """
    One entry per sampling scheme; names are unique.
    """
