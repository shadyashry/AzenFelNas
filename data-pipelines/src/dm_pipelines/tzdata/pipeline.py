"""`BuildTzdata`: the `tzdata` payload and its DST oracle (DESIGN.md §9.5, §13 S10, §15 D66).

pinned IANA source ─▶ stage (pinned files + `version`) ─▶ make rearguard.zi + zic (same release)
  ─▶ zic -b fat ─▶ zoneinfo/ ─┬─▶ dm_civil_time tool/encode_tzf.dart ─▶ tzdata.tzf
                              └─▶ CPython zoneinfo ─▶ dst_oracle.json
  ─▶ manifest.json (pipeline_manifest.v1: input and output sha256s, no timestamps)
"""

import re
import struct
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

from dm_pipelines.commands import CommandRunner
from dm_pipelines.hashing import sha256_file
from dm_pipelines.schema.base import WireModel
from dm_pipelines.schema.pipeline_manifest_v1 import Input, Output, PipelineManifestV1
from dm_pipelines.tzdata.compile import DATA_FORM, ZIC_FLAGS, compile_zoneinfo, encode_tzf
from dm_pipelines.tzdata.config import TzdataConfig, load_tzdata_config
from dm_pipelines.tzdata.oracle import build_oracle, corpus_zone_ids
from dm_pipelines.tzdata.source import pin_digest, stage_source

PIPELINE = "data-pipelines.tzdata"
CONFIG = "data-pipelines/config/tzdata.v1.toml"
DART_PACKAGE = "packages/dm_civil_time"
ENCODER = f"{DART_PACKAGE}/tool/encode_tzf.dart"
PAYLOAD = "tzdata.tzf"
ORACLE = "dst_oracle.json"
MANIFEST = "manifest.json"
_SOURCES = (
    "data-pipelines/src/dm_pipelines/tzdata/compile.py",
    "data-pipelines/src/dm_pipelines/tzdata/oracle.py",
)


class PinError(Exception):
    """A tool version the outputs depend on is not pinned in the repository."""


@dataclass(frozen=True)
class BuildTzdata:
    """Builds the payload, the oracle and the manifest from a pinned source tree."""

    runner: CommandRunner
    repo: Path

    def run(self, source: Path, out: Path) -> PipelineManifestV1:
        """Build into `out` (created if needed) and return the manifest written there."""
        config = load_tzdata_config(self.repo / CONFIG)
        version = config.release.version
        out.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix="dm-tzdata-") as scratch:
            build = Path(scratch) / "tz"
            stage_source(source, config.files, version, build)
            zoneinfo = compile_zoneinfo(self.runner, build, version)
            encode_tzf(self.runner, self.repo / DART_PACKAGE, zoneinfo, out / PAYLOAD)
            oracle = build_oracle(
                zoneinfo,
                corpus_zone_ids(self.repo / config.oracle.cities),
                tzdb_version=version,
                settings=config.oracle,
            )
        # One line: the oracle is data for tests, read by machines only.
        (out / ORACLE).write_text(_json(oracle, indent=None), encoding="utf-8")
        manifest = self._manifest(config, out, oracle_zones=len(oracle.zones))
        (out / MANIFEST).write_text(_json(manifest), encoding="utf-8")
        return manifest

    def _manifest(
        self, config: TzdataConfig, out: Path, *, oracle_zones: int
    ) -> PipelineManifestV1:
        oracle = config.oracle
        repo_files = [("config", CONFIG), ("cities", oracle.cities), ("encoder", ENCODER)]
        repo_files += [("pipeline_source", path) for path in _SOURCES]
        return PipelineManifestV1(
            schema_version=1,
            pipeline=PIPELINE,
            inputs=[
                Input(
                    role="iana_tz", url=config.release.tarball_url, sha256=pin_digest(config.files)
                ),
                *(
                    Input(role=role, path=path, sha256=sha256_file(self.repo / path))
                    for role, path in repo_files
                ),
            ],
            tools={
                "zic": f"tzcode {config.release.version} (built from the pinned release)",
                "package:timezone": self._locked_dart_package("timezone"),
                "dart": self._tool_version("dart"),
                "python": f"{sys.version_info.major}.{sys.version_info.minor}",
            },
            parameters={
                "tzdbVersion": config.release.version,
                "dataForm": DATA_FORM,
                "zicFlags": " ".join(ZIC_FLAGS),
                "oracleFromYear": str(oracle.from_year),
                "oracleToYear": str(oracle.to_year),
                "oracleWindowDays": str(oracle.window_days),
            },
            outputs=[
                Output(
                    path=PAYLOAD,
                    sha256=sha256_file(out / PAYLOAD),
                    records=tzf_zone_count(out / PAYLOAD),
                ),
                Output(path=ORACLE, sha256=sha256_file(out / ORACLE), records=oracle_zones),
            ],
        )

    def _locked_dart_package(self, name: str) -> str:
        lock = (self.repo / "pubspec.lock").read_text(encoding="utf-8")
        match = re.search(
            rf'^  {re.escape(name)}:\n(?:    .*\n)*?    version: "([^"]+)"', lock, re.MULTILINE
        )
        if match is None:
            message = f"{name} is not in pubspec.lock"
            raise PinError(message)
        return match.group(1)

    def _tool_version(self, name: str) -> str:
        pins = (self.repo / ".tool-versions").read_text(encoding="utf-8")
        match = re.search(rf"^{re.escape(name)} (\S+)$", pins, re.MULTILINE)
        if match is None:
            message = f"{name} is not in .tool-versions"
            raise PinError(message)
        return match.group(1)


def tzf_zone_count(path: Path) -> int:
    """Count the location chunks of a `.tzf` database (u32 length, u32 padding, payload)."""
    data = path.read_bytes()
    count = offset = 0
    while offset < len(data):
        (length,) = struct.unpack_from(">I", data, offset)
        offset += 8 + length
        count += 1
    return count


def _json(model: WireModel, *, indent: int | None = 2) -> str:
    return model.model_dump_json(exclude_none=True, indent=indent) + "\n"
