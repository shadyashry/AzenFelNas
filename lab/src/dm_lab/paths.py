"""Default locations of the lab's inputs and outputs inside the repository (DESIGN.md §5.3)."""

import os
from pathlib import Path

LAB_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = LAB_ROOT.parent

DEFAULT_CONFIG = LAB_ROOT / "config" / "harness.v1.toml"
DEFAULT_CITIES = LAB_ROOT / "benchmarks" / "cities.v1.json"
DEFAULT_REFERENCE = LAB_ROOT / "reference" / "sun_events.2026-2028.v1.jsonl"
DEFAULT_BENCHMARK_OUT = LAB_ROOT / "out" / "benchmark"
ENGINE_PACKAGE_DIR = REPO_ROOT / "packages" / "geo_salah_core"


def cache_dir() -> Path:
    """Return the download cache: `$DM_LAB_CACHE`, else `lab/.cache` (gitignored)."""
    override = os.environ.get("DM_LAB_CACHE")
    return Path(override) if override else LAB_ROOT / ".cache"


def repo_relative(path: Path) -> str:
    """`path` relative to the repository root, with forward slashes, for manifests.

    Raises:
        ValueError: `path` is outside the repository.

    """
    return path.resolve().relative_to(REPO_ROOT).as_posix()
