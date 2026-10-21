"""Harness configuration: the cited constants of `lab/config/harness.v1.toml` (DESIGN.md §9.4).

The file is the lab's own configuration, not a wire contract, so its model is hand-written
(DESIGN.md §15 D27). Every value in it is an astronomy or time-scale constant; none is religious.
"""

import tomllib
from pathlib import Path
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

type EngineEvent = Literal["IMSAK", "FAJR", "SUNRISE", "DHUHR", "ASR", "MAGHRIB", "ISHA"]
"""PrayerEvent of DESIGN.md §6.2 as spelled in calculation_trace.v1."""

type ReferenceEvent = Literal["SUNRISE", "TRANSIT", "SUNSET"]
"""Astronomical event of lab_reference.v1."""

_MINUTES_PER_DEGREE = 60.0


class _Section(BaseModel):
    model_config = ConfigDict(frozen=True, extra="forbid")


class EphemerisConfig(_Section):
    """Where the JPL ephemeris comes from and the bytes it must have."""

    file_name: str = Field(pattern=r"^[A-Za-z0-9_.-]+$")
    url: str = Field(pattern=r"^https://")
    sha256: str = Field(pattern=r"^[a-f0-9]{64}$")
    size_bytes: int = Field(gt=0)


class HorizonConfig(_Section):
    """ADR-003 sunrise/sunset constants."""

    refraction_arcmin: float = Field(ge=0)
    semidiameter_arcmin: float = Field(ge=0)
    dip_deg: float = Field(ge=0)

    @property
    def altitude_deg(self) -> float:
        """Geometric altitude of the Sun's centre at sunrise/sunset: −(R + S)/60 − dip."""
        arcmin = self.refraction_arcmin + self.semidiameter_arcmin
        return -arcmin / _MINUTES_PER_DEGREE - self.dip_deg


class TimeConfig(_Section):
    """ADR-019 time-scale constants (seconds)."""

    ut1_minus_utc_s: float
    tt_minus_tai_s: float
    tai_minus_utc_s: float

    @property
    def delta_t_s(self) -> float:
        """ΔT = TT − UT1 implied by the constants."""
        return self.tt_minus_tai_s + self.tai_minus_utc_s - self.ut1_minus_utc_s


class ObserverConfig(_Section):
    """ADR-003 observer height above the WGS84 ellipsoid."""

    elevation_m: float


class ToleranceConfig(_Section):
    """ADR-019 time tolerances (§15 D26): altitude events by formula, the transit by fixed time."""

    altitude_deg: float = Field(gt=0)
    min_s: float = Field(gt=0)
    max_s: float = Field(gt=0)
    transit_s: float = Field(gt=0)

    @property
    def min_rate_deg_per_s(self) -> float:
        """Slowest altitude rate the formula applies to; slower crossings are near-tangent."""
        return self.altitude_deg / self.max_s


class SearchConfig(_Section):
    """Root search sampling (ADR-004 half segments)."""

    step_minutes: float = Field(gt=0, le=60)
    rate_half_width_s: float = Field(gt=0, le=60)


class HijriConfig(_Section):
    """ADR-016 tabular calendar: cycle length, leap years within it, epoch of 1 Muharram 1 AH."""

    epoch_jdn: int = Field(gt=0)
    cycle_years: int = Field(gt=0)
    leap_years: frozenset[int] = Field(min_length=1)


class BenchmarkConfig(_Section):
    """Which reference event each compared engine event realises, and for which profiles."""

    event_map: dict[EngineEvent, ReferenceEvent] = Field(min_length=1)
    profiles: frozenset[str] = Field(min_length=1)


class HarnessConfig(_Section):
    """The whole of `harness.v1.toml`."""

    schema_version: Literal[1]
    ephemeris: EphemerisConfig
    horizon: HorizonConfig
    time: TimeConfig
    observer: ObserverConfig
    tolerance: ToleranceConfig
    search: SearchConfig
    hijri: HijriConfig
    benchmark: BenchmarkConfig


def load_config(path: Path) -> HarnessConfig:
    """Parse and validate the harness TOML at `path`.

    Raises:
        OSError: `path` cannot be read.
        tomllib.TOMLDecodeError: the file is not TOML.
        pydantic.ValidationError: a value is missing or out of range.

    """
    with path.open("rb") as stream:
        return HarnessConfig.model_validate(tomllib.load(stream))
