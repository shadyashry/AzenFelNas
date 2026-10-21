"""Use case: run the engine over the reference cases and compare (DESIGN.md §9.4)."""

from collections.abc import Sequence
from dataclasses import dataclass
from datetime import date

from dm_lab.bench import BenchResponse, RunEngineBench, request_for
from dm_lab.compare import CompareWithReference
from dm_lab.dateset import YearRange
from dm_lab.schema.bench_request_v1 import BenchRequestV1
from dm_lab.schema.discrepancy_report_v1 import DiscrepancyReportV1
from dm_lab.schema.lab_reference_v1 import LabReferenceDayV1


@dataclass(frozen=True, slots=True)
class BenchmarkRun:
    """Everything one run produced: what was asked, what the engine answered, the verdict."""

    requests: list[BenchRequestV1]
    responses: list[BenchResponse]
    report: DiscrepancyReportV1


class RunBenchmark:
    """Select the reference cases, ask the engine, compare."""

    def __init__(self, engine: RunEngineBench, compare: CompareWithReference) -> None:
        """Compose an engine port and the comparator."""
        self._engine = engine
        self._compare = compare

    def __call__(
        self,
        references: Sequence[LabReferenceDayV1],
        *,
        city_ids: frozenset[str],
        years: YearRange,
        profile_id: str,
        reference_sha256: str,
    ) -> BenchmarkRun:
        """Benchmark the reference cases of `city_ids` within `years`.

        Raises:
            ValueError: no reference case matches the selection.
            dm_lab.bench.BenchContractError: the engine broke the bench contract.

        """
        cases = [
            reference
            for reference in references
            if reference.city_id in city_ids and years.contains(date.fromisoformat(reference.day))
        ]
        if not cases:
            msg = f"no reference case for the selected cities in {years.first}-{years.last}"
            raise ValueError(msg)
        requests = [request_for(case, profile_id) for case in cases]
        responses = self._engine(requests)
        report = self._compare(
            cases,
            responses,
            profile_id=profile_id,
            reference_sha256=reference_sha256,
        )
        return BenchmarkRun(requests=requests, responses=responses, report=report)
