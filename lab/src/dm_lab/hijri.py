"""ADR-016 tabular Islamic calendar: the `Expected` Hijri state the lab sends with bench requests.

Only a stand-in until the signed hijri package exists (DESIGN.md §15 D29): the engine must echo the
state it was given, so the lab supplies one instead of letting the bench invent it (§0.2 rule 10).
The calendar constants are read from `harness.v1.toml` [hijri].
"""

from dataclasses import dataclass
from datetime import date, timedelta

from dm_lab.config import HijriConfig
from dm_lab.schema.bench_request_v1 import Hijri, HijriDate

# date.toordinal() + this = Julian Day Number (2000-01-01 → 2451545).
_JDN_OF_ORDINAL_ZERO = 1_721_425
_COMMON_YEAR_DAYS = 354
_MONTHS = 12
_LONG_MONTH = 30
_SHORT_MONTH = 29
_ONE_DAY = timedelta(days=1)


@dataclass(frozen=True, slots=True, order=True)
class TabularDate:
    """A date of the tabular calendar."""

    year: int
    month: int
    day: int


class TabularHijriCalendar:
    """Gregorian date → tabular Hijri date and the §6.2 `HijriState` of a prayer day."""

    def __init__(self, config: HijriConfig) -> None:
        """Create the calendar from the ADR-016 constants."""
        self._config = config
        self._cycle_days = config.cycle_years * _COMMON_YEAR_DAYS + len(config.leap_years)

    def date_of(self, day: date) -> TabularDate:
        """Return the tabular Hijri date that `day` falls on.

        Raises:
            ValueError: `day` precedes the calendar's epoch.

        """
        elapsed = day.toordinal() + _JDN_OF_ORDINAL_ZERO - self._config.epoch_jdn
        if elapsed < 0:
            msg = f"{day} precedes the tabular epoch"
            raise ValueError(msg)
        cycles, remaining = divmod(elapsed, self._cycle_days)
        year_in_cycle = 1
        while remaining >= self._year_days(year_in_cycle):
            remaining -= self._year_days(year_in_cycle)
            year_in_cycle += 1
        month = 1
        while remaining >= self._month_days(year_in_cycle, month):
            remaining -= self._month_days(year_in_cycle, month)
            month += 1
        return TabularDate(cycles * self._config.cycle_years + year_in_cycle, month, remaining + 1)

    def state_for(self, day: date) -> Hijri:
        """Return the `Expected` state of prayer day `day` (dawn: `day`; night: the next day)."""
        return Hijri(
            date_at_dawn=_wire(self.date_of(day)),
            date_at_night=_wire(self.date_of(day + _ONE_DAY)),
            confidence="EXPECTED",
        )

    def _year_days(self, year_in_cycle: int) -> int:
        return _COMMON_YEAR_DAYS + (year_in_cycle in self._config.leap_years)

    def _month_days(self, year_in_cycle: int, month: int) -> int:
        if month == _MONTHS and year_in_cycle in self._config.leap_years:
            return _LONG_MONTH
        return _LONG_MONTH if month % 2 else _SHORT_MONTH


def _wire(tabular: TabularDate) -> HijriDate:
    return HijriDate(year=tabular.year, month=tabular.month, day=tabular.day)
