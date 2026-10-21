"""Use case: run the engine over the reference cases and compare (DESIGN.md §9.4, §15 D29)."""

from collections.abc import Sequence
from dataclasses import dataclass
from datetime import date

from dm_lab.bench import BenchResponse, RunEngineBench, request_for
from dm_lab.compare import BenchCase, CompareWithReference
from dm_lab.dateset import DateTag, YearRange
from dm_lab.hijri import TabularHijriCalendar
from dm_lab.schema.bench_request_v1 import BenchRequestV1
from dm_lab.schema.discrepancy_report_v1 import DiscrepancyReportV1
from dm_lab.schema.lab_reference_v1 import LabReferenceDayV1


@dataclass(frozen=True, slots=True)
class BenchmarkRun:
    """Everything one run produced: what was asked, what the engine answered, the verdict."""

    requests: list[BenchRequestV1]
    responses: list[BenchResponse]
    report: DiscrepancyReportV1


@dataclass(frozen=True, slots=True)
class CaseSelection:
    """Which reference cases a run covers; `tags` None means every tag."""

    city_ids: frozenset[str]
    years: YearRange
    tags: frozenset[DateTag] | None = None

    def covers(self, reference: LabReferenceDayV1) -> bool:
        """Whether `reference` belongs to the selection."""
        in_tags = self.tags is None or not self.tags.isdisjoint(reference.tags)
        return (
            reference.city_id in self.city_ids
            and self.years.contains(date.fromisoformat(reference.day))
            and in_tags
        )


class RunBenchmark:
    """Select the reference cases, ask the engine, compare."""

    def __init__(
        self,
        engine: RunEngineBench,
        compare: CompareWithReference,
        calendar: TabularHijriCalendar,
        allowed_profiles: frozenset[str],
    ) -> None:
        """Compose an engine port, the comparator, the Hijri source and the profile allow-list."""
        self._engine = engine
        self._compare = compare
        self._calendar = calendar
        self._allowed_profiles = allowed_profiles

    def __call__(
        self,
        references: Sequence[LabReferenceDayV1],
        selection: CaseSelection,
        *,
        profile_id: str,
        reference_sha256: str,
    ) -> BenchmarkRun:
        """Benchmark the reference cases in `selection` with `profile_id`.

        Raises:
            ValueError: the profile is not one the comparison is valid for, or no case matches.
            dm_lab.bench.BenchContractError: the engine broke the bench contract.

        """
        if profile_id not in self._allowed_profiles:
            msg = (
                f"profile {profile_id} is not benchmarkable against the sun-event reference; "
                f"allowed: {sorted(self._allowed_profiles)} (DESIGN.md §15 D29)"
            )
            raise ValueError(msg)
        cases = [
            BenchCase(
                reference,
                request_for(
                    reference,
                    profile_id,
                    self._calendar.state_for(date.fromisoformat(reference.day)),
                ),
            )
            for reference in references
            if selection.covers(reference)
        ]
        if not cases:
            msg = "no reference case matches the selected cities, years and tags"
            raise ValueError(msg)
        requests = [case.request for case in cases]
        responses = self._engine(requests)
        report = self._compare(
            cases,
            responses,
            profile_id=profile_id,
            reference_sha256=reference_sha256,
        )
        return BenchmarkRun(requests=requests, responses=responses, report=report)
