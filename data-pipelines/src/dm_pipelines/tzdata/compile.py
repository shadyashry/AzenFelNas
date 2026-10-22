"""Compiles the staged IANA source into a zoneinfo directory (DESIGN.md §9.5, §15 D66).

This is `package:timezone`'s own recipe (`tool/refresh.sh`): the `rearguard` data form and
`zic -b fat`, so every transition up to 2037 is explicit. The `zic` is built from the same pinned
release, so the output does not depend on the host's zic.
"""

from pathlib import Path

from dm_pipelines.commands import CommandRunner

ZIC_FLAGS = ("-b", "fat")
DATA_FORM = "rearguard"


def compile_zoneinfo(runner: CommandRunner, build_dir: Path, version: str) -> Path:
    """Build `zic` and `rearguard.zi` in `build_dir`, compile them and return the zoneinfo dir."""
    runner.run(["make", "-s", f"VERSION={version}", f"{DATA_FORM}.zi", "zic"], build_dir)
    zoneinfo = build_dir / "zoneinfo"
    runner.run(["./zic", *ZIC_FLAGS, "-d", str(zoneinfo), f"{DATA_FORM}.zi"], build_dir)
    return zoneinfo


def encode_tzf(runner: CommandRunner, dart_package: Path, zoneinfo: Path, out: Path) -> None:
    """Encode `zoneinfo` into the `.tzf` database at `out` with dm_civil_time's encoder tool."""
    runner.run(["dart", "run", "tool/encode_tzf.dart", str(zoneinfo), str(out)], dart_package)
