"""The pinned input of the gazetteer pipeline: `config/gazetteer.v1.toml` (§9.5, §15 D72)."""

import tomllib
from pathlib import Path
from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field, StrictStr


class _Record(BaseModel):
    model_config = ConfigDict(
        frozen=True, extra="forbid", strict=True, validate_by_name=True, validate_by_alias=True
    )


class GazetteerSource(_Record):
    """The source release: where its bytes come from, their sha256 and the member to read."""

    version: Annotated[StrictStr, Field(min_length=1)]
    url: Annotated[StrictStr, Field(pattern=r"^https://")]
    sha256: Annotated[StrictStr, Field(pattern=r"^[a-f0-9]{64}$")]
    zip_member: Annotated[StrictStr, Field(alias="zipMember", min_length=1)]
    license: Annotated[StrictStr, Field(min_length=1)]


class GazetteerConfig(_Record):
    """The whole pin file."""

    source: GazetteerSource


def load_gazetteer_config(path: Path) -> GazetteerConfig:
    """Read and validate the pin file at `path`; raise `ValueError` when it is invalid."""
    with path.open("rb") as stream:
        document = tomllib.load(stream)
    return GazetteerConfig.model_validate(document, by_alias=True)
