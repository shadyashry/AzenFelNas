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


def test_tolerance_is_the_adr019_formula(config: HarnessConfig) -> None:
    """ADR-019: 0.001°, clamped to [0.2 s, 60 s]."""
    assert (config.tolerance.altitude_deg, config.tolerance.min_s, config.tolerance.max_s) == (
        0.001,
        0.2,
        60.0,
    )


def test_benchmark_compares_only_astronomical_events(config: HarnessConfig) -> None:
    """Only Sunrise, Dhuhr (transit) and Maghrib (sunset) are compared (§15 D29)."""
    assert config.benchmark.event_map == {
        "SUNRISE": "SUNRISE",
        "DHUHR": "TRANSIT",
        "MAGHRIB": "SUNSET",
    }
