"""The tzdata build: commands, the committed outputs and the CLI (DESIGN.md §9.5, §15 D66)."""

import os
from collections.abc import Sequence
from pathlib import Path

import pytest

from dm_pipelines.cli import run
from dm_pipelines.commands import SubprocessRunner
from dm_pipelines.hashing import sha256_file
from dm_pipelines.schema.pipeline_manifest_v1 import PipelineManifestV1
from dm_pipelines.schema.tz_transition_oracle_v1 import TzTransitionOracleV1
from dm_pipelines.tzdata.compile import compile_zoneinfo, encode_tzf
from dm_pipelines.tzdata.pipeline import BuildTzdata, tzf_zone_count

REPO = Path(__file__).resolve().parents[2]
PINNED = REPO / "packages" / "dm_civil_time" / "data" / "tzdata" / "2026e"


class RecordingRunner:
    """Fake `CommandRunner` port: records each command instead of running it."""

    def __init__(self) -> None:
        """Start with no calls."""
        self.calls: list[tuple[list[str], Path]] = []

    def run(self, args: Sequence[str], cwd: Path) -> None:
        """Record the call."""
        self.calls.append((list(args), cwd))


def _manifest() -> PipelineManifestV1:
    return PipelineManifestV1.model_validate_json((PINNED / "manifest.json").read_text("utf-8"))


def test_zic_is_built_from_the_release_and_writes_fat_rearguard_files(tmp_path: Path) -> None:
    runner = RecordingRunner()
    zoneinfo = compile_zoneinfo(runner, tmp_path, "2026e")
    assert runner.calls == [
        (["make", "-s", "VERSION=2026e", "rearguard.zi", "zic"], tmp_path),
        (["./zic", "-b", "fat", "-d", str(zoneinfo), "rearguard.zi"], tmp_path),
    ]


def test_the_encoder_is_dm_civil_time_tool(tmp_path: Path) -> None:
    runner = RecordingRunner()
    encode_tzf(runner, tmp_path, tmp_path / "zi", tmp_path / "o.tzf")
    assert runner.calls == [
        (
            ["dart", "run", "tool/encode_tzf.dart", str(tmp_path / "zi"), str(tmp_path / "o.tzf")],
            tmp_path,
        )
    ]


def test_the_pinned_outputs_match_their_manifest_req_time_020() -> None:
    manifest = _manifest()
    assert manifest.parameters["tzdbVersion"] == "2026e"
    for output in manifest.outputs:
        assert sha256_file(PINNED / output.path) == output.sha256, output.path
    assert tzf_zone_count(PINNED / "tzdata.tzf") == manifest.outputs[0].records


def test_the_manifest_inputs_are_the_current_files_req_time_020() -> None:
    # A change to the pins, the corpus, the encoder or the pipeline needs a rebuild (runbook
    # tzdb-emergency): `uv run dm-pipelines tzdata build --source <tz>`.
    for item in _manifest().inputs:
        if item.path is not None:
            assert sha256_file(REPO / item.path) == item.sha256, item.path


def test_the_oracle_covers_every_corpus_zone_req_time_020() -> None:
    oracle = TzTransitionOracleV1.model_validate_json(
        (PINNED / "dst_oracle.json").read_text("utf-8")
    )
    assert (oracle.tzdb_version, oracle.from_year, oracle.to_year, oracle.window_days) == (
        "2026e",
        2026,
        2028,
        7,
    )
    assert len(oracle.zones) == 41
    assert all(len(z.days) >= 15 for z in oracle.zones if z.transitions)


def test_a_usage_error_exits_2() -> None:
    assert run(["tzdata", "build"], RecordingRunner()) == 2


def test_a_source_that_does_not_match_the_pins_exits_1(tmp_path: Path) -> None:
    runner = RecordingRunner()
    assert (
        run(
            [
                "--repo",
                str(REPO),
                "tzdata",
                "build",
                "--source",
                str(tmp_path),
                "--out",
                str(tmp_path / "o"),
            ],
            runner,
        )
        == 1
    )
    assert runner.calls == []


def test_fetch_checks_out_the_pinned_commit_then_verifies_it(tmp_path: Path) -> None:
    runner = RecordingRunner()
    assert (
        run(["--repo", str(REPO), "tzdata", "fetch", "--dest", str(tmp_path / "tz")], runner) == 1
    )
    commands = [args[:2] for args, _ in runner.calls]
    assert commands == [["git", "init"], ["git", "fetch"], ["git", "checkout"]]
    assert "039ef27cc5f062a2055cb67435d6d71adbefd27d" in runner.calls[1][0]


@pytest.mark.skipif(
    "DM_TZ_SOURCE" not in os.environ, reason="needs the IANA source, make, cc and dart"
)
def test_a_rebuild_reproduces_the_pinned_outputs_byte_for_byte_req_time_020(tmp_path: Path) -> None:
    # ci-lab's tzdata-rebuild job sets DM_TZ_SOURCE after `dm-pipelines tzdata fetch`.
    BuildTzdata(runner=SubprocessRunner(), repo=REPO).run(
        Path(os.environ["DM_TZ_SOURCE"]), tmp_path
    )
    for name in ("tzdata.tzf", "dst_oracle.json", "manifest.json"):
        assert (tmp_path / name).read_bytes() == (PINNED / name).read_bytes(), name
