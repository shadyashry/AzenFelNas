"""The pinned inputs of the polygon pipelines: `config/polygons.v1.toml` (§9.5, §15 D70-D71)."""

import tomllib
from pathlib import Path
from typing import Annotated, Literal

from pydantic import BaseModel, ConfigDict, Field, StrictFloat, StrictInt, StrictStr

type Dataset = Literal["tz", "country"]


class _Record(BaseModel):
    model_config = ConfigDict(
        frozen=True, extra="forbid", strict=True, validate_by_name=True, validate_by_alias=True
    )


class SourcePin(_Record):
    """One source release: where its bytes come from, their sha256 and how features are named."""

    version: Annotated[StrictStr, Field(min_length=1)]
    url: Annotated[StrictStr, Field(pattern=r"^https://")]
    sha256: Annotated[StrictStr, Field(pattern=r"^[a-f0-9]{64}$")]
    zip_member: Annotated[StrictStr, Field(alias="zipMember")]
    name_property: Annotated[StrictStr, Field(alias="nameProperty", min_length=1)]
    license: Annotated[StrictStr, Field(min_length=1)]


class BuildSettings(_Record):
    """How the payload is simplified (§9.5)."""

    simplify_tolerance_deg: Annotated[StrictFloat, Field(alias="simplifyToleranceDeg", gt=0)]


class OracleSettings(_Record):
    """The seeded points of the lookup oracle (§13 S11)."""

    seed: Annotated[StrictInt, Field(ge=0)]
    points_per_sample: Annotated[StrictInt, Field(alias="pointsPerSample", ge=1)]
    earth_radius_m: Annotated[StrictFloat, Field(alias="earthRadiusM", gt=0)]
    distance_limit_m: Annotated[StrictFloat, Field(alias="distanceLimitM", gt=0)]


class PolygonsConfig(_Record):
    """The whole pin file."""

    tz: SourcePin
    country: SourcePin
    build: BuildSettings
    oracle: OracleSettings

    def source(self, dataset: Dataset) -> SourcePin:
        """Return the pin of `dataset`."""
        match dataset:
            case "tz":
                return self.tz
            case "country":
                return self.country


def load_polygons_config(path: Path) -> PolygonsConfig:
    """Read and validate the pin file at `path`; raise `ValueError` when it is invalid."""
    with path.open("rb") as stream:
        document = tomllib.load(stream)
    return PolygonsConfig.model_validate(document, by_alias=True)
