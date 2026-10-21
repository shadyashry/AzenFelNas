"""Engine raw instants versus the lab reference (DESIGN.md §6.7, §9.4, §15 D26, D29).

Per compared event:
- PRIMARY reference: the engine must give a PRIMARY instant whose residual
  `raw − reference − expected offset` is within the event's tolerance. A Dhuhr residual of whole
  minutes is reported as a DHUHR_OFFSET mismatch, separately from a transit error (INSTANT).
- NO_EVENT reference: a no-event with the same reason, or a typed fallback (REQ-DOM-002), agrees.
- NEAR_TANGENT / AMBIGUOUS reference: the reference instant is ill-conditioned or absent, so a
  mismatch is REFERENCE_AMBIGUITY, listed for triage and never blocking.
Every engine-attributable mismatch is UNKNOWN and blocks promotion until a human reclassifies it.
"""

from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from typing import Literal, assert_never

from dm_lab.bench import BenchContractError, BenchResponse
from dm_lab.config import EngineEvent, ReferenceEvent, ToleranceConfig
from dm_lab.schema.bench_failure_v1 import BenchFailureV1
from dm_lab.schema.bench_request_v1 import BenchRequestV1
from dm_lab.schema.calculation_trace_v1 import (
    CalculationTraceV1,
    OriginFALLBACK,
    OriginNOEVENT,
    OriginPRIMARY,
    Time,
)
from dm_lab.schema.discrepancy_report_v1 import (
    Discrepancy,
    DiscrepancyReportV1,
    Failure,
    Summary,
)
from dm_lab.schema.lab_reference_v1 import (
    EventAMBIGUOUS,
    EventNEARTANGENT,
    EventNOEVENT,
    EventPRIMARY,
    LabReferenceDayV1,
)
from dm_lab.tolerance import near_tangent_window_ms

type Classification = Literal["REFERENCE_AMBIGUITY", "UNKNOWN"]
type Check = Literal["INSTANT", "ORIGIN", "DHUHR_OFFSET", "NEAR_TANGENT", "AMBIGUOUS_REFERENCE"]
type ReferenceDayEvent = EventPRIMARY | EventNEARTANGENT | EventNOEVENT | EventAMBIGUOUS

_COORDINATE_DECIMALS = 6
_COORDINATE_EPSILON = 5e-7
_MS_PER_MINUTE = 60_000


@dataclass(frozen=True, slots=True)
class BenchCase:
    """One benchmark case: the reference line and the request the engine answered."""

    reference: LabReferenceDayV1
    request: BenchRequestV1


@dataclass(frozen=True, slots=True)
class _Finding:
    classification: Classification
    check: Check
    reference_ms: int | None
    engine_ms: int | None
    tolerance_ms: int


@dataclass(frozen=True, slots=True)
class _Outcome:
    """`finding` is None when both sides agree; `residual_ms` feeds maxAbsDeltaMs."""

    finding: _Finding | None
    residual_ms: int | None = None


@dataclass(frozen=True, slots=True)
class _Expectation:
    """What the compared engine event should show beyond the reference instant."""

    offset_ms: int
    offset_checked: bool


class CompareWithReference:
    """Use case: the discrepancy report of one benchmark run."""

    def __init__(
        self,
        event_map: Mapping[EngineEvent, ReferenceEvent],
        tolerance: ToleranceConfig,
        *,
        dhuhr_offset_minutes: int,
    ) -> None:
        """Compare each engine event with its reference event; Dhuhr carries the run's offset."""
        self._event_map = dict(event_map)
        self._near_tangent_window_ms = near_tangent_window_ms(tolerance)
        self._expectations: dict[EngineEvent, _Expectation] = {
            "DHUHR": _Expectation(dhuhr_offset_minutes * _MS_PER_MINUTE, offset_checked=True),
        }

    def __call__(
        self,
        cases: Sequence[BenchCase],
        responses: Sequence[BenchResponse],
        *,
        profile_id: str,
        reference_sha256: str,
    ) -> DiscrepancyReportV1:
        """Compare `responses[i]` with `cases[i]` for every case.

        Raises:
            BenchContractError: counts differ, a trace answers another case or echoes another
                Hijri state, a time's shape contradicts its origin, or a compared event carries a
                non-rounding adjustment.

        """
        if len(cases) != len(responses):
            msg = f"{len(responses)} responses for {len(cases)} cases"
            raise BenchContractError(msg)
        discrepancies: list[Discrepancy] = []
        failures: list[Failure] = []
        compared = agreed = max_abs_residual = 0
        for case, response in zip(cases, responses, strict=True):
            match response:
                case BenchFailureV1(failure=failure):
                    failures.append(
                        Failure(
                            case_id=case.reference.case_id,
                            code=failure.code,
                            detail=failure.detail,
                        ),
                    )
                    continue
                case CalculationTraceV1():
                    _check_same_case(case, response)
                case _:
                    assert_never(response)
            reference_events = {event.event: event for event in case.reference.events}
            engine_times = {time.event: time for time in response.times}
            for engine_event, reference_event in self._event_map.items():
                engine_time = engine_times.get(engine_event)
                if engine_time is not None:
                    _check_time_shape(case.reference.case_id, engine_time)
                outcome = self._judge(
                    reference_events[reference_event],
                    engine_time,
                    self._expectations.get(engine_event, _Expectation(0, offset_checked=False)),
                )
                compared += 1
                if outcome.residual_ms is not None:
                    max_abs_residual = max(max_abs_residual, abs(outcome.residual_ms))
                if outcome.finding is None:
                    agreed += 1
                else:
                    discrepancies.append(
                        _discrepancy(case.reference, response, engine_event, outcome.finding),
                    )
        blocking = len(failures) + sum(d.classification == "UNKNOWN" for d in discrepancies)
        return DiscrepancyReportV1(
            schema_version=1,
            profile_id=profile_id,
            reference_sha256=reference_sha256,
            summary=Summary(
                cases=len(cases),
                failed_cases=len(failures),
                compared_events=compared,
                agreed=agreed,
                discrepancies=len(discrepancies),
                blocking=blocking,
                max_abs_delta_ms=max_abs_residual,
            ),
            discrepancies=discrepancies,
            failures=failures,
        )

    def _judge(
        self,
        reference: ReferenceDayEvent,
        engine: Time | None,
        expectation: _Expectation,
    ) -> _Outcome:
        engine_ms = None if engine is None else engine.raw_utc_ms
        match reference:
            case EventPRIMARY(reference_utc_ms=reference_ms, tolerance_ms=tolerance):
                return _judge_primary(reference_ms, tolerance, engine, expectation)
            case EventNEARTANGENT(reference_utc_ms=reference_ms):
                window = self._near_tangent_window_ms
                if _primary_within(engine, reference_ms, window):
                    return _Outcome(None)
                finding = _Finding(
                    "REFERENCE_AMBIGUITY",
                    "NEAR_TANGENT",
                    reference_ms,
                    engine_ms,
                    window,
                )
                return _Outcome(finding)
            case EventNOEVENT(reason=reason):
                if _no_event_agrees(reason, engine):
                    return _Outcome(None)
                return _Outcome(_Finding("UNKNOWN", "ORIGIN", None, engine_ms, 0))
            case EventAMBIGUOUS():
                finding = _Finding("REFERENCE_AMBIGUITY", "AMBIGUOUS_REFERENCE", None, engine_ms, 0)
                return _Outcome(finding)
            case _:
                assert_never(reference)


def _judge_primary(
    reference_ms: int,
    tolerance_ms: int,
    engine: Time | None,
    expectation: _Expectation,
) -> _Outcome:
    """Judge a reference root: the engine needs a primary instant within tolerance (REQ-DOM-002)."""
    if engine is None or engine.raw_utc_ms is None:
        return _Outcome(_Finding("UNKNOWN", "ORIGIN", reference_ms, None, tolerance_ms))
    engine_ms = engine.raw_utc_ms
    match engine.origin:
        case OriginPRIMARY():
            residual = engine_ms - reference_ms - expectation.offset_ms
            if abs(residual) <= tolerance_ms:
                return _Outcome(None, residual)
            whole_minutes = round(residual / _MS_PER_MINUTE)
            offset_only = (
                expectation.offset_checked
                and whole_minutes != 0
                and abs(residual - whole_minutes * _MS_PER_MINUTE) <= tolerance_ms
            )
            check: Check = "DHUHR_OFFSET" if offset_only else "INSTANT"
            finding = _Finding("UNKNOWN", check, reference_ms, engine_ms, tolerance_ms)
            return _Outcome(finding, residual)
        case OriginFALLBACK() | OriginNOEVENT():
            return _Outcome(_Finding("UNKNOWN", "ORIGIN", reference_ms, engine_ms, tolerance_ms))
        case _:
            assert_never(engine.origin)


def _primary_within(engine: Time | None, reference_ms: int, window_ms: int) -> bool:
    """Whether the engine gives a primary instant within `window_ms` of the reference."""
    if engine is None or engine.raw_utc_ms is None:
        return False
    match engine.origin:
        case OriginPRIMARY():
            return abs(engine.raw_utc_ms - reference_ms) <= window_ms
        case OriginFALLBACK() | OriginNOEVENT():
            return False
        case _:
            assert_never(engine.origin)


def _no_event_agrees(reason: str, engine: Time | None) -> bool:
    """Judge a reference no-event: a no-event of the same reason, or a typed fallback, agrees.

    A fallback is legitimate exactly when no primary root exists (REQ-DOM-002).
    """
    if engine is None:
        return False
    match engine.origin:
        case OriginNOEVENT(reason=engine_reason):
            return engine_reason == reason
        case OriginFALLBACK():
            return True
        case OriginPRIMARY():
            return False
        case _:
            assert_never(engine.origin)


def _check_same_case(case: BenchCase, trace: CalculationTraceV1) -> None:
    """Require the trace to answer its request: same day, place, profile and Hijri state."""
    inputs = trace.inputs
    observer = case.request.observer
    same = (
        trace.day == case.request.day
        and inputs.day == case.request.day
        and inputs.zone_id == observer.zone_id
        and inputs.profile_id == case.request.profile_id
        and _same_coordinate(inputs.lat, observer.latitude_deg)
        and _same_coordinate(inputs.lon, observer.longitude_deg)
        and inputs.hijri.model_dump() == case.request.hijri.model_dump()
    )
    if not same:
        msg = f"trace {trace.calculation_id} does not answer case {case.reference.case_id}"
        raise BenchContractError(msg)


def _same_coordinate(trace_value: float, request_value: float) -> bool:
    return abs(trace_value - round(request_value, _COORDINATE_DECIMALS)) <= _COORDINATE_EPSILON


def _check_time_shape(case_id: str, time: Time) -> None:
    """Instants exist exactly when the origin has one; compared events carry no adjustments.

    A no-event carrying an instant would be an invented time passing the gate (§0.2 rule 10);
    a per-event adjustment would make the raw instant incomparable with the reference (§15 D29).
    """
    instants = (time.raw_utc_ms, time.displayed_utc_ms, time.day_offset)
    match time.origin:
        case OriginNOEVENT():
            shape_ok = all(value is None for value in instants)
        case OriginPRIMARY() | OriginFALLBACK():
            shape_ok = all(value is not None for value in instants)
        case _:
            assert_never(time.origin)
    if not shape_ok:
        msg = f"{case_id} {time.event}: instants do not match origin {time.origin.kind}"
        raise BenchContractError(msg)
    adjusted = [step.kind for step in time.adjustment_trace if step.kind != "ROUNDING"]
    if adjusted:
        msg = f"{case_id} {time.event}: adjustments {adjusted} make the raw instant incomparable"
        raise BenchContractError(msg)


def _discrepancy(
    reference: LabReferenceDayV1,
    trace: CalculationTraceV1,
    event: EngineEvent,
    finding: _Finding,
) -> Discrepancy:
    provenance = trace.provenance
    delta = (
        None
        if finding.reference_ms is None or finding.engine_ms is None
        else finding.engine_ms - finding.reference_ms
    )
    return Discrepancy(
        case_id=reference.case_id,
        city=reference.city_id,
        lat=reference.latitude_deg,
        lon=reference.longitude_deg,
        day=reference.day,
        event=event,
        engine_version=provenance.engine_version,
        profile_id=provenance.profile_id,
        profile_version=provenance.profile_version,
        tzdb_version=provenance.tzdb_version,
        reference_utc_ms=finding.reference_ms,
        engine_raw_utc_ms=finding.engine_ms,
        delta_ms=delta,
        tolerance_ms=finding.tolerance_ms,
        check=finding.check,
        classification=finding.classification,
    )
