"""Checks and stages the IANA source tree against its pins (DESIGN.md §17.6, §15 D66)."""

import shutil
from pathlib import Path

from dm_pipelines.hashing import sha256_bytes, sha256_file


class SourceMismatchError(Exception):
    """The source tree does not hold the pinned bytes."""


def verify_source(source: Path, pins: dict[str, str]) -> None:
    """Raise `SourceMismatchError` naming every pinned file that is missing or differs."""
    problems: list[str] = []
    for name in sorted(pins):
        path = source / name
        if not path.is_file():
            problems.append(f"{name}: missing")
        elif (actual := sha256_file(path)) != pins[name]:
            problems.append(f"{name}: sha256 {actual}, pinned {pins[name]}")
    if problems:
        raise SourceMismatchError("; ".join(problems))


def stage_source(source: Path, pins: dict[str, str], version: str, dest: Path) -> None:
    """Copy exactly the pinned files of a verified `source` into `dest` and write `version`.

    The build then reads nothing that is not pinned, and the Makefile takes the release name from
    the `version` file instead of `git describe`.
    """
    verify_source(source, pins)
    dest.mkdir(parents=True, exist_ok=False)
    for name in sorted(pins):
        shutil.copyfile(source / name, dest / name)
    (dest / "version").write_text(f"{version}\n", encoding="ascii")


def pin_digest(pins: dict[str, str]) -> str:
    """Return one sha256 for the whole pin set: of the sorted `<sha256>  <name>` lines."""
    listing = "".join(f"{pins[name]}  {name}\n" for name in sorted(pins))
    return sha256_bytes(listing.encode("utf-8"))
