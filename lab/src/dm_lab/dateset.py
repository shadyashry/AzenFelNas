"""The Appendix H benchmark date set of one city (DESIGN.md Appendix H, §15 D30).

Both solstices and both equinoxes (the civil date of each instant in the city's zone), the
configured day of every month, every UTC-offset transition day ± the configured window, and the
first and last day of each listed Ramadan, all clipped to the requested years.
"""

from collections.abc import Mapping
from dataclasses import dataclass
from datetime import UTC, date, datetime, time, timedelta, tzinfo
from typing import Literal, Protocol

from dm_lab.schema.benchmark_cities_v1 import DateSet
from dm_lab.sky import Season

type DateTag = Literal[
    "MARCH_EQUINOX",
    "JUNE_SOLSTICE",
    "SEPTEMBER_EQUINOX",
    "DECEMBER_SOLSTICE",
    "DAY_OF_MONTH",
    "DST_WINDOW",
    "RAMADAN_FIRST_DAY",
    "RAMADAN_LAST_DAY",
]

# lab_reference.v1 tags order; a day's tags are emitted in this order.
TAG_ORDER: tuple[DateTag, ...] = (
    "MARCH_EQUINOX",
    "JUNE_SOLSTICE",
    "SEPTEMBER_EQUINOX",
    "DECEMBER_SOLSTICE",
    "DAY_OF_MONTH",
    "DST_WINDOW",
    "RAMADAN_FIRST_DAY",
    "RAMADAN_LAST_DAY",
)
_MONTHS = 12
_NOON = time(12)
_EPOCH = datetime(1970, 1, 1, tzinfo=UTC)
_ONE_DAY = timedelta(days=1)


class SeasonInstants(Protocol):
    """Port: the equinox and solstice instants (UTC epoch ms) of a UTC calendar year."""

    def season_instants_ms(self, year: int) -> Mapping[Season, int]:
        """Instants of the year's four seasons."""
        ...


@dataclass(frozen=True, slots=True)
class YearRange:
    """Inclusive range of Gregorian years."""

    first: int
    last: int

    def __post_init__(self) -> None:
        """Reject an empty range."""
        if self.first > self.last:
            msg = f"empty year range {self.first}-{self.last}"
            raise ValueError(msg)

    @property
    def start(self) -> date:
        """1 January of the first year."""
        return date(self.first, 1, 1)

    @property
    def end(self) -> date:
        """31 December of the last year."""
        return date(self.last, 12, 31)

    def contains(self, day: date) -> bool:
        """Whether `day` lies in the range."""
        return self.start <= day <= self.end


@dataclass(frozen=True, slots=True)
class BenchmarkDay:
    """A selected day and why it was selected, tags in `TAG_ORDER`."""

    day: date
    tags: tuple[DateTag, ...]


class SelectBenchmarkDays:
    """Use case: the Appendix H days of one city over a year range."""

    def __init__(self, seasons: SeasonInstants) -> None:
        """Create the selector over a season-instant source; instants are cached per year."""
        self._seasons = seasons
        self._season_cache: dict[int, Mapping[Season, int]] = {}

    def __call__(self, zone: tzinfo, date_set: DateSet, years: YearRange) -> list[BenchmarkDay]:
        """Every selected day of the city whose zone is `zone`, in date order."""
        tags: dict[date, set[DateTag]] = {}

        def add(day: date, tag: DateTag) -> None:
            if years.contains(day):
                tags.setdefault(day, set()).add(tag)

        for year in range(years.first, years.last + 1):
            instants = self._season_instants(year)
            for season in date_set.seasons:
                add(_local_date(instants[season], zone), season)
            for month in range(1, _MONTHS + 1):
                add(date(year, month, date_set.day_of_month), "DAY_OF_MONTH")
        window = timedelta(days=date_set.dst_window_days)
        for transition in _offset_transition_days(zone, years.start - window, years.end + window):
            day = transition - window
            while day <= transition + window:
                add(day, "DST_WINDOW")
                day += _ONE_DAY
        for ramadan in date_set.ramadan:
            add(date.fromisoformat(ramadan.first_day), "RAMADAN_FIRST_DAY")
            add(date.fromisoformat(ramadan.last_day), "RAMADAN_LAST_DAY")
        return [
            BenchmarkDay(day, tuple(tag for tag in TAG_ORDER if tag in day_tags))
            for day, day_tags in sorted(tags.items())
        ]

    def _season_instants(self, year: int) -> Mapping[Season, int]:
        cached = self._season_cache.get(year)
        if cached is None:
            cached = self._seasons.season_instants_ms(year)
            self._season_cache[year] = cached
        return cached


def _local_date(utc_ms: int, zone: tzinfo) -> date:
    return (_EPOCH + timedelta(milliseconds=utc_ms)).astimezone(zone).date()


def _noon_offset(day: date, zone: tzinfo) -> timedelta:
    offset = datetime.combine(day, _NOON, tzinfo=zone).utcoffset()
    if offset is None:
        msg = f"zone {zone} has no UTC offset on {day}"
        raise ValueError(msg)
    return offset


def _offset_transition_days(zone: tzinfo, start: date, end: date) -> list[date]:
    """Days in [start, end] whose local-noon UTC offset differs from the previous day's."""
    days: list[date] = []
    previous = _noon_offset(start - _ONE_DAY, zone)
    day = start
    while day <= end:
        current = _noon_offset(day, zone)
        if current != previous:
            days.append(day)
        previous = current
        day += _ONE_DAY
    return days
