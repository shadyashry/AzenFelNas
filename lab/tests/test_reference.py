"""Reference events of a prayer day: ADR-004 segments, ADR-003 horizon, typed polar outcomes."""

from datetime import UTC, date, datetime, timedelta
from pathlib import Path

import pytest
from hypothesis import given, settings
from hypothesis import strategies as st

from dm_lab.config import HarnessConfig
from dm_lab.dateset import BenchmarkDay, DateTag
from dm_lab.reference import CalculateReferenceDay
from dm_lab.schema.benchmark_cities_v1 import City
from dm_lab.schema.lab_reference_v1 import EventNOEVENT, EventPRIMARY, LabReferenceDayV1
from dm_lab.sky import SkyfieldSun, TimeScaleError
from dm_lab.tzdb import PinnedTzdb

_EPOCH = datetime(1970, 1, 1, tzinfo=UTC)
_TAGS: tuple[DateTag, ...] = ("DAY_OF_MONTH",)


def _day(calculate: CalculateReferenceDay, city: City, day: str) -> LabReferenceDayV1:
    return calculate(city, BenchmarkDay(date.fromisoformat(day), _TAGS))


def _primaries(reference: LabReferenceDayV1) -> dict[str, EventPRIMARY]:
    return {e.event: e for e in reference.events if isinstance(e, EventPRIMARY)}


def _local_date(utc_ms: int, zone_id: str) -> date:
    return (_EPOCH + timedelta(milliseconds=utc_ms)).astimezone(PinnedTzdb().zone(zone_id)).date()


@pytest.mark.parametrize(
    ("city_id", "day"),
    [
        ("kiritimati", "2026-06-15"),  # UTC+14: civil day far from the UTC day
        ("suva", "2027-01-15"),  # date line
        ("utqiagvik", "2026-03-20"),  # Alaska zone ~2.5 h from solar time
        ("ushuaia", "2026-12-21"),  # southern summer
    ],
)
def test_events_lie_in_the_culmination_segment_of_the_prayer_day_req_time_002(
    calculate: CalculateReferenceDay,
    cities: dict[str, City],
    city_id: str,
    day: str,
) -> None:
    """REQ-TIME-002: T₀ falls on the civil day; sunrise precedes and sunset follows it."""
    city = cities[city_id]

    events = _primaries(_day(calculate, city, day))

    assert _local_date(events["TRANSIT"].reference_utc_ms, city.zone_id) == date.fromisoformat(day)
    assert events["SUNRISE"].reference_utc_ms < events["TRANSIT"].reference_utc_ms
    assert events["TRANSIT"].reference_utc_ms < events["SUNSET"].reference_utc_ms
    assert events["SUNSET"].reference_utc_ms - events["SUNRISE"].reference_utc_ms < 86_400_000


def test_polar_day_is_a_typed_no_event_not_an_invented_time(
    calculate: CalculateReferenceDay,
    cities: dict[str, City],
) -> None:
    """Longyearbyen at the June solstice: no sunrise/sunset (POLAR_DAY), transit still exists."""
    reference = _day(calculate, cities["longyearbyen"], "2026-06-21")

    no_events = {e.event: e.reason for e in reference.events if isinstance(e, EventNOEVENT)}

    assert no_events == {"SUNRISE": "POLAR_DAY", "SUNSET": "POLAR_DAY"}
    assert set(_primaries(reference)) == {"TRANSIT"}


def test_polar_night_is_a_typed_no_event(
    calculate: CalculateReferenceDay,
    cities: dict[str, City],
) -> None:
    """Tromsø at the December solstice: the Sun never reaches −0.833° (POLAR_NIGHT)."""
    reference = _day(calculate, cities["tromso"], "2026-12-21")

    no_events = {e.event: e.reason for e in reference.events if isinstance(e, EventNOEVENT)}

    assert no_events == {"SUNRISE": "POLAR_NIGHT", "SUNSET": "POLAR_NIGHT"}


def test_tolerance_follows_the_event_rate_req_test_003(
    calculate: CalculateReferenceDay,
    cities: dict[str, City],
) -> None:
    """REQ-TEST-003: steep equatorial sunrise near the floor, grazing Arctic sunrise much looser."""
    quito = _primaries(_day(calculate, cities["quito"], "2026-03-20"))
    longyearbyen = _primaries(_day(calculate, cities["longyearbyen"], "2026-03-20"))

    assert quito["SUNRISE"].tolerance_ms == 240
    assert quito["TRANSIT"].tolerance_ms == 240
    assert longyearbyen["SUNRISE"].tolerance_ms > 1000


def test_refuses_a_time_scale_that_contradicts_the_leap_second_table(
    config: HarnessConfig,
    ephemeris_path: Path,
) -> None:
    """A wrong TAI − UTC would silently shift UT1 off UTC; the harness fails instead (§15 D25)."""
    wrong_time = config.time.model_copy(update={"tai_minus_utc_s": 36.0})
    wrong = config.model_copy(update={"time": wrong_time})

    sun = SkyfieldSun(ephemeris_path, wrong)
    try:
        with pytest.raises(TimeScaleError):
            sun.check_time_scale(1_780_000_000_000)
    finally:
        sun.close()


_ZONE_HOURS = st.integers(min_value=-12, max_value=12)


@settings(max_examples=25, deadline=None)
@given(
    lat=st.floats(min_value=-60.0, max_value=60.0),
    zone_hours=_ZONE_HOURS,
    lon_offset=st.floats(min_value=-7.0, max_value=7.0),
    day=st.dates(min_value=date(2026, 1, 1), max_value=date(2028, 12, 31)),
)
def test_mid_latitude_days_have_ordered_primary_events(
    calculate: CalculateReferenceDay,
    lat: float,
    zone_hours: int,
    lon_offset: float,
    day: date,
) -> None:
    """Below 60° every day has sunrise < transit < sunset with rising/setting rate signs."""
    lon = max(-180.0, min(180.0, zone_hours * 15 + lon_offset))
    city = City(
        city_id="zz_city",
        name="Fixture",
        latitude_deg=round(lat, 2),
        longitude_deg=round(lon, 2),
        zone_id=f"Etc/GMT{-zone_hours:+d}",
        country="ZZ",
    )

    events = _primaries(calculate(city, BenchmarkDay(day, _TAGS)))

    assert set(events) == {"SUNRISE", "TRANSIT", "SUNSET"}
    assert events["SUNRISE"].reference_utc_ms < events["TRANSIT"].reference_utc_ms
    assert events["TRANSIT"].reference_utc_ms < events["SUNSET"].reference_utc_ms
    assert events["SUNRISE"].rate_deg_per_s > 0 > events["SUNSET"].rate_deg_per_s
    assert all(200 <= e.tolerance_ms <= 60_000 for e in events.values())
