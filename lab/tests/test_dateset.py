"""The Appendix H benchmark date set (DESIGN.md Appendix H, §15 D30)."""

from collections.abc import Mapping
from datetime import UTC, date, datetime

import pytest
from hypothesis import given, settings
from hypothesis import strategies as st

from dm_lab.dateset import TAG_ORDER, SelectBenchmarkDays, YearRange
from dm_lab.schema.benchmark_cities_v1 import BenchmarkCitiesV1, DateSet
from dm_lab.sky import Season
from dm_lab.tzdb import PinnedTzdb


def _ms(text: str) -> int:
    return round(datetime.fromisoformat(text).timestamp() * 1000)


class _FakeSeasons:
    """Fake `SeasonInstants` port: the same instant every year (shape data, not astronomy)."""

    def season_instants_ms(self, year: int) -> Mapping[Season, int]:
        return {
            "MARCH_EQUINOX": _ms(f"{year}-03-20T14:46:00+00:00"),
            "JUNE_SOLSTICE": _ms(f"{year}-06-21T08:24:00+00:00"),
            "SEPTEMBER_EQUINOX": _ms(f"{year}-09-23T00:05:00+00:00"),
            "DECEMBER_SOLSTICE": _ms(f"{year}-12-21T20:50:00+00:00"),
        }


def _days_tagged(days: list[tuple[date, tuple[str, ...]]], tag: str) -> list[date]:
    return [day for day, tags in days if tag in tags]


def _select(
    zone_id: str, date_set: DateSet, years: YearRange
) -> list[tuple[date, tuple[str, ...]]]:
    selected = SelectBenchmarkDays(_FakeSeasons())(PinnedTzdb().zone(zone_id), date_set, years)
    return [(day.day, day.tags) for day in selected]


def test_selects_the_15th_of_every_month(city_file: BenchmarkCitiesV1) -> None:
    """Twelve DAY_OF_MONTH days per year."""
    days = _select("Asia/Riyadh", city_file.date_set, YearRange(2026, 2026))

    assert _days_tagged(days, "DAY_OF_MONTH") == [date(2026, month, 15) for month in range(1, 13)]


def test_selects_seven_days_around_each_dst_transition(city_file: BenchmarkCitiesV1) -> None:
    """London 2026 changes offset on 29 March and 25 October: 15 days around each."""
    days = _days_tagged(
        _select("Europe/London", city_file.date_set, YearRange(2026, 2026)),
        "DST_WINDOW",
    )

    assert len(days) == 30
    assert (days[0], days[14]) == (date(2026, 3, 22), date(2026, 4, 5))
    assert (days[15], days[29]) == (date(2026, 10, 18), date(2026, 11, 1))


def test_selects_no_dst_window_in_a_zone_without_transitions(city_file: BenchmarkCitiesV1) -> None:
    """Asia/Riyadh keeps one offset, so no DST_WINDOW day exists."""
    days = _select("Asia/Riyadh", city_file.date_set, YearRange(2026, 2028))

    assert _days_tagged(days, "DST_WINDOW") == []


def test_dates_a_season_instant_in_the_city_zone(city_file: BenchmarkCitiesV1) -> None:
    """The December solstice at 20:50 UTC falls on the 22nd in Auckland (UTC+13)."""
    days = _select("Pacific/Auckland", city_file.date_set, YearRange(2026, 2026))

    assert _days_tagged(days, "DECEMBER_SOLSTICE") == [date(2026, 12, 22)]


def test_selects_the_first_and_last_day_of_ramadan(city_file: BenchmarkCitiesV1) -> None:
    """Each listed Ramadan inside the range contributes its first and last day."""
    days = _select("Africa/Cairo", city_file.date_set, YearRange(2026, 2028))

    assert _days_tagged(days, "RAMADAN_FIRST_DAY") == [
        date(2026, 2, 17),
        date(2027, 2, 7),
        date(2028, 1, 27),
    ]
    assert _days_tagged(days, "RAMADAN_LAST_DAY") == [
        date(2026, 3, 18),
        date(2027, 3, 8),
        date(2028, 2, 25),
    ]


def test_rejects_an_empty_year_range() -> None:
    """A range whose first year follows its last is a usage error."""
    with pytest.raises(ValueError, match="empty year range"):
        YearRange(2028, 2026)


@settings(max_examples=40, deadline=None)
@given(data=st.data(), first=st.integers(2026, 2028), span=st.integers(0, 2))
def test_days_are_unique_sorted_inside_the_range_and_tagged_in_order(
    city_file: BenchmarkCitiesV1,
    data: st.DataObject,
    first: int,
    span: int,
) -> None:
    """Every selected day is unique, in order, inside the years, with ordered non-empty tags."""
    city = data.draw(st.sampled_from(city_file.cities))
    years = YearRange(first, min(first + span, 2028))

    days = _select(city.zone_id, city_file.date_set, years)

    assert [day for day, _ in days] == sorted({day for day, _ in days})
    assert all(years.contains(day) for day, _ in days)
    assert all(tags and list(tags) == [t for t in TAG_ORDER if t in tags] for _, tags in days)


def test_uses_the_pinned_tzdb_not_the_operating_system() -> None:
    """Zones come from the tzdata wheel; its IANA version is recorded."""
    tzdb = PinnedTzdb()

    zone = tzdb.zone("Africa/Cairo")

    assert tzdb.version == "2026e"
    assert datetime(2026, 7, 1, 12, tzinfo=zone).utcoffset() is not None
    assert datetime(2026, 7, 1, 12, tzinfo=UTC).astimezone(zone).hour == 15
