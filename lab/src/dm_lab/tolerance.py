"""ADR-019 time tolerance of a reference event."""

import math

from dm_lab.config import ToleranceConfig

_MS_PER_S = 1000
_MS_DECIMALS = 6


def tolerance_ms(rate_deg_per_s: float, config: ToleranceConfig) -> int:
    """`clamp(altitude_deg / |rate|, min_s, max_s)` in whole milliseconds, rounded up.

    `rate_deg_per_s` is the rate of the event's defining angle at the event: the altitude rate for
    sunrise/sunset, the local hour-angle rate for the transit (DESIGN.md §15 D26). A zero rate means
    the angle is stationary and yields the cap.
    """
    rate = abs(rate_deg_per_s)
    seconds = config.max_s if rate == 0 else config.altitude_deg / rate
    clamped = min(max(seconds, config.min_s), config.max_s)
    # Round away float noise (0.2 * 1000 must stay 200) before rounding up.
    return math.ceil(round(clamped * _MS_PER_S, _MS_DECIMALS))
