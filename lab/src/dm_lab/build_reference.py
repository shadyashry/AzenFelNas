"""Use case: the reference lines of every benchmark city and day over a year range (§9.4)."""

from dm_lab.dateset import SelectBenchmarkDays, YearRange
from dm_lab.reference import CalculateReferenceDay, ZoneLookup
from dm_lab.schema.benchmark_cities_v1 import BenchmarkCitiesV1
from dm_lab.schema.lab_reference_v1 import LabReferenceDayV1


class BuildReference:
    """All lab_reference.v1 lines, in city-file order then date order."""

    def __init__(
        self,
        zones: ZoneLookup,
        select_days: SelectBenchmarkDays,
        calculate_day: CalculateReferenceDay,
    ) -> None:
        """Compose the day selection and the per-day calculation."""
        self._zones = zones
        self._select_days = select_days
        self._calculate_day = calculate_day

    def __call__(self, cities: BenchmarkCitiesV1, years: YearRange) -> list[LabReferenceDayV1]:
        """Compute the reference lines of `cities` over `years`."""
        lines: list[LabReferenceDayV1] = []
        for city in cities.cities:
            zone = self._zones.zone(city.zone_id)
            lines.extend(
                self._calculate_day(city, day)
                for day in self._select_days(zone, cities.date_set, years)
            )
        return lines
