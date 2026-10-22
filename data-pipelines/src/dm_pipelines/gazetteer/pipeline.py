"""`BuildGazetteer`: the gazetteer payload and its manifest (§9.5, §13 S12, §15 D72).

pinned geonamescache wheel ─▶ cities15000.json ─▶ places (sorted by id) ─▶ gazetteer.json
  ─▶ manifest.json (pipeline_manifest.v1: input and output sha256s, no timestamps)

The payload is a JSON array with one place per line, so a source update reviews as a line diff.
"""

import sys
from dataclasses import dataclass
from importlib.metadata import version as installed_version
from pathlib import Path

from dm_pipelines.gazetteer.config import GazetteerConfig, load_gazetteer_config
from dm_pipelines.gazetteer.source import read_places
from dm_pipelines.hashing import sha256_file
from dm_pipelines.schema.gazetteer_package_v1 import Place
from dm_pipelines.schema.pipeline_manifest_v1 import Input, Output, PipelineManifestV1

CONFIG = "data-pipelines/config/gazetteer.v1.toml"
APP_PACKAGES = "apps/mobile/assets/packages"
PAYLOAD = "gazetteer.json"
MANIFEST = "manifest.json"
_SOURCES = ("data-pipelines/src/dm_pipelines/gazetteer/source.py",)


def default_out(repo: Path, config: GazetteerConfig) -> Path:
    """Return `apps/mobile/assets/packages/gazetteer/<source version>`."""
    return repo / APP_PACKAGES / "gazetteer" / config.source.version


def encode_payload(places: list[Place]) -> str:
    """Return the payload text: a JSON array, one compact place per line, UTF-8 unescaped."""
    lines = ",\n".join(place.model_dump_json(by_alias=True) for place in places)
    return f"[\n{lines}\n]\n"


@dataclass(frozen=True)
class BuildGazetteer:
    """Builds the gazetteer payload and its manifest from the pinned source."""

    repo: Path

    def run(self, source: Path, out: Path) -> PipelineManifestV1:
        """Build into `out` (created if needed) and return the manifest written there."""
        config = load_gazetteer_config(self.repo / CONFIG)
        pin = config.source
        places = read_places(source, pin)
        out.mkdir(parents=True, exist_ok=True)
        (out / PAYLOAD).write_text(encode_payload(places), encoding="utf-8")
        manifest = PipelineManifestV1(
            schema_version=1,
            pipeline="data-pipelines.gazetteer",
            inputs=[
                Input(role="source", url=pin.url, sha256=pin.sha256),
                Input(role="config", path=CONFIG, sha256=sha256_file(self.repo / CONFIG)),
                *(
                    Input(role="pipeline_source", path=path, sha256=sha256_file(self.repo / path))
                    for path in _SOURCES
                ),
            ],
            tools={
                "pydantic": installed_version("pydantic"),
                "python": f"{sys.version_info.major}.{sys.version_info.minor}",
            },
            parameters={
                "sourceVersion": pin.version,
                "sourceMember": pin.zip_member,
                "license": pin.license,
                "places": str(len(places)),
                "arabicNames": str(sum(len(p.alt_names.ar) for p in places)),
                "latinNames": str(sum(len(p.alt_names.en) for p in places)),
            },
            outputs=[
                Output(path=PAYLOAD, sha256=sha256_file(out / PAYLOAD), records=len(places)),
            ],
        )
        (out / MANIFEST).write_text(
            manifest.model_dump_json(exclude_none=True, indent=2) + "\n", encoding="utf-8"
        )
        return manifest
