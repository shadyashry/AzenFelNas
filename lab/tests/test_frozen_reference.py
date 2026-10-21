"""The frozen S03 reference: integrity, coverage and reproducibility (DESIGN.md §9.4, ADR-019).

`lab/reference/sun_events.2026-2028.v1.jsonl` is frozen before the engine (S04–S06) exists.
"""

from datetime import date

import pytest

from dm_lab.config import HarnessConfig
from dm_lab.dateset import BenchmarkDay
from dm_lab.hashing import sha256_file
from dm_lab.jsonl import read_jsonl
from dm_lab.manifest import REFERENCE_SOURCES, source_input
from dm_lab.paths import (
    DEFAULT_CITIES,
    DEFAULT_CONFIG,
    DEFAULT_REFERENCE,
    PACKAGE_DIR,
    repo_relative,
)
from dm_lab.reference import CalculateReferenceDay
from dm_lab.schema.benchmark_cities_v1 import BenchmarkCitiesV1, City
from dm_lab.schema.lab_reference_v1 import EventPRIMARY, LabReferenceDayV1
from dm_lab.schema.pipeline_manifest_v1 import PipelineManifestV1

_MANIFEST = DEFAULT_REFERENCE.with_name("sun_events.2026-2028.v1.manifest.json")
_SAMPLE_EVERY = 173  # ~25 lines spread over every city and year, plus every polar line
_SLACK_MS = 1  # 1 ms truncation can flip with the platform's libm (DESIGN.md §15 D25)
_INSTANT_KEYS = ("referenceUtcMs", "toleranceMs", "candidatesUtcMs", "rateDegPerS")


@pytest.fixture(scope="module")
def manifest() -> PipelineManifestV1:
    """The manifest frozen beside the reference."""
    return PipelineManifestV1.model_validate_json(_MANIFEST.read_text(encoding="utf-8"))


@pytest.fixture(scope="module")
def frozen() -> list[LabReferenceDayV1]:
    """Every line of the frozen reference."""
    return read_jsonl(DEFAULT_REFERENCE, LabReferenceDayV1)


def test_matches_the_sha256_in_its_manifest(manifest: PipelineManifestV1) -> None:
    """The committed JSONL is byte-identical to what the manifest recorded."""
    [output] = manifest.outputs

    assert (output.path, output.sha256) == (DEFAULT_REFERENCE.name, sha256_file(DEFAULT_REFERENCE))


def test_was_built_from_the_committed_inputs(
    manifest: PipelineManifestV1,
    config: HarnessConfig,
) -> None:
    """Changing the cities, the config or the ephemeris pin requires regenerating the reference."""
    inputs = {i.role: i for i in manifest.inputs}

    assert inputs["cities"].path == repo_relative(DEFAULT_CITIES)
    assert inputs["cities"].sha256 == sha256_file(DEFAULT_CITIES)
    assert inputs["config"].sha256 == sha256_file(DEFAULT_CONFIG)
    assert inputs["ephemeris"].sha256 == config.ephemeris.sha256
    assert manifest.parameters["years"] == "2026-2028"


def test_was_built_by_the_current_harness_source(manifest: PipelineManifestV1) -> None:
    """Changing reference-deciding code requires regenerating the reference (`reference-update`)."""
    recorded = {i.role: i.sha256 for i in manifest.inputs}["harness_source"]

    current = source_input("harness_source", PACKAGE_DIR, REFERENCE_SOURCES).sha256

    assert recorded == current


def test_covers_every_city_in_every_year(
    frozen: list[LabReferenceDayV1],
    city_file: BenchmarkCitiesV1,
) -> None:
    """All 49 Appendix H cities have days in 2026, 2027 and 2028; case ids are unique."""
    covered = {(line.city_id, line.day[:4]) for line in frozen}

    expected = {(c.city_id, str(y)) for c in city_file.cities for y in (2026, 2027, 2028)}
    assert covered == expected
    assert len({line.case_id for line in frozen}) == len(frozen)


def test_every_day_has_a_primary_transit(frozen: list[LabReferenceDayV1]) -> None:
    """Dhuhr's astronomical anchor exists every day, even in polar day and night."""
    assert all(
        any(isinstance(e, EventPRIMARY) and e.event == "TRANSIT" for e in line.events)
        for line in frozen
    )


def _shape(line: LabReferenceDayV1) -> list[dict[str, object]]:
    """Every event field except the numbers that may move by 1 ms across platforms."""
    return [
        {k: v for k, v in e.model_dump(mode="json").items() if k not in _INSTANT_KEYS}
        for e in line.events
    ]


def _numbers(line: LabReferenceDayV1) -> list[int]:
    values: list[int] = []
    for event in line.events:
        document = event.model_dump(mode="json")
        values.extend(
            v for k in ("referenceUtcMs", "toleranceMs") if isinstance(v := document.get(k), int)
        )
        values.extend(document.get("candidatesUtcMs", []))
    return values


def test_regenerates_a_sample_within_one_millisecond(
    frozen: list[LabReferenceDayV1],
    calculate: CalculateReferenceDay,
    cities: dict[str, City],
) -> None:
    """Sampled and all polar lines recompute exactly, numbers within 1 ms (§15 D25).

    Kinds, reasons, tags and ids must match exactly; instants and tolerances may move by 1 ms.
    """
    polar = [line for line in frozen if any(e.kind != "PRIMARY" for e in line.events)]
    for line in frozen[::_SAMPLE_EVERY] + polar:
        day = BenchmarkDay(date.fromisoformat(line.day), tuple(line.tags))

        again = calculate(cities[line.city_id], day)

        assert (again.case_id, again.tags, _shape(again)) == (line.case_id, line.tags, _shape(line))
        old, new = _numbers(line), _numbers(again)
        assert len(old) == len(new)
        assert all(abs(a - b) <= _SLACK_MS for a, b in zip(old, new, strict=True))
