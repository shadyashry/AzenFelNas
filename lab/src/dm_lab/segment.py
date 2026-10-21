"""Classification of the horizon crossings in one half of a culmination segment (ADR-004).

The ascending half [A₋, T₀] holds sunrise, the descending half [T₀, A₊] holds sunset. A half
yields a root only when it holds exactly one crossing in the event's direction; otherwise it
reports why not and never picks a candidate (DESIGN.md §0.2 rule 10).
"""

from collections.abc import Sequence
from dataclasses import dataclass
from typing import Literal

from dm_lab.sky import Crossing

type NoRootReason = Literal["POLAR_DAY", "POLAR_NIGHT"]


@dataclass(frozen=True, slots=True)
class Root:
    """Exactly one crossing in the event's direction."""

    utc_ms: int


@dataclass(frozen=True, slots=True)
class NoRoot:
    """No crossing: the Sun's centre stays above (polar day) or below (polar night) the horizon."""

    reason: NoRootReason


@dataclass(frozen=True, slots=True)
class Ambiguous:
    """Crossings exist but not exactly one in the event's direction."""

    candidates_utc_ms: tuple[int, ...]


type HalfOutcome = Root | NoRoot | Ambiguous


def classify_half(
    crossings: Sequence[Crossing],
    *,
    rising: bool,
    above_at_transit: bool,
) -> HalfOutcome:
    """Outcome of one half segment.

    Args:
        crossings: every crossing of the horizon altitude inside the half, in time order.
        rising: True for the ascending half (sunrise), False for the descending half (sunset).
        above_at_transit: whether the Sun's centre is above the horizon altitude at T₀; with no
            crossing it decides polar day versus polar night.

    """
    if not crossings:
        return NoRoot("POLAR_DAY" if above_at_transit else "POLAR_NIGHT")
    if len(crossings) == 1 and crossings[0].rising == rising:
        return Root(crossings[0].utc_ms)
    return Ambiguous(tuple(crossing.utc_ms for crossing in crossings))
