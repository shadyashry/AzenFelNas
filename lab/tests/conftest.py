"""Shared fixtures: the real harness over the pinned ephemeris, fetched once into the lab cache."""

from collections.abc import Iterator
from pathlib import Path

import pytest

from dm_lab.config import HarnessConfig, load_config
from dm_lab.ephemeris import ensure_ephemeris, urllib_fetch
from dm_lab.paths import DEFAULT_CITIES, DEFAULT_CONFIG, cache_dir
from dm_lab.reference import CalculateReferenceDay
from dm_lab.schema.benchmark_cities_v1 import BenchmarkCitiesV1, City
from dm_lab.sky import SkyfieldSun
from dm_lab.tzdb import PinnedTzdb


@pytest.fixture(scope="session")
def config() -> HarnessConfig:
    """The committed harness configuration."""
    return load_config(DEFAULT_CONFIG)


@pytest.fixture(scope="session")
def ephemeris_path(config: HarnessConfig) -> Path:
    """The sha256-verified de440s.bsp in the lab cache (fetched on first use)."""
    return ensure_ephemeris(config.ephemeris, cache_dir(), urllib_fetch)


@pytest.fixture(scope="session")
def sun(config: HarnessConfig, ephemeris_path: Path) -> Iterator[SkyfieldSun]:
    """Skyfield over the pinned ephemeris."""
    adapter = SkyfieldSun(ephemeris_path, config)
    yield adapter
    adapter.close()


@pytest.fixture(scope="session")
def tzdb() -> PinnedTzdb:
    """Zones of the pinned tzdata release."""
    return PinnedTzdb()


@pytest.fixture(scope="session")
def city_file() -> BenchmarkCitiesV1:
    """The committed Appendix H city file."""
    return BenchmarkCitiesV1.model_validate_json(DEFAULT_CITIES.read_text(encoding="utf-8"))


@pytest.fixture(scope="session")
def cities(city_file: BenchmarkCitiesV1) -> dict[str, City]:
    """Appendix H cities by id."""
    return {city.city_id: city for city in city_file.cities}


@pytest.fixture(scope="session")
def calculate(
    sun: SkyfieldSun,
    tzdb: PinnedTzdb,
    config: HarnessConfig,
) -> CalculateReferenceDay:
    """The reference calculator as `lab reference` wires it."""
    return CalculateReferenceDay(sun, tzdb, config.horizon.altitude_deg, config.tolerance)
