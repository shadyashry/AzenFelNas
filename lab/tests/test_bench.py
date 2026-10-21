"""Lab side of the bench JSONL contract and the benchmark run (DESIGN.md §6.1, §9.4, §15 D29)."""

import json
from collections.abc import Sequence

import pytest

from dm_lab.bench import BenchContractError, BenchResponse, parse_responses
from dm_lab.compare import CompareWithReference
from dm_lab.config import HarnessConfig
from dm_lab.dateset import DateTag, YearRange
from dm_lab.hijri import TabularHijriCalendar
from dm_lab.jsonl import encode_line
from dm_lab.run_benchmark import CaseSelection, RunBenchmark
from dm_lab.schema.bench_failure_v1 import BenchFailureV1
from dm_lab.schema.bench_request_v1 import BenchRequestV1
from dm_lab.schema.calculation_trace_v1 import CalculationTraceV1
from dm_lab.schema.lab_reference_v1 import LabReferenceDayV1
from tests.factories import HIJRI_2026_03_20, case_for, reference_day, trace_for

_EQUINOX_OR_MONTHLY: frozenset[DateTag] = frozenset({"MARCH_EQUINOX", "DAY_OF_MONTH"})
_DST_ONLY: frozenset[DateTag] = frozenset({"DST_WINDOW"})


class _FakeEngineBench:
    """Fake `RunEngineBench` port: answers every request with an exact trace of the fixture case."""

    def __init__(self) -> None:
        self.requests: list[BenchRequestV1] = []

    def __call__(self, requests: Sequence[BenchRequestV1]) -> list[BenchResponse]:
        self.requests.extend(requests)
        return [trace_for(reference_day()) for _ in requests]


def _run_benchmark(config: HarnessConfig, engine: _FakeEngineBench) -> RunBenchmark:
    return RunBenchmark(
        engine,
        CompareWithReference(config.benchmark.event_map, config.tolerance, dhuhr_offset_minutes=0),
        TabularHijriCalendar(config.hijri),
        config.benchmark.profiles,
    )


def _selection(
    *,
    years: YearRange | None = None,
    tags: frozenset[DateTag] | None = None,
) -> CaseSelection:
    return CaseSelection(
        city_ids=frozenset({"zz_city"}),
        years=years or YearRange(2026, 2026),
        tags=tags,
    )


def _other_case(reference: LabReferenceDayV1, city_id: str) -> LabReferenceDayV1:
    return reference.model_copy(update={"city_id": city_id, "case_id": f"{city_id}/2026-03-20"})


def test_request_carries_observer_profile_day_and_hijri_state() -> None:
    """A request is {observer, profileId, day, hijri} with a BENCHMARK observer (§6.1, §15 D29)."""
    request = case_for(reference_day()).request

    assert json.loads(encode_line(request)) == {
        "schemaVersion": 1,
        "observer": {
            "latitudeDeg": 12.34,
            "longitudeDeg": 45.67,
            "zoneId": "Etc/GMT-3",
            "source": "BENCHMARK",
        },
        "profileId": "engine.default",
        "day": "2026-03-20",
        "hijri": HIJRI_2026_03_20,
    }


def test_parses_traces_and_failures_in_line_order() -> None:
    """Each stdout line is a calculation_trace.v1 or a bench_failure.v1, in request order."""
    failure = '{"schemaVersion":1,"failure":{"code":"PROFILE_NOT_FOUND"}}'
    stdout = encode_line(trace_for(reference_day())) + "\n" + failure + "\n"

    responses = parse_responses(stdout, expected=2)

    assert isinstance(responses[0], CalculationTraceV1)
    assert isinstance(responses[1], BenchFailureV1)


def test_rejects_a_missing_answer_line() -> None:
    """Fewer lines than requests breaks the one-line-per-request contract."""
    with pytest.raises(BenchContractError, match="1 lines for 2 requests"):
        parse_responses(encode_line(trace_for(reference_day())) + "\n", expected=2)


def test_rejects_a_line_outside_both_schemas() -> None:
    """A line that is neither schema (here an unknown key) is a contract error."""
    with pytest.raises(BenchContractError, match="not a valid response"):
        parse_responses('{"schemaVersion":1,"result":{}}\n', expected=1)


def test_benchmark_sends_the_tabular_hijri_state(config: HarnessConfig) -> None:
    """The lab supplies the ADR-016 Expected state, so the bench never invents one (rule 10)."""
    engine = _FakeEngineBench()

    result = _run_benchmark(config, engine)(
        [reference_day()],
        _selection(),
        profile_id="engine.default",
        reference_sha256="f" * 64,
    )

    assert engine.requests[0].hijri.model_dump(by_alias=True) == HIJRI_2026_03_20
    assert result.report.summary.blocking == 0


def test_benchmark_asks_only_for_the_selected_cities_years_and_tags(config: HarnessConfig) -> None:
    """Cases outside the cities, the years or the tags are not sent to the engine."""
    engine = _FakeEngineBench()
    in_range = reference_day()

    _run_benchmark(config, engine)(
        [in_range, _other_case(in_range, "zz_other")],
        _selection(tags=_EQUINOX_OR_MONTHLY),
        profile_id="engine.default",
        reference_sha256="f" * 64,
    )

    assert [r.day for r in engine.requests] == ["2026-03-20"]


def test_benchmark_skips_cases_without_a_selected_tag(config: HarnessConfig) -> None:
    """A tag filter excludes cases that carry none of the tags."""
    with pytest.raises(ValueError, match="no reference case"):
        _run_benchmark(config, _FakeEngineBench())(
            [reference_day()],
            _selection(tags=_DST_ONLY),
            profile_id="engine.default",
            reference_sha256="f" * 64,
        )


def test_benchmark_refuses_a_profile_the_comparison_is_not_valid_for(config: HarnessConfig) -> None:
    """Only allow-listed profiles are benchmarked against the sun-event reference (§15 D29)."""
    engine = _FakeEngineBench()

    with pytest.raises(ValueError, match="not benchmarkable"):
        _run_benchmark(config, engine)(
            [reference_day()],
            _selection(),
            profile_id="eg.egas.standard",
            reference_sha256="f" * 64,
        )

    assert engine.requests == []


def test_benchmark_refuses_an_empty_selection(config: HarnessConfig) -> None:
    """A selection with no case is a usage error, never an empty green report."""
    with pytest.raises(ValueError, match="no reference case"):
        _run_benchmark(config, _FakeEngineBench())(
            [reference_day()],
            _selection(years=YearRange(2027, 2028)),
            profile_id="engine.default",
            reference_sha256="f" * 64,
        )
