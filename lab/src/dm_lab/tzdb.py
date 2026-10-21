"""IANA zones from the pinned `tzdata` package, never the operating system's database.

The lab derives civil dates (the prayer day of ADR-004, the Appendix H date set) from one recorded
TZDB version so that a reference run is reproducible on every machine.
"""

from importlib import resources
from zoneinfo import ZoneInfo

import tzdata


class PinnedTzdb:
    """Zone lookup over the `tzdata` wheel locked in `uv.lock`."""

    def __init__(self) -> None:
        """Create a lookup with an empty zone cache."""
        self._zones: dict[str, ZoneInfo] = {}

    @property
    def version(self) -> str:
        """IANA release of the data, e.g. `2026e`."""
        version: str = tzdata.IANA_VERSION
        return version

    def zone(self, zone_id: str) -> ZoneInfo:
        """Return the zone named `zone_id`.

        Raises:
            FileNotFoundError: the release has no such zone.

        """
        cached = self._zones.get(zone_id)
        if cached is not None:
            return cached
        resource = resources.files("tzdata.zoneinfo").joinpath(*zone_id.split("/"))
        with resource.open("rb") as stream:
            zone = ZoneInfo.from_file(stream, key=zone_id)
        self._zones[zone_id] = zone
        return zone
