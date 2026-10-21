"""The harness configuration carries only the cited ADR-003/ADR-019 constants."""

import math

from dm_lab.config import HarnessConfig


def test_horizon_altitude_is_the_adr003_default(config: HarnessConfig) -> None:
    """34′ refraction + 16′ semidiameter, dip 0: the Sun's centre at −0.8333°."""
    assert math.isclose(config.horizon.altitude_deg, -50 / 60, abs_tol=1e-12)


def test_time_scale_makes_ut1_equal_utc(config: HarnessConfig) -> None:
    """ADR-019: UT1 − UTC ignored, so ΔT = 32.184 s + 37 s."""
    assert config.time.ut1_minus_utc_s == 0
    assert math.isclose(config.time.delta_t_s, 69.184, abs_tol=1e-9)


def test_tolerance_is_the_amended_adr019_policy(config: HarnessConfig) -> None:
    """ADR-019 (§15 D26): 0.001° in [0.2 s, 60 s] for altitude events; 0.2 s for the transit."""
    tolerance = config.tolerance

    assert (tolerance.altitude_deg, tolerance.min_s, tolerance.max_s) == (0.001, 0.2, 60.0)
    assert tolerance.transit_s == 0.2
    assert math.isclose(tolerance.min_rate_deg_per_s, 0.001 / 60)


def test_hijri_calendar_is_the_adr016_tabular_one(config: HarnessConfig) -> None:
    """ADR-016: 30-year cycle, leap years {2,5,7,10,13,16,18,21,24,26,29}, epoch JDN 1948439."""
    assert (config.hijri.epoch_jdn, config.hijri.cycle_years) == (1_948_439, 30)
    assert config.hijri.leap_years == {2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29}


def test_benchmark_compares_only_astronomical_events(config: HarnessConfig) -> None:
    """Only Sunrise, Dhuhr (transit) and Maghrib (sunset), only for engine.default (§15 D29)."""
    assert config.benchmark.profiles == {"engine.default"}
    assert config.benchmark.event_map == {
        "SUNRISE": "SUNRISE",
        "DHUHR": "TRANSIT",
        "MAGHRIB": "SUNSET",
    }
