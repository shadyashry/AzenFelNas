"""Generated pydantic models round-trip the schema fixtures (ADR-023, DESIGN.md §17.6).

Valid fixtures decode and re-encode to the same JSON value. Invalid fixtures are rejected, except
those whose single mutation needs a JSON Schema feature pydantic does not model (listed below with
the reason); ajv in ci-schemas rejects every invalid fixture.
"""

import json
from pathlib import Path

import pytest
from pydantic import BaseModel, ValidationError

from dm_lab.jsonl import encode_document
from dm_lab.paths import REPO_ROOT
from dm_lab.schema.bench_failure_v1 import BenchFailureV1
from dm_lab.schema.bench_request_v1 import BenchRequestV1
from dm_lab.schema.benchmark_cities_v1 import BenchmarkCitiesV1
from dm_lab.schema.calculation_trace_v1 import CalculationTraceV1
from dm_lab.schema.discrepancy_report_v1 import DiscrepancyReportV1
from dm_lab.schema.lab_reference_v1 import LabReferenceDayV1
from dm_lab.schema.pipeline_manifest_v1 import PipelineManifestV1

_FIXTURES = REPO_ROOT / "schemas" / "fixtures"
_MODELS: dict[str, type[BaseModel]] = {
    "bench_failure": BenchFailureV1,
    "bench_request": BenchRequestV1,
    "benchmark_cities": BenchmarkCitiesV1,
    "calculation_trace": CalculationTraceV1,
    "discrepancy_report": DiscrepancyReportV1,
    "lab_reference": LabReferenceDayV1,
    "pipeline_manifest": PipelineManifestV1,
}
# Invalid fixtures that only JSON Schema conditionals or uniqueness can reject.
_SCHEMA_ONLY = {
    "calculation_trace/REQ-DOM-002_no_event_with_time.json": "if/then/else on origin.kind",
    "calculation_trace/primary_without_time.json": "if/then/else on origin.kind",
}


def _fixtures(kind: str) -> list[tuple[str, Path]]:
    return [
        (name, path)
        for name in sorted(_MODELS)
        for path in sorted((_FIXTURES / name / kind).glob("*.json"))
    ]


def _schema_only(case: tuple[str, Path]) -> bool:
    return f"{case[0]}/{case[1].name}" in _SCHEMA_ONLY


def _id(case: tuple[str, Path]) -> str:
    return f"{case[0]}/{case[1].name}"


@pytest.mark.parametrize("case", _fixtures("valid"), ids=_id)
def test_valid_fixture_round_trips(case: tuple[str, Path]) -> None:
    """Decoding then encoding a valid fixture reproduces its JSON value (absent stays absent)."""
    name, path = case
    original = json.loads(path.read_text(encoding="utf-8"))

    model = _MODELS[name].model_validate(original)

    assert json.loads(encode_document(model)) == original


@pytest.mark.parametrize(
    "case",
    [case for case in _fixtures("invalid") if not _schema_only(case)],
    ids=_id,
)
def test_invalid_fixture_is_rejected(case: tuple[str, Path]) -> None:
    """Every invalid fixture the model can express is rejected."""
    name, path = case

    with pytest.raises(ValidationError):
        _MODELS[name].model_validate_json(path.read_text(encoding="utf-8"))


@pytest.mark.parametrize("case", [c for c in _fixtures("invalid") if _schema_only(c)], ids=_id)
def test_schema_only_constraints_are_left_to_ajv_and_the_comparator(case: tuple[str, Path]) -> None:
    """The documented gap: these decode; ajv rejects them and compare.py treats them as mismatches.

    If a generator upgrade starts rejecting one, drop it from `_SCHEMA_ONLY`.
    """
    name, path = case

    model = _MODELS[name].model_validate_json(path.read_text(encoding="utf-8"))

    assert model is not None


def test_every_python_modelled_schema_has_fixtures() -> None:
    """Each schema the lab models has at least one valid fixture to round-trip."""
    assert all(any((_FIXTURES / name / "valid").glob("*.json")) for name in _MODELS)
