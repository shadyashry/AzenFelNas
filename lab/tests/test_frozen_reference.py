"""The frozen S03 reference: integrity, coverage and reproducibility (DESIGN.md §9.4, ADR-019).

`lab/reference/sun_events.2026-2028.v1.jsonl` is frozen before the engine (S04–S06) exists.
"""

from datetime import date

import pytest

from dm_lab.config import HarnessConfig
from dm_lab.dateset import BenchmarkDay
from dm_lab.hashing import sha256_file
from dm_lab.jsonl import read_jsonl
from dm_lab.paths import DEFAULT_CITIES, DEFAULT_CONFIG, DEFAULT_REFERENCE, repo_relative
from dm_lab.reference import CalculateReferenceDay
from dm_lab.schema.benchmark_cities_v1 import BenchmarkCitiesV1, City
from dm_lab.schema.lab_reference_v1 import EventPRIMARY, LabReferenceDayV1
from dm_lab.schema.pipeline_manifest_v1 import PipelineManifestV1

_MANIFEST = DEFAULT_REFERENCE.with_name("sun_events.2026-2028.v1.manifest.json")
_SAMPLE_EVERY = 173  # ~25 lines spread over every city and year
_SLACK_MS = 1  # 1 ms truncation can flip with the platform's libm (DESIGN.md §15 D25)


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


def test_regenerates_a_sample_within_one_millisecond(
    frozen: list[LabReferenceDayV1],
    calculate: CalculateReferenceDay,
    cities: dict[str, City],
) -> None:
    """Recomputing spread-out lines gives the same outcomes and instants within 1 ms."""
    for line in frozen[::_SAMPLE_EVERY]:
        day = BenchmarkDay(date.fromisoformat(line.day), tuple(line.tags))

        again = calculate(cities[line.city_id], day)

        assert [e.kind for e in again.events] == [e.kind for e in line.events]
        for old, new in zip(line.events, again.events, strict=True):
            if isinstance(old, EventPRIMARY) and isinstance(new, EventPRIMARY):
                assert abs(old.reference_utc_ms - new.reference_utc_ms) <= _SLACK_MS
                assert abs(old.tolerance_ms - new.tolerance_ms) <= _SLACK_MS
