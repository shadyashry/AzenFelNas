"""`lab` command line: reference pipeline output and its manifest (DESIGN.md §9.4, §17.6)."""

from pathlib import Path

from dm_lab.cli import EXIT_ERROR, EXIT_OK, main
from dm_lab.hashing import sha256_file
from dm_lab.jsonl import read_jsonl
from dm_lab.schema.lab_reference_v1 import LabReferenceDayV1
from dm_lab.schema.pipeline_manifest_v1 import PipelineManifestV1

_CITIES = Path(__file__).parent / "data" / "cities.zz.json"


def _build(out: Path) -> int:
    return main(["reference", "--cities", str(_CITIES), "--years", "2026-2026", "--out", str(out)])


def test_reference_writes_jsonl_and_a_manifest_of_hashes(tmp_path: Path) -> None:
    """The pipeline records every input by sha256 and its output by sha256 and count (§17.6)."""
    out = tmp_path / "ref.jsonl"

    status = _build(out)

    manifest = PipelineManifestV1.model_validate_json(
        (tmp_path / "ref.manifest.json").read_text(encoding="utf-8"),
    )
    lines = read_jsonl(out, LabReferenceDayV1)
    assert status == EXIT_OK
    assert [(o.path, o.sha256, o.records) for o in manifest.outputs] == [
        ("ref.jsonl", sha256_file(out), len(lines)),
    ]
    assert {i.role for i in manifest.inputs} == {"cities", "config", "ephemeris"}
    assert manifest.parameters["years"] == "2026-2026"
    assert manifest.tools["skyfield"] == "1.55"


def test_reference_is_deterministic(tmp_path: Path) -> None:
    """Two runs over the same pinned inputs write identical bytes."""
    first, second = tmp_path / "a.jsonl", tmp_path / "b.jsonl"

    _build(first)
    _build(second)

    assert first.read_bytes() == second.read_bytes()


def test_reference_selects_cities_in_file_order_with_their_dates(tmp_path: Path) -> None:
    """Cairo then Tromsø; each gets 12 monthly days, the equinox and (Cairo) its DST days."""
    out = tmp_path / "ref.jsonl"

    _build(out)

    case_ids = [line.case_id for line in read_jsonl(out, LabReferenceDayV1)]
    assert case_ids[0] == "cairo/2026-01-15"
    assert case_ids[-1] == "tromso/2026-12-15"
    assert "cairo/2026-03-20" in case_ids
    assert "tromso/2026-03-20" in case_ids


def test_benchmark_refuses_a_reference_that_differs_from_its_manifest(tmp_path: Path) -> None:
    """A tampered frozen reference is rejected before any engine runs."""
    out = tmp_path / "ref.jsonl"
    _build(out)
    out.write_text(out.read_text(encoding="utf-8") + "\n", encoding="utf-8", newline="\n")

    status = main(
        [
            "benchmark",
            "--engine",
            "dart",
            "--cities",
            str(_CITIES),
            "--reference",
            str(out),
            "--out",
            str(tmp_path / "bench"),
        ],
    )

    assert status == EXIT_ERROR
