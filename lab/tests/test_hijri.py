"""ADR-016 tabular Hijri calendar: the Expected state the lab sends with requests (§15 D29)."""

from datetime import date, timedelta

import pytest
from hypothesis import given
from hypothesis import strategies as st

from dm_lab.config import HarnessConfig
from dm_lab.hijri import TabularDate, TabularHijriCalendar
from dm_lab.schema.benchmark_cities_v1 import BenchmarkCitiesV1
from tests.factories import HIJRI_2026_03_20

_RAMADAN = 9
_ONE_DAY = timedelta(days=1)


@pytest.fixture(scope="module")
def calendar(config: HarnessConfig) -> TabularHijriCalendar:
    """The calendar over the configured ADR-016 constants."""
    return TabularHijriCalendar(config.hijri)


def test_epoch_is_1_muharram_1_ah(calendar: TabularHijriCalendar) -> None:
    """JDN 1948439 (15 July 622 Julian = 0622-07-18 proleptic Gregorian) is 1/1/1 AH."""
    assert calendar.date_of(date(622, 7, 18)) == TabularDate(1, 1, 1)


def test_refuses_a_day_before_the_epoch(calendar: TabularHijriCalendar) -> None:
    """There is no tabular date before 1 Muharram 1 AH."""
    with pytest.raises(ValueError, match="precedes"):
        calendar.date_of(date(622, 7, 17))


def test_ramadan_bounds_in_the_city_file_are_the_tabular_ones(
    calendar: TabularHijriCalendar,
    city_file: BenchmarkCitiesV1,
) -> None:
    """The Ramadan days in cities.v1.json are 1 and 30 Ramadan of the tabular calendar."""
    for ramadan in city_file.date_set.ramadan:
        first = calendar.date_of(date.fromisoformat(ramadan.first_day))
        last = calendar.date_of(date.fromisoformat(ramadan.last_day))

        assert first == TabularDate(ramadan.hijri_year, _RAMADAN, 1)
        assert last == TabularDate(ramadan.hijri_year, _RAMADAN, 30)


def test_state_of_a_day_is_expected_with_the_next_day_at_night(
    calendar: TabularHijriCalendar,
) -> None:
    """At dawn the day itself, at night the following day, confidence EXPECTED (§6.2)."""
    state = calendar.state_for(date(2026, 3, 20))

    assert state.model_dump(by_alias=True) == HIJRI_2026_03_20


@given(day=st.dates(min_value=date(1900, 1, 1), max_value=date(2150, 12, 31)))
def test_consecutive_days_advance_by_exactly_one_tabular_day(
    calendar: TabularHijriCalendar,
    day: date,
) -> None:
    """The next Gregorian day is the next tabular day: day + 1, else the 1st of the next month."""
    today, tomorrow = calendar.date_of(day), calendar.date_of(day + _ONE_DAY)

    next_month = (today.year, today.month + 1) if today.month < 12 else (today.year + 1, 1)
    assert tomorrow in {
        TabularDate(today.year, today.month, today.day + 1),
        TabularDate(*next_month, 1),
    }
    if tomorrow.day == 1:
        assert today.day in {29, 30}  # every tabular month has 29 or 30 days
