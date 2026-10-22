"""The gazetteer pipeline: name selection, payload, pins and reproducibility (§9.5, §15 D72)."""

import json
import os
import zipfile
from collections.abc import Sequence
from pathlib import Path

import pytest

from dm_pipelines.cli import run
from dm_pipelines.gazetteer.config import GazetteerSource, load_gazetteer_config
from dm_pipelines.gazetteer.pipeline import (
    CONFIG,
    MANIFEST,
    PAYLOAD,
    BuildGazetteer,
    default_out,
    encode_payload,
)
from dm_pipelines.gazetteer.source import ascii_name, place_of, read_places
from dm_pipelines.hashing import sha256_file
from dm_pipelines.schema.gazetteer_package_v1 import GazetteerPackagePayloadV1
from dm_pipelines.schema.pipeline_manifest_v1 import PipelineManifestV1
from dm_pipelines.tzdata.source import SourceMismatchError

REPO = Path(__file__).resolve().parents[2]
MEMBER = "geonamescache/data/cities15000.json"
CAIRO: dict[str, object] = {
    "geonameid": 360630,
    "name": "Cairo",
    "latitude": 30.06263,
    "longitude": 31.24967,
    "countrycode": "EG",
    "population": 9606916,
    "timezone": "Africa/Cairo",
    "admin1code": "11",
    "alternatenames": [
        "CAI",
        "Cairo",
        "Le Caire",
        "alqahrt",
        "El-Qâhira",
        "Каир",
        "القاهرة",
        "قاهره",
        "قاہرہ",
        "القَاهِرَة",
        "开罗",
    ],
}
ZURICH: dict[str, object] = {
    **CAIRO,
    "geonameid": 2657896,
    "name": "Zürich",
    "countrycode": "CH",
    "timezone": "Europe/Zurich",
    "admin1code": "ZH",
    "alternatenames": ["Zurich", "زيورخ"],
}


def _wheel(tmp_path: Path, records: Sequence[dict[str, object]]) -> tuple[Path, GazetteerSource]:
    path = tmp_path / "source.whl"
    with zipfile.ZipFile(path, "w") as archive:
        archive.writestr(MEMBER, json.dumps({str(r["geonameid"]): r for r in records}))
    source = GazetteerSource(
        version="test",
        url="https://example.invalid/source.whl",
        sha256=sha256_file(path),
        zip_member=MEMBER,
        license="CC-BY-4.0",
    )
    return path, source


def test_arabic_names_are_arabic_letter_names_and_english_ones_capitalised_latin() -> None:
    place = place_of(CAIRO)
    assert [item.root for item in place.alt_names.ar] == ["القاهرة", "القَاهِرَة", "قاهره"]
    assert [item.root for item in place.alt_names.en] == ["El-Qâhira", "Le Caire"]


def test_the_ascii_name_drops_diacritics_and_spells_out_letters() -> None:
    assert ascii_name("Zürich") == "Zurich"
    assert ascii_name("Łódź") == "Lodz"
    assert ascii_name("Straße") == "Strasse"
    assert ascii_name("北京") == "北京"


def test_req_pkg_001_the_source_must_match_its_pin(tmp_path: Path) -> None:
    path, source = _wheel(tmp_path, [CAIRO])
    with pytest.raises(SourceMismatchError):
        read_places(path, source.model_copy(update={"sha256": "0" * 64}))


def test_places_sort_by_id_and_the_payload_is_one_schema_valid_place_per_line(
    tmp_path: Path,
) -> None:
    path, source = _wheel(tmp_path, [ZURICH, CAIRO])
    places = read_places(path, source)
    assert [place.id for place in places] == [360630, 2657896]
    text = encode_payload(places)
    assert text.splitlines()[0] == "["
    assert '"name":"Zürich"' in text.splitlines()[2]
    decoded = GazetteerPackagePayloadV1.model_validate_json(text)
    assert decoded.root == places


@pytest.mark.parametrize("field", ["countrycode", "timezone"])
def test_req_pkg_001_a_record_outside_the_schema_is_refused(field: str) -> None:
    with pytest.raises(ValueError, match="validation error"):
        place_of({**CAIRO, field: "not valid!"})


def test_req_dist_003_the_committed_output_matches_its_manifest() -> None:
    config = load_gazetteer_config(REPO / CONFIG)
    out = default_out(REPO, config)
    manifest = PipelineManifestV1.model_validate_json((out / MANIFEST).read_text(encoding="utf-8"))
    assert manifest.inputs[0].sha256 == config.source.sha256
    assert manifest.inputs[1].sha256 == sha256_file(REPO / CONFIG)
    (output,) = manifest.outputs
    assert output.path == PAYLOAD
    assert output.sha256 == sha256_file(out / PAYLOAD)
    payload = GazetteerPackagePayloadV1.model_validate_json((out / PAYLOAD).read_bytes())
    assert len(payload.root) == output.records


@pytest.mark.skipif(
    "DM_GAZETTEER_SOURCE" not in os.environ,
    reason="set DM_GAZETTEER_SOURCE to the pinned source file",
)
def test_req_dist_003_a_rebuild_is_byte_identical(tmp_path: Path) -> None:
    BuildGazetteer(repo=REPO).run(Path(os.environ["DM_GAZETTEER_SOURCE"]), tmp_path)
    committed = default_out(REPO, load_gazetteer_config(REPO / CONFIG))
    for name in (PAYLOAD, MANIFEST):
        assert (tmp_path / name).read_bytes() == (committed / name).read_bytes(), name


class WritingRunner:
    """Fake `CommandRunner` port: `curl -o FILE` writes fixed bytes instead of downloading."""

    def __init__(self, body: bytes) -> None:
        """Answer every download with `body`."""
        self.body = body

    def run(self, args: Sequence[str], cwd: Path) -> None:
        """Write the file `-o` names."""
        (cwd / args[args.index("-o") + 1]).write_bytes(self.body)


def test_fetch_refuses_and_removes_bytes_that_do_not_match_the_pin(tmp_path: Path) -> None:
    dest = tmp_path / "source.whl"
    code = run(
        ["--repo", str(REPO), "gazetteer", "fetch", "--dest", str(dest)],
        WritingRunner(b"not the pinned file"),
    )
    assert code == 1
    assert not dest.exists()


def test_build_through_the_cli_writes_payload_and_manifest(tmp_path: Path) -> None:
    out = tmp_path / "out"
    source = tmp_path / "pinned.whl"
    source.write_bytes(b"x")
    code = run(
        ["--repo", str(REPO), "gazetteer", "build", "--source", str(source), "--out", str(out)],
        WritingRunner(b""),
    )
    assert code == 1  # the bytes are not the pinned wheel
    assert not (out / PAYLOAD).exists()
