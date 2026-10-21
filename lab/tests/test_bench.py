"""Lab side of the engine bench JSONL contract (DESIGN.md §6.1, §9.4, §15 D29)."""

import json
from collections.abc import Sequence

import pytest

from dm_lab.bench import BenchContractError, BenchResponse, parse_responses, request_for
from dm_lab.compare import CompareWithReference
from dm_lab.config import HarnessConfig
from dm_lab.dateset import YearRange
from dm_lab.jsonl import encode_line
from dm_lab.run_benchmark import RunBenchmark
from dm_lab.schema.bench_failure_v1 import BenchFailureV1
from dm_lab.schema.bench_request_v1 import BenchRequestV1
from dm_lab.schema.calculation_trace_v1 import CalculationTraceV1
from tests.factories import reference_day, trace_for


class _FakeEngineBench:
    """Fake `RunEngineBench` port: answers every request with an exact trace of its case."""

    def __init__(self) -> None:
        self.requests: list[BenchRequestV1] = []

    def __call__(self, requests: Sequence[BenchRequestV1]) -> list[BenchResponse]:
        self.requests.extend(requests)
        return [trace_for(reference_day()) for _ in requests]


def test_request_carries_observer_profile_and_day() -> None:
    """A request is {observer, profileId, day} with a BENCHMARK observer (§6.1)."""
    request = request_for(reference_day(), "engine.default")

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


def test_benchmark_asks_only_for_the_selected_cities_and_years(config: HarnessConfig) -> None:
    """Cases outside the city file or the year range are not sent to the engine."""
    engine = _FakeEngineBench()
    run = RunBenchmark(engine, CompareWithReference(config.benchmark.event_map))
    in_range = reference_day()
    other_city = in_range.model_copy(
        update={"city_id": "zz_other", "case_id": "zz_other/2026-03-20"}
    )

    result = run(
        [in_range, other_city],
        city_ids=frozenset({"zz_city"}),
        years=YearRange(2026, 2026),
        profile_id="engine.default",
        reference_sha256="f" * 64,
    )

    assert [r.day for r in engine.requests] == ["2026-03-20"]
    assert result.report.summary.cases == 1
    assert result.report.summary.blocking == 0


def test_benchmark_refuses_an_empty_selection(config: HarnessConfig) -> None:
    """A selection with no case is a usage error, never an empty green report."""
    run = RunBenchmark(_FakeEngineBench(), CompareWithReference(config.benchmark.event_map))

    with pytest.raises(ValueError, match="no reference case"):
        run(
            [reference_day()],
            city_ids=frozenset({"zz_city"}),
            years=YearRange(2027, 2028),
            profile_id="engine.default",
            reference_sha256="f" * 64,
        )
