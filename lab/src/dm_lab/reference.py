"""Reference events of one benchmark city on one prayer day (ADR-003, ADR-004, ADR-019).

Prayer day D: the upper transit T₀ whose civil date in the city's zone is D, and the lower transits
A₋ < T₀ < A₊ around it. Sunrise is the upward crossing of the ADR-003 horizon altitude in [A₋, T₀],
sunset the downward crossing in [T₀, A₊], the transit is T₀ itself (REQ-TIME-002).

Tolerances (ADR-019 as amended by §15 D26): sunrise/sunset by the altitude-rate formula, except a
near-tangent crossing, which is reported as NEAR_TANGENT with no tolerance; the transit by its own
fixed time tolerance.
"""

from datetime import UTC, date, datetime, time, timedelta, tzinfo
from typing import Literal, Protocol, assert_never

from dm_lab.config import ToleranceConfig
from dm_lab.dateset import BenchmarkDay
from dm_lab.schema.benchmark_cities_v1 import City
from dm_lab.schema.lab_reference_v1 import (
    CandidatesUtcM,
    EventAMBIGUOUS,
    EventNEARTANGENT,
    EventNOEVENT,
    EventPRIMARY,
    LabReferenceDayV1,
)
from dm_lab.segment import Ambiguous, HalfOutcome, NoRoot, Root, classify_half
from dm_lab.sky import Crossing, Transit
from dm_lab.tolerance import altitude_tolerance_ms, is_near_tangent, transit_tolerance_ms

type ReferenceEvent = EventPRIMARY | EventNEARTANGENT | EventNOEVENT | EventAMBIGUOUS

_EPOCH = datetime(1970, 1, 1, tzinfo=UTC)
_ONE_DAY = timedelta(days=1)
_ONE_MS = timedelta(milliseconds=1)
_DAY_MS = 86_400_000
_RATE_DECIMALS = 9


class PrayerDayError(Exception):
    """The culmination segment of a prayer day cannot be formed (no single T₀ on that date)."""


class SunEphemeris(Protocol):
    """Port: the Sun as seen from a WGS84 site (implemented by `dm_lab.sky.SkyfieldSun`)."""

    def check_time_scale(self, utc_ms: int) -> None:
        """Fail when the configured time scale does not hold at `utc_ms`."""
        ...

    def transits(self, lat: float, lon: float, start_ms: int, end_ms: int) -> list[Transit]:
        """Upper and lower meridian transits in the span, in time order."""
        ...

    def crossings(
        self,
        lat: float,
        lon: float,
        span_ms: tuple[int, int],
        altitude_deg: float,
    ) -> list[Crossing]:
        """Crossings of a geometric altitude in the span, in time order."""
        ...

    def altitude_deg(self, lat: float, lon: float, utc_ms: int) -> float:
        """Geometric altitude of the Sun's centre."""
        ...

    def altitude_rate_deg_per_s(self, lat: float, lon: float, utc_ms: int) -> float:
        """d(altitude)/dt in °/s."""
        ...

    def hour_angle_rate_deg_per_s(self, lat: float, lon: float, utc_ms: int) -> float:
        """d(local hour angle)/dt in °/s."""
        ...


class ZoneLookup(Protocol):
    """Port: IANA zones by id (implemented by `dm_lab.tzdb.PinnedTzdb`)."""

    def zone(self, zone_id: str) -> tzinfo:
        """Return the zone named `zone_id`."""
        ...


class CalculateReferenceDay:
    """Use case: the lab_reference.v1 line of one city on one benchmark day."""

    def __init__(
        self,
        sun: SunEphemeris,
        zones: ZoneLookup,
        horizon_altitude_deg: float,
        tolerance: ToleranceConfig,
    ) -> None:
        """Create the calculator for the ADR-003 horizon altitude and the ADR-019 tolerance."""
        self._sun = sun
        self._zones = zones
        self._horizon_deg = horizon_altitude_deg
        self._tolerance = tolerance

    def __call__(self, city: City, benchmark_day: BenchmarkDay) -> LabReferenceDayV1:
        """Compute the reference sunrise, transit and sunset of `city` on `benchmark_day`.

        Raises:
            PrayerDayError: the day has no single upper transit, or no lower transit around it.
            dm_lab.sky.TimeScaleError: the configured time scale does not hold on that day.

        """
        lat, lon = city.latitude_deg, city.longitude_deg
        zone = self._zones.zone(city.zone_id)
        segment = self._segment(lat, lon, zone, benchmark_day.day)
        transit_ms, lower_before_ms, lower_after_ms = segment
        self._sun.check_time_scale(transit_ms)
        above = self._sun.altitude_deg(lat, lon, transit_ms) > self._horizon_deg
        rising = self._sun.crossings(lat, lon, (lower_before_ms, transit_ms), self._horizon_deg)
        setting = self._sun.crossings(lat, lon, (transit_ms, lower_after_ms), self._horizon_deg)
        events: list[ReferenceEvent] = [
            self._horizon_event(
                "SUNRISE",
                classify_half(rising, rising=True, above_at_transit=above),
                (lat, lon),
            ),
            EventPRIMARY(
                kind="PRIMARY",
                event="TRANSIT",
                reference_utc_ms=transit_ms,
                tolerance_ms=transit_tolerance_ms(self._tolerance),
                rate_deg_per_s=_rounded(self._sun.hour_angle_rate_deg_per_s(lat, lon, transit_ms)),
            ),
            self._horizon_event(
                "SUNSET",
                classify_half(setting, rising=False, above_at_transit=above),
                (lat, lon),
            ),
        ]
        day = benchmark_day.day.isoformat()
        return LabReferenceDayV1(
            schema_version=1,
            case_id=f"{city.city_id}/{day}",
            city_id=city.city_id,
            latitude_deg=lat,
            longitude_deg=lon,
            zone_id=city.zone_id,
            day=day,
            tags=list(benchmark_day.tags),
            events=events,
        )

    def _segment(self, lat: float, lon: float, zone: tzinfo, day: date) -> tuple[int, int, int]:
        """(T₀, A₋, A₊) of prayer day `day` (ADR-004)."""
        start_ms = _utc_ms(datetime.combine(day, time.min, tzinfo=zone))
        end_ms = _utc_ms(datetime.combine(day + _ONE_DAY, time.min, tzinfo=zone))
        transits = self._sun.transits(lat, lon, start_ms - _DAY_MS, end_ms + _DAY_MS)
        uppers = [t.utc_ms for t in transits if t.upper and _local_date(t.utc_ms, zone) == day]
        if len(uppers) != 1:
            msg = f"{len(uppers)} upper transits on {day} in {zone}"
            raise PrayerDayError(msg)
        transit_ms = uppers[0]
        before = [t.utc_ms for t in transits if not t.upper and t.utc_ms < transit_ms]
        after = [t.utc_ms for t in transits if not t.upper and t.utc_ms > transit_ms]
        if not before or not after:
            msg = f"no lower transit around the upper transit of {day} in {zone}"
            raise PrayerDayError(msg)
        return transit_ms, max(before), min(after)

    def _horizon_event(
        self,
        event: Literal["SUNRISE", "SUNSET"],
        outcome: HalfOutcome,
        site: tuple[float, float],
    ) -> ReferenceEvent:
        match outcome:
            case Root(utc_ms=utc_ms):
                lat, lon = site
                rate = self._sun.altitude_rate_deg_per_s(lat, lon, utc_ms)
                if is_near_tangent(rate, self._tolerance):
                    return EventNEARTANGENT(
                        kind="NEAR_TANGENT",
                        event=event,
                        reference_utc_ms=utc_ms,
                        rate_deg_per_s=_rounded(rate),
                    )
                return EventPRIMARY(
                    kind="PRIMARY",
                    event=event,
                    reference_utc_ms=utc_ms,
                    tolerance_ms=altitude_tolerance_ms(rate, self._tolerance),
                    rate_deg_per_s=_rounded(rate),
                )
            case NoRoot(reason=reason):
                return EventNOEVENT(kind="NO_EVENT", event=event, reason=reason)
            case Ambiguous(candidates_utc_ms=candidates):
                return EventAMBIGUOUS(
                    kind="AMBIGUOUS",
                    event=event,
                    candidates_utc_ms=[CandidatesUtcM(root=c) for c in candidates],
                )
            case _:
                assert_never(outcome)


def _rounded(rate_deg_per_s: float) -> float:
    return round(rate_deg_per_s, _RATE_DECIMALS)


def _utc_ms(moment: datetime) -> int:
    return (moment.astimezone(UTC) - _EPOCH) // _ONE_MS


def _local_date(utc_ms: int, zone: tzinfo) -> date:
    return (_EPOCH + utc_ms * _ONE_MS).astimezone(zone).date()
