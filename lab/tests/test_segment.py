"""Half-segment classification: one crossing in the event's direction, else a typed reason."""

from hypothesis import given
from hypothesis import strategies as st

from dm_lab.segment import Ambiguous, NoRoot, Root, classify_half
from dm_lab.sky import Crossing

_CROSSINGS = st.lists(
    st.builds(Crossing, utc_ms=st.integers(min_value=0, max_value=2**42), rising=st.booleans()),
    max_size=4,
)


def test_one_rising_crossing_is_the_sunrise_root() -> None:
    """Exactly one upward crossing in the ascending half is the root."""
    outcome = classify_half([Crossing(1000, rising=True)], rising=True, above_at_transit=True)

    assert outcome == Root(1000)


def test_no_crossing_above_at_transit_is_polar_day() -> None:
    """Above the horizon at T₀ and never crossing it: polar day."""
    assert classify_half([], rising=True, above_at_transit=True) == NoRoot("POLAR_DAY")


def test_no_crossing_below_at_transit_is_polar_night() -> None:
    """Below the horizon at T₀ and never crossing it: polar night."""
    assert classify_half([], rising=False, above_at_transit=False) == NoRoot("POLAR_NIGHT")


def test_crossing_in_the_wrong_direction_is_ambiguous() -> None:
    """A downward crossing in the ascending half is listed, never used."""
    outcome = classify_half([Crossing(1000, rising=False)], rising=True, above_at_transit=False)

    assert outcome == Ambiguous((1000,))


def test_two_crossings_are_ambiguous() -> None:
    """Two crossings in one half are listed in order, none is picked."""
    crossings = [Crossing(1000, rising=True), Crossing(2000, rising=False)]

    outcome = classify_half(crossings, rising=True, above_at_transit=True)

    assert outcome == Ambiguous((1000, 2000))


@given(crossings=_CROSSINGS, rising=st.booleans(), above=st.booleans())
def test_root_only_for_a_single_crossing_in_the_event_direction(
    crossings: list[Crossing],
    *,
    rising: bool,
    above: bool,
) -> None:
    """Unknown beats invented: a root exists exactly for one same-direction crossing."""
    outcome = classify_half(crossings, rising=rising, above_at_transit=above)

    single_match = len(crossings) == 1 and crossings[0].rising == rising
    assert isinstance(outcome, Root) == single_match
