# Generated from schemas/gazetteer_package.v1.schema.json by datamodel-code-generator 0.86.0.
# Do not edit: run data-pipelines/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6).

from typing import Annotated

from dm_pipelines.schema.base import WireModel
from pydantic import ConfigDict, Field, RootModel, StrictInt, StrictStr


class ArItem(RootModel[StrictStr]):
    root: Annotated[StrictStr, Field(min_length=1)]


class EnItem(RootModel[StrictStr]):
    root: Annotated[StrictStr, Field(min_length=1)]


class AltNames(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    ar: list[ArItem]
    en: list[EnItem]


class Place(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    id: Annotated[StrictInt, Field(ge=1)]
    """
    GeoNames id.
    """
    name: Annotated[StrictStr, Field(min_length=1)]
    ascii_name: Annotated[StrictStr, Field(alias="asciiName", min_length=1)]
    alt_names: Annotated[AltNames, Field(alias="altNames")]
    country: Annotated[StrictStr, Field(pattern="^[A-Z]{2}$")]
    admin1: StrictStr
    """
    GeoNames admin1 code; empty when unknown.
    """
    lat: Annotated[float, Field(ge=-90.0, le=90.0)]
    lon: Annotated[float, Field(ge=-180.0, le=180.0)]
    population: Annotated[StrictInt, Field(ge=0)]
    zone_id: Annotated[
        StrictStr, Field(alias="zoneId", max_length=64, pattern="^[A-Za-z_]+(/[A-Za-z0-9_+-]+)*$")
    ]


class GazetteerPackagePayloadV1(RootModel[list[Place]]):
    """
    Offline place search entries from GeoNames cities15000 with Arabic/English alternate names (DESIGN.md §9.5, ADR-015); imported into drift at activation.
    """

    root: Annotated[list[Place], Field(title="Gazetteer package payload v1")]
    """
    Offline place search entries from GeoNames cities15000 with Arabic/English alternate names (DESIGN.md §9.5, ADR-015); imported into drift at activation.
    """
