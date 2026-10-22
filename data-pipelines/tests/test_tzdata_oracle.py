"""The DST transition oracle (DESIGN.md §13 S10, §15 D66-D67) over hand-built zones."""

import io
import json
from datetime import UTC, datetime
from pathlib import Path
from zoneinfo import ZoneInfo

import pytest

from dm_pipelines.tzdata.config import OracleSettings
from dm_pipelines.tzdata.oracle import CorpusError, build_oracle, corpus_zone_ids, zone_oracle
from tests.tzif import LocalType, tzif_v1

_CET = LocalType(3600, is_dst=False, abbreviation="CET")
_CEST = LocalType(7200, is_dst=True, abbreviation="CEST")
_SPRING = int(datetime(2026, 3, 29, 1, tzinfo=UTC).timestamp())
_AUTUMN = int(datetime(2026, 10, 25, 1, tzinfo=UTC).timestamp())


def _ms(year: int, month: int, day: int, hour: int) -> int:
    return int(datetime(year, month, day, hour, tzinfo=UTC).timestamp()) * 1000


def _zone(key: str, transitions: list[tuple[int, int]], types: list[LocalType]) -> ZoneInfo:
    return ZoneInfo.from_file(io.BytesIO(tzif_v1(transitions, types)), key=key)


@pytest.fixture
def berlin_like() -> ZoneInfo:
    """CET/CEST with the 2026 EU transitions only."""
    return _zone("Test/Berlin", [(_SPRING, 1), (_AUTUMN, 0)], [_CET, _CEST])


def test_finds_each_offset_change_to_the_second_req_time_020(berlin_like: ZoneInfo) -> None:
    oracle = zone_oracle(berlin_like, 2026, 2026, 7)
    assert [
        (t.utc_ms, t.offset_before_seconds, t.offset_after_seconds) for t in oracle.transitions
    ] == [
        (_SPRING * 1000, 3600, 7200),
        (_AUTUMN * 1000, 7200, 3600),
    ]
    assert oracle.offset_at_start_seconds == 3600


def test_covers_fifteen_days_around_each_transition_req_time_020(berlin_like: ZoneInfo) -> None:
    oracle = zone_oracle(berlin_like, 2026, 2026, 7)
    days = [d.day for d in oracle.days]
    assert len(days) == 30
    assert days[0] == "2026-03-22"
    assert days[14] == "2026-04-05"
    assert days[-1] == "2026-11-01"


def test_gap_reading_moves_forward_and_overlap_takes_the_earlier_instant_req_time_020(
    berlin_like: ZoneInfo,
) -> None:
    oracle = zone_oracle(berlin_like, 2026, 2026, 0)
    spring, autumn = oracle.days
    assert spring.start_of_day_utc_ms == _ms(2026, 3, 28, 23)
    assert spring.local_hour_utc_ms[2] == _ms(2026, 3, 29, 1)  # 02:00 does not exist: as 03:00
    assert spring.hour_offsets_seconds[2] == 7200
    assert autumn.local_hour_utc_ms[2] == _ms(2026, 10, 25, 0)  # 02:00 occurs twice: the first
    assert autumn.hour_offsets_seconds[2] == 7200
    assert autumn.local_hour_utc_ms[3] == _ms(2026, 10, 25, 2)


def test_a_day_whose_midnight_falls_in_a_gap_starts_at_the_transition_req_time_020() -> None:
    minus3 = LocalType(-10800, is_dst=False, abbreviation="-03")
    minus2 = LocalType(-7200, is_dst=True, abbreviation="-02")
    jump = int(datetime(2026, 11, 1, 3, tzinfo=UTC).timestamp())  # local 00:00 → 01:00
    zone = _zone("Test/Midnight", [(jump, 1)], [minus3, minus2])
    (day,) = [d for d in zone_oracle(zone, 2026, 2026, 0).days if d.day == "2026-11-01"]
    assert day.start_of_day_utc_ms == jump * 1000
    assert day.local_hour_utc_ms[0] == jump * 1000


def test_a_zone_without_changes_has_no_days_req_time_020() -> None:
    zone = _zone("Test/Fixed", [], [LocalType(10800, is_dst=False, abbreviation="+03")])
    oracle = zone_oracle(zone, 2026, 2028, 7)
    assert (oracle.transitions, oracle.days, oracle.offset_at_start_seconds) == ([], [], 10800)


def test_build_reads_each_zone_file_under_its_name_req_time_020(tmp_path: Path) -> None:
    (tmp_path / "Test").mkdir()
    (tmp_path / "Test" / "Berlin").write_bytes(tzif_v1([(_SPRING, 1), (_AUTUMN, 0)], [_CET, _CEST]))
    settings = OracleSettings(cities="c.json", from_year=2026, to_year=2026, window_days=1)
    oracle = build_oracle(tmp_path, ["Test/Berlin"], tzdb_version="2026e", settings=settings)
    assert oracle.tzdb_version == "2026e"
    assert [z.zone_id for z in oracle.zones] == ["Test/Berlin"]
    assert len(oracle.zones[0].days) == 6


def test_corpus_zones_are_the_distinct_zones_of_the_city_file(tmp_path: Path) -> None:
    cities = tmp_path / "cities.json"
    zones = ["Europe/Oslo", "Africa/Cairo", "Europe/Oslo"]
    cities.write_text(json.dumps({"cities": [{"zoneId": z} for z in zones]}), encoding="utf-8")
    assert corpus_zone_ids(cities) == ["Africa/Cairo", "Europe/Oslo"]


def test_a_city_without_a_zone_is_refused(tmp_path: Path) -> None:
    cities = tmp_path / "cities.json"
    cities.write_text(json.dumps({"cities": [{"name": "Cairo"}]}), encoding="utf-8")
    with pytest.raises(CorpusError):
        corpus_zone_ids(cities)
