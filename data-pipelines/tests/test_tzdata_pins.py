"""Pinned inputs of the tzdata pipeline: config, source verification, staging (§17.6, §15 D66)."""

from pathlib import Path

import pytest
from pydantic import ValidationError

from dm_pipelines.hashing import sha256_bytes
from dm_pipelines.tzdata.config import TzdataConfig, load_tzdata_config
from dm_pipelines.tzdata.source import SourceMismatchError, pin_digest, stage_source, verify_source

REPO = Path(__file__).resolve().parents[2]

_RELEASE = {
    "version": "2026e",
    "tarballUrl": "https://data.iana.org/time-zones/releases/tzdb-2026e.tar.lz",
    "gitUrl": "https://github.com/eggert/tz",
    "gitCommit": "0" * 40,
}
_ORACLE = {"cities": "c.json", "fromYear": 2026, "toYear": 2028, "windowDays": 7}


def _config(files: dict[str, str], oracle: dict[str, object] | None = None) -> TzdataConfig:
    document = {"release": _RELEASE, "oracle": oracle or _ORACLE, "files": files}
    return TzdataConfig.model_validate(document, by_alias=True)


def _tree(tmp_path: Path, files: dict[str, bytes]) -> tuple[Path, dict[str, str]]:
    source = tmp_path / "src"
    source.mkdir()
    for name, data in files.items():
        (source / name).write_bytes(data)
    return source, {name: sha256_bytes(data) for name, data in files.items()}


def test_the_repository_pins_one_iana_release() -> None:
    config = load_tzdata_config(REPO / "data-pipelines" / "config" / "tzdata.v1.toml")
    assert config.release.version == "2026e"
    assert {"africa", "europe", "Makefile", "zic.c", "ziguard.awk"} <= config.files.keys()


@pytest.mark.parametrize(
    "files",
    [{"africa": "abc"}, {".gitignore": "0" * 64}, {"version": "0" * 64}, {"sub/dir": "0" * 64}],
)
def test_a_pin_without_a_hash_or_with_a_special_name_is_refused(files: dict[str, str]) -> None:
    with pytest.raises(ValidationError):
        _config(files)


def test_oracle_years_must_be_ordered() -> None:
    with pytest.raises(ValidationError):
        _config({"africa": "0" * 64}, {**_ORACLE, "fromYear": 2029})


def test_a_tampered_or_missing_file_is_named(tmp_path: Path) -> None:
    source, pins = _tree(tmp_path, {"africa": b"Zone A", "europe": b"Zone B"})
    (source / "africa").write_bytes(b"Zone X")
    (source / "europe").unlink()
    with pytest.raises(SourceMismatchError, match=r"africa: sha256 .*europe: missing"):
        verify_source(source, pins)


def test_staging_copies_only_pinned_files_and_writes_the_version(tmp_path: Path) -> None:
    source, pins = _tree(tmp_path, {"africa": b"Zone A"})
    (source / "extra").write_bytes(b"not pinned")
    dest = tmp_path / "build"
    stage_source(source, pins, "2026e", dest)
    assert sorted(p.name for p in dest.iterdir()) == ["africa", "version"]
    assert (dest / "version").read_text(encoding="ascii") == "2026e\n"


def test_the_pin_digest_does_not_depend_on_order() -> None:
    assert pin_digest({"a": "1" * 64, "b": "2" * 64}) == pin_digest({"b": "2" * 64, "a": "1" * 64})
    assert pin_digest({"a": "1" * 64}) != pin_digest({"a": "2" * 64})
