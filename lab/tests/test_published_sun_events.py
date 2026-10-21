"""S03 done-test: published equinox/solstice sunrise for 3 cities is reproduced within 1 min.

Published source (cited per case in the data file): MET Norway Sunrise API 3.0,
https://api.met.no/weatherapi/sunrise/3.0/sun, retrieved 2026-10-21, licence NLOD 2.0 / CC BY 4.0,
attribution "MET Norway". It defines sunrise/sunset as the Sun's centre 0.833° below the horizon,
the ADR-003 definition. Values are minutes in UTC, so the comparison allows 60 s.
"""

from datetime import UTC, date, datetime
from pathlib import Path
from typing import Literal

import pytest
from pydantic import BaseModel, ConfigDict, Field

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


@pytest.mark.parametrize("case", _PUBLISHED.cases, ids=_case_id)
def test_reproduces_published_sunrise_within_one_minute(
    case: _Case,
    calculate: CalculateReferenceDay,
    cities: dict[str, City],
) -> None:
    """Reference sunrise is within 60 s of the published minute (S03 done-test)."""
    reference = _reference(calculate, cities[case.city_id], case)

    delta_ms = _instant(reference, "SUNRISE") - _ms(case.sunrise)

    assert abs(delta_ms) <= _PUBLISHED.tolerance_seconds * 1000


@pytest.mark.parametrize("case", _PUBLISHED.cases, ids=_case_id)
def test_reproduces_published_solar_noon_and_sunset_within_one_minute(
    case: _Case,
    calculate: CalculateReferenceDay,
    cities: dict[str, City],
) -> None:
    """Reference transit and sunset are within 60 s of the published minutes."""
    reference = _reference(calculate, cities[case.city_id], case)

    transit_delta_ms = _instant(reference, "TRANSIT") - _ms(case.solar_noon)
    sunset_delta_ms = _instant(reference, "SUNSET") - _ms(case.sunset)

    assert abs(transit_delta_ms) <= _PUBLISHED.tolerance_seconds * 1000
    assert abs(sunset_delta_ms) <= _PUBLISHED.tolerance_seconds * 1000
