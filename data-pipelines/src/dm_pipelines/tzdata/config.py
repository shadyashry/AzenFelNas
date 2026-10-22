"""The pinned inputs of the `tzdata` pipeline: `config/tzdata.v1.toml` (DESIGN.md §9.5, §15 D66)."""

import re
import tomllib
from pathlib import Path
from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field, StrictInt, StrictStr, model_validator

_HEX64 = r"^[a-f0-9]{64}$"


class _Record(BaseModel):
    model_config = ConfigDict(
        frozen=True, extra="forbid", strict=True, validate_by_name=True, validate_by_alias=True
    )


class ReleasePin(_Record):
    """The IANA release: its name and where the pinned bytes come from."""

    version: Annotated[StrictStr, Field(pattern=r"^\d{4}[a-z]+$")]
    tarball_url: Annotated[StrictStr, Field(alias="tarballUrl", pattern=r"^https://")]
    git_url: Annotated[StrictStr, Field(alias="gitUrl", pattern=r"^https://")]
    git_commit: Annotated[StrictStr, Field(alias="gitCommit", pattern=r"^[a-f0-9]{40}$")]


class OracleSettings(_Record):
    """Which zones and days the DST transition oracle covers (§13 S10)."""

    cities: StrictStr
    from_year: Annotated[StrictInt, Field(alias="fromYear", ge=1)]
    to_year: Annotated[StrictInt, Field(alias="toYear", ge=1)]
    window_days: Annotated[StrictInt, Field(alias="windowDays", ge=0, le=31)]

    @model_validator(mode="after")
    def _years_ordered(self) -> OracleSettings:
        if self.to_year < self.from_year:
            message = "oracle toYear precedes fromYear"
            raise ValueError(message)
        return self


class TzdataConfig(_Record):
    """The whole pin file."""

    release: ReleasePin
    oracle: OracleSettings
    files: Annotated[dict[StrictStr, StrictStr], Field(min_length=1)]

    @model_validator(mode="after")
    def _files_are_plain_and_hashed(self) -> TzdataConfig:
        for name, digest in self.files.items():
            if "/" in name or name.startswith(".") or name == "version":
                message = f"pinned file {name!r} must be a plain top-level name other than version"
                raise ValueError(message)
            if re.fullmatch(_HEX64, digest) is None:
                message = f"pinned file {name!r} has no lowercase hex sha256"
                raise ValueError(message)
        return self


def load_tzdata_config(path: Path) -> TzdataConfig:
    """Read and validate the pin file at `path`; raise `ValueError` when it is invalid."""
    with path.open("rb") as stream:
        document = tomllib.load(stream)
    return TzdataConfig.model_validate(document, by_alias=True)
