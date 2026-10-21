"""Engine raw instants versus the reference under ADR-019 (DESIGN.md §6.7, §15 D29)."""

import pytest

from dm_lab.bench import BenchContractError, BenchResponse
from dm_lab.compare import CompareWithReference
from dm_lab.config import HarnessConfig
from dm_lab.schema.bench_failure_v1 import BenchFailureV1
from dm_lab.schema.discrepancy_report_v1 import DiscrepancyReportV1
from dm_lab.schema.lab_reference_v1 import LabReferenceDayV1
from tests.factories import SUNRISE_MS, SUNSET_MS, TRANSIT_MS, reference_day, trace_for

_SHA = "f" * 64


@pytest.fixture
def compare(config: HarnessConfig) -> CompareWithReference:
    """The comparator over the configured event map."""
    return CompareWithReference(config.benchmark.event_map)


def _run(
    compare: CompareWithReference,
    *pairs: tuple[LabReferenceDayV1, BenchResponse],
) -> DiscrepancyReportV1:
    return compare(
        [reference for reference, _ in pairs],
        [response for _, response in pairs],
        profile_id="engine.default",
        reference_sha256=_SHA,
    )


def test_agrees_within_tolerance_req_test_003(compare: CompareWithReference) -> None:
    """REQ-TEST-003: instants within each event's ADR-019 tolerance agree and do not block."""
    reference = reference_day()
    trace = trace_for(
        reference,
        sunrise=("PRIMARY", SUNRISE_MS + 300),
        dhuhr=("PRIMARY", TRANSIT_MS - 240),
        maghrib=("PRIMARY", SUNSET_MS),
    )

    report = _run(compare, (reference, trace))

    assert report.summary.agreed == 3
    assert report.summary.blocking == 0
    assert report.summary.max_abs_delta_ms == 300
    assert report.discrepancies == []


def test_flags_an_instant_outside_tolerance_as_blocking_unknown_req_test_003(
    compare: CompareWithReference,
) -> None:
    """REQ-TEST-003: 241 ms off a 240 ms transit tolerance is an UNKNOWN discrepancy (§6.7)."""
    reference = reference_day()
    trace = trace_for(reference, dhuhr=("PRIMARY", TRANSIT_MS + 241))

    report = _run(compare, (reference, trace))

    [discrepancy] = report.discrepancies
    assert (discrepancy.event, discrepancy.classification) == ("DHUHR", "UNKNOWN")
    assert (discrepancy.delta_ms, discrepancy.tolerance_ms) == (241, 240)
    assert discrepancy.engine_version == "0.1.0"
    assert report.summary.blocking == 1


def test_flags_a_fallback_where_a_primary_root_exists_req_dom_002(
    compare: CompareWithReference,
) -> None:
    """REQ-DOM-002: a fallback is never used when a primary root exists, even if close in time."""
    reference = reference_day()
    trace = trace_for(reference, sunrise=("FALLBACK", SUNRISE_MS))

    report = _run(compare, (reference, trace))

    [discrepancy] = report.discrepancies
    assert (discrepancy.event, discrepancy.classification) == ("SUNRISE", "UNKNOWN")


def test_accepts_a_typed_no_event_with_the_reference_reason_req_dom_002(
    compare: CompareWithReference,
) -> None:
    """REQ-DOM-002: polar day on both sides agrees; no instant is invented."""
    no_event = {"kind": "NO_EVENT", "event": "SUNRISE", "reason": "POLAR_DAY"}
    reference = reference_day(sunrise=no_event)
    trace = trace_for(reference, sunrise=("NO_EVENT", None), no_event_reason="POLAR_DAY")

    report = _run(compare, (reference, trace))

    assert report.summary.agreed == 3
    assert report.summary.max_abs_delta_ms == 0


def test_flags_a_no_event_with_another_reason(compare: CompareWithReference) -> None:
    """Polar night where the reference has polar day is a discrepancy."""
    no_event = {"kind": "NO_EVENT", "event": "SUNSET", "reason": "POLAR_DAY"}
    reference = reference_day(sunset=no_event)
    trace = trace_for(reference, maghrib=("NO_EVENT", None), no_event_reason="POLAR_NIGHT")

    report = _run(compare, (reference, trace))

    [discrepancy] = report.discrepancies
    assert discrepancy.event == "MAGHRIB"
    assert discrepancy.reference_utc_ms is None


def test_flags_an_engine_instant_where_the_reference_has_none(
    compare: CompareWithReference,
) -> None:
    """An engine primary root where the Sun never crosses the horizon is a discrepancy."""
    no_event = {"kind": "NO_EVENT", "event": "SUNSET", "reason": "POLAR_NIGHT"}
    reference = reference_day(sunset=no_event)
    trace = trace_for(reference)

    report = _run(compare, (reference, trace))

    [discrepancy] = report.discrepancies
    assert (discrepancy.engine_raw_utc_ms, discrepancy.delta_ms) == (SUNSET_MS, None)


def test_ambiguous_reference_is_reported_without_blocking(compare: CompareWithReference) -> None:
    """An ambiguous reference is REFERENCE_AMBIGUITY: listed for triage, not blocking."""
    ambiguous = {"kind": "AMBIGUOUS", "event": "SUNRISE", "candidatesUtcMs": [SUNRISE_MS]}
    reference = reference_day(sunrise=ambiguous)

    report = _run(compare, (reference, trace_for(reference)))

    [discrepancy] = report.discrepancies
    assert discrepancy.classification == "REFERENCE_AMBIGUITY"
    assert report.summary.blocking == 0


def test_counts_a_bench_failure_as_blocking(compare: CompareWithReference) -> None:
    """A typed engine failure is listed with its Appendix J code and blocks promotion."""
    reference = reference_day()
    failure = BenchFailureV1.model_validate(
        {"schemaVersion": 1, "failure": {"code": "ENGINE_ORDERING", "detail": "fixture"}},
    )

    report = _run(compare, (reference, failure))

    assert [f.code for f in report.failures] == ["ENGINE_ORDERING"]
    assert (report.summary.failed_cases, report.summary.blocking) == (1, 1)


def test_rejects_a_trace_for_another_day(compare: CompareWithReference) -> None:
    """A trace that answers a different case breaks the line-order contract."""
    reference = reference_day()

    with pytest.raises(BenchContractError, match="does not answer"):
        _run(
            compare,
            (reference_day(), trace_for(reference.model_copy(update={"day": "2026-03-21"}))),
        )
