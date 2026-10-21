"""ADR-019 time tolerance: clamp(0.001° / |dh/dt|, 0.2 s, 60 s)."""

from hypothesis import given
from hypothesis import strategies as st

from dm_lab.config import HarnessConfig
from dm_lab.tolerance import tolerance_ms

_RATES = st.floats(min_value=-1.0, max_value=1.0, allow_nan=False)


def test_equatorial_sunrise_rate_gives_240_ms_req_test_003(config: HarnessConfig) -> None:
    """15°/h (0.0041667°/s) yields 0.24 s (REQ-TEST-003 tolerance)."""
    assert tolerance_ms(15 / 3600, config.tolerance) == 240


def test_stationary_angle_gives_the_60_s_cap(config: HarnessConfig) -> None:
    """A zero rate means the angle is stationary: the cap applies."""
    assert tolerance_ms(0.0, config.tolerance) == 60_000


def test_fast_rate_gives_the_200_ms_floor(config: HarnessConfig) -> None:
    """Rates above 0.005°/s hit the 0.2 s floor exactly, without float noise."""
    assert tolerance_ms(0.01, config.tolerance) == 200


@given(rate=_RATES)
def test_stays_within_floor_and_cap(config: HarnessConfig, rate: float) -> None:
    """Every rate yields a tolerance in [200 ms, 60 000 ms]."""
    assert 200 <= tolerance_ms(rate, config.tolerance) <= 60_000


@given(rate=_RATES)
def test_ignores_the_sign_of_the_rate(config: HarnessConfig, rate: float) -> None:
    """Rising and setting rates of equal size give equal tolerances."""
    assert tolerance_ms(rate, config.tolerance) == tolerance_ms(-rate, config.tolerance)


@given(slower=_RATES, faster=_RATES)
def test_never_grows_with_a_faster_rate(
    config: HarnessConfig, slower: float, faster: float
) -> None:
    """A faster-moving angle never gets a looser tolerance."""
    if abs(faster) < abs(slower):
        slower, faster = faster, slower
    assert tolerance_ms(faster, config.tolerance) <= tolerance_ms(slower, config.tolerance)
