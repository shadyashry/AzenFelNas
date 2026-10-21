"""ADR-019 time tolerances as amended by DESIGN.md §15 D26.

Altitude-defined events (sunrise, sunset) use `clamp(0.001° / |dh/dt|, 0.2 s, 60 s)` only where the
crossing is not near-tangent; the transit (Dhuhr) has its own fixed time tolerance.
"""

import math

from dm_lab.config import ToleranceConfig

_MS_PER_S = 1000
_MS_DECIMALS = 6


def is_near_tangent(rate_deg_per_s: float, config: ToleranceConfig) -> bool:
    """Whether an altitude crossing is too slow for the formula (it would exceed the 60 s cap)."""
    return abs(rate_deg_per_s) < config.min_rate_deg_per_s


def altitude_tolerance_ms(rate_deg_per_s: float, config: ToleranceConfig) -> int:
    """`clamp(altitude_deg / |dh/dt|, min_s, max_s)` in whole milliseconds, rounded up.

    Raises:
        ValueError: the crossing is near-tangent; the formula does not apply to it.

    """
    if is_near_tangent(rate_deg_per_s, config):
        msg = f"near-tangent crossing (|dh/dt| = {abs(rate_deg_per_s)} °/s)"
        raise ValueError(msg)
    seconds = config.altitude_deg / abs(rate_deg_per_s)
    return _ceil_ms(min(max(seconds, config.min_s), config.max_s))


def transit_tolerance_ms(config: ToleranceConfig) -> int:
    """Return the transit's fixed time tolerance in whole milliseconds, rounded up."""
    return _ceil_ms(config.transit_s)


def near_tangent_window_ms(config: ToleranceConfig) -> int:
    """Window within which an engine instant counts as matching a near-tangent reference."""
    return _ceil_ms(config.max_s)


def _ceil_ms(seconds: float) -> int:
    # Round away float noise (0.2 * 1000 must stay 200) before rounding up.
    return math.ceil(round(seconds * _MS_PER_S, _MS_DECIMALS))
