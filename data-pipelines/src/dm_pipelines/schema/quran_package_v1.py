# Generated from schemas/quran_package.v1.schema.json by datamodel-code-generator 0.86.0.
# Do not edit: run data-pipelines/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6).

from typing import Annotated, Literal

from dm_pipelines.schema.base import WireModel
from pydantic import ConfigDict, Field, StrictInt, StrictStr


class Source(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    role: Literal["pages", "text", "juz"]
    url: Annotated[StrictStr, Field(pattern="^https://")]
    sha256: Annotated[StrictStr, Field(pattern="^[a-f0-9]{64}$")]
    version: Annotated[StrictStr, Field(min_length=1)]
    license: Annotated[StrictStr, Field(min_length=1)]


class PageImage(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    format: Literal["webp-lossless"]
    width: Annotated[StrictInt, Field(ge=1)]
    height: Annotated[StrictInt, Field(ge=1)]
    path_pattern: Annotated[
        StrictStr, Field(alias="pathPattern", pattern="^[a-z]+/\\{page:03\\}\\.webp$")
    ]
    """
    e.g. pages/{page:03}.webp.
    """


class File(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    path: Annotated[StrictStr, Field(pattern="^[a-z0-9][a-z0-9_.-]*(/[a-z0-9_-][a-z0-9_.-]*)*$")]
    """
    Relative to the package directory; lowercase, no '..' segment.
    """
    bytes: Annotated[StrictInt, Field(ge=1)]
    sha256: Annotated[StrictStr, Field(pattern="^[a-f0-9]{64}$")]


class Edition(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    riwayah: Literal["hafs"]
    publisher: Annotated[StrictStr, Field(min_length=1)]
    print_edition: Annotated[StrictStr, Field(alias="printEdition", min_length=1)]
    """
    e.g. 1441 (Hijri year of the digital edition).
    """
    page_count: Annotated[StrictInt, Field(alias="pageCount", ge=1)]
    sura_count: Annotated[StrictInt, Field(alias="suraCount", ge=1)]
    verse_count: Annotated[StrictInt, Field(alias="verseCount", ge=1)]
    sources: Annotated[list[Source], Field(min_length=1)]


class QuranPackageManifestV1(WireModel):
    """
    manifest.json of the offline Quran package (DESIGN.md §9.5, §15 D106): the edition, its sources and licences, the page image geometry and every file with its size and sha256. The app pins this manifest's own sha256, so every file it lists is verified against a value the app was built with.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    schema_version: Annotated[Literal[1], Field(alias="schemaVersion")]
    package_id: Annotated[StrictStr, Field(alias="packageId", pattern="^[a-z0-9][a-z0-9-]*$")]
    """
    e.g. hafs-madinah-1441.
    """
    version: Annotated[StrictStr, Field(pattern="^[0-9]+(\\.[0-9]+)*$")]
    """
    Package build, e.g. 1441.1.
    """
    layout_id: Annotated[StrictStr, Field(alias="layoutId", pattern="^[a-z0-9][a-z0-9-]*$")]
    """
    Identity of the page layout. Bookmarks and highlights are stored against it; a package with another layoutId never shows them.
    """
    edition: Edition
    page_image: Annotated[PageImage, Field(alias="pageImage")]
    files: Annotated[list[File], Field(min_length=1)]
