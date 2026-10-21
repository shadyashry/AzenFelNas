"""Skyfield + JPL DE440s adapter (ADR-019): the only module that touches Skyfield.

Positions are apparent topocentric positions of the Sun's centre (light time, aberration,
deflection, nutation of date) for an observer on the WGS84 ellipsoid; altitudes are geometric
(no refraction model), as ADR-003 requires. Instants cross this boundary as UTC epoch
milliseconds, truncated.
Time scales follow `harness.v1.toml` [time]: UT1 ≡ UTC and TT = UTC + 32.184 s + 37 s (§15 D25).
"""

from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from pathlib import Path
from typing import Literal

from skyfield import almanac
from skyfield.api import load, load_file, wgs84
from skyfield.positionlib import Apparent
from skyfield.searchlib import find_discrete
from skyfield.timelib import Time
from skyfield.vectorlib import VectorFunction

from dm_lab.config import HarnessConfig

type Season = Literal["MARCH_EQUINOX", "JUNE_SOLSTICE", "SEPTEMBER_EQUINOX", "DECEMBER_SOLSTICE"]

# Order of the values of skyfield.almanac.seasons (0 = March equinox … 3 = December solstice).
_SEASONS: tuple[Season, ...] = (
    "MARCH_EQUINOX",
    "JUNE_SOLSTICE",
    "SEPTEMBER_EQUINOX",
    "DECEMBER_SOLSTICE",
)
_EPOCH = datetime(1970, 1, 1, tzinfo=UTC)
_ONE_MS = timedelta(milliseconds=1)
_MINUTES_PER_DAY = 1440.0
_MS_PER_S = 1000
_HALF_TURN_DEG = 180.0
_TURN_DEG = 360.0
_DUT1_EPSILON_S = 1e-6


class TimeScaleError(Exception):
    """Skyfield's leap-second table disagrees with the configured UT1 − UTC on some instant."""


@dataclass(frozen=True, slots=True)
class Transit:
    """A meridian transit of the Sun: upper (culmination) or lower."""

    utc_ms: int
    upper: bool


@dataclass(frozen=True, slots=True)
class Crossing:
    """The Sun's centre crossing a geometric altitude, upwards (`rising`) or downwards."""

    utc_ms: int
    rising: bool


class _AboveAltitude:
    """Discrete function for find_discrete: whether the Sun's centre is above `altitude_deg`."""

    def __init__(
        self,
        sun_from_observer: _Observation,
        altitude_deg: float,
        step_days: float,
    ) -> None:
        self._observe = sun_from_observer
        self._altitude_deg = altitude_deg
        self.step_days = step_days

    def __call__(self, t: Time) -> object:
        altitude, _, _ = self._observe(t).altaz()
        return altitude.degrees > self._altitude_deg


class _Observation:
    """Apparent topocentric position of the Sun for one observer."""

    def __init__(self, sun: VectorFunction, observer: VectorFunction) -> None:
        self._sun = sun
        self._observer = observer

    def __call__(self, t: Time) -> Apparent:
        return self._observer.at(t).observe(self._sun).apparent()


class SkyfieldSun:
    """The Sun as seen from WGS84 sites, computed with Skyfield over the pinned ephemeris."""

    def __init__(self, ephemeris_path: Path, config: HarnessConfig) -> None:
        """Load the ephemeris (already sha256-verified) and build the configured time scale."""
        self._kernel = load_file(str(ephemeris_path))
        self._sun = self._kernel["sun"]
        self._earth = self._kernel["earth"]
        self._ts = load.timescale(builtin=True, delta_t=config.time.delta_t_s)
        self._ut1_minus_utc_s = config.time.ut1_minus_utc_s
        self._elevation_m = config.observer.elevation_m
        self._step_days = config.search.step_minutes / _MINUTES_PER_DAY
        self._half_width_ms = round(config.search.rate_half_width_s * _MS_PER_S)

    def close(self) -> None:
        """Release the ephemeris file."""
        self._kernel.close()

    def check_time_scale(self, utc_ms: int) -> None:
        """Fail unless UT1 − UTC at `utc_ms` equals the configured value.

        Raises:
            TimeScaleError: a leap second in Skyfield's table breaks the UT1 ≡ UTC assumption.

        """
        dut1 = float(self._time(utc_ms).dut1)
        if abs(dut1 - self._ut1_minus_utc_s) > _DUT1_EPSILON_S:
            msg = f"UT1 - UTC = {dut1} s at {utc_ms} ms; [time] expects {self._ut1_minus_utc_s} s"
            raise TimeScaleError(msg)

    def transits(self, lat: float, lon: float, start_ms: int, end_ms: int) -> list[Transit]:
        """Upper and lower meridian transits in [start_ms, end_ms], in time order."""
        topos = wgs84.latlon(lat, lon, elevation_m=self._elevation_m)
        west_of_meridian = almanac.meridian_transits(self._kernel, self._sun, topos)
        times, values = find_discrete(self._time(start_ms), self._time(end_ms), west_of_meridian)
        return [Transit(self._ms(t), upper=bool(v)) for t, v in zip(times, values, strict=True)]

    def crossings(
        self,
        lat: float,
        lon: float,
        span_ms: tuple[int, int],
        altitude_deg: float,
    ) -> list[Crossing]:
        """Crossings of `altitude_deg` by the Sun's centre inside `span_ms`, in time order."""
        above = _AboveAltitude(self._observation(lat, lon), altitude_deg, self._step_days)
        start_ms, end_ms = span_ms
        times, values = find_discrete(self._time(start_ms), self._time(end_ms), above)
        return [Crossing(self._ms(t), rising=bool(v)) for t, v in zip(times, values, strict=True)]

    def altitude_deg(self, lat: float, lon: float, utc_ms: int) -> float:
        """Geometric altitude of the Sun's centre at `utc_ms`."""
        altitude, _, _ = self._observation(lat, lon)(self._time(utc_ms)).altaz()
        return float(altitude.degrees)

    def altitude_rate_deg_per_s(self, lat: float, lon: float, utc_ms: int) -> float:
        """d(altitude)/dt at `utc_ms` by central difference, in °/s."""
        before = self.altitude_deg(lat, lon, utc_ms - self._half_width_ms)
        after = self.altitude_deg(lat, lon, utc_ms + self._half_width_ms)
        return (after - before) * _MS_PER_S / (2 * self._half_width_ms)

    def hour_angle_rate_deg_per_s(self, lat: float, lon: float, utc_ms: int) -> float:
        """d(local hour angle)/dt at `utc_ms` by central difference, in °/s."""
        before = self._hour_angle_deg(lat, lon, utc_ms - self._half_width_ms)
        after = self._hour_angle_deg(lat, lon, utc_ms + self._half_width_ms)
        delta = (after - before + _HALF_TURN_DEG) % _TURN_DEG - _HALF_TURN_DEG
        return delta * _MS_PER_S / (2 * self._half_width_ms)

    def season_instants_ms(self, year: int) -> dict[Season, int]:
        """Equinox and solstice instants of the UTC calendar year `year`."""
        times, values = find_discrete(
            self._ts.utc(year, 1, 1),
            self._ts.utc(year + 1, 1, 1),
            almanac.seasons(self._kernel),
        )
        return {_SEASONS[int(v)]: self._ms(t) for t, v in zip(times, values, strict=True)}

    def _hour_angle_deg(self, lat: float, lon: float, utc_ms: int) -> float:
        hour_angle, _, _ = self._observation(lat, lon)(self._time(utc_ms)).hadec()
        return float(hour_angle.degrees)

    def _observation(self, lat: float, lon: float) -> _Observation:
        topos = wgs84.latlon(lat, lon, elevation_m=self._elevation_m)
        return _Observation(self._sun, self._earth + topos)

    def _time(self, utc_ms: int) -> Time:
        return self._ts.from_datetime(_EPOCH + utc_ms * _ONE_MS)

    def _ms(self, t: Time) -> int:
        moment, leap_second = t.utc_datetime_and_leap_second()
        if leap_second:
            msg = f"instant {moment} falls in a leap second"
            raise TimeScaleError(msg)
        elapsed: timedelta = moment - _EPOCH
        return elapsed // _ONE_MS
