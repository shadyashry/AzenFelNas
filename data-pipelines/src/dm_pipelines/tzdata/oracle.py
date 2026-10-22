"""The DST transition oracle: an independent reference for the S10 suite (DESIGN.md §13, §15 D66).

CPython's `zoneinfo` reads the zic output directly, so the oracle shares only the compiled TZif
files with the `.tzf` database: not `package:timezone`'s converter, its encoder or the Dart reader.
Transitions are found by sampling every hour and bisecting each change to the second (IANA
transitions fall on whole seconds); two changes less than an hour apart would be missed, and none
exists in the corpus zones' modern rules.
"""

import json
from datetime import UTC, date, datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

from dm_pipelines.schema.tz_transition_oracle_v1 import (
    Day,
    Transition,
    TzTransitionOracleV1,
    Zone,
)
from dm_pipelines.tzdata.config import OracleSettings

_HOUR = 3600
_DAY = 86400
_EPOCH = date(1970, 1, 1)


class CorpusError(Exception):
    """The benchmark city file does not name its zones as expected."""


def corpus_zone_ids(cities_file: Path) -> list[str]:
    """Return the sorted distinct `zoneId`s of the benchmark city file (Appendix H)."""
    document: object = json.loads(cities_file.read_text(encoding="utf-8"))
    match document:
        case {"cities": [*cities]} if cities:
            pass
        case _:
            message = f"{cities_file}: no cities"
            raise CorpusError(message)
    zones: set[str] = set()
    for city in cities:
        match city:
            case {"zoneId": str(zone_id)}:
                zones.add(zone_id)
            case _:
                message = f"{cities_file}: a city has no zoneId"
                raise CorpusError(message)
    return sorted(zones)


class _ZoneProbe:
    """Offsets and local dates of one zone, in whole seconds."""

    def __init__(self, zone: ZoneInfo) -> None:
        self._zone = zone

    def offset(self, utc_s: int) -> int:
        delta = datetime.fromtimestamp(utc_s, self._zone).utcoffset()
        if delta is None:
            message = f"{self._zone.key} has no offset at {utc_s}"
            raise CorpusError(message)
        return int(delta.total_seconds())

    def local_date(self, utc_s: int) -> date:
        return datetime.fromtimestamp(utc_s, self._zone).date()

    def utc_of_local(self, day: date, hour: int) -> int:
        """UTC seconds of local `day` `hour`:00 with PEP 495 fold = 0."""
        local = datetime(day.year, day.month, day.day, hour, tzinfo=self._zone)
        return int(local.timestamp())


def _transitions(probe: _ZoneProbe, start_s: int, end_s: int) -> list[Transition]:
    found: list[Transition] = []
    previous = probe.offset(start_s)
    for at in range(start_s + _HOUR, end_s + 1, _HOUR):
        current = probe.offset(at)
        if current == previous:
            continue
        low, high = at - _HOUR, at
        while high - low > 1:
            middle = (low + high) // 2
            if probe.offset(middle) == previous:
                low = middle
            else:
                high = middle
        found.append(
            Transition(
                utc_ms=high * 1000,
                offset_before_seconds=previous,
                offset_after_seconds=current,
            )
        )
        previous = current
    return found


def _start_of_day(probe: _ZoneProbe, day: date, transitions: list[Transition]) -> int:
    """First UTC second whose local date is `day`: a local midnight or a transition into the day."""
    midnight = (day - _EPOCH).days * _DAY
    window = range(midnight - 27 * _HOUR, midnight + 27 * _HOUR + 1, _HOUR)
    candidates = {midnight - probe.offset(at) for at in window}
    candidates |= {t.utc_ms // 1000 for t in transitions if abs(t.utc_ms // 1000 - midnight) < _DAY}
    valid = [u for u in candidates if probe.local_date(u) == day]
    if not valid:
        message = f"{day} does not exist locally"
        raise CorpusError(message)
    return min(valid)


def _day(probe: _ZoneProbe, day: date, transitions: list[Transition]) -> Day:
    hours = [probe.utc_of_local(day, hour) for hour in range(24)]
    return Day(
        day=day.isoformat(),
        start_of_day_utc_ms=_start_of_day(probe, day, transitions) * 1000,
        local_hour_utc_ms=[u * 1000 for u in hours],
        hour_offsets_seconds=[probe.offset(u) for u in hours],
    )


def zone_oracle(zone: ZoneInfo, from_year: int, to_year: int, window_days: int) -> Zone:
    """Return the oracle entry of `zone` for the years `from_year`..`to_year` (inclusive)."""
    probe = _ZoneProbe(zone)
    start_s = int(datetime(from_year, 1, 1, tzinfo=UTC).timestamp())
    end_s = int(datetime(to_year + 1, 1, 1, tzinfo=UTC).timestamp())
    transitions = _transitions(probe, start_s, end_s)
    days: set[date] = set()
    for transition in transitions:
        centre = probe.local_date(transition.utc_ms // 1000)
        days.update(centre + timedelta(days=d) for d in range(-window_days, window_days + 1))
    return Zone(
        zone_id=zone.key,
        offset_at_start_seconds=probe.offset(start_s),
        transitions=transitions,
        days=[_day(probe, day, transitions) for day in sorted(days)],
    )


def build_oracle(
    zoneinfo_dir: Path, zone_ids: list[str], *, tzdb_version: str, settings: OracleSettings
) -> TzTransitionOracleV1:
    """Return the oracle for `zone_ids`, reading each zone's TZif file under `zoneinfo_dir`."""
    zones: list[Zone] = []
    for zone_id in zone_ids:
        with (zoneinfo_dir / zone_id).open("rb") as stream:
            zone = ZoneInfo.from_file(stream, key=zone_id)
        zones.append(zone_oracle(zone, settings.from_year, settings.to_year, settings.window_days))
    return TzTransitionOracleV1(
        schema_version=1,
        tzdb_version=tzdb_version,
        from_year=settings.from_year,
        to_year=settings.to_year,
        window_days=settings.window_days,
        zones=zones,
    )
