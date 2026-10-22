"""`BuildPolygons`: a polygon index payload and its lookup oracle (§9.5, §13 S11, §15 D70-D71).

pinned GeoJSON ─▶ NamedPolygons (make_valid) ─┬─▶ simplify + round + grid ─▶ <package>.bin
                                              └─▶ shapely on the source ─▶ lookup_oracle.json
  ─▶ manifest.json (pipeline_manifest.v1: input and output sha256s, no timestamps)
"""

import sys
from dataclasses import dataclass
from importlib.metadata import version as installed_version
from pathlib import Path
from typing import Literal

from dm_pipelines.hashing import sha256_file
from dm_pipelines.polygons.config import Dataset, PolygonsConfig, load_polygons_config
from dm_pipelines.polygons.encode import encode_index
from dm_pipelines.polygons.oracle import SourceIndex, build_samples
from dm_pipelines.polygons.source import read_source
from dm_pipelines.schema.base import WireModel
from dm_pipelines.schema.pipeline_manifest_v1 import Input, Output, PipelineManifestV1
from dm_pipelines.schema.polygon_lookup_oracle_v1 import PolygonLookupOracleV1

CONFIG = "data-pipelines/config/polygons.v1.toml"
DART_PACKAGE = "packages/dm_civil_time"
ORACLE = "lookup_oracle.json"
MANIFEST = "manifest.json"
MAGIC: dict[Dataset, bytes] = {"tz": b"TZPG", "country": b"CTPG"}
PACKAGE: dict[Dataset, Literal["tz_polygons", "country_polygons"]] = {
    "tz": "tz_polygons",
    "country": "country_polygons",
}
_SOURCES = (
    "data-pipelines/src/dm_pipelines/polygons/source.py",
    "data-pipelines/src/dm_pipelines/polygons/encode.py",
    "data-pipelines/src/dm_pipelines/polygons/oracle.py",
)


def package_name(dataset: Dataset) -> str:
    """Return `tz_polygons` or `country_polygons`."""
    return PACKAGE[dataset]


def payload_name(dataset: Dataset) -> str:
    """Return the payload file name, e.g. `tz_polygons.bin`."""
    return f"{package_name(dataset)}.bin"


def default_out(repo: Path, dataset: Dataset, config: PolygonsConfig) -> Path:
    """Return `packages/dm_civil_time/data/<package>/<source version>`."""
    return repo / DART_PACKAGE / "data" / package_name(dataset) / config.source(dataset).version


@dataclass(frozen=True)
class BuildPolygons:
    """Builds the payload, the oracle and the manifest of one dataset from its pinned source."""

    repo: Path

    def run(self, dataset: Dataset, source: Path, out: Path) -> PipelineManifestV1:
        """Build into `out` (created if needed) and return the manifest written there."""
        config = load_polygons_config(self.repo / CONFIG)
        pin = config.source(dataset)
        polygons = read_source(source, pin, iso2=dataset == "country")
        encoded = encode_index(
            polygons, magic=MAGIC[dataset], tolerance=config.build.simplify_tolerance_deg
        )
        oracle = PolygonLookupOracleV1(
            schema_version=1,
            dataset=PACKAGE[dataset],
            source_version=pin.version,
            seed=config.oracle.seed,
            earth_radius_m=config.oracle.earth_radius_m,
            distance_limit_m=config.oracle.distance_limit_m,
            samples=build_samples(SourceIndex.of(polygons), config.oracle),
        )
        out.mkdir(parents=True, exist_ok=True)
        (out / payload_name(dataset)).write_bytes(encoded.payload)
        # One line: the oracle is data for tests, read by machines only.
        (out / ORACLE).write_text(_json(oracle, indent=None, nulls=True), encoding="utf-8")
        manifest = PipelineManifestV1(
            schema_version=1,
            pipeline=f"data-pipelines.{package_name(dataset)}",
            inputs=[
                Input(role="source", url=pin.url, sha256=pin.sha256),
                Input(role="config", path=CONFIG, sha256=sha256_file(self.repo / CONFIG)),
                *(
                    Input(role="pipeline_source", path=path, sha256=sha256_file(self.repo / path))
                    for path in _SOURCES
                ),
            ],
            tools={
                "shapely": installed_version("shapely"),
                "numpy": installed_version("numpy"),
                "python": f"{sys.version_info.major}.{sys.version_info.minor}",
            },
            parameters={
                "sourceVersion": pin.version,
                "license": pin.license,
                "nameProperty": pin.name_property,
                "simplifyToleranceDeg": str(config.build.simplify_tolerance_deg),
                "polygons": str(encoded.polygons),
                "points": str(encoded.points),
                "oracleSeed": str(config.oracle.seed),
            },
            outputs=[
                Output(
                    path=payload_name(dataset),
                    sha256=sha256_file(out / payload_name(dataset)),
                    records=len(encoded.names),
                ),
                Output(
                    path=ORACLE,
                    sha256=sha256_file(out / ORACLE),
                    records=sum(len(sample.points) for sample in oracle.samples),
                ),
            ],
        )
        (out / MANIFEST).write_text(_json(manifest), encoding="utf-8")
        return manifest


def _json(model: WireModel, *, indent: int | None = 2, nulls: bool = False) -> str:
    return model.model_dump_json(exclude_none=not nulls, indent=indent) + "\n"
