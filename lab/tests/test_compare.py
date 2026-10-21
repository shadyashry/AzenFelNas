"""Engine raw instants versus the reference (DESIGN.md §6.7, §15 D26, D29)."""

import pytest

from dm_lab.bench import BenchContractError, BenchResponse
from dm_lab.compare import CompareWithReference
from dm_lab.config import HarnessConfig
from dm_lab.schema.bench_failure_v1 import BenchFailureV1
from dm_lab.schema.discrepancy_report_v1 import DiscrepancyReportV1
from dm_lab.schema.lab_reference_v1 import LabReferenceDayV1
from tests.factories import (
    SUNRISE_MS,
    SUNSET_MS,
    TRANSIT_MS,
    case_for,
    reference_day,
    trace_for,
    with_time,
)

_SHA = "f" * 64
_MINUTE_MS = 60_000


def _compare(config: HarnessConfig, *, dhuhr_offset_minutes: int = 0) -> CompareWithReference:
    return CompareWithReference(
        config.benchmark.event_map,
        config.tolerance,
        dhuhr_offset_minutes=dhuhr_offset_minutes,
    )


def _run(
    compare: CompareWithReference,
    reference: LabReferenceDayV1,
    response: BenchResponse,
) -> DiscrepancyReportV1:
    return compare(
        [case_for(reference)],
        [response],
        profile_id="engine.default",
        reference_sha256=_SHA,
    )


def test_agrees_within_tolerance_req_test_003(config: HarnessConfig) -> None:
    """REQ-TEST-003: residuals within each event's tolerance agree and do not block."""
    reference = reference_day()
    trace = trace_for(
        reference,
        sunrise=("PRIMARY", SUNRISE_MS + 300),
        dhuhr=("PRIMARY", TRANSIT_MS - 240),
    )

    report = _run(_compare(config), reference, trace)

    assert (report.summary.agreed, report.summary.blocking) == (3, 0)
    assert report.summary.max_abs_delta_ms == 300


def test_flags_an_instant_outside_tolerance_as_blocking_req_test_003(config: HarnessConfig) -> None:
    """REQ-TEST-003: 241 ms off a 240 ms Dhuhr tolerance is a blocking INSTANT mismatch (§6.7)."""
    reference = reference_day()
    trace = trace_for(reference, dhuhr=("PRIMARY", TRANSIT_MS + 241))

    report = _run(_compare(config), reference, trace)

    [discrepancy] = report.discrepancies
    assert (discrepancy.event, discrepancy.check, discrepancy.classification) == (
        "DHUHR",
        "INSTANT",
        "UNKNOWN",
    )
    assert (discrepancy.delta_ms, discrepancy.tolerance_ms) == (241, 240)
    assert report.summary.blocking == 1


def test_checks_the_dhuhr_offset_separately_from_the_transit(config: HarnessConfig) -> None:
    """A configured 2-minute Dhuhr offset is removed before the transit residual is judged."""
    reference = reference_day()
    trace = trace_for(reference, dhuhr=("PRIMARY", TRANSIT_MS + 2 * _MINUTE_MS + 100))

    report = _run(_compare(config, dhuhr_offset_minutes=2), reference, trace)

    assert report.discrepancies == []
    assert report.summary.max_abs_delta_ms == 100


def test_reports_a_wrong_dhuhr_offset_as_an_offset_mismatch(config: HarnessConfig) -> None:
    """An engine that ignored a 2-minute offset is a DHUHR_OFFSET mismatch, not a transit error."""
    reference = reference_day()
    trace = trace_for(reference, dhuhr=("PRIMARY", TRANSIT_MS + 50))

    report = _run(_compare(config, dhuhr_offset_minutes=2), reference, trace)

    [discrepancy] = report.discrepancies
    assert (discrepancy.check, discrepancy.delta_ms) == ("DHUHR_OFFSET", 50)


def test_whole_minute_error_on_another_event_is_an_instant_mismatch(config: HarnessConfig) -> None:
    """Only Dhuhr has an offset to check; a Maghrib a minute late is simply wrong."""
    reference = reference_day()
    trace = trace_for(reference, maghrib=("PRIMARY", SUNSET_MS + _MINUTE_MS))

    report = _run(_compare(config), reference, trace)

    [discrepancy] = report.discrepancies
    assert (discrepancy.event, discrepancy.check) == ("MAGHRIB", "INSTANT")


def test_flags_a_fallback_where_a_primary_root_exists_req_dom_002(config: HarnessConfig) -> None:
    """REQ-DOM-002: a fallback is never used when a primary root exists, even if close in time."""
    reference = reference_day()
    trace = trace_for(reference, sunrise=("FALLBACK", SUNRISE_MS))

    report = _run(_compare(config), reference, trace)

    [discrepancy] = report.discrepancies
    assert (discrepancy.event, discrepancy.check) == ("SUNRISE", "ORIGIN")


def test_accepts_a_typed_no_event_with_the_reference_reason_req_dom_002(
    config: HarnessConfig,
) -> None:
    """REQ-DOM-002: polar day on both sides agrees; no instant is invented."""
    reference = reference_day(
        sunrise={"kind": "NO_EVENT", "event": "SUNRISE", "reason": "POLAR_DAY"}
    )
    trace = trace_for(reference, sunrise=("NO_EVENT", None), no_event_reason="POLAR_DAY")

    report = _run(_compare(config), reference, trace)

    assert report.summary.agreed == 3


def test_flags_a_no_event_with_another_reason(config: HarnessConfig) -> None:
    """Polar night where the reference has polar day is an ORIGIN mismatch."""
    reference = reference_day(sunset={"kind": "NO_EVENT", "event": "SUNSET", "reason": "POLAR_DAY"})
    trace = trace_for(reference, maghrib=("NO_EVENT", None), no_event_reason="POLAR_NIGHT")

    report = _run(_compare(config), reference, trace)

    [discrepancy] = report.discrepancies
    assert (discrepancy.event, discrepancy.check, discrepancy.reference_utc_ms) == (
        "MAGHRIB",
        "ORIGIN",
        None,
    )


def test_flags_an_engine_instant_where_the_reference_has_none(config: HarnessConfig) -> None:
    """An engine primary root where the Sun never crosses the horizon is a mismatch."""
    reference = reference_day(
        sunset={"kind": "NO_EVENT", "event": "SUNSET", "reason": "POLAR_NIGHT"}
    )

    report = _run(_compare(config), reference, trace_for(reference))

    [discrepancy] = report.discrepancies
    assert (discrepancy.engine_raw_utc_ms, discrepancy.delta_ms) == (SUNSET_MS, None)


def test_near_tangent_reference_accepts_an_instant_within_the_cap(config: HarnessConfig) -> None:
    """A near-tangent crossing is graded explicitly: a primary instant within 60 s agrees."""
    near = {
        "kind": "NEAR_TANGENT",
        "event": "SUNRISE",
        "referenceUtcMs": SUNRISE_MS,
        "rateDegPerS": 1e-6,
    }
    reference = reference_day(sunrise=near)
    trace = trace_for(reference, sunrise=("PRIMARY", SUNRISE_MS + 59_000))

    report = _run(_compare(config), reference, trace)

    assert report.summary.agreed == 3
    assert report.summary.max_abs_delta_ms == 0


def test_near_tangent_reference_never_blocks(config: HarnessConfig) -> None:
    """An engine no-event against a near-tangent reference is listed for triage, not blocking."""
    near = {
        "kind": "NEAR_TANGENT",
        "event": "SUNSET",
        "referenceUtcMs": SUNSET_MS,
        "rateDegPerS": -1e-6,
    }
    reference = reference_day(sunset=near)
    trace = trace_for(reference, maghrib=("NO_EVENT", None))

    report = _run(_compare(config), reference, trace)

    [discrepancy] = report.discrepancies
    assert (discrepancy.check, discrepancy.classification) == (
        "NEAR_TANGENT",
        "REFERENCE_AMBIGUITY",
    )
    assert report.summary.blocking == 0


def test_ambiguous_reference_is_reported_without_blocking(config: HarnessConfig) -> None:
    """An ambiguous reference is REFERENCE_AMBIGUITY: listed for triage, not blocking."""
    ambiguous = {"kind": "AMBIGUOUS", "event": "SUNRISE", "candidatesUtcMs": [SUNRISE_MS]}
    reference = reference_day(sunrise=ambiguous)

    report = _run(_compare(config), reference, trace_for(reference))

    [discrepancy] = report.discrepancies
    assert (discrepancy.check, discrepancy.classification) == (
        "AMBIGUOUS_REFERENCE",
        "REFERENCE_AMBIGUITY",
    )
    assert report.summary.blocking == 0


def test_counts_a_bench_failure_as_blocking(config: HarnessConfig) -> None:
    """A typed engine failure is listed with its Appendix J code and blocks promotion."""
    failure = BenchFailureV1.model_validate(
        {"schemaVersion": 1, "failure": {"code": "ENGINE_ORDERING", "detail": "fixture"}},
    )

    report = _run(_compare(config), reference_day(), failure)

    assert [f.code for f in report.failures] == ["ENGINE_ORDERING"]
    assert (report.summary.failed_cases, report.summary.blocking) == (1, 1)


def test_rejects_a_no_event_that_carries_an_instant(config: HarnessConfig) -> None:
    """§0.2 rule 10: a no-event with a time is an invented instant; it breaks the contract."""
    reference = reference_day()
    trace = with_time(
        trace_for(reference, sunrise=("NO_EVENT", None)),
        "SUNRISE",
        {"rawUtcMs": SUNRISE_MS, "displayedUtcMs": SUNRISE_MS, "dayOffset": 0},
    )

    with pytest.raises(BenchContractError, match="do not match origin NO_EVENT"):
        _run(_compare(config), reference, trace)


def test_rejects_a_primary_time_without_an_instant(config: HarnessConfig) -> None:
    """A primary origin without its raw instant breaks the contract."""
    reference = reference_day()
    trace = with_time(trace_for(reference), "DHUHR", {"rawUtcMs": None})

    with pytest.raises(BenchContractError, match="do not match origin PRIMARY"):
        _run(_compare(config), reference, trace)


def test_rejects_a_compared_event_with_a_per_event_adjustment(config: HarnessConfig) -> None:
    """A per-event offset makes the raw instant incomparable with the reference (§15 D29)."""
    reference = reference_day()
    step = {"event": "MAGHRIB", "kind": "PER_EVENT_OFFSET", "deltaMs": 60_000, "reason": "fixture"}
    trace = with_time(trace_for(reference), "MAGHRIB", {"adjustmentTrace": [step]})

    with pytest.raises(BenchContractError, match="incomparable"):
        _run(_compare(config), reference, trace)


def test_rejects_a_trace_for_another_day(config: HarnessConfig) -> None:
    """A trace that answers a different case breaks the line-order contract."""
    reference = reference_day()
    other_day = trace_for(reference.model_copy(update={"day": "2026-03-21"}))

    with pytest.raises(BenchContractError, match="does not answer"):
        _run(_compare(config), reference, other_day)


def test_rejects_a_trace_that_does_not_echo_the_hijri_state(config: HarnessConfig) -> None:
    """The engine must use the Hijri state it was given, not one of its own (§15 D29)."""
    reference = reference_day()
    trace = trace_for(reference)
    document = trace.model_dump(mode="json", exclude_none=True)
    document["inputs"]["hijri"]["dateAtDawn"]["day"] = 1
    other_state = type(trace).model_validate(document)

    with pytest.raises(BenchContractError, match="does not answer"):
        _run(_compare(config), reference, other_state)
