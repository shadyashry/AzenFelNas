"""S03 done-test: published equinox/solstice sunrise for 3 cities is reproduced within 1 min.

Published source (cited per case in the data file): MET Norway Sunrise API 3.0,
https://api.met.no/weatherapi/sunrise/3.0/sun, retrieved 2026-10-21, licence NLOD 2.0 / CC BY 4.0,
attribution "MET Norway". It defines sunrise/sunset as the Sun's centre 0.833° below the horizon,
the ADR-003 definition. It publishes UTC minutes truncated, not rounded: on all 36 values the
reference lies 3.7–57.3 s after the published minute, which nearest-minute rounding could not
produce. So the check is `0 ≤ reference − published < 60 s` (the reference truncated to the minute
equals the published minute), which bounds any systematic bias to a few seconds.

A 60 s window cannot validate the 0.2–0.5 s ADR-019 tolerances; the sub-second check at the end
compares the harness wiring (segments, observer, horizon) with Skyfield's own rise/set/transit
finders.
"""

from datetime import UTC, date, datetime, timedelta
from pathlib import Path
from typing import Literal

import pytest
from pydantic import BaseModel, ConfigDict, Field
from skyfield import almanac
from skyfield.api import load, load_file, wgs84

from dm_lab.config import HarnessConfig
from dm_lab.dateset import BenchmarkDay
from dm_lab.reference import CalculateReferenceDay
from dm_lab.schema.benchmark_cities_v1 import City
from dm_lab.schema.lab_reference_v1 import EventPRIMARY, LabReferenceDayV1
from dm_lab.sky import SkyfieldSun


class _Case(BaseModel):
    model_config = ConfigDict(frozen=True)
    city_id: str = Field(alias="cityId")
    day: str
    url: str
    sunrise: datetime
    solar_noon: datetime = Field(alias="solarNoon")
    sunset: datetime


class _Published(BaseModel):
    model_config = ConfigDict(frozen=True)
    source: str
    tolerance_seconds: int = Field(alias="toleranceSeconds")
    cases: list[_Case]


_DATA = Path(__file__).parent / "data" / "published_sun_events_2026.json"
_PUBLISHED = _Published.model_validate_json(_DATA.read_text(encoding="utf-8"))
_EPOCH = datetime(1970, 1, 1, tzinfo=UTC)


def _ms(moment: datetime) -> int:
    return round((moment - _EPOCH).total_seconds() * 1000)


def _instant(
    reference: LabReferenceDayV1,
    event: Literal["SUNRISE", "TRANSIT", "SUNSET"],
) -> int:
    matches = [e for e in reference.events if isinstance(e, EventPRIMARY) and e.event == event]
    assert len(matches) == 1, f"{reference.case_id} has no primary {event}"
    return matches[0].reference_utc_ms


def _reference(calculate: CalculateReferenceDay, city: City, case: _Case) -> LabReferenceDayV1:
    return calculate(city, BenchmarkDay(date.fromisoformat(case.day), ("DAY_OF_MONTH",)))


def _case_id(case: _Case) -> str:
    return f"{case.city_id}/{case.day}"


def test_published_days_are_the_2026_equinoxes_and_solstices(sun: SkyfieldSun) -> None:
    """The published cases sit on the UTC dates of the harness's 2026 season instants."""
    instants = sun.season_instants_ms(2026)

    utc_dates = {
        datetime.fromtimestamp(ms / 1000, UTC).date().isoformat() for ms in instants.values()
    }

    assert utc_dates == {case.day for case in _PUBLISHED.cases}


def test_covers_three_cities_at_four_seasons_within_one_minute() -> None:
    """The done-test data: 3 cities × the 2 equinoxes and 2 solstices of 2026, within 1 min."""
    assert len({case.city_id for case in _PUBLISHED.cases}) == 3
    assert len(_PUBLISHED.cases) == 12
    assert _PUBLISHED.tolerance_seconds == 60
    assert "MET Norway" in _PUBLISHED.source


def _in_published_minute(reference_ms: int, published: datetime) -> bool:
    """Whether the reference, truncated to the minute, is the published (truncated) minute."""
    return 0 <= reference_ms - _ms(published) < _PUBLISHED.tolerance_seconds * 1000


@pytest.mark.parametrize("case", _PUBLISHED.cases, ids=_case_id)
def test_reproduces_published_sunrise_within_one_minute(
    case: _Case,
    calculate: CalculateReferenceDay,
    cities: dict[str, City],
) -> None:
    """Reference sunrise falls in the published minute (S03 done-test)."""
    reference = _reference(calculate, cities[case.city_id], case)

    assert _in_published_minute(_instant(reference, "SUNRISE"), case.sunrise)


@pytest.mark.parametrize("case", _PUBLISHED.cases, ids=_case_id)
def test_reproduces_published_solar_noon_and_sunset_within_one_minute(
    case: _Case,
    calculate: CalculateReferenceDay,
    cities: dict[str, City],
) -> None:
    """Reference transit and sunset fall in the published minutes."""
    reference = _reference(calculate, cities[case.city_id], case)

    assert _in_published_minute(_instant(reference, "TRANSIT"), case.solar_noon)
    assert _in_published_minute(_instant(reference, "SUNSET"), case.sunset)


_WIRING_SLACK_MS = 2  # both sides bracket roots to 1 ms
_WINDOW_DAYS = 2 / 24


@pytest.mark.parametrize("city_id", ["london", "tromso", "quito", "reykjavik", "kiritimati"])
def test_matches_skyfields_own_rise_set_and_transit_finders_to_the_millisecond(
    city_id: str,
    calculate: CalculateReferenceDay,
    cities: dict[str, City],
    config: HarnessConfig,
    ephemeris_path: Path,
) -> None:
    """Sub-second wiring check: segment logic, observer and horizon match Skyfield's almanac."""
    city = cities[city_id]
    reference = calculate(city, BenchmarkDay(date(2026, 3, 20), ("MARCH_EQUINOX",)))
    kernel = load_file(str(ephemeris_path))
    try:
        ts = load.timescale(builtin=True, delta_t=config.time.delta_t_s)
        observer = kernel["earth"] + wgs84.latlon(city.latitude_deg, city.longitude_deg)
        horizon = config.horizon.altitude_deg
        sun_body = kernel["sun"]
        sunrise, transit, sunset = (
            _instant(reference, e) for e in ("SUNRISE", "TRANSIT", "SUNSET")
        )

        def window(ms: int) -> tuple[object, object]:
            middle = ts.from_datetime(_EPOCH + timedelta(milliseconds=ms))
            return middle - _WINDOW_DAYS, middle + _WINDOW_DAYS

        risings, _ = almanac.find_risings(observer, sun_body, *window(sunrise), horizon)
        settings, _ = almanac.find_settings(observer, sun_body, *window(sunset), horizon)
        transits = almanac.find_transits(observer, sun_body, *window(transit))

        for ours, found in ((sunrise, risings), (sunset, settings), (transit, transits)):
            [theirs] = [_ms(t.utc_datetime()) for t in found]
            assert abs(ours - theirs) <= _WIRING_SLACK_MS
    finally:
        kernel.close()
