"""ADR-019 as amended by §15 D26: altitude formula, near-tangent cut-off, fixed transit."""

import pytest
from hypothesis import assume, given
from hypothesis import strategies as st

from dm_lab.config import HarnessConfig
from dm_lab.tolerance import (
    altitude_tolerance_ms,
    is_near_tangent,
    near_tangent_window_ms,
    transit_tolerance_ms,
)

_RATES = st.floats(min_value=-1.0, max_value=1.0, allow_nan=False)


def test_transit_has_a_fixed_200_ms_tolerance_req_test_003(config: HarnessConfig) -> None:
    """REQ-TEST-003: Dhuhr has its own time tolerance, not an altitude-rate one (§15 D26)."""
    assert transit_tolerance_ms(config.tolerance) == 200


def test_equatorial_sunrise_rate_gives_240_ms_req_test_003(config: HarnessConfig) -> None:
    """REQ-TEST-003: an altitude rate of 15°/h (0.0041667°/s) yields 0.24 s."""
    assert altitude_tolerance_ms(15 / 3600, config.tolerance) == 240


def test_fast_rate_gives_the_200_ms_floor(config: HarnessConfig) -> None:
    """Rates above 0.005°/s hit the 0.2 s floor exactly, without float noise."""
    assert altitude_tolerance_ms(0.01, config.tolerance) == 200


def test_the_slowest_rate_the_formula_accepts_gives_exactly_the_cap(config: HarnessConfig) -> None:
    """At |dh/dt| = 0.001° / 60 s the formula still applies and gives 60 s."""
    boundary = config.tolerance.min_rate_deg_per_s

    assert not is_near_tangent(boundary, config.tolerance)
    assert altitude_tolerance_ms(boundary, config.tolerance) == 60_000


def test_refuses_the_formula_for_a_near_tangent_crossing(config: HarnessConfig) -> None:
    """Below the cut-off the crossing is near-tangent: no time tolerance is invented for it."""
    slower = config.tolerance.min_rate_deg_per_s / 2

    assert is_near_tangent(slower, config.tolerance)
    with pytest.raises(ValueError, match="near-tangent"):
        altitude_tolerance_ms(slower, config.tolerance)


def test_near_tangent_window_is_the_cap(config: HarnessConfig) -> None:
    """A near-tangent reference accepts an engine instant within the 60 s cap."""
    assert near_tangent_window_ms(config.tolerance) == 60_000


@given(rate=_RATES)
def test_formula_stays_within_floor_and_cap(config: HarnessConfig, rate: float) -> None:
    """Every rate the formula accepts yields a tolerance in [200 ms, 60 000 ms]."""
    assume(not is_near_tangent(rate, config.tolerance))

    assert 200 <= altitude_tolerance_ms(rate, config.tolerance) <= 60_000


@given(rate=_RATES)
def test_ignores_the_sign_of_the_rate(config: HarnessConfig, rate: float) -> None:
    """Rising and setting crossings of equal steepness are treated alike."""
    assert is_near_tangent(rate, config.tolerance) == is_near_tangent(-rate, config.tolerance)
    assume(not is_near_tangent(rate, config.tolerance))

    assert altitude_tolerance_ms(rate, config.tolerance) == altitude_tolerance_ms(
        -rate,
        config.tolerance,
    )


@given(slower=_RATES, faster=_RATES)
def test_never_grows_with_a_faster_rate(
    config: HarnessConfig, slower: float, faster: float
) -> None:
    """A faster-moving altitude never gets a looser tolerance."""
    if abs(faster) < abs(slower):
        slower, faster = faster, slower
    assume(not is_near_tangent(slower, config.tolerance))

    assert altitude_tolerance_ms(faster, config.tolerance) <= altitude_tolerance_ms(
        slower,
        config.tolerance,
    )
