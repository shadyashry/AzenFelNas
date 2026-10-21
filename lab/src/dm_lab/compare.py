"""Engine raw instants versus the lab reference under the ADR-019 tolerance (DESIGN.md §6.7, §9.4).

Every engine-attributable mismatch is classified UNKNOWN and blocks promotion until a human
reclassifies it; an ambiguous reference is REFERENCE_AMBIGUITY and does not block (§15 D29).
"""

from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from typing import Literal, assert_never

from dm_lab.bench import BenchContractError, BenchResponse
from dm_lab.config import EngineEvent, ReferenceEvent
from dm_lab.schema.bench_failure_v1 import BenchFailureV1
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
    EventNOEVENT,
    EventPRIMARY,
    LabReferenceDayV1,
)

type Classification = Literal["REFERENCE_AMBIGUITY", "UNKNOWN"]

_COORDINATE_DECIMALS = 6
_COORDINATE_EPSILON = 5e-7


@dataclass(frozen=True, slots=True)
class _Verdict:
    """Outcome of one compared event; `classification` is None when both sides agree."""

    classification: Classification | None
    reference_ms: int | None
    engine_ms: int | None
    tolerance_ms: int

    @property
    def delta_ms(self) -> int | None:
        if self.reference_ms is None or self.engine_ms is None:
            return None
        return self.engine_ms - self.reference_ms


class CompareWithReference:
    """Use case: the discrepancy report of one benchmark run."""

    def __init__(self, event_map: Mapping[EngineEvent, ReferenceEvent]) -> None:
        """Compare each engine event with the reference event `event_map` assigns to it."""
        self._event_map = dict(event_map)

    def __call__(
        self,
        references: Sequence[LabReferenceDayV1],
        responses: Sequence[BenchResponse],
        *,
        profile_id: str,
        reference_sha256: str,
    ) -> DiscrepancyReportV1:
        """Compare `responses[i]` with `references[i]` for every case.

        Raises:
            BenchContractError: counts differ, or a trace answers another case than its request.

        """
        if len(references) != len(responses):
            msg = f"{len(responses)} responses for {len(references)} cases"
            raise BenchContractError(msg)
        discrepancies: list[Discrepancy] = []
        failures: list[Failure] = []
        compared = agreed = max_abs_delta = 0
        for reference, response in zip(references, responses, strict=True):
            match response:
                case BenchFailureV1(failure=failure):
                    failures.append(
                        Failure(
                            case_id=reference.case_id,
                            code=failure.code,
                            detail=failure.detail,
                        ),
                    )
                    continue
                case CalculationTraceV1():
                    _check_same_case(reference, response, profile_id)
                case _:
                    assert_never(response)
            reference_events = {event.event: event for event in reference.events}
            engine_times = {time.event: time for time in response.times}
            for engine_event, reference_event in self._event_map.items():
                verdict = _judge(reference_events[reference_event], engine_times.get(engine_event))
                compared += 1
                if verdict.delta_ms is not None:
                    max_abs_delta = max(max_abs_delta, abs(verdict.delta_ms))
                if verdict.classification is None:
                    agreed += 1
                else:
                    discrepancies.append(_discrepancy(reference, response, engine_event, verdict))
        blocking = len(failures) + sum(d.classification == "UNKNOWN" for d in discrepancies)
        return DiscrepancyReportV1(
            schema_version=1,
            profile_id=profile_id,
            reference_sha256=reference_sha256,
            summary=Summary(
                cases=len(references),
                failed_cases=len(failures),
                compared_events=compared,
                agreed=agreed,
                discrepancies=len(discrepancies),
                blocking=blocking,
                max_abs_delta_ms=max_abs_delta,
            ),
            discrepancies=discrepancies,
            failures=failures,
        )


def _check_same_case(
    reference: LabReferenceDayV1,
    trace: CalculationTraceV1,
    profile_id: str,
) -> None:
    inputs = trace.inputs
    same = (
        trace.day == reference.day
        and inputs.day == reference.day
        and inputs.zone_id == reference.zone_id
        and inputs.profile_id == profile_id
        and abs(inputs.lat - round(reference.latitude_deg, _COORDINATE_DECIMALS))
        <= _COORDINATE_EPSILON
        and abs(inputs.lon - round(reference.longitude_deg, _COORDINATE_DECIMALS))
        <= _COORDINATE_EPSILON
    )
    if not same:
        msg = f"trace {trace.calculation_id} does not answer case {reference.case_id}"
        raise BenchContractError(msg)


def _judge(
    reference: EventPRIMARY | EventNOEVENT | EventAMBIGUOUS,
    engine: Time | None,
) -> _Verdict:
    engine_ms = None if engine is None else engine.raw_utc_ms
    match reference:
        case EventAMBIGUOUS():
            return _Verdict("REFERENCE_AMBIGUITY", None, engine_ms, 0)
        case EventPRIMARY(reference_utc_ms=reference_ms, tolerance_ms=tolerance):
            agrees = _primary_agrees(engine, reference_ms, tolerance)
            return _Verdict(None if agrees else "UNKNOWN", reference_ms, engine_ms, tolerance)
        case EventNOEVENT(reason=reason):
            agrees = _no_event_agrees(reason, engine)
            return _Verdict(None if agrees else "UNKNOWN", None, engine_ms, 0)
        case _:
            assert_never(reference)


def _primary_agrees(engine: Time | None, reference_ms: int, tolerance_ms: int) -> bool:
    """Decide a reference root: the engine must give a primary instant within the tolerance.

    A fallback or no-event where a primary root exists is a discrepancy (REQ-DOM-002).
    """
    if engine is None or engine.raw_utc_ms is None:
        return False
    match engine.origin:
        case OriginPRIMARY():
            return abs(engine.raw_utc_ms - reference_ms) <= tolerance_ms
        case OriginFALLBACK() | OriginNOEVENT():
            return False
        case _:
            assert_never(engine.origin)


def _no_event_agrees(reason: str, engine: Time | None) -> bool:
    """Decide a reference no-event: a no-event of the same reason, or a typed fallback, agrees.

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


def _discrepancy(
    reference: LabReferenceDayV1,
    trace: CalculationTraceV1,
    event: EngineEvent,
    verdict: _Verdict,
) -> Discrepancy:
    classification = verdict.classification
    if classification is None:
        msg = "an agreeing verdict is not a discrepancy"
        raise ValueError(msg)
    provenance = trace.provenance
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
        reference_utc_ms=verdict.reference_ms,
        engine_raw_utc_ms=verdict.engine_ms,
        delta_ms=verdict.delta_ms,
        tolerance_ms=verdict.tolerance_ms,
        classification=classification,
    )
