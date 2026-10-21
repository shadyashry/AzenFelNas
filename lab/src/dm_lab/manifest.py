"""pipeline_manifest.v1 documents: pinned inputs, tool versions and outputs, by sha256 (§17.6)."""

import platform
from collections.abc import Iterable, Mapping
from importlib import metadata
from pathlib import Path

from dm_lab.hashing import sha256_file
from dm_lab.paths import repo_relative
from dm_lab.schema.pipeline_manifest_v1 import Input, Output, PipelineManifestV1

LAB_DISTRIBUTIONS = ("dm_lab", "jplephem", "numpy", "pydantic", "skyfield", "tzdata")


def file_input(role: str, path: Path) -> Input:
    """Describe a repository file the pipeline read."""
    return Input(role=role, path=repo_relative(path), sha256=sha256_file(path))


def url_input(role: str, url: str, sha256: str) -> Input:
    """Describe a downloaded input by its URL and verified sha256."""
    return Input(role=role, url=url, sha256=sha256)


def file_output(path: Path, records: int, manifest_dir: Path) -> Output:
    """Describe a file written beside the manifest and how many records it holds."""
    relative = path.resolve().relative_to(manifest_dir.resolve()).as_posix()
    return Output(path=relative, sha256=sha256_file(path), records=records)


def tool_versions(extra: Mapping[str, str]) -> dict[str, str]:
    """Python and the lab's output-affecting distributions, plus `extra`."""
    versions = {"python": platform.python_version()}
    versions.update({name: metadata.version(name) for name in LAB_DISTRIBUTIONS})
    versions.update(extra)
    return versions


def build_manifest(
    pipeline: str,
    inputs: Iterable[Input],
    tools: Mapping[str, str],
    parameters: Mapping[str, str],
    outputs: Iterable[Output],
) -> PipelineManifestV1:
    """Assemble the manifest of one run (no timestamps, so it is reproducible)."""
    return PipelineManifestV1(
        schema_version=1,
        pipeline=pipeline,
        inputs=list(inputs),
        tools=dict(tools),
        parameters=dict(parameters),
        outputs=list(outputs),
    )
