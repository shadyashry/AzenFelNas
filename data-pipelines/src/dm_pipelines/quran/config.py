"""The pinned inputs of the Quran pipeline: `config/quran.v1.toml` (§9.5, §15 D107)."""

import tomllib
from pathlib import Path
from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field, StrictInt, StrictStr


class _Record(BaseModel):
    model_config = ConfigDict(
        frozen=True, extra="forbid", strict=True, validate_by_name=True, validate_by_alias=True
    )


class PackagePin(_Record):
    """The package this pipeline writes."""

    id: Annotated[StrictStr, Field(pattern=r"^[a-z0-9][a-z0-9-]*$")]
    version: Annotated[StrictStr, Field(pattern=r"^[0-9]+(\.[0-9]+)*$")]
    page_count: Annotated[StrictInt, Field(alias="pageCount", ge=1)]
    page_width: Annotated[StrictInt, Field(alias="pageWidth", ge=256)]


class MushafSource(_Record):
    """The KFGQPC digital Mushaf: one Illustrator file per page in a zip."""

    version: Annotated[StrictStr, Field(min_length=1)]
    url: Annotated[StrictStr, Field(pattern=r"^https://")]
    sha256: Annotated[StrictStr, Field(pattern=r"^[a-f0-9]{64}$")]
    license: Annotated[StrictStr, Field(min_length=1)]


class TextSource(_Record):
    """The KFGQPC Hafs font package: the font and the Word file of the whole Mushaf."""

    version: Annotated[StrictStr, Field(min_length=1)]
    url: Annotated[StrictStr, Field(pattern=r"^https://")]
    sha256: Annotated[StrictStr, Field(pattern=r"^[a-f0-9]{64}$")]
    docx_member: Annotated[StrictStr, Field(alias="docxMember", min_length=1)]
    font_member: Annotated[StrictStr, Field(alias="fontMember", min_length=1)]
    license: Annotated[StrictStr, Field(min_length=1)]


class JuzSource(_Record):
    """The juz boundaries (Tanzil metadata)."""

    version: Annotated[StrictStr, Field(min_length=1)]
    url: Annotated[StrictStr, Field(pattern=r"^https://")]
    sha256: Annotated[StrictStr, Field(pattern=r"^[a-f0-9]{64}$")]
    license: Annotated[StrictStr, Field(min_length=1)]


class QuranConfig(_Record):
    """The whole pin file."""

    package: PackagePin
    mushaf: MushafSource
    text: TextSource
    juz: JuzSource


def load_quran_config(path: Path) -> QuranConfig:
    """Read and validate the pin file at `path`; raise `ValueError` when it is invalid."""
    with path.open("rb") as stream:
        document = tomllib.load(stream)
    return QuranConfig.model_validate(document, by_alias=True)
